USE [DataWarehouse]
GO
/****** Объект:  View [gold].[v_rep_sip]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_rep_sip] AS

WITH MainData AS
(
SELECT 
       S.[DATE]
      ,L.Company
      ,L.Location
      ,L.StoreName
      ,MAX(M.NAME) AS [ASSISTANT]
      ,CASE WHEN I.OPCODE = '50' THEN I.[SUMN] ELSE -I.[SUMN] END AS [SALES]
      ,C.COEFFICIENT
      ,C.[PERCENT]
  FROM [DataWarehouse].[silver].[ac_dopdata_salersip] S
  LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(S.NUMBER, 3)
  LEFT JOIN bronze.pos_mol_users M ON M.LOGIN = S.VALUE AND M.FLAG = CASE 
                                                                        WHEN S.SERVER = 'DC1-SRV-KC01' THEN 'RUDF'
                                                                        WHEN S.SERVER = 'DC1-SRV-KC03' THEN 'KZDF' 
                                                                        ELSE 'RUDP'
                                                                      END
  LEFT JOIN silver.act_items I ON I.POSITION = S.POSITION AND I.UNIQ = S.UNIQ
  LEFT JOIN bronze.ref_sipcoefficient C ON C.STORE_NAME = L.StoreName
  GROUP BY
      S.[DATE]
      ,L.Company
      ,L.Location
      ,L.StoreName
      ,I.OPCODE
      ,I.[SUMN]
      ,C.COEFFICIENT
      ,C.[PERCENT]
)
SELECT
    [DATE],
    [COMPANY],
    [LOCATION],
    [STORENAME] AS [STORE],
    [ASSISTANT],
    SUM([SALES]) AS [SALES],
    (SUM([SALES]) * [PERCENT]) AS [SIP],
    [COEFFICIENT]
FROM
    MainData M
GROUP BY
    [DATE],
    [COMPANY],
    [LOCATION],
    [STORENAME],
    [ASSISTANT],
    [COEFFICIENT],
    [PERCENT]
GO
/****** Объект:  View [gold].[v_dash_sip]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [gold].[v_dash_sip] AS
SELECT 
	CONCAT(DATENAME(M, DATE),' ',YEAR(DATE)) AS [PERIOD],
	[COMPANY],
	CAST(AVG([SIP]) as decimal(10,2)) AS [AVG SIP]
FROM 
	[DataWarehouse].[gold].[v_rep_sip]
GROUP BY
	CONCAT(DATENAME(M, DATE),' ',YEAR(DATE)),
	[COMPANY]

GO
/****** Объект:  View [gold].[v_dash_promos]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_dash_promos] AS

WITH PromoData AS
(
    -- Агрегируем промо-номера один раз на UNIQ + POSITION
    SELECT
        UNIQ,
        [POSITION],
        MAX(CASE WHEN DATA = 'PROMODISC' THEN VALUE END) AS PromoDiscNumber
    FROM silver.ac_dopdata_promonumber
    GROUP BY UNIQ, [POSITION]
),

AvoltaAgg AS
(
    -- Агрегируем AvoltaClub один раз на уровень чека
    SELECT
        UNIQ,
        CASHCODE,
        CHECKNUM,
        MAX(CASE WHEN DATA = 'NDISC' THEN VALUE END) AS AVOLTA_LEVEL,
        MAX(CASE WHEN DATA = 'LCUSID' THEN VALUE END) AS AVOLTA_ID
    FROM silver.ac_dopdata_avoltaclub
    GROUP BY UNIQ, CASHCODE, CHECKNUM
),

CouponAgg AS
(
    -- Агрегируем купоны один раз на уровень чека
    SELECT
        UNIQ,
        POS_NUMBER,
        RECEIPT_NUMBER,
        MAX(CASE 
            WHEN VALUE = '741123369986' THEN N'Сотрудники и Экипаж 20%'
            WHEN VALUE = '741123369987' THEN N'Руководители подразделений 25%'
            WHEN VALUE = '741123369988' THEN N'Руководители структур 30%'
            WHEN VALUE = '741123369989' THEN N'Акционеры и партнёры 50%'
            WHEN VALUE = '0242' THEN N'VIP 15% VKO DP'
            WHEN VALUE = '10999' THEN N'VIP АэроРегион 15%'
            WHEN VALUE = '741123369990' THEN N'Предзаказ 10%'
            WHEN VALUE = '0241' THEN N'Регстаэр ВИП 15% VKO Pilot Shop'
            WHEN VALUE = '6051' THEN N'Регстаэр ВИП 20%'
            WHEN VALUE = '0217' THEN N'Регстаэр ВИП 25% VKO Pilot Shop'
            WHEN VALUE = '6054' THEN N'Регстаэр ВИП 30%'
            WHEN VALUE IN ('150200','150300','150333','150400','150222') THEN N'Регстаэр ВИП 50% VKO T3'
        END) AS DISCOUNT_CARDS,
        MAX(CASE WHEN VALUE LIKE '999%' THEN VALUE END) AS VIP_VOUCHER,
        MAX(CASE WHEN VALUE LIKE 'FANDS%' THEN N'FUN AND SUN' END) AS PARTNER_VOUCHER
    FROM silver.ac_dopdata_coupons
    GROUP BY UNIQ, POS_NUMBER, RECEIPT_NUMBER
),
ExchangeRates AS
(
	SELECT
	DATE,
	MAX(CASE WHEN VALCODE = 3 THEN NRATE END) AS NRATE_EUR,
	MAX(CASE WHEN VALCODE = 5 THEN NRATE END) AS NRATE_RUB,
	SERVER
	FROM
		silver.acm_payments
	GROUP BY
		DATE, SERVER
),

BaseData AS
(
    SELECT
        ACT.SERVER,
        ACT.UNIQ,
        ACT.CASHCODE,
        ACT.SName,
        ACT.CHECKNUM,
        ACT.SHIFT,
        ACT.DATE,
        LEFT(ACT.TIME, 8) AS [TIME],
        ACT.NAME,
        ACT.CODE,
        ACT.BQUANT,
        ACT.PRICE,
        ACT.SUMI,
        ACT.DISC_ABS,
        ACT.DISC_PERC,
        ACT.SUMB,
        ACT.[POSITION],
        PN.Description,
        AA.AVOLTA_LEVEL,
        AA.AVOLTA_ID,
        CA.DISCOUNT_CARDS,
        CA.VIP_VOUCHER,
        CA.PARTNER_VOUCHER
    FROM silver.act_items ACT
    LEFT JOIN PromoData PD 
        ON PD.UNIQ = ACT.UNIQ AND PD.[POSITION] = ACT.[POSITION]
    LEFT JOIN silver.ref_promoid PN 
        ON PN.PROMOID = PD.PromoDiscNumber 
        AND PN.FLAG = CASE 
                        WHEN ACT.CASHCODE LIKE '1%' THEN 'RUDP'
                        WHEN ACT.CASHCODE LIKE '28%' THEN 'KZDF' 
                        ELSE 'RUDF'
                      END
    LEFT JOIN AvoltaAgg AA 
        ON AA.UNIQ = ACT.UNIQ 
        AND AA.CASHCODE = ACT.CASHCODE 
        AND AA.CHECKNUM = ACT.CHECKNUM
    LEFT JOIN CouponAgg CA 
        ON CA.UNIQ = ACT.UNIQ 
        AND CA.POS_NUMBER = ACT.CASHCODE 
        AND CA.RECEIPT_NUMBER = ACT.CHECKNUM
    WHERE (ACT.DISC_ABS > 0 OR ACT.DISC_PERC > 0) 
        AND ACT.NAME NOT LIKE '%Товар упакован в cейф-пакет%' AND ACT.OPCODE = 50 AND PN.Description <> 'Скидка на сейф-пакет'
),
Final AS
(
    SELECT
        YEAR(BD.[DATE]) as [YEAR],
        DATENAME(Q, BD.[DATE]) as [QUARTER],
        DATENAME(M, BD.[DATE]) as [MONTH],
        DATEPART(iso_week, BD.[DATE]) as [WEEK],
        L.Company AS [COMPANY],
        L.Duty AS [DUTY],
        L.Location AS [LOCATION],
        L.StoreName AS [STORE],
        BD.[DATE] AS [DATE],
        
        -- Конвертация через CROSS APPLY для упрощения
        CAST(SUM(BD.PRICE * CONV.PriceFactor) AS decimal(10,2)) AS [SUM Price RUB],
        CAST(SUM(BD.DISC_ABS * CONV.PriceFactor) AS decimal(10,2)) AS [SUM Discount RUB],
        CAST(SUM(BD.SUMB * CONV.PriceFactor) AS decimal(10,2)) AS [SUM Final Price RUB],
        
        COUNT(CASE WHEN BD.DISCOUNT_CARDS IS NOT NULL THEN 1 END) AS [QTY Discount Cards],
        CAST(ISNULL(SUM(CASE WHEN BD.DISCOUNT_CARDS IS NOT NULL THEN BD.DISC_ABS * CONV.PriceFactor END), 0) AS decimal(10,2)) AS [SUM Discount Cards RUB],
        
        COUNT(CASE WHEN BD.AVOLTA_LEVEL IS NOT NULL THEN 1 END) AS [QTY Avolta],
        CAST(ISNULL(SUM(CASE WHEN BD.AVOLTA_LEVEL IS NOT NULL THEN BD.DISC_ABS * CONV.PriceFactor END), 0) AS decimal(10,2)) AS [SUM Avolta RUB],
        
        COUNT(CASE WHEN BD.VIP_VOUCHER IS NOT NULL THEN 1 END) AS [QTY VIP Vouchers],
        CAST(ISNULL(SUM(CASE WHEN BD.VIP_VOUCHER IS NOT NULL THEN BD.DISC_ABS * CONV.PriceFactor END), 0) AS decimal(10,2)) AS [SUM VIP Voucher RUB],
        
        COUNT(CASE WHEN BD.PARTNER_VOUCHER IS NOT NULL THEN 1 END) AS [QTY Partner Voucher],
        CAST(ISNULL(SUM(CASE WHEN BD.PARTNER_VOUCHER IS NOT NULL THEN BD.DISC_ABS * CONV.PriceFactor END), 0) AS decimal(10,2)) AS [SUM Partner Voucher RUB]
    FROM BaseData BD
    LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(BD.CASHCODE, 3)
    LEFT JOIN ExchangeRates ER ON ER.[DATE] = BD.[DATE] AND ER.SERVER = BD.SERVER
    CROSS APPLY (
        -- Вычисляем коэффициент конвертации один раз
        SELECT CASE 
                 WHEN BD.SERVER = 'DC1-SRV-KC01' THEN COALESCE(ER.NRATE_EUR, 1)
                 WHEN BD.SERVER = 'DC1-SRV-KC03' THEN COALESCE(ER.NRATE_EUR, 1) / NULLIF(COALESCE(ER.NRATE_RUB, 1), 0)
                 ELSE 1
               END AS PriceFactor
    ) CONV
    GROUP BY
        L.Company,
        L.Duty,
        L.Location,
        L.StoreName,
        BD.[DATE],
        BD.SERVER
)
SELECT
    *, ([SUM Discount RUB] - [SUM Discount Cards RUB] - [SUM Avolta RUB] - [SUM VIP Voucher RUB] - [SUM Partner Voucher RUB]) AS [SUM PROMO RUB]
FROM
    Final
GO
/****** Объект:  View [gold].[v_dash_ptw_currency_companies_ru]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [gold].[v_dash_ptw_currency_companies_ru] AS 

WITH InitialCalculation AS
(
SELECT
       P.[VC_TYPE]
      ,L.Company
      ,SUM(P.[SUMN]) AS [VAL_SUM]
      ,COUNT(P.[SUMN]) AS [VAL_COUNT]
FROM 
    [DataWarehouse].[silver].[acm_payments] P
LEFT JOIN bronze.ref_locations L  ON L.STORECODE = LEFT(P.CASHCODE, 3)
WHERE P.CASHCODE NOT LIKE '28%'
GROUP BY
    P.[VC_TYPE],L.Company
)
SELECT
    Company AS [Компания],
    VC_TYPE AS [Валюта],
    VAL_SUM AS [Сумма по типу валюты],
    VAL_COUNT AS [Кол-во по типу валюты],
    ROUND((CAST(VAL_SUM as FLOAT) / SUM(VAL_SUM) OVER()) * 100, 2) AS [Доля сумм по типам валюты %],
    ROUND((CAST(VAL_COUNT as FLOAT) / SUM(VAL_COUNT) OVER()) * 100, 2) AS [Доля использования типов валют %]
FROM
    InitialCalculation
GO
/****** Объект:  View [gold].[v_dash_ptw_currency_monthdynamic_kz]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [gold].[v_dash_ptw_currency_monthdynamic_kz] AS

WITH InitialCalculation AS
(
SELECT
       [VC_TYPE]
      ,DATETRUNC(MONTH, DATE) AS [DATE]
      ,SUM([SUMN]) AS [VAL_SUM]
      ,COUNT([SUMN]) AS [VAL_COUNT]
FROM 
    [DataWarehouse].[silver].[acm_payments]
WHERE CASHCODE LIKE '28%'
GROUP BY
    [VC_TYPE], DATETRUNC(MONTH, DATE)
)
SELECT
    [DATE] AS [Месяц],
    VC_TYPE AS [Валюта],
    VAL_SUM AS [Сумма по типу валюты],
    VAL_COUNT AS [Кол-во по типу валюты],
    ROUND((CAST(VAL_SUM as FLOAT) / SUM(VAL_SUM) OVER()) * 100, 2) AS [Доля сумм по типам валюты %],
    ROUND((CAST(VAL_COUNT as FLOAT) / SUM(VAL_COUNT) OVER()) * 100, 2) AS [Доля использования типов валют %]
FROM
    InitialCalculation

GO
/****** Объект:  View [gold].[v_dash_ptw_currency_monthdynamic_ru]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [gold].[v_dash_ptw_currency_monthdynamic_ru] AS 

WITH InitialCalculation AS
(
SELECT
       [VC_TYPE]
      ,DATETRUNC(MONTH, DATE) AS [DATE]
      ,SUM([SUMN]) AS [VAL_SUM]
      ,COUNT([SUMN]) AS [VAL_COUNT]
FROM 
    [DataWarehouse].[silver].[acm_payments]
WHERE CASHCODE NOT LIKE '28%'
GROUP BY
    [VC_TYPE], DATETRUNC(MONTH, DATE)
)
SELECT
    [DATE] AS [Месяц],
    VC_TYPE AS [Валюта],
    VAL_SUM AS [Сумма по типу валюты],
    VAL_COUNT AS [Кол-во по типу валюты],
    ROUND((CAST(VAL_SUM as FLOAT) / SUM(VAL_SUM) OVER()) * 100, 2) AS [Доля сумм по типам валюты %],
    ROUND((CAST(VAL_COUNT as FLOAT) / SUM(VAL_COUNT) OVER()) * 100, 2) AS [Доля использования типов валют %]
FROM
    InitialCalculation
GO
/****** Объект:  View [gold].[v_dash_ptw_currencyusage_kz]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [gold].[v_dash_ptw_currencyusage_kz] AS

WITH InitialCalculation AS
(
SELECT
       [VC_TYPE]
      ,SUM([SUMN]) AS [VAL_SUM]
      ,COUNT([SUMN]) AS [VAL_COUNT]
FROM 
    [DataWarehouse].[silver].[acm_payments]
WHERE CASHCODE LIKE '28%'
GROUP BY
    [VC_TYPE]
)
SELECT
    VC_TYPE AS [Тип валюты],
    VAL_SUM AS [Сумма по типу валюты],
    VAL_COUNT AS [Кол-во по типу валюты],
    SUM(VAL_SUM) OVER() AS [Общий итог, Тенге],
    SUM(VAL_COUNT) OVER() AS [Общий итог, Количество],
    ROUND((CAST(VAL_SUM as FLOAT) / SUM(VAL_SUM) OVER()) * 100, 2) AS [Доля сумм по типам валюты %],
    ROUND((CAST(VAL_COUNT as FLOAT) / SUM(VAL_COUNT) OVER()) * 100, 2) AS [Доля использования типов валют %]
FROM
    InitialCalculation
GO
/****** Объект:  View [gold].[v_dash_ptw_currencyusage_ru]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [gold].[v_dash_ptw_currencyusage_ru] AS 

WITH InitialCalculation AS
(
SELECT
       [VC_TYPE]
      ,SUM([SUMN]) AS [VAL_SUM]
      ,COUNT([SUMN]) AS [VAL_COUNT]
FROM 
    [DataWarehouse].[silver].[acm_payments]
WHERE CASHCODE NOT LIKE '28%'
GROUP BY
    [VC_TYPE]
)
SELECT
    VC_TYPE AS [Тип валюты],
    VAL_SUM AS [Сумма по типу валюты, РУБ],
    VAL_COUNT AS [Кол-во использований по типу валюты],
    SUM(VAL_SUM) OVER() AS [Общий итог, РУБ],
    SUM(VAL_COUNT) OVER() AS [Общий итог, Количество],
    ROUND((CAST(VAL_SUM as FLOAT) / SUM(VAL_SUM) OVER()) * 100, 2) AS [Доля сумм по типам валюты %],
    ROUND((CAST(VAL_COUNT as FLOAT) / SUM(VAL_COUNT) OVER()) * 100, 2) AS [Доля использования типов валют %]
FROM
    InitialCalculation
GO
/****** Объект:  View [gold].[v_dash_yandex]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [gold].[v_dash_yandex] AS

WITH main AS
(
SELECT 
    YEAR(M.DATE) as [YEAR],
    DATENAME(Q, M.DATE) as [QUARTER],
    DATENAME(M, M.DATE) as [MONTH],
    DATEPART(iso_week, M.DATE) as [WEEK],
    DAY(M.DATE) as [DAY],
    M.*, 
    ISNULL(Y.VALUE, N'СБП') AS [VALUE] 
FROM 
    silver.acm_payments M
LEFT JOIN silver.ac_dopdata_yandex Y on Y.UNIQ = M.UNIQ
WHERE 
    CHR = 'YP'
),
Final AS
(
SELECT 
    L.[Location],
    [YEAR],
    [QUARTER],
    [MONTH],
    [WEEK],
    [DAY],
    ISNULL(SUM(CASE WHEN OPCODE = 70 THEN SUMN END), 0) AS [SALES],
    ISNULL(SUM(CASE WHEN OPCODE = 74 THEN SUMN END), 0) AS [REFUNDS],
    ISNULL(SUM(CASE WHEN OPCODE = 70 THEN 1 END), 0) AS [QTY_SALES],
    ISNULL(SUM(CASE WHEN OPCODE = 74 THEN 1 END), 0) AS [QTY_REFUNDS],
    ISNULL(SUM(CASE WHEN OPCODE = 70 AND VALUE = N'ЯНДЕКС СПЛИТ'THEN SUMN END), 0) AS [SALES SPLIT],
    ISNULL(SUM(CASE WHEN OPCODE = 74 AND VALUE = N'ЯНДЕКС СПЛИТ' THEN SUMN END), 0) AS [REFUNDS SPLIT],
    ISNULL(SUM(CASE WHEN OPCODE = 70 AND VALUE = N'ЯНДЕКС СПЛИТ' THEN 1 END), 0) AS [QTY SALES SPLIT],
    ISNULL(SUM(CASE WHEN OPCODE = 74 AND VALUE = N'ЯНДЕКС СПЛИТ' THEN 1 END), 0) AS [QTY REFUNDS SPLIT],
    ISNULL(SUM(CASE 
                    WHEN OPCODE = 70 THEN SUMN
                    WHEN OPCODE = 74 THEN -SUMN 
                    ELSE 0
               END), 0) AS [REVENUE],
    ISNULL(SUM(CASE 
                    WHEN OPCODE = 70 THEN 1 
                    WHEN OPCODE = 74 THEN -1 
                    ELSE 0 
               END), 0) AS [QTY_REVENUE],
    ISNULL(SUM(CASE 
                    WHEN OPCODE = 70 AND VALUE = N'ЯНДЕКС СПЛИТ' THEN SUMN
                    WHEN OPCODE = 74 AND VALUE = N'ЯНДЕКС СПЛИТ'  THEN -SUMN 
                    ELSE 0 
               END), 0) AS [REVENUE_SPLIT],
    ISNULL(SUM(CASE 
                    WHEN OPCODE = 70 AND VALUE = N'ЯНДЕКС СПЛИТ' THEN 1 
                    WHEN OPCODE = 74 AND VALUE = N'ЯНДЕКС СПЛИТ' THEN -1 
                    ELSE 0 
               END), 0) AS [QTY_REVENUE_SPLIT],

    ISNULL(CAST(SUM(CASE WHEN VALUE = N'ЯНДЕКС СПЛИТ' AND OPCODE = 70 THEN SUMN * 0.043 END) AS decimal(10,2)), 0) AS [SPLIT COMMISSION],
    ISNULL(CAST(SUM(CASE WHEN VALUE = N'СБП' AND OPCODE = 70 THEN SUMN * 0.004 END) AS decimal(10,2)), 0) AS [FSP COMMISSION]
FROM 
    main M
LEFT JOIN bronze.ref_locations L on L.StoreCode = LEFT(M.CASHCODE, 3)
GROUP BY
    L.[Location], [YEAR],[QUARTER],[MONTH],[WEEK],[DAY]
)
SELECT
    [Location],
    [YEAR],
    [QUARTER],
    [MONTH],
    [WEEK],
    [DAY],
    SALES,
    REFUNDS,
    [QTY_SALES],
    [QTY_REFUNDS],
    [SALES SPLIT],
    [REFUNDS SPLIT],
    [QTY SALES SPLIT],
    [QTY REFUNDS SPLIT],
    [REVENUE],
    [QTY_REVENUE],
    [REVENUE_SPLIT],
    [QTY_REVENUE_SPLIT],
    CASE 
        WHEN [REVENUE] > 0 THEN ISNULL(CAST([REVENUE]/NULLIF([QTY_REVENUE], 0) as decimal(10,2)), 0)
        ELSE 0
        END AS [AVERAGE SUM FSP],
    CASE 
        WHEN [REVENUE_SPLIT] > 0 THEN ISNULL(CAST([REVENUE_SPLIT]/NULLIF([QTY_REVENUE_SPLIT], 0) as decimal(10,2)), 0) 
        ELSE 0
        END AS [AVERAGE SUM SPLIT],
    [SPLIT COMMISSION],
    [FSP COMMISSION]
FROM
    Final

GO
/****** Объект:  View [gold].[v_graphs_cot_sales_and_refunds_months]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_graphs_cot_sales_and_refunds_months] AS
SELECT 
       L.Company AS [КОМПАНИЯ]
      ,L.Duty  AS [ТИП]
      ,R.[TR_TYPE] AS [ТИП ТРАНЗАКЦИИ]
      ,DATETRUNC(MONTH, R.[DATE_BEG]) AS [ПЕРИОД: МЕСЯЦ]
      ,SUM(R.[SUMN]) AS [СУММА В НАЦ. ВАЛЮТЕ]
      ,COUNT(R.[TR_TYPE]) AS [ВСЕГО ЧЕКОВ]
  FROM [DataWarehouse].[silver].[acc_receipts] R
  LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(R.CASHCODE, 3)
  GROUP BY
    L.Company
    ,L.Duty 
    ,R.[TR_TYPE]
    ,DATETRUNC(MONTH, R.[DATE_BEG])
GO
/****** Объект:  View [gold].[v_graphs_cot_sales_and_refunds_pos_months]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [gold].[v_graphs_cot_sales_and_refunds_pos_months] AS
SELECT 
       L.Company AS [КОМПАНИЯ]
      ,L.Duty  AS [ТИП]
      ,L.StoreName  AS [МАГАЗИН]
      ,R.[CASHCODE] AS [КАССА]
      ,R.[TR_TYPE] AS [ТИП ТРАНЗАКЦИИ]
      ,DATETRUNC(MONTH, R.[DATE_BEG]) AS [ПЕРИОД: МЕСЯЦ]
      ,SUM(R.[SUMN]) AS [СУММА В НАЦ. ВАЛЮТЕ]
      ,COUNT(R.[TR_TYPE]) AS [ВСЕГО ЧЕКОВ]
  FROM [DataWarehouse].[silver].[acc_receipts] R
  LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(R.CASHCODE, 3)
  GROUP BY
    L.Company
    ,L.Duty 
    ,L.StoreName
    ,R.[CASHCODE]
    ,R.[TR_TYPE]
    ,DATETRUNC(MONTH, R.[DATE_BEG])
GO
/****** Объект:  View [gold].[v_graphs_cot_sales_and_refunds_pos_weeks]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [gold].[v_graphs_cot_sales_and_refunds_pos_weeks] AS
SELECT 
       L.Company AS [КОМПАНИЯ]
      ,L.Duty  AS [ТИП]
      ,L.StoreName  AS [МАГАЗИН]
      ,R.[CASHCODE] AS [КАССА]
      ,R.[TR_TYPE] AS [ТИП ТРАНЗАКЦИИ]
      ,DATEPART(ISO_WEEK, R.[DATE_BEG]) AS [НОМЕР НЕДЕЛИ]
      ,DATETRUNC(WEEK, R.[DATE_BEG]) AS [ПЕРИОД: НЕДЕЛЯ]
      ,SUM(R.[SUMN]) AS [СУММА В НАЦ. ВАЛЮТЕ]
      ,COUNT(R.[TR_TYPE]) AS [ВСЕГО ЧЕКОВ]
  FROM [DataWarehouse].[silver].[acc_receipts] R
  LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(R.CASHCODE, 3)
  GROUP BY
    L.Company
    ,L.Duty
    ,L.StoreName
    ,R.[CASHCODE]
    ,R.[TR_TYPE]
    ,DATEPART(ISO_WEEK, R.[DATE_BEG])
    ,DATETRUNC(WEEK, R.[DATE_BEG])
GO
/****** Объект:  View [gold].[v_graphs_cot_sales_and_refunds_pos_years]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [gold].[v_graphs_cot_sales_and_refunds_pos_years] AS
SELECT 
       L.Company AS [КОМПАНИЯ]
      ,L.Duty  AS [ТИП]
      ,L.StoreName  AS [МАГАЗИН]
      ,R.[CASHCODE] AS [КАССА]
      ,R.[TR_TYPE] AS [ТИП ТРАНЗАКЦИИ]
      ,DATETRUNC(YEAR, R.[DATE_BEG]) AS [ПЕРИОД: ГОД]
      ,SUM(R.[SUMN]) AS [СУММА В НАЦ. ВАЛЮТЕ]
      ,COUNT(R.[TR_TYPE]) AS [ВСЕГО ЧЕКОВ]
  FROM [DataWarehouse].[silver].[acc_receipts] R
  LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(R.CASHCODE, 3)
  GROUP BY
    L.Company
    ,L.Duty 
    ,L.StoreName
    ,R.[CASHCODE]
    ,R.[TR_TYPE]
    ,DATETRUNC(YEAR, R.[DATE_BEG])
GO
/****** Объект:  View [gold].[v_graphs_cot_sales_and_refunds_shops_months]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_graphs_cot_sales_and_refunds_shops_months] AS
SELECT 
       L.Company AS [КОМПАНИЯ]
      ,L.Duty  AS [ТИП]
      ,L.StoreName  AS [МАГАЗИН]
      ,R.[TR_TYPE] AS [ТИП ТРАНЗАКЦИИ]
      ,DATETRUNC(MONTH, R.[DATE_BEG]) AS [ПЕРИОД: МЕСЯЦ]
      ,SUM(R.[SUMN]) AS [СУММА В НАЦ. ВАЛЮТЕ]
      ,COUNT(R.[TR_TYPE]) AS [ВСЕГО ЧЕКОВ]
  FROM [DataWarehouse].[silver].[acc_receipts] R
  LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(R.CASHCODE, 3)
  GROUP BY
    L.Company
    ,L.Duty 
    ,L.StoreName
    ,R.[TR_TYPE]
    ,DATETRUNC(MONTH, R.[DATE_BEG])
GO
/****** Объект:  View [gold].[v_graphs_cot_sales_and_refunds_shops_weeks]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [gold].[v_graphs_cot_sales_and_refunds_shops_weeks] AS
SELECT 
       L.Company AS [КОМПАНИЯ]
      ,L.Duty  AS [ТИП]
      ,L.StoreName  AS [МАГАЗИН]
      ,R.[TR_TYPE] AS [ТИП ТРАНЗАКЦИИ]
      ,DATEPART(ISO_WEEK, R.[DATE_BEG]) AS [НОМЕР НЕДЕЛИ]
      ,DATETRUNC(WEEK, R.[DATE_BEG]) AS [ПЕРИОД: НЕДЕЛЯ]
      ,SUM(R.[SUMN]) AS [СУММА В НАЦ. ВАЛЮТЕ]
      ,COUNT(R.[TR_TYPE]) AS [ВСЕГО ЧЕКОВ]
  FROM [DataWarehouse].[silver].[acc_receipts] R
  LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(R.CASHCODE, 3)
  GROUP BY
    L.Company
    ,L.Duty
    ,L.StoreName
    ,R.[TR_TYPE]
    ,DATEPART(ISO_WEEK, R.[DATE_BEG])
    ,DATETRUNC(WEEK, R.[DATE_BEG])
GO
/****** Объект:  View [gold].[v_graphs_cot_sales_and_refunds_shops_years]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [gold].[v_graphs_cot_sales_and_refunds_shops_years] AS
SELECT 
       L.Company AS [КОМПАНИЯ]
      ,L.Duty  AS [ТИП]
      ,L.StoreName  AS [МАГАЗИН]
      ,R.[TR_TYPE] AS [ТИП ТРАНЗАКЦИИ]
      ,DATETRUNC(YEAR, R.[DATE_BEG]) AS [ПЕРИОД: ГОД]
      ,SUM(R.[SUMN]) AS [СУММА В НАЦ. ВАЛЮТЕ]
      ,COUNT(R.[TR_TYPE]) AS [ВСЕГО ЧЕКОВ]
  FROM [DataWarehouse].[silver].[acc_receipts] R
  LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(R.CASHCODE, 3)
  GROUP BY
    L.Company
    ,L.Duty 
    ,L.StoreName
    ,R.[TR_TYPE]
    ,DATETRUNC(YEAR, R.[DATE_BEG])
GO
/****** Объект:  View [gold].[v_graphs_cot_sales_and_refunds_weeks]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_graphs_cot_sales_and_refunds_weeks] AS
SELECT 
       L.Company AS [КОМПАНИЯ]
      ,L.Duty  AS [ТИП]
      ,R.[TR_TYPE] AS [ТИП ТРАНЗАКЦИИ]
      ,DATEPART(ISO_WEEK, R.[DATE_BEG]) AS [НОМЕР НЕДЕЛИ]
      ,DATETRUNC(WEEK, R.[DATE_BEG]) AS [ПЕРИОД: НЕДЕЛЯ]
      ,SUM(R.[SUMN]) AS [СУММА В НАЦ. ВАЛЮТЕ]
      ,COUNT(R.[TR_TYPE]) AS [ВСЕГО ЧЕКОВ]
  FROM [DataWarehouse].[silver].[acc_receipts] R
  LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(R.CASHCODE, 3)
  GROUP BY
    L.Company
    ,L.Duty 
    ,R.[TR_TYPE]
    ,DATEPART(ISO_WEEK, R.[DATE_BEG])
    ,DATETRUNC(WEEK, R.[DATE_BEG])
GO
/****** Объект:  View [gold].[v_graphs_cot_sales_and_refunds_years]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_graphs_cot_sales_and_refunds_years] AS
SELECT 
       L.Company AS [КОМПАНИЯ]
      ,L.Duty  AS [ТИП]
      ,R.[TR_TYPE] AS [ТИП ТРАНЗАКЦИИ]
      ,DATETRUNC(YEAR, R.[DATE_BEG]) AS [ПЕРИОД: ГОД]
      ,SUM(R.[SUMN]) AS [СУММА В НАЦ. ВАЛЮТЕ]
      ,COUNT(R.[TR_TYPE]) AS [ВСЕГО ЧЕКОВ]
  FROM [DataWarehouse].[silver].[acc_receipts] R
  LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(R.CASHCODE, 3)
  GROUP BY
    L.Company
    ,L.Duty 
    ,R.[TR_TYPE]
    ,DATETRUNC(YEAR, R.[DATE_BEG])
GO
/****** Объект:  View [gold].[v_graphs_tr_avgbill]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [gold].[v_graphs_tr_avgbill] AS

WITH ItemData AS
(
    SELECT
        L.Company,
        L.Duty,
        DATETRUNC(MONTH, I.DATE) AS [DATEBEG],
        I.PriceTypeName,
        I.SUMN,
        I.UNIQ
    FROM silver.act_items I
    LEFT JOIN bronze.ref_locations L ON L.STORECODE = LEFT(I.CASHCODE, 3)
    WHERE I.OP_TYPE = 'Продажа'
)
SELECT
    I.Company AS [КОМПАНИЯ],
    I.Duty AS [ТИП ЛОКАЦИИ],
    I.DATEBEG AS [МЕСЯЦ],
    I.PriceTypeName AS [ТИП ЦЕНЫ],
    CAST(AVG(I.SUMN) as decimal(10,2)) AS [СРЕДНИЙ ЧЕК]
FROM ItemData I
GROUP BY I.Company, I.Duty, I.DATEBEG, PriceTypeName
GO
/****** Объект:  View [gold].[v_graphs_tr_refunds]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_graphs_tr_refunds] AS

WITH MainData AS
(
SELECT
	L.Company,
	L.Duty,
	SUM(CASE WHEN R.TR_TYPE = 'Продажа' THEN 1 END) AS [QTY_SALES],
	SUM(CASE WHEN R.TR_TYPE = 'Возврат' THEN 1 END) AS [QTY_REFUNDS]
FROM
	silver.acc_receipts R
LEFT JOIN [DataWarehouse].[bronze].[ref_locations] L ON L.STORECODE = LEFT(R.CASHCODE, 3)
GROUP BY
	L.Company,
	L.Duty
)
SELECT
	Company AS [КОМПАНИЯ],
	Duty AS [ТИП ЛОКАЦИИ],
	QTY_SALES AS [КОЛ-ВО ПРОДАЖ],
	QTY_REFUNDS AS [КОЛ-ВО ВОЗВРАТОВ],
	CAST((QTY_REFUNDS * 100.0 / QTY_SALES) as decimal(5,2)) AS [ДОЛЯ ВОЗВРАТОВ %]
FROM
	MainData
GO
/****** Объект:  View [gold].[v_history_dash]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [gold].[v_history_dash] AS
WITH AllCities AS
(
    SELECT DISTINCT CITY
    FROM bronze.ref_locations
    WHERE CITY IS NOT NULL
),
AllPriceTypes AS
(
    SELECT DISTINCT PriceTypeName
    FROM silver.act_items
    WHERE PriceTypeName IS NOT NULL
),
-- Декартово произведение: все города × все типы цен
AllCombinations AS
(
    SELECT C.CITY, PT.PriceTypeName
    FROM AllCities C
    CROSS JOIN AllPriceTypes PT
),
-- Реальные данные
ActualData AS
(
    SELECT
        L.CITY,
        I.PriceTypeName,
        COUNT(DISTINCT I.UNIQ) AS [QTY: RECEIPTS],
        SUM(I.SUMN) AS [TOTAL IN NATIONAL CURRENCY]
    FROM silver.act_items I
    LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(I.CASHCODE, 3)
    WHERE I.OPCODE = 50
    GROUP BY L.CITY, I.PriceTypeName
)
SELECT
    AC.CITY,
    AC.PriceTypeName,
    ISNULL(AD.[QTY: RECEIPTS], 0) AS [QTY: RECEIPTS],
    ISNULL(AD.[TOTAL IN NATIONAL CURRENCY], 0) AS [TOTAL IN NATIONAL CURRENCY]
FROM AllCombinations AC
LEFT JOIN ActualData AD 
    ON AD.CITY = AC.CITY 
    AND AD.PriceTypeName = AC.PriceTypeName;
GO
/****** Объект:  View [gold].[v_history_table]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [gold].[v_history_table] AS

WITH AllCities AS
(
    SELECT DISTINCT CITY
    FROM bronze.ref_locations
    WHERE CITY IS NOT NULL
),
AllPriceTypes AS
(
    SELECT DISTINCT PriceTypeName
    FROM silver.act_items
    WHERE PriceTypeName IS NOT NULL
),
-- Декартово произведение: все города × все типы цен
AllCombinations AS
(
    SELECT C.CITY, PT.PriceTypeName
    FROM AllCities C
    CROSS JOIN AllPriceTypes PT
),
-- Реальные данные
ActualData AS
(
    SELECT
        I.DATE,
        L.CITY,
        I.PriceTypeName,
        COUNT(DISTINCT I.UNIQ) AS [QTY: RECEIPTS],
        COUNT(I.CODE) AS [QTY: ITEMS],
        SUM(I.SUMN) AS [TOTAL IN NATIONAL CURRENCY]
    FROM silver.act_items I
    LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(I.CASHCODE, 3)
    WHERE I.OPCODE = 50
    GROUP BY L.CITY, I.PriceTypeName, I.DATE
)
SELECT
    AD.DATE,
    AC.CITY,
    AC.PriceTypeName,
    ISNULL(AD.[QTY: RECEIPTS], 0) AS [QTY: RECEIPTS],
    ISNULL(AD.[QTY: ITEMS], 0) AS [QTY: ITEMS],
    ISNULL(AD.[TOTAL IN NATIONAL CURRENCY], 0) AS [TOTAL IN NATIONAL CURRENCY]
FROM AllCombinations AC
LEFT JOIN ActualData AD 
    ON AD.CITY = AC.CITY 
    AND AD.PriceTypeName = AC.PriceTypeName;
GO
/****** Объект:  View [gold].[v_pa_rep_abc]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_pa_rep_abc] AS

WITH ExchangeRate AS
(
    -- 1. Средний курс для DCA (как в предыдущих запросах)
    SELECT AVG(P.NRATE) AS AVG_RATE_KZT_TO_RUB
    FROM [silver].[acm_payments] P
    LEFT JOIN [bronze].[ref_locations] L ON L.STORECODE = LEFT(P.CASHCODE, 3)
    WHERE L.Company = 'DCA' AND P.VALCODE = 5
),
CategorySales AS
(
    -- 2. Считаем выручку по каждой категории (в рублях)
    SELECT
        L.Company,
        C.CATEGORY_NAME,
        SUM(CASE 
            WHEN R.TR_TYPE = N'Продажа' THEN 
                CASE WHEN L.Company = 'DCA' THEN I.SUMN / ER.AVG_RATE_KZT_TO_RUB ELSE I.SUMN END
            ELSE 0 
        END) AS REVENUE_RUB
    FROM silver.acc_receipts R
    LEFT JOIN bronze.ref_locations L ON L.STORECODE = LEFT(R.CASHCODE, 3)
    LEFT JOIN silver.act_items I ON I.UNIQ = R.UNIQ
    LEFT JOIN bronze.ref_item_category C ON C.ITEM_ID = I.CODE
    CROSS JOIN ExchangeRate ER
    WHERE R.TR_TYPE = N'Продажа' 
      AND C.CATEGORY_NAME IS NOT NULL
      -- AND R.DATE_BEG >= '2026-01-01' -- Не забудь фильтр по дате!
    GROUP BY L.Company, C.CATEGORY_NAME
),
CumulativeData AS
(
    -- 3. Магия ABC: считаем накопительный итог
    SELECT
        Company,
        CATEGORY_NAME,
        REVENUE_RUB,
        
        -- Общая выручка компании (для расчёта процентов)
        SUM(REVENUE_RUB) OVER(PARTITION BY Company) AS TOTAL_COMPANY_REVENUE,
        
        -- Накопительная выручка (сортируем от самой прибыльной категории к наименей)
        SUM(REVENUE_RUB) OVER(
            PARTITION BY Company 
            ORDER BY REVENUE_RUB DESC, CATEGORY_NAME -- Вторичная сортировка для стабильности при равных суммах
            ROWS UNBOUNDED PRECEDING
        ) AS CUMULATIVE_REVENUE
        
    FROM CategorySales
),
ABC_Classified AS
(
    -- 4. Присваиваем класс A, B или C
    SELECT
        Company,
        CATEGORY_NAME,
        CAST(REVENUE_RUB AS DECIMAL(18,2)) AS REVENUE_RUB,
        
        -- Доля этой категории в выручке компании
        CAST((REVENUE_RUB * 100.0 / TOTAL_COMPANY_REVENUE) AS DECIMAL(5,2)) AS SHARE_IN_COMPANY_PCT,
        
        -- Накопительная доля (именно по ней определяем группу)
        CAST((CUMULATIVE_REVENUE * 100.0 / TOTAL_COMPANY_REVENUE) AS DECIMAL(5,2)) AS CUMULATIVE_PCT,
        
        CASE 
            WHEN (CUMULATIVE_REVENUE * 100.0 / TOTAL_COMPANY_REVENUE) <= 80.0 THEN 'A'
            WHEN (CUMULATIVE_REVENUE * 100.0 / TOTAL_COMPANY_REVENUE) <= 95.0 THEN 'B'
            ELSE 'C'
        END AS ABC_GROUP
    FROM CumulativeData
)
-- 5. Финальный вывод (отсортирован по группе и выручке)
SELECT 
    Company AS [КОМПАНИЯ],
    ABC_GROUP AS [ABC ГРУППА],
    CATEGORY_NAME AS [КАТЕГОРИЯ ТОВАРОВ],
    REVENUE_RUB AS [ВЫРУЧКА, РУБ],
    SHARE_IN_COMPANY_PCT AS [ДОЛЯ КАТЕГОРИИ В ВЫРУЧКЕ КОМПАНИИ],
    CUMULATIVE_PCT AS [НАКОПИТЕЛЬНАЯ ДОЛЯ]
FROM ABC_Classified
GO
/****** Объект:  View [gold].[v_pa_rep_abc_paretto]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_pa_rep_abc_paretto] AS

WITH ExchangeRate AS
(
    -- 1. Средний курс для DCA (как в предыдущих запросах)
    SELECT AVG(P.NRATE) AS AVG_RATE_KZT_TO_RUB
    FROM [silver].[acm_payments] P
    LEFT JOIN [bronze].[ref_locations] L ON L.STORECODE = LEFT(P.CASHCODE, 3)
    WHERE L.Company = 'DCA' AND P.VALCODE = 5
),
CategorySales AS
(
    -- 2. Считаем выручку по каждой категории (в рублях)
    SELECT
        L.Company,
        C.CATEGORY_NAME,
        SUM(CASE 
            WHEN R.TR_TYPE = N'Продажа' THEN 
                CASE WHEN L.Company = 'DCA' THEN I.SUMN / ER.AVG_RATE_KZT_TO_RUB ELSE I.SUMN END
            ELSE 0 
        END) AS REVENUE_RUB
    FROM silver.acc_receipts R
    LEFT JOIN bronze.ref_locations L ON L.STORECODE = LEFT(R.CASHCODE, 3)
    LEFT JOIN silver.act_items I ON I.UNIQ = R.UNIQ
    LEFT JOIN bronze.ref_item_category C ON C.ITEM_ID = I.CODE
    CROSS JOIN ExchangeRate ER
    WHERE R.TR_TYPE = N'Продажа' 
      AND C.CATEGORY_NAME IS NOT NULL
      -- AND R.DATE_BEG >= '2026-01-01' -- Не забудь фильтр по дате!
    GROUP BY L.Company, C.CATEGORY_NAME
),
CumulativeData AS
(
    -- 3. Магия ABC: считаем накопительный итог
    SELECT
        Company,
        CATEGORY_NAME,
        REVENUE_RUB,
        
        -- Общая выручка компании (для расчёта процентов)
        SUM(REVENUE_RUB) OVER(PARTITION BY Company) AS TOTAL_COMPANY_REVENUE,
        
        -- Накопительная выручка (сортируем от самой прибыльной категории к наименей)
        SUM(REVENUE_RUB) OVER(
            PARTITION BY Company 
            ORDER BY REVENUE_RUB DESC, CATEGORY_NAME -- Вторичная сортировка для стабильности при равных суммах
            ROWS UNBOUNDED PRECEDING
        ) AS CUMULATIVE_REVENUE
        
    FROM CategorySales
),
ABC_Classified AS
(
    -- 4. Присваиваем класс A, B или C
    SELECT
        Company,
        CATEGORY_NAME,
        CAST(REVENUE_RUB AS DECIMAL(18,2)) AS REVENUE_RUB,
        
        -- Доля этой категории в выручке компании
        CAST((REVENUE_RUB * 100.0 / TOTAL_COMPANY_REVENUE) AS DECIMAL(5,2)) AS SHARE_IN_COMPANY_PCT,
        
        -- Накопительная доля (именно по ней определяем группу)
        CAST((CUMULATIVE_REVENUE * 100.0 / TOTAL_COMPANY_REVENUE) AS DECIMAL(5,2)) AS CUMULATIVE_PCT,
        
        CASE 
            WHEN (CUMULATIVE_REVENUE * 100.0 / TOTAL_COMPANY_REVENUE) <= 80.0 THEN 'A'
            WHEN (CUMULATIVE_REVENUE * 100.0 / TOTAL_COMPANY_REVENUE) <= 95.0 THEN 'B'
            ELSE 'C'
        END AS ABC_GROUP
    FROM CumulativeData
),
ABC_Summary AS (
    -- Берём результат предыдущего запроса 
    SELECT 
        Company,
        ABC_GROUP,
        COUNT(CATEGORY_NAME) AS QTY_CATEGORIES,
        SUM(REVENUE_RUB) AS TOTAL_REVENUE_GROUP
    FROM ABC_Classified
    GROUP BY Company, ABC_GROUP
)
SELECT 
    Company AS [КОМПАНИЯ],
    ABC_GROUP AS [ABC ГРУППА],
    QTY_CATEGORIES AS [КОЛ-ВО КАТЕГОРИЙ],
    CAST(QTY_CATEGORIES * 100.0 / SUM(QTY_CATEGORIES) OVER(PARTITION BY Company) AS DECIMAL(5,2)) AS [% КАТЕГОРИЙ],
    CAST(TOTAL_REVENUE_GROUP AS DECIMAL(18,2)) AS [ВЫРУЧКА ПО ГРУППЕ],
    CAST(TOTAL_REVENUE_GROUP * 100.0 / SUM(TOTAL_REVENUE_GROUP) OVER(PARTITION BY Company) AS DECIMAL(5,2)) AS [% ВЫРУЧКИ]
FROM ABC_Summary
GO
/****** Объект:  View [gold].[v_pa_rep_salesvelocity]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [gold].[v_pa_rep_salesvelocity] AS

WITH ExchangeRate AS
(
    -- 1. Считаем средний курс для DCA (Тенге -> Рубли)
    SELECT 
        AVG(P.NRATE) AS AVG_RATE_KZT_TO_RUB
    FROM [silver].[acm_payments] P
    LEFT JOIN [bronze].[ref_locations] L ON L.STORECODE = LEFT(P.CASHCODE, 3)
    WHERE L.Company = 'DCA' 
      AND P.VALCODE = 5  -- Код тенге
),
SalesVelocity AS
(
    -- 2. Считаем скорость и выручку, конвертируя DCA в рубли
    SELECT
        L.Company,
        I.CODE AS [SKU_CODE],
        I.NAME AS [SKU_NAME],
        
        -- Физические штуки (валюта не важна, но считаем честно)
        SUM(CASE WHEN R.TR_TYPE = N'Продажа' THEN I.BQUANT ELSE 0 END) AS [TOTAL_QTY_SOLD],
        
        -- Дней, когда были продажи этого товара
        COUNT(DISTINCT CAST(R.DATE_BEG AS DATE)) AS [ACTIVE_DAYS],
        
        -- Выручка в РУБЛЯХ (с конвертацией для DCA)
        SUM(CASE 
            WHEN R.TR_TYPE = N'Продажа' THEN 
                CASE 
                    WHEN L.Company = 'DCA' THEN I.SUMN / ER.AVG_RATE_KZT_TO_RUB 
                    ELSE I.SUMN 
                END
            ELSE 0 
        END) AS [REVENUE_RUB]
        
    FROM silver.acc_receipts R
    LEFT JOIN bronze.ref_locations L ON L.STORECODE = LEFT(R.CASHCODE, 3)
    LEFT JOIN silver.act_items I ON I.UNIQ = R.UNIQ
    CROSS JOIN ExchangeRate ER  -- "Приклеиваем" курс ко всем строкам
    WHERE R.TR_TYPE = N'Продажа'
      AND I.CODE IS NOT NULL
      AND I.CODE NOT IN ('138994','138996','300042','138995', '253261','253260','253262', '297961','306432','306431', '306430','239839',
						'297962','239838','239837')
       AND R.DATE_BEG >= DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
    GROUP BY 
        L.Company, 
        I.CODE, 
        I.NAME
)
-- 3. Финальный расчёт скорости и ранжирование
SELECT
    Company AS [КОМПАНИЯ],
    SKU_CODE AS [КОД ТОВАРА],
    SKU_NAME AS [ТОВАР],
    TOTAL_QTY_SOLD AS [ПРОДАНО, ШТ],
    CAST(REVENUE_RUB AS DECIMAL(18,2)) AS [ВЫРУЧКА, РУБ],
    ACTIVE_DAYS AS [ДНЕЙ ПРОДАЖ ИЗ 30 ПОСЛЕДНИХ],
    
    -- ГЛАВНАЯ МЕТРИКА: Средняя скорость продаж в день (штук)
    CAST((CAST(TOTAL_QTY_SOLD AS FLOAT) / NULLIF(ACTIVE_DAYS, 0)) AS DECIMAL(10,2)) AS [СРЕДНЯЯ СКОРОСТЬ ПРОДАЖ В ДЕНЬ, ШТ],
    
    -- Ранг по скорости внутри компании (1 = самый быстро продаваемый)
    RANK() OVER(PARTITION BY Company ORDER BY (CAST(TOTAL_QTY_SOLD AS FLOAT) / NULLIF(ACTIVE_DAYS, 0)) DESC) AS [РЕЙТИНГ ПО СКОРОСТИ (1 = самый быстро продаваемый)]
    
FROM SalesVelocity
WHERE ACTIVE_DAYS > 0  -- Убираем товары, которые ни разу не продавались за период
GO
/****** Объект:  View [gold].[v_pa_rep_top20scu]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [gold].[v_pa_rep_top20scu] AS

WITH ExchangeRate AS
(
    -- 1. Считаем средний курс для DCA (Тенге -> Рубли)
    SELECT 
        AVG(P.NRATE) AS AVG_RATE_KZT_TO_RUB
    FROM [silver].[acm_payments] P
    LEFT JOIN [bronze].[ref_locations] L ON L.STORECODE = LEFT(P.CASHCODE, 3)
    WHERE L.Company = 'DCA' 
      AND P.VALCODE = 5
),
SKUSales AS
(
    -- 2. Агрегируем продажи, сразу конвертируя DCA в рубли
    SELECT
        L.Company,
        I.CODE AS [SKU_CODE],
        I.NAME AS [SKU_NAME],
        C.CATEGORY_NAME AS [CATEGORY_NAME],
        -- Конвертация: если DCA, делим на курс (или умножай, если курс хранится как "рублей за 1 тенге")
        SUM(CASE 
            WHEN R.TR_TYPE = N'Продажа' THEN 
                CASE 
                    WHEN L.Company = 'DCA' THEN I.SUMN / ER.AVG_RATE_KZT_TO_RUB 
                    ELSE I.SUMN 
                END
            ELSE 0 
        END) AS [REVENUE_RUB],
        
        SUM(CASE WHEN R.TR_TYPE = N'Продажа' THEN I.BQUANT ELSE 0 END) AS [QTY],
        COUNT(DISTINCT R.UNIQ) AS [RECEIPTS_WITH_ITEM]   
    FROM silver.acc_receipts R
    LEFT JOIN bronze.ref_locations L ON L.STORECODE = LEFT(R.CASHCODE, 3)
    LEFT JOIN silver.act_items I ON I.UNIQ = R.UNIQ
    LEFT JOIN bronze.ref_item_category C ON C.ITEM_ID = I.CODE
    CROSS JOIN ExchangeRate ER  -- "Приклеиваем" средний курс ко всем строкам
    WHERE R.TR_TYPE = N'Продажа' 
      AND I.CODE IS NOT NULL
      AND I.CODE NOT IN ('138994','138996','300042','138995', '253261','253260','253262', '297961','306432','306431', '306430','239839',
						'297962','239838','239837')
    GROUP BY 
        L.Company, 
        C.CATEGORY_NAME, 
        I.CODE, 
        I.NAME
),
RankedData AS
(
    -- 3. Добавляем рейтинги уже на основе выручки в РУБЛЯХ
    SELECT
        Company,
        SKU_CODE,
        SKU_NAME,
        CATEGORY_NAME,
        REVENUE_RUB,
        QTY,
        RECEIPTS_WITH_ITEM,
        CASE WHEN QTY > 0 THEN REVENUE_RUB / QTY ELSE 0 END AS [AVG_PRICE_RUB],
        
        -- 🏆 Рейтинг по всей группе компаний (теперь всё в одной валюте!)
        RANK() OVER (ORDER BY REVENUE_RUB DESC) AS [GROUP_RANK],
        
        -- 🏆 Рейтинг внутри конкретной компании
        RANK() OVER (PARTITION BY Company ORDER BY REVENUE_RUB DESC) AS [COMPANY_RANK],
        
        -- 📊 Доля этого SKU в общей выручке компании (в рублях)
        REVENUE_RUB * 100.0 / NULLIF(SUM(REVENUE_RUB) OVER(PARTITION BY Company), 0) AS [SHARE_IN_COMPANY_%]
        
    FROM SKUSales
)
-- 4. Финальная выборка
SELECT
    Company AS [КОМПАНИЯ],
    SKU_CODE AS [КОД ТОВАРА],
    SKU_NAME AS [ТОВАР],
    CATEGORY_NAME AS [КАТЕГОРИЯ ТОВАРА],
    CAST(REVENUE_RUB AS DECIMAL(18,2)) AS [ВЫРУЧКА, РУБ],
    QTY AS [КОЛИЧЕСТВО],
    CAST(AVG_PRICE_RUB AS DECIMAL(18,2)) AS [СРЕДНЯЯ ЦЕНА, РУБ],
    GROUP_RANK AS [РЕЙТИНГ ТОВАРА В ГК],
    COMPANY_RANK AS [РЕЙТИНГ ТОВАРА В КОМПАНИИ],
    CAST([SHARE_IN_COMPANY_%] AS DECIMAL(5,2)) AS [ДОЛЯ ВЫРУЧКИ ПО ТОВАРУ В КОМПАНИИ, %]
FROM RankedData
WHERE 
    -- Показываем товар, если он в ТОП-20 по ГРУППЕ или в ТОП-20 по своей КОМПАНИИ
    GROUP_RANK <= 20 OR COMPANY_RANK <= 20
GO
/****** Объект:  View [gold].[v_perf_budgets]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_perf_budgets] AS

WITH FactDataNative AS (
-- 1. Calculation in national currencies
    SELECT
        L.Company,
        DATETRUNC(MONTH, R.DATE_BEG) AS [DATEBEG],
        YEAR(R.DATE_BEG) AS [YEAR],
        MONTH(R.DATE_BEG) AS [MONTH],
        (SUM(CASE WHEN R.TR_TYPE = N'Продажа' THEN R.SUMN END) -
            SUM(CASE WHEN R.TR_TYPE = N'Возврат' THEN R.SUMN END)) AS [SALES_NATIVE]
    FROM
        [DataWarehouse].[silver].[acc_receipts] R
    LEFT JOIN [DataWarehouse].[bronze].[ref_locations] L ON L.STORECODE = LEFT(R.CASHCODE, 3)
    GROUP BY
        L.Company,
        DATETRUNC(MONTH, R.DATE_BEG),
        YEAR(R.DATE_BEG),
        MONTH(R.DATE_BEG)
),
ExchangeRates AS
-- Average rate RUB-KZT per month (for DCA only)
(
select 
  L.Company,
  DATETRUNC(MONTH, P.DATE) AS [DATEBEG],
  AVG(P.NRATE) AS [RATE_AVG]
  from [silver].[acm_payments] P
  LEFT JOIN [DataWarehouse].[bronze].[ref_locations] L ON L.STORECODE = LEFT(P.CASHCODE, 3)
  where P.CASHCODE like '28%' and VALCODE = 5
  group by L.Company, DATETRUNC(MONTH, P.DATE)
),
FactDataRUB AS(
SELECT
    F.Company,
    F.DATEBEG,
    F.[YEAR],
    F.[MONTH],
    CASE
        WHEN F.Company = 'DCA' THEN F.SALES_NATIVE / E.RATE_AVG
        ELSE F.SALES_NATIVE
    END AS [SALES]
FROM
    FactDataNative F
LEFT JOIN ExchangeRates E ON E.Company = F.Company AND E.DATEBEG = F.DATEBEG
),
BudgetData AS (
    SELECT
        COMPANY,
        [YEAR],
        [MONTH],
        SUM(BUDGETAMOUNT) AS [BUDGET]
    FROM
        bronze.ref_budgets
    GROUP BY
        COMPANY, [YEAR], [MONTH]
)
SELECT
    F.Company AS [Комания],
    F.DATEBEG AS [Период: Месяц],
    ISNULL(F.SALES, 0) AS [ИТОГ: За месяц, РУБ],
    B.BUDGET AS [План: За месяц],
        SUM(F.SALES) OVER(PARTITION BY F.DATEBEG) AS [ИТОГ: По ГК за месяц, РУБ],
/* Доля компании в общем итоге за месяц % */
        ISNULL(CAST(F.SALES * 100.0 / NULLIF(SUM(F.SALES) OVER(PARTITION BY F.DATEBEG), 0) AS DECIMAL(5,2)), 0) AS [ДОЛЯ: Компании в ГК %],
/* Доля месяца в общем итоге по компании % */
        ISNULL(CAST(F.SALES * 100.0 / NULLIF(SUM(F.SALES) OVER(PARTITION BY F.COMPANY), 0) AS DECIMAL(5,2)), 0) AS [ДОЛЯ: Месяца в Компании %],
/* Разница с предыдущим месяцем (абсолют) */
        ISNULL(F.SALES - LAG(F.SALES) OVER(PARTITION BY F.COMPANY ORDER BY F.DATEBEG), 0) AS [РАЗНИЦА: С предыдущим месяцем, РУБ],
/* Изменение к предыдущему месяцу % */
        ISNULL(CAST((F.SALES - LAG(F.SALES) OVER(PARTITION BY F.COMPANY ORDER BY F.DATEBEG)) * 100.0
                       / NULLIF(LAG(F.SALES) OVER(PARTITION BY F.COMPANY ORDER BY F.DATEBEG), 0)
                            AS DECIMAL(7,2)), 0) AS [ИЗМЕНЕНИЕ: К предыдущему месяцу %],
--Will be activated in 2027---------------------------------------------------------------------------------------------------------------
/* Изменение к тому же месяцу прошлого года (%)
CAST(
        (SALES - LAG(SALES, 12) OVER(PARTITION BY COMPANY ORDER BY DATE_BEG)) * 100.0
        / NULLIF(LAG(SALES, 12) OVER(PARTITION BY COMPANY ORDER BY DATE_BEG), 0)
    AS DECIMAL(7,2)) AS [YoY %],
*/
/* Ранг компании за месяц (1 = самая крупная) */
--RANK() OVER(PARTITION BY DATE_BEG ORDER BY SALES DESC) AS [RANK BY MONTH],
------------------------------------------------------------------------------------------------------------------------------------------
/* Скользящее среднее за 3 месяца */
        ISNULL(CAST(AVG(F.SALES) OVER(PARTITION BY F.COMPANY ORDER BY F.DATEBEG ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS DECIMAL(18,2)), 0) AS [Скользящее среднее за 3M],
/* Абсолютное отклонение от плана за месяц */
/* Что показывает: Насколько факт отличается от бюджета в абсолютных числах. */
        ISNULL(F.SALES - ISNULL(B.BUDGET, 0), 0)  AS [Отклонение от плана, РУБ],
/* Процент отклонения от плана за месяц */
/* Что показывает: На сколько процентов факт отклонился от бюджета. */
        ISNULL(CASE WHEN B.BUDGET IS NOT NULL AND B.BUDGET <> 0 THEN (F.SALES - B.BUDGET) * 100.0 / B.BUDGET
             ELSE NULL
        END, 0)  AS [Отклонение от плана, %],
/* Процент выполнения плана за месяц */
/* Что показывает: Какой процент от бюджета фактически выполнен за месяц. */
        ISNULL(CASE WHEN B.BUDGET IS NOT NULL AND B.BUDGET <> 0 THEN F.SALES * 100.0 / B.BUDGET
             ELSE NULL
        END, 0)  AS [Выполнение плана %],
/* Накопленные продажи с начала года */
/* Что показывает: Сумма продаж с января по текущий месяц (накопительным итогом). */
        ISNULL(SUM(F.SALES) OVER(PARTITION BY F.Company, F.[YEAR] ORDER BY F.DATEBEG ROWS UNBOUNDED PRECEDING), 0) AS [YTD: Сумма продаж],
/* Накопленный бюджет с начала года */
/* Что показывает: Сумма бюджета с января по текущий месяц (накопительно). */
        SUM(B.BUDGET) OVER(PARTITION BY F.Company, F.[YEAR] ORDER BY F.DATEBEG ROWS UNBOUNDED PRECEDING) AS [YTD: План],
/* Накопленное выполнение плана с начала года */
/* Что показывает: Какой процент годового плана выполнен к текущему моменту. Показывает тренд: компания догоняет план или отстаёт ещё больше */
        ISNULL(SUM(F.SALES) OVER(PARTITION BY F.Company, F.[YEAR] ORDER BY F.DATEBEG ROWS UNBOUNDED PRECEDING) * 100.0
        / NULLIF(SUM(B.BUDGET) OVER(PARTITION BY F.Company, F.[YEAR] ORDER BY F.DATEBEG ROWS UNBOUNDED PRECEDING), 0), 0) AS [YTD: Выполнение плана %],
   CASE WHEN F.SALES >= ISNULL(B.BUDGET, 0) THEN 'Выполнен' ELSE 'Не выполнен' END AS [Статус выполнения плана]
FROM
    FactDataRUB F
LEFT JOIN BudgetData B ON B.Company = F.Company
            AND B.[YEAR] = YEAR(F.DATEBEG)
            AND B.[MONTH] = MONTH(F.DATEBEG)

GO
/****** Объект:  View [gold].[v_rep_cashiers]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [gold].[v_rep_cashiers] AS
SELECT
       L.COMPANY
	  ,L.LOCATION
      ,U.NAME
      ,R.[DATE_BEG] AS [DATE]
      ,COUNT(CASE WHEN R.TR_TYPE = 'Продажа' THEN R.CHECKNUM END) AS [QTY OF SALES]
      ,COUNT(CASE WHEN R.TR_TYPE != 'Продажа' THEN R.CHECKNUM END) AS [QTY OF REFUNDS]
      ,ISNULL(SUM(CASE WHEN R.TR_TYPE = 'Продажа' THEN R.SUMN END), 0) AS [SUM OF SALES NC]
      ,ISNULL(SUM(CASE WHEN R.TR_TYPE != 'Продажа' THEN R.SUMN END), 0) AS [SUM OF REFUNDS NC]
  FROM [DataWarehouse].[silver].[acc_receipts] R
  LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(R.CASHCODE, 3)
  INNER JOIN bronze.pos_mol_users U ON U.CODE = R.SCODE 
  AND U.FLAG = CASE
                WHEN R.CASHCODE like '1%' THEN 'RUDF'
                WHEN R.CASHCODE like '28%' THEN 'KZDF'
                ELSE 'RUDP' 
               END
  GROUP BY L.COMPANY,L.LOCATION,U.NAME,R.[DATE_BEG]


GO
/****** Объект:  View [gold].[v_rep_categories]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_rep_categories] AS
WITH ExchangeRates AS
(
	SELECT
	DATE,
	MAX(CASE WHEN VALCODE = 3 THEN NRATE END) AS NRATE_EUR,
	MAX(CASE WHEN VALCODE = 5 THEN NRATE END) AS NRATE_RUB,
	SERVER
	FROM
		silver.acm_payments
	GROUP BY
		DATE, SERVER
),
BaseData AS
(
SELECT 
    L.Company,
    L.Location,
    L.StoreName,
    I.SERVER,
    I.[DATE],
    ISNULL(CAST(C.CATEGORY_CODE as nvarchar), N'Без Кода') AS [CATEGORY CODE],
    ISNULL(C.CATEGORY_NAME, N'Без Кода') AS [CATEGORY NAME],
    SUM(I.[BQUANT]) AS [QTY],
    SUM(I.[SUMI]) AS [TOTAL]
FROM [DataWarehouse].[silver].[act_items] I
LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(I.CASHCODE, 3)
LEFT JOIN bronze.ref_item_category C ON C.ITEM_ID = I.CODE
WHERE I.[NAME] NOT LIKE N'%cейф-пакет%' AND I.CODE NOT IN ('138996','138994') AND I.OPCODE = 50
GROUP BY
     L.Company,
    L.Location,
    L.StoreName,
    I.SERVER,
    I.[DATE],
    C.CATEGORY_CODE,
    C.CATEGORY_NAME
)
SELECT
BD.Company AS [COMPANY],
BD.Location AS [LOCATION],
BD.StoreName AS [STORE],
BD.DATE AS [DATE],
BD.[CATEGORY CODE] AS [CATEGORY CODE],
BD.[CATEGORY NAME] AS [CATEGORY NAME],
BD.QTY AS [QTY],
CASE WHEN BD.SERVER = 'DC1-SRV-KC01' THEN BD.TOTAL * ER.NRATE_EUR
         WHEN BD.SERVER = 'DC1-SRV-KC03' THEN BD.TOTAL * ER.NRATE_EUR / ER.NRATE_RUB
         ELSE BD.TOTAL END AS [TOTAL RUB]

FROM
    BaseData BD
LEFT JOIN ExchangeRates ER ON ER.[DATE] = BD.[DATE] AND ER.SERVER = BD.SERVER
GO
/****** Объект:  View [gold].[v_rep_destinations]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_rep_destinations] AS
SELECT [CITY] AS [AIRPORT of LOCATION]
      ,[DATE]
      ,[DIRECTION]
      ,[PRICE_TYPE] AS [PRICE TYPE]
      ,[DEPARTURE_CODE] AS [DEPARTURE: CODE]
      ,[DEPARTURE_CITY] AS [DEPARTURE: CITY]
      ,[DEPARTURE_COUNTRY] AS [DEPARTURE: COUNTRY]
      ,[ARRIVAL_CODE] AS [ARRIVAL: CODE]  
      ,[ARRIVAL_CITY] AS [ARRIVAL: CITY]
      ,[ARRIVAL_COUNTRY] AS [ARRIVAL: COUNTRY]
      ,[QTY_OF_RECEIPTS] AS [RECEIPTS QTY]
      ,[TOTAL_RUB] AS [TOTAL in RUB]
  FROM [DataWarehouse].[gold].[rep_destinations]
GO
/****** Объект:  View [gold].[v_rep_discountcards]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_rep_discountcards] AS
SELECT  
       [LOCATION]
      ,CONCAT(DATENAME(M, [DATE]), ' ', YEAR([DATE])) AS [PERIOD]     
      ,[STORE]
      ,[CASHCODE]
      ,[CASHIER]
      ,[DISCOUNT_CARD]
      ,[CHECKNUM]
      ,[DATE]
      ,[TIME]
      ,[ITEM_NAME]
      ,[QUANTITY]
      ,[ITEM_PRICE]
      ,[PRICE_AFTER_DISCOUNT]
      ,[DISCOUNT_AMOUNT]
      ,[TOTAL_IN_NATIONAL]
  FROM [DataWarehouse].[gold].[rep_discounts]
  where DISCOUNT_CARD != '-'
GO
/****** Объект:  View [gold].[v_rep_items]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_rep_items] AS
SELECT 
    L.Company,
    L.Location,
    L.StoreName,
    I.[DATE],
    LEFT(I.[TIME], 8) AS [TIME],
    I.[OP_TYPE] AS [TRANSACTION TYPE],
    I.[PriceTypeName] AS [PRICE TYPE],
    I.[CHECKNUM] AS [RECEIPT NUMBER],
    I.[CASHCODE] AS [POS NUMBER],
    I.[SName] AS [CASHIER],
    I.[NAME] AS [ITEM NAME],
    I.[CODE] AS [ITEM CODE],
    I.[BQUANT] AS [QTY],
    I.[PRICE],
    I.[DISC_ABS] AS [ABSOLUTE DISCOUNT],
    CASE WHEN I.[PRICE] <> 0 
         THEN CAST((((I.[PRICE] - I.[SUMI]) / I.[PRICE]) * 100) AS decimal(10,2))
         ELSE 0 
    END AS [DISCOUNT %],
    I.[SUMI] AS [TOTAL],
    I.[VATRATE1] AS [VAT %],
    I.[VATSUM1] AS [VAT SUM],
    ISNULL(SIP.[VALUE], '-') AS [SIP NUMBER],
    ISNULL(MAX(MOL.[NAME]), '-') AS [SIP NAME]
FROM [DataWarehouse].[silver].[act_items] I
LEFT JOIN bronze.ref_locations L 
    ON L.StoreCode = LEFT(I.CASHCODE, 3)
LEFT JOIN silver.ac_dopdata_salersip SIP 
    ON SIP.UNIQ = I.UNIQ AND SIP.POSITION = I.POSITION
LEFT JOIN bronze.pos_mol_users MOL 
    ON MOL.LOGIN = SIP.VALUE
    AND MOL.FLAG = CASE 
                     WHEN I.CASHCODE LIKE '1%' THEN 'RUDP'
                     WHEN I.CASHCODE LIKE '28%' THEN 'KZDF' 
                     ELSE 'RUDF'
                   END
WHERE I.[NAME] NOT LIKE N'%cейф-пакет%'
GROUP BY
     L.Company,
    L.Location,
    L.StoreName,
    I.[DATE],
    I.[TIME],
    I.[OP_TYPE],
    I.[PriceTypeName],
    I.[CHECKNUM],
    I.[CASHCODE],
    I.[SName],
    I.[NAME],
    I.[CODE],
    I.[BQUANT],
    I.[PRICE],
    I.[DISC_ABS],
    I.[SUMI],
    I.[VATRATE1],
    I.[VATSUM1],
    SIP.[VALUE];
GO
/****** Объект:  View [gold].[v_rep_kyfo]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_rep_kyfo] AS

WITH MainData AS
(
SELECT
	P.UNIQ,
	L.Company,
	L.Duty,
	L.Location,
	L.StoreName,
	P.DATE,
	LEFT(P.TIME, 8) AS [TIME],
	CASE
		WHEN P.OPCODE = 70 THEN N'Продажа' ELSE N'Возврат'
	END AS [TYPE],
	P.CASHCODE,
	P.CHECKNUM,
	P.SHIFT,
	CASE WHEN P.OPCODE = 70 THEN P.SUMN ELSE -P.SUMN
	END AS [PAID BY KYFO],
	R.SUMN AS [RECEIPT TOTAL],
	ISNULL(K.[ID],'-') AS [ID],
	ISNULL(K.[ORDER],'-') AS [ORDER]
FROM
	silver.acm_payments P
LEFT JOIN silver.ac_dopdata_kyfo K ON K.UNIQ = P.UNIQ AND K.CASHCODE = P.CASHCODE AND K.CHECKNUM = P.CHECKNUM
LEFT JOIN silver.acc_receipts R ON R.UNIQ = P.UNIQ AND R.CASHCODE = P.CASHCODE AND R.CHECKNUM = P.CHECKNUM
LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(P.CASHCODE, 3)
WHERE
	P.VALCODE = 40
)
SELECT
	[COMPANY] AS [КОМПАНИЯ],
	[DUTY] AS [ТИП],
	[LOCATION] AS [ЛОКАЦИЯ],
	[STORENAME] AS [МАГАЗИН],
	[DATE] AS [ДАТА],
	[TIME] AS [ВРЕМЯ],
	[TYPE] AS [ТИП ТРАНЗАКЦИИ],
	[CASHCODE] AS [КАССА],
	[CHECKNUM] AS [НОМЕР ЧЕКА],
	[SHIFT] AS [НОМЕР СМЕНЫ],
	[PAID BY KYFO] AS [СУММА В KYFO],
	[RECEIPT TOTAL] AS [СУММА ВСЕГО ЧЕКА],
	CAST((CASE 
        WHEN [RECEIPT TOTAL] <> 0 
        THEN ([PAID BY KYFO] / [RECEIPT TOTAL]) * 100 
        ELSE 0 
    END) AS decimal(5,2)) AS [ДОЛЯ KYFO В ЧЕКЕ, %],
	[ID] AS [ID KYFO],
	[ORDER] AS [НОМЕР ЗАКАЗА KYFO]
FROM
	MainData
GO
/****** Объект:  View [gold].[v_rep_promos]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [gold].[v_rep_promos] AS

WITH PromoData AS
(
    -- Агрегируем промо-номера один раз на UNIQ + POSITION
    SELECT
        UNIQ,
        [POSITION],
        MAX(CASE WHEN DATA = 'PROMODISC' THEN VALUE END) AS PromoDiscNumber
    FROM silver.ac_dopdata_promonumber
    GROUP BY UNIQ, [POSITION]
),

AvoltaAgg AS
(
    -- Агрегируем AvoltaClub один раз на уровень чека
    SELECT
        UNIQ,
        CASHCODE,
        CHECKNUM,
        MAX(CASE WHEN DATA = 'NDISC' THEN VALUE END) AS AVOLTA_LEVEL,
        MAX(CASE WHEN DATA = 'LCUSID' THEN VALUE END) AS AVOLTA_ID
    FROM silver.ac_dopdata_avoltaclub
    GROUP BY UNIQ, CASHCODE, CHECKNUM
),

CouponAgg AS
(
    -- Агрегируем купоны один раз на уровень чека
    SELECT
        UNIQ,
        POS_NUMBER,
        RECEIPT_NUMBER,
        MAX(CASE 
            WHEN VALUE = '741123369986' THEN N'Сотрудники и Экипаж 20%'
            WHEN VALUE = '741123369987' THEN N'Руководители подразделений 25%'
            WHEN VALUE = '741123369988' THEN N'Руководители структур 30%'
            WHEN VALUE = '741123369989' THEN N'Акционеры и партнёры 50%'
            WHEN VALUE = '0242' THEN N'VIP 15% VKO DP'
            WHEN VALUE = '10999' THEN N'VIP АэроРегион 15%'
            WHEN VALUE = '741123369990' THEN N'Предзаказ 10%'
            WHEN VALUE = '0241' THEN N'Регстаэр ВИП 15% VKO Pilot Shop'
            WHEN VALUE = '6051' THEN N'Регстаэр ВИП 20%'
            WHEN VALUE = '0217' THEN N'Регстаэр ВИП 25% VKO Pilot Shop'
            WHEN VALUE = '6054' THEN N'Регстаэр ВИП 30%'
            WHEN VALUE IN ('150200','150300','150333','150400','150222') THEN N'Регстаэр ВИП 50% VKO T3'
        END) AS DISCOUNT_CARDS,
        MAX(CASE WHEN VALUE LIKE '999%' THEN VALUE END) AS VIP_VOUCHER,
        MAX(CASE WHEN VALUE LIKE 'FANDS%' THEN N'FUN AND SUN' END) AS PARTNER_VOUCHER
    FROM silver.ac_dopdata_coupons
    GROUP BY UNIQ, POS_NUMBER, RECEIPT_NUMBER
),

BaseData AS
(
    SELECT
        ACT.UNIQ,
        ACT.CASHCODE,
        ACT.SName,
        ACT.CHECKNUM,
        ACT.SHIFT,
        ACT.DATE,
        LEFT(ACT.TIME, 8) AS [TIME],
        ACT.NAME,
        ACT.CODE,
        ACT.BQUANT,
        ACT.PRICE,
        ACT.SUMI,
        ACT.DISC_ABS,
        ACT.DISC_PERC,
        ACT.SUMN,
        ACT.[POSITION],
        PN.Description,
        AA.AVOLTA_LEVEL,
        AA.AVOLTA_ID,
        CA.DISCOUNT_CARDS,
        CA.VIP_VOUCHER,
        CA.PARTNER_VOUCHER
    FROM silver.act_items ACT
    LEFT JOIN PromoData PD 
        ON PD.UNIQ = ACT.UNIQ AND PD.[POSITION] = ACT.[POSITION]
    LEFT JOIN silver.ref_promoid PN 
        ON PN.PROMOID = PD.PromoDiscNumber 
        AND PN.FLAG = CASE 
                        WHEN ACT.CASHCODE LIKE '1%' THEN 'RUDP'
                        WHEN ACT.CASHCODE LIKE '28%' THEN 'KZDF' 
                        ELSE 'RUDF'
                      END
    LEFT JOIN AvoltaAgg AA 
        ON AA.UNIQ = ACT.UNIQ 
        AND AA.CASHCODE = ACT.CASHCODE 
        AND AA.CHECKNUM = ACT.CHECKNUM
    LEFT JOIN CouponAgg CA 
        ON CA.UNIQ = ACT.UNIQ 
        AND CA.POS_NUMBER = ACT.CASHCODE 
        AND CA.RECEIPT_NUMBER = ACT.CHECKNUM
    WHERE (ACT.DISC_ABS > 0 OR ACT.DISC_PERC > 0) 
        AND ACT.NAME NOT LIKE '%Товар упакован в cейф-пакет%'
)

SELECT
    L.Company,
    L.Duty,
    L.Location,
    L.StoreName,
    BD.CASHCODE,
    BD.SName,
    ISNULL(BD.DISCOUNT_CARDS, '-') AS DISCOUNT_CARDS,
    BD.CHECKNUM,
    BD.DATE,
    BD.TIME,
    BD.NAME,
    BD.CODE,
    BD.BQUANT,
    BD.PRICE,
    BD.SUMI,
    BD.DISC_ABS,
    BD.SUMN,
    BD.Description,
    ISNULL(BD.AVOLTA_LEVEL, '-') AS AVOLTA_LEVEL,
    ISNULL(BD.AVOLTA_ID, '-') AS AVOLTA_ID,
    ISNULL(BD.VIP_VOUCHER, '-') AS VIP_VOUCHER,
    ISNULL(BD.PARTNER_VOUCHER, '-') AS PARTNER_VOUCHER
FROM BaseData BD
LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(BD.CASHCODE, 3)
WHERE BD.Description <> 'Скидка на сейф-пакет';
GO
/****** Объект:  View [gold].[v_rep_SCO]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_rep_SCO] AS
WITH CTE_Main AS 
(
    SELECT 
        L.Company, 
        L.Location, 
        L.StoreName,
        SUM(CASE WHEN S.CASHCODE NOT LIKE '___5_' AND S.CASHCODE NOT LIKE '28%' THEN S.[SUMN] END) AS POS_SUM,
        SUM(CASE WHEN S.CASHCODE LIKE '___5_' THEN S.[SUMN] END) AS SCO_SUM
    FROM silver.act_items S
    LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(S.CASHCODE, 3)
    GROUP BY
        L.Company, 
        L.Location, 
        L.StoreName
    HAVING 
        SUM(CASE WHEN S.CASHCODE LIKE '___5_' THEN 1 ELSE 0 END) > 0
        AND SUM(CASE WHEN S.CASHCODE NOT LIKE '___5_' THEN 1 ELSE 0 END) > 0
)
SELECT
    COMPANY,
    LOCATION,
    StoreName AS [STORE],
    POS_SUM AS [SALES ON POS],
    SCO_SUM AS [SALES ON SCO],
    CAST((SCO_SUM * 100.0 / NULLIF(POS_SUM + SCO_SUM, 0)) AS DECIMAL(10,2)) AS [SHARE % SCO]
FROM 
    CTE_Main
GO
/****** Объект:  View [gold].[v_rep_seif_bags]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [gold].[v_rep_seif_bags] AS
SELECT 
    L.Company,
    L.Location,
    L.StoreName,
    I.[DATE],
    LEFT(I.[TIME], 8) AS [TIME],
    I.[OP_TYPE] AS [TRANSACTION TYPE],
    I.[PriceTypeName] AS [PRICE TYPE],
    I.[CHECKNUM] AS [RECEIPT NUMBER],
    I.[CASHCODE] AS [POS NUMBER],
    I.[NAME] AS [ITEM NAME],
    I.[CODE] AS [ITEM CODE],
    I.[BQUANT] AS [QTY],
    I.[PRICE],
    I.[SUMI] AS [TOTAL],
    I.[VATRATE1] AS [VAT %],
    I.[VATSUM1] AS [VAT SUM]
FROM [DataWarehouse].[silver].[act_items] I
LEFT JOIN bronze.ref_locations L 
    ON L.StoreCode = LEFT(I.CASHCODE, 3)
WHERE I.[NAME] LIKE N'%cейф-пакет%'
GO
/****** Объект:  View [gold].[v_rep_shifts]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_rep_shifts] WITH SCHEMABINDING AS

WITH BaseShifts AS
(
    SELECT
        CASHCODE, FSHIFT, DATEBEGIN, DATEEND, FSSALE, FSBACK, FCSALE, FCBACK, ECTSERIAL 
    FROM silver.acs_shifts
),
ShiftOps AS
(
    SELECT
        S.CASHCODE, S.FSHIFT, S.DATEBEGIN, S.DATEEND, 
        S.FSSALE, S.FSBACK, S.FCSALE, S.FCBACK, S.ECTSERIAL,
        SUM(CASE WHEN A.VALCODE = 1 AND A.OPCODE = 70 THEN A.SUMN ELSE 0 END) AS [CASH],
        SUM(CASE WHEN A.VALCODE <> 1 AND A.OPCODE = 70 THEN A.SUMN ELSE 0 END) AS [CARDS],
        SUM(CASE WHEN A.VALCODE = 1 AND A.OPCODE = 72 THEN A.SUMN ELSE 0 END) AS [CASHCHANGE],
        SUM(CASE WHEN A.VALCODE = 1 AND A.OPCODE = 74 THEN A.SUMN ELSE 0 END) AS [CASHREFUND],
        SUM(CASE WHEN A.VALCODE <> 1 AND A.OPCODE = 74 THEN A.SUMN ELSE 0 END) AS [CARDREFUND],
        MAX(A.FSERIAL) AS [SERIAL]
    FROM BaseShifts S
    LEFT JOIN silver.acm_payments A 
        ON A.CASHCODE = S.CASHCODE AND A.FSHIFT = S.FSHIFT
    GROUP BY
        S.CASHCODE, S.FSHIFT, S.DATEBEGIN, S.DATEEND, 
        S.FSSALE, S.FSBACK, S.FCSALE, S.FCBACK, S.ECTSERIAL
),
CashierNames AS
(
    SELECT
        S.CASHCODE, 
        S.FSHIFT,
        (SELECT TOP 1 A.SNAME 
         FROM silver.acm_payments A 
         WHERE A.CASHCODE = S.CASHCODE AND A.FSHIFT = S.FSHIFT
         ORDER BY CASE WHEN A.CHECKNUM = 1 THEN 0 ELSE 1 END, A.CHECKNUM) AS FIRST_CASHIER,
        (SELECT TOP 1 A.SNAME 
         FROM silver.acm_payments A 
         WHERE A.CASHCODE = S.CASHCODE AND A.FSHIFT = S.FSHIFT
         ORDER BY A.CHECKNUM DESC) AS LAST_CASHIER
    FROM BaseShifts S
),
ShiftVAT AS
(
    SELECT
        A.CASHCODE, A.FSHIFT,
        SUM(CASE WHEN A.VATRATE1 = 10 AND A.OPCODE = 50 THEN A.VATSUM1 ELSE 0 END) AS VAT10,
        SUM(CASE WHEN A.VATRATE1 = 22 AND A.OPCODE = 50 THEN A.VATSUM1 ELSE 0 END) AS VAT22,
        SUM(CASE WHEN A.VATRATE1 = 20 AND A.OPCODE = 50 THEN A.VATSUM1 ELSE 0 END) AS VAT20,
        SUM(CASE WHEN A.VATRATE1 = 5 AND A.OPCODE = 50 THEN A.VATSUM1 ELSE 0 END) AS VAT5,
        SUM(CASE WHEN A.VATRATE1 = 7 AND A.OPCODE = 50 THEN A.VATSUM1 ELSE 0 END) AS VAT7,
        SUM(CASE WHEN A.VATRATE1 = 10 AND A.OPCODE = 58 THEN A.VATSUM1 ELSE 0 END) AS REFVAT10,
        SUM(CASE WHEN A.VATRATE1 = 22 AND A.OPCODE = 58 THEN A.VATSUM1 ELSE 0 END) AS REFVAT22,
        SUM(CASE WHEN A.VATRATE1 = 20 AND A.OPCODE = 58 THEN A.VATSUM1 ELSE 0 END) AS REFVAT20,
        SUM(CASE WHEN A.VATRATE1 = 5 AND A.OPCODE = 58 THEN A.VATSUM1 ELSE 0 END) AS REFVAT5,
        SUM(CASE WHEN A.VATRATE1 = 7 AND A.OPCODE = 58 THEN A.VATSUM1 ELSE 0 END) AS REFVAT7
    FROM silver.act_items A
    INNER JOIN BaseShifts S 
        ON A.CASHCODE = S.CASHCODE AND A.FSHIFT = S.FSHIFT
    GROUP BY A.CASHCODE, A.FSHIFT
)
SELECT DISTINCT
    L.Company AS [COMPANY], 
    L.Location AS [LOCATION],
    O.CASHCODE AS [POS NUMBER], 
    O.ECTSERIAL AS [FM SERIAL], 
    O.Serial AS [FP SERIAL],
    O.FSHIFT AS [FISCAL SHIFT NUMBER],
    CF.FIRST_CASHIER AS [FIRST CASHIER], 
    CL.LAST_CASHIER AS [LAST CASHIER],
    CONVERT(VARCHAR(19), O.DATEBEGIN, 120) AS [SHIFT STARTED AT],
    CONVERT(VARCHAR(19), O.DATEEND, 120) AS [SHIFT ENDED AT],
    CAST(O.FSSALE - O.FSBACK AS DECIMAL(10,2)) AS [REVENUE: TOTAL],
    CAST(O.CASH - O.CASHCHANGE - O.CASHREFUND AS DECIMAL(10,2)) AS [REVENUE: CASH],
    CAST(O.CARDS AS DECIMAL(10,2)) AS  [REVENUE: CARDS],
    ISNULL(CAST((V.VAT22 - V.REFVAT22) AS DECIMAL(10,2)), 0) AS [VAT 22%],
    ISNULL(CAST((V.VAT10 - V.REFVAT10) AS DECIMAL(10,2)), 0) AS [VAT 10%],
    ISNULL(CAST((V.VAT20 - V.REFVAT20) AS DECIMAL(10,2)), 0) AS [VAT 20%],
    ISNULL(CAST((V.VAT5 - V.REFVAT5) AS DECIMAL(10,2)), 0) AS [VAT 5%],
    ISNULL(CAST((V.VAT7 - V.REFVAT7) AS DECIMAL(10,2)), 0) AS [VAT 7%],
    CAST(O.FCSALE AS INT) AS [QTY of SALES],
    CAST(O.FCBACK AS INT) AS [QTY of REFUNDS],
    CAST(O.CASHREFUND AS DECIMAL(10,2)) AS [REFUNDS: CASH],
    CAST(O.CARDREFUND AS DECIMAL(10,2)) AS [REFUNDS: CARDS]  
FROM ShiftOps O
LEFT JOIN ShiftVAT V ON V.CASHCODE = O.CASHCODE AND V.FSHIFT = O.FSHIFT
LEFT JOIN CashierNames CF ON CF.CASHCODE = O.CASHCODE AND CF.FSHIFT = O.FSHIFT
LEFT JOIN CashierNames CL ON CL.CASHCODE = O.CASHCODE AND CL.FSHIFT = O.FSHIFT
LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(O.CASHCODE, 3);
GO
/****** Объект:  View [gold].[v_rep_uin]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_rep_uin] AS

WITH FNSERIAL_CTE AS
(
	SELECT DISTINCT
		CASHCODE,
		MAX(ECTSERIAL) AS ECTSERIAL
	FROM
		silver.acc_receipts
	WHERE 
		ECTSERIAL != ''
	GROUP BY CASHCODE
)

SELECT
	ACT.OP_TYPE AS [OPERATION TYPE],
	ACT.CODE AS [ITEM ID],
	ACT.NAME AS [ITEM NAME],
	UIN.VALUE AS [UIN],
	ACT.SHIFT AS [SHIFT NUMBER],
	ACT.CHECKNUM AS [RECEIPT NUMBER],
	L.Company AS [COMPANY],
	L.Duty AS [DUTY],
	L.Location AS [LOCATION],
	L.StoreName AS [STORE],
	ACT.CASHCODE AS [POS NUMBER],
	ACT.FSERIAL AS [FP SERIAN],
	CTE.ECTSERIAL AS [FM SERIAL],
	ACT.DATE AS [DATE],
	LEFT(ACT.TIME, 8) AS [TIME],
	ACT.PRICE AS [PRICE],
	ACT.SUMB AS [TOTAL]
FROM
	silver.act_items ACT
INNER JOIN silver.ac_dopdata_uin UIN ON UIN.UNIQ = ACT.UNIQ AND UIN.POSITION = ACT.POSITION
LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(ACT.CASHCODE, 3)
INNER JOIN FNSERIAL_CTE CTE ON CTE.CASHCODE = ACT.CASHCODE
GO
/****** Объект:  View [gold].[v_rep_yandex]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_rep_yandex] AS
SELECT
	P.DATE,
	LEFT(P.TIME, 8) AS [TIME],
	CASE WHEN P.OPCODE = 70 THEN N'Продажа'
		 ELSE N'Возврат'
	END AS [TR_TYPE],
	ISNULL(Y.VALUE, N'СБП') AS [PAYMENT_TYPE],
	L.Company,
	L.Duty,
	L.Location,
	L.StoreName,
	P.CHECKNUM,
	P.CASHCODE,
	P.SUMN,
	P.SNAME
FROM
	silver.acm_payments P
LEFT JOIN silver.ac_dopdata_yandex Y ON Y.UNIQ = P.UNIQ
LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(P.CASHCODE, 3)
WHERE
	P.CHR = 'YP'
GO
/****** Объект:  View [gold].[v_statistic_by_locations]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_statistic_by_locations] AS
SELECT
	L.IATA AS [CODE],
	L.CITY AS [CITY],
	COUNT(CASE WHEN I.OPCODE = 50 THEN I.CODE END) AS [QTY: SOLD ITEMS],
	SUM(CASE WHEN I.OPCODE = 50 THEN I.SUMN END) AS [SUM: REVENUE],
	COUNT(DISTINCT CASE WHEN I.OPCODE = 50 THEN I.CHECKNUM END) AS [QTY: SALES],
	COUNT(DISTINCT CASE WHEN I.OPCODE = 58 THEN I.CHECKNUM END) AS [QTY: REFUNDS]
FROM
	silver.operative_ct_items I
LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(I.CASHCODE, 3)
GROUP BY
	L.IATA,
	L.CITY
GO
/****** Объект:  View [gold].[v_statistic_common]    Дата создания скрипта: 12.10.2026 10:12:44 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [gold].[v_statistic_common] AS
SELECT
	COUNT(CASE WHEN I.OPCODE = 50 THEN I.CODE END) AS [QTY: SOLD ITEMS],
	SUM(CASE WHEN I.OPCODE = 50 THEN I.SUMN END) AS [SUM: REVENUE],
	COUNT(DISTINCT CASE WHEN I.OPCODE = 50 THEN I.CHECKNUM END) AS [QTY: SALES],
	COUNT(DISTINCT CASE WHEN I.OPCODE = 58 THEN I.CHECKNUM END) AS [QTY: REFUNDS]
FROM
	silver.operative_ct_items I
GO

