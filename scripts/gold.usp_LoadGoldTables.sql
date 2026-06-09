USE [DataWarehouse]
GO

/****** Объект:  StoredProcedure [silver].[usp_LoadSilverTables]    Дата создания скрипта: 03.06.2026 9:39:19 ******/ 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [gold].[usp_LoadGoldTables]
    AS
    BEGIN
        SET NOCOUNT ON;
/*===================================================================================================*/
        DECLARE @sql NVARCHAR(MAX);
        DECLARE @Yesterday DATE = DATEADD(DAY, -1, GETDATE());
        -- Объявляем параметры для sp_executesql
        DECLARE @Params NVARCHAR(MAX) = N'@YesterdayParam DATE';
/*=============================== rep_cashiers ====================================================================*/
SET @sql = N'
    INSERT INTO [gold].[rep_cashiers] 
        ([COMPANY], [LOCATION], [CASHIER], [QTY], [TOTAL])

   SELECT
	L.COMPANY,
	L.LOCATION,
	I.SNAME,
	COUNT(DISTINCT I.CHECKNUM),
	SUM(I.SUMN)
FROM
	silver.act_items I
LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(I.CASHCODE, 3)
GROUP BY
	I.SNAME, L.COMPANY, L.LOCATION';
EXEC sp_executesql @sql;
/*================================= rep_shifts  ==================================================================*/
SET @sql = N'
;WITH BaseShifts AS
(
	SELECT
		CASHCODE, FSHIFT, DATEBEGIN, DATEEND, FSSALE, FSBACK, FCSALE, FCBACK, ECTSERIAL 
	FROM 
		silver.acs_shifts
	--WHERE CAST(DATEEND AS DATE) = @YesterdayParam -- Используем параметр
),
ShiftOps AS
(
	SELECT
		S.CASHCODE, S.FSHIFT, S.DATEBEGIN, S.DATEEND, S.FSSALE, S.FSBACK, S.FCSALE, S.FCBACK, S.ECTSERIAL,
		SUM(CASE WHEN A.VALCODE = 1 and A.OPCODE = 70 THEN A.SUMN ELSE 0 END) AS [CASH],
		SUM(CASE WHEN A.VALCODE <> 1 and A.OPCODE = 70 THEN A.SUMN ELSE 0 END) AS [CARDS],
		SUM(CASE WHEN A.VALCODE = 1 and A.OPCODE = 72 THEN A.SUMN ELSE 0 END) AS [CASHCHANGE],
		SUM(CASE WHEN A.VALCODE = 1 and A.OPCODE = 74 THEN A.SUMN ELSE 0 END) AS [CASHREFUND],
		SUM(CASE WHEN A.VALCODE <> 1 and A.OPCODE = 74 THEN A.SUMN ELSE 0 END) AS [CARDREFUND],
		MAX(FSERIAL) AS [SERIAL]
	FROM 
		BaseShifts S
	LEFT JOIN silver.acm_payments A ON A.CASHCODE = S.CASHCODE AND A.FSHIFT = S.FSHIFT
	GROUP BY
        S.CASHCODE, S.FSHIFT, S.DATEBEGIN, S.DATEEND, S.FSSALE, S.FSBACK, S.FCSALE, S.FCBACK, S.ECTSERIAL
),
CashierNames AS
(
	SELECT
		A.CASHCODE, A.FSHIFT, A.SNAME,
		ROW_NUMBER() OVER(PARTITION BY A.CASHCODE, A.FSHIFT ORDER BY CASE WHEN A.CHECKNUM = 1 THEN 0 ELSE 1 END, A.CHECKNUM) AS RN_FIRST,
		ROW_NUMBER() OVER(PARTITION BY A.CASHCODE, A.FSHIFT ORDER BY A.CHECKNUM DESC) AS RN_LAST
	FROM 
		silver.acm_payments A
	INNER JOIN BaseShifts S ON A.CASHCODE = S.CASHCODE AND A.FSHIFT = S.FSHIFT
),
ShiftVAT AS
(
	SELECT
		A.CASHCODE, A.FSHIFT,
		SUM(CASE WHEN A.VATRATE1 = 10 AND A.OPCODE = 50 THEN A.VATSUM1 ELSE 0 END) AS VAT10,
		SUM(CASE WHEN A.VATRATE1 = 22 AND A.OPCODE = 50 THEN A.VATSUM1 ELSE 0 END) AS VAT22,
		SUM(CASE WHEN A.VATRATE1 = 20 AND A.OPCODE = 50 THEN A.VATSUM1 ELSE 0 END) AS VAT20,
		SUM(CASE WHEN A.VATRATE1 = 5 AND  A.OPCODE = 50 THEN A.VATSUM1 ELSE 0 END) AS VAT5,
		SUM(CASE WHEN A.VATRATE1 = 7 AND  A.OPCODE = 50 THEN A.VATSUM1 ELSE 0 END) AS VAT7,
		SUM(CASE WHEN A.VATRATE1 = 10 AND A.OPCODE = 58 THEN A.VATSUM1 ELSE 0 END) AS REFVAT10,
		SUM(CASE WHEN A.VATRATE1 = 22 AND A.OPCODE = 58 THEN A.VATSUM1 ELSE 0 END) AS REFVAT22,
		SUM(CASE WHEN A.VATRATE1 = 20 AND A.OPCODE = 58 THEN A.VATSUM1 ELSE 0 END) AS REFVAT20,
		SUM(CASE WHEN A.VATRATE1 = 5 AND  A.OPCODE = 58 THEN A.VATSUM1 ELSE 0 END) AS REFVAT5,
		SUM(CASE WHEN A.VATRATE1 = 7 AND  A.OPCODE = 58 THEN A.VATSUM1 ELSE 0 END) AS REFVAT7
	FROM 
		silver.act_items A
	INNER JOIN BaseShifts S ON A.CASHCODE = S.CASHCODE AND A.FSHIFT = S.FSHIFT
	GROUP BY
		A.CASHCODE, A.FSHIFT
)
INSERT INTO gold.rep_shifts 
([DUTY],[COMPANY],[LOCATION],[CASHCODE],[SERIAL_NUMBER],[FISCALSHIFT_NUMBER],[FIRST_CASHIER],[LAST_CASHIER],[SHIFT_STARTED],[SHIFT_ENDED]
  ,[REVENUE],[CASH_REVENUE],[CARD_REVENUE],[VAT22],[VAT10],[VAT20],[VAT5],[VAT7],[SALES_QTY],[REFUNDs_QTY],[CASH_REFUND],[CARD_REFUND],[FR_NUMBER])
SELECT
	L.Duty,
	L.Company,
	L.Location,
	O.CASHCODE,
	O.ECTSERIAL,
	O.FSHIFT,
	CF.SNAME,
	CL.SNAME,
	CONVERT(VARCHAR(19), O.DATEBEGIN, 120) AS DATEBEGIN,
	CONVERT(VARCHAR(19), O.DATEEND, 120) AS DATEEND,
	CAST(O.FSSALE - O.FSBACK AS DECIMAL(10,2)) AS Revenue,
	CAST(O.CASH - O.CASHCHANGE - O.CASHREFUND AS DECIMAL(10,2)) AS CashRevenue,
    CAST(O.CARDS AS DECIMAL(10,2)) AS CardRevenue,
    ISNULL(CAST((V.VAT22 - V.REFVAT22) AS DECIMAL(10,2)), 0) AS VAT22,
    ISNULL(CAST((V.VAT10 - V.REFVAT10) AS DECIMAL(10,2)), 0) AS VAT10,
    ISNULL(CAST((V.VAT20 - V.REFVAT20) AS DECIMAL(10,2)), 0) AS VAT20,
    ISNULL(CAST((V.VAT5 - V.REFVAT5) AS DECIMAL(10,2)), 0) AS VAT5,
    ISNULL(CAST((V.VAT7 - V.REFVAT7) AS DECIMAL(10,2)), 0) AS VAT7,
    CAST(O.FCSALE AS INT) AS Sales_Qty,
    CAST(O.FCBACK AS INT) AS Refund_Qty,
    CAST(O.CASHREFUND AS DECIMAL(10,2)) AS CashRefund,
    CAST(O.CARDREFUND AS DECIMAL(10,2)) AS CardRefund,
    O.Serial
FROM
	ShiftOps O
LEFT JOIN ShiftVAT V ON V.CASHCODE = O.CASHCODE AND V.FSHIFT  = O.FSHIFT
LEFT JOIN CashierNames CF ON CF.CASHCODE = O.CASHCODE AND CF.FSHIFT  = O.FSHIFT AND CF.RN_FIRST = 1
LEFT JOIN CashierNames CL ON CL.CASHCODE = O.CASHCODE AND CL.FSHIFT  = O.FSHIFT AND CL.RN_LAST = 1
LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(O.CASHCODE, 3)';
EXEC sp_executesql @sql --, @Params, @YesterdayParam = @Yesterday;
/*================================ rep_yandex ===================================================================*/
SET @sql = N'
INSERT INTO [gold].[rep_yandex]
([DATE],[TIME],[TR_TYPE],[PAYMENT_TYPE],[COMPANY],[DUTY],[LOCATION],[STORE],[CHECKNUM],[CASHCODE],[TOTAL],[CASHIER])

SELECT
	P.DATE,
	LEFT(P.TIME, 8) AS [TIME],
	CASE WHEN P.OPCODE = 70 THEN N''Продажа''
		 ELSE N''Возврат''
	END AS [TR_TYPE],
	ISNULL(Y.VALUE, N''СБП'') AS [PAYMENT_TYPE],
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
	P.CHR = ''YP'' AND CAST(P.DATE AS DATE) = @YesterdayParam';
	EXEC sp_executesql @sql, @Params, @YesterdayParam = @Yesterday;

/*=============================== dash_yandex ====================================================================*/
SET @sql = N'
;WITH main AS
(
SELECT 
    YEAR(M.DATE) as [YEAR],
    DATENAME(Q, M.DATE) as [QUARTER],
    DATENAME(M, M.DATE) as [MONTH],
    DATEPART(iso_week, M.DATE) as [WEEK],
    M.*, 
    ISNULL(Y.VALUE, N''СБП'') AS [VALUE] 
FROM 
    silver.acm_payments M
LEFT JOIN silver.ac_dopdata_yandex Y on Y.UNIQ = M.UNIQ
WHERE 
    CHR = ''yp''
)
INSERT INTO [gold].[dash_yandex]
    (
        [LOCATION],[YEAR],[QUARTER],[MONTH],[WEEK],[SALES],[REFUNDS],[QTY_SALES],[QTY_REFUNDS],[SALES_SPLIT],[REFUNDS_SPLIT],[QTY_SALES_SPLIT],[QTY_REFUNDS_SPLIT]
        ,[REVENUE],[QTY_REVENUE],[REVENUE_SPLIT],[QTY_REVENUE_SPLIT],[SPLIT_COMM],[FSP_COMM]
    )
SELECT 
    L.[Location],
    [YEAR],
    [QUARTER],
    [MONTH],
    [WEEK],
    ISNULL(SUM(CASE WHEN OPCODE = 70 THEN SUMN END), 0) AS [SALES],
    ISNULL(SUM(CASE WHEN OPCODE = 74 THEN SUMN END), 0) AS [REFUNDS],
    ISNULL(SUM(CASE WHEN OPCODE = 70 THEN 1 END), 0) AS [QTY_SALES],
    ISNULL(SUM(CASE WHEN OPCODE = 74 THEN 1 END), 0) AS [QTY_REFUNDS],
    ISNULL(SUM(CASE WHEN OPCODE = 70 AND VALUE = N''ЯНДЕКС СПЛИТ''THEN SUMN END), 0) AS [SALES SPLIT],
    ISNULL(SUM(CASE WHEN OPCODE = 74 AND VALUE = N''ЯНДЕКС СПЛИТ'' THEN SUMN END), 0) AS [REFUNDS SPLIT],
    ISNULL(SUM(CASE WHEN OPCODE = 70 AND VALUE = N''ЯНДЕКС СПЛИТ'' THEN 1 END), 0) AS [QTY SALES SPLIT],
    ISNULL(SUM(CASE WHEN OPCODE = 74 AND VALUE = N''ЯНДЕКС СПЛИТ'' THEN 1 END), 0) AS [QTY REFUNDS SPLIT],
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
                    WHEN OPCODE = 70 AND VALUE = N''ЯНДЕКС СПЛИТ'' THEN SUMN
                    WHEN OPCODE = 74 AND VALUE = N''ЯНДЕКС СПЛИТ''  THEN -SUMN 
                    ELSE 0 
               END), 0) AS [REVENUE_SPLIT],
    ISNULL(SUM(CASE 
                    WHEN OPCODE = 70 AND VALUE = N''ЯНДЕКС СПЛИТ'' THEN 1 
                    WHEN OPCODE = 74 AND VALUE = N''ЯНДЕКС СПЛИТ'' THEN -1 
                    ELSE 0 
               END), 0) AS [QTY_REVENUE_SPLIT],

    ISNULL(CAST(SUM(CASE WHEN VALUE = N''ЯНДЕКС СПЛИТ'' AND OPCODE = 70 THEN SUMN * 0.043 END) AS decimal(10,2)), 0) AS [SPLIT COMMISSION],
    ISNULL(CAST(SUM(CASE WHEN VALUE = N''СБП'' AND OPCODE = 70 THEN SUMN * 0.004 END) AS decimal(10,2)), 0) AS [FSP COMMISSION]
FROM 
    main M
LEFT JOIN bronze.ref_locations L on L.StoreCode = LEFT(M.CASHCODE, 3)
GROUP BY
    L.[Location], [YEAR],[QUARTER],[MONTH],[WEEK]';
    EXEC sp_executesql @sql;
/*============================== rep_discounts =====================================================================*/
SET @sql = N'
;WITH BaseData AS
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
        ACT.POSITION,
        (CASE WHEN PN.DATA = ''PROMODISC'' THEN PN.VALUE END) AS PromoDiscNumber
    FROM 
        silver.act_items ACT
    LEFT JOIN silver.ac_dopdata_promonumber PN ON PN.UNIQ = ACT.UNIQ AND PN.POSITION = ACT.POSITION
    WHERE
        (ACT.DISC_ABS > 0 OR ACT.DISC_PERC > 0) AND ACT.NAME NOT LIKE ''%Товар упакован в cейф-пакет%''
),
PromoNames AS
(
    SELECT
        BD.*,
        RPI.Description
    FROM 
        BaseData BD
    LEFT JOIN silver.ref_promoid RPI ON RPI.PROMOID = BD.PromoDiscNumber AND RPI.FLAG = CASE 
                                                                                    WHEN BD.CASHCODE LIKE ''1%'' THEN ''RUDP''
                                                                                    WHEN BD.CASHCODE LIKE ''28%'' THEN ''KZDF'' 
                                                                                    ELSE ''RUDF''
                                                                                  END
),
AvoltaClub AS
(
    SELECT
        PN.*,
        MAX(CASE WHEN AC.DATA = ''NDISC'' AND PN.Description LIKE ''%Avolta%'' THEN AC.VALUE ELSE N''-'' END) AS [AVOLTA_LEVEL],
        MAX(CASE WHEN AC.DATA = ''LCUSID'' AND PN.Description LIKE ''%Avolta%'' THEN AC.VALUE ELSE N''-'' END) AS [AVOLTA_ID]
    FROM
        PromoNames PN
    LEFT JOIN silver.ac_dopdata_avoltaclub AC ON AC.UNIQ = PN.UNIQ AND AC.CASHCODE = PN.CASHCODE AND AC.CHECKNUM = PN.CHECKNUM
    WHERE
        PN.Description <> ''Скидка на сейф-пакет''
    GROUP BY
        PN.UNIQ,
        PN.CASHCODE,
        PN.SName,
        PN.CHECKNUM,
        PN.SHIFT,
        PN.DATE,
        PN.[TIME],
        PN.NAME,
        PN.CODE,
        PN.BQUANT,
        PN.PRICE,
        PN.SUMI,
        PN.DISC_ABS,
        PN.DISC_PERC,
        PN.SUMN,
        PN.POSITION,
        PN.Description,
        PN.PromoDiscNumber
),
Coupons AS
(
    SELECT
        AC.*,
        MAX(CASE WHEN C.VALUE = ''741123369986'' THEN N''Сотрудники и Экипаж 20%''
                 WHEN C.VALUE = ''741123369987'' THEN N''Руководители подразделений 25%''
                 WHEN C.VALUE = ''741123369988'' THEN N''Руководители структур 30%''
                 WHEN C.VALUE = ''741123369989'' THEN N''Акционеры и партнёры 50%''
                 WHEN C.VALUE = ''0242'' THEN N''VIP 15% VKO DP''
                 WHEN C.VALUE = ''10999'' THEN N''VIP АэроРегион 15%''
                 WHEN C.VALUE = ''741123369990'' THEN N''Предзаказ 10%''
                 WHEN C.VALUE = ''0241'' THEN N''Регстаэр ВИП 15% VKO Pilot Shop''
                 WHEN C.VALUE = ''6051'' THEN N''Регстаэр ВИП 20%''
                 WHEN C.VALUE = ''0217'' THEN N''Регстаэр ВИП 25% VKO Pilot Shop''
                 WHEN C.VALUE = ''6054'' THEN N''Регстаэр ВИП 30%''
                 WHEN C.VALUE IN (''150200'',''150300'',''150333'',''150400'',''150222'') THEN N''Регстаэр ВИП 50% VKO T3''
                 ELSE ''-'' END) AS [DISCOUNT_CARDS],
        MAX(CASE WHEN C.VALUE LIKE ''999%'' THEN C.VALUE ELSE N''-'' END) AS [VIP_VOUCHER],
        MAX(CASE WHEN C.VALUE LIKE ''FANDS%'' THEN N''FUN AND SUN'' ELSE N''-'' END) AS [PARTNER_VOUCHER]

    FROM
        AvoltaClub AC
    LEFT JOIN silver.ac_dopdata_coupons C ON C.POS_NUMBER = AC.CASHCODE AND C.RECEIPT_NUMBER = AC.CHECKNUM AND C.UNIQ = AC.UNIQ
    GROUP BY
        AC.UNIQ,
        AC.CASHCODE,
        AC.SName,
        AC.CHECKNUM,
        AC.SHIFT,
        AC.DATE,
        AC.[TIME],
        AC.NAME,
        AC.CODE,
        AC.BQUANT,
        AC.PRICE,
        AC.SUMI,
        AC.DISC_ABS,
        AC.DISC_PERC,
        AC.SUMN,
        AC.POSITION,
        AC.Description,
        AC.PromoDiscNumber,
        AC.AVOLTA_LEVEL,
        AC.AVOLTA_ID
)
INSERT INTO [gold].[rep_discounts]
(
    [COMPANY],[DUTY],[LOCATION],[STORE],[CASHCODE],[CASHIER],[DISCOUNT_CARD],[CHECKNUM],[DATE],[TIME]
      ,[ITEM_NAME],[ITEM_CODE],[QUANTITY],[ITEM_PRICE],[PRICE_AFTER_DISCOUNT],[DISCOUNT_AMOUNT],[TOTAL_IN_NATIONAL],[PROMO_NAME]
      ,[AVOLTA_LEVEL],[AVOLTA_ID],[VIP_VOUCHER_CODE],[PARTNER_VOUCHER_CODE]
)
SELECT
    L.Company,
    L.Duty,
    L.Location,
    L.StoreName,
    C.CASHCODE,
    C.SName,
    C.DISCOUNT_CARDS,
    C.CHECKNUM,
    C.DATE,
    C.TIME,
    C.NAME,
    C.CODE,
    C.BQUANT,
    C.PRICE,
    C.SUMI,
    C.DISC_ABS,
    C.SUMN,
    C.Description,
    C.AVOLTA_LEVEL,
    C.AVOLTA_ID,
    C.VIP_VOUCHER,
    C.PARTNER_VOUCHER
FROM
    Coupons C
LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(C.CASHCODE, 3)
WHERE
    CAST(C.DATE AS DATE) = @YesterdayParam';
    EXEC sp_executesql @sql;
/*================================= dash_discounts ==================================================================*/
SET @sql = N'
;WITH ExchangeRates AS
(
	SELECT
	DATE,
	MAX(CASE WHEN VALCODE = 3 THEN NRATE ELSE 1 END) AS NRATE_EUR,
	MAX(CASE WHEN VALCODE = 5 THEN NRATE ELSE 1 END) AS NRATE_RUB,
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
		L.Duty,
		L.Location,
		L.StoreName,
		ACT.SERVER,
		ACT.DATE,
		SUM(ACT.PRICE) AS [PRICE],
		SUM(ACT.DISC_ABS) AS [DISCOUNT],
		SUM(ACT.SUMB) AS [TOTAL]
	FROM
		silver.act_items ACT
	LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(ACT.CASHCODE, 3)
	WHERE
		(ACT.DISC_ABS > 0 OR ACT.DISC_PERC > 0)
	GROUP BY
		L.Company,
		L.Duty,
		L.Location,
		L.StoreName,
		ACT.SERVER,
		ACT.DATE
)
INSERT INTO [gold].[dash_discounts]
(
	[YEAR],[QUARTER],[MONTH],[WEEK],[COMPANY],[DUTY],[LOCATION],[STORE],[DATE],[PRICE RUB]
      ,[DISCOUNT RUB],[TOTAL RUB]
)
SELECT
	YEAR(BD.DATE) as [YEAR],
    DATENAME(Q, BD.DATE) as [QUARTER],
    DATENAME(M, BD.DATE) as [MONTH],
    DATEPART(iso_week, BD.DATE) as [WEEK],
	BD.Company,
	BD.Duty,
	BD.Location,
	BD.StoreName,
	BD.DATE,
	CASE WHEN BD.SERVER = ''DC1-SRV-KC01'' THEN (BD.PRICE * ER.NRATE_EUR) 
		 WHEN BD.SERVER = ''DC1-SRV-KC03'' THEN ((BD.PRICE * ER.NRATE_EUR) / ER.NRATE_RUB)  
		 ELSE BD.PRICE END AS [PRICE RUB],
	CASE WHEN BD.SERVER = ''DC1-SRV-KC01'' THEN (BD.DISCOUNT * ER.NRATE_EUR) 
		 WHEN BD.SERVER = ''DC1-SRV-KC03'' THEN ((BD.DISCOUNT * ER.NRATE_EUR) / ER.NRATE_RUB) 
		 ELSE BD.DISCOUNT END AS [DISCOUNT RUB],
	CASE WHEN BD.SERVER = ''DC1-SRV-KC01'' THEN (BD.TOTAL * ER.NRATE_EUR) 
		 WHEN BD.SERVER = ''DC1-SRV-KC03'' THEN ((BD.TOTAL * ER.NRATE_EUR) / ER.NRATE_RUB) 
		 ELSE BD.TOTAL END AS [TOTAL RUB]

FROM
	BaseData BD
LEFT JOIN ExchangeRates ER ON ER.DATE = BD.DATE and ER.SERVER = BD.SERVER';
EXEC sp_executesql @sql;

END
GO



