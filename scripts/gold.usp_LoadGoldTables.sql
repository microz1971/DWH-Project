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
/*===================================================================================================*/
SET @sql = N'
    INSERT INTO [gold].[rep_cashiers] 
        ([COMPANY], [LOCATION], [CASHIER], [QTY], [TOTAL])

    SELECT 
       L.COMPANY,
       L.LOCATION,
       I.SNAME,
       COUNT(DISTINCT I.CHECKNUM),
       SUM(I.SUMN)
    FROM [DataWarehouse].[bronze].[pos_ac_dopdata]';
EXEC sp_executesql @sql;
/*===================================================================================================*/
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
/*===================================================================================================*/
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
	P.CHR = ''YP'' --AND CAST(P.DATE AS DATE) = @YesterdayParam';
	EXEC sp_executesql @sql--, @Params, @YesterdayParam = @Yesterday;

/*===================================================================================================*/
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
/*===================================================================================================*/
END
GO



