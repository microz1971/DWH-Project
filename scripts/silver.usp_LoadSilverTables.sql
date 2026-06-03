USE DataWarehouse;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [silver].[usp_LoadSilverTables]
    AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @sql NVARCHAR(MAX);

SET @sql = N'
    INSERT INTO silver.ac_dopdata_yandex 
    ([UNIQ],[DATE],[CHECKNUM],[CASHCODE],[SHIFT],[VALUE],[SERVER])

    SELECT [UNIQ]
         ,CAST([DATE] AS date) as [DATE]
         ,[CHECKNUM]
         ,[CASHCODE]
         ,[SHIFT]
         ,CASE WHEN [VALUE] IN (''SBP'', ''UNIQR_REUSABLE'') THEN N''СБП''
               WHEN [VALUE] = ''SPLIT'' THEN N''ЯНДЕКС СПЛИТ''
               ELSE N''н/а''
        END AS [VALUE],
        CASE WHEN CASHCODE like ''1%'' THEN ''DC1-SRV-KC02''
             WHEN CASHCODE like ''28%'' THEN ''DC1-SRV-KC03''
             ELSE ''DC1-SRV-KC01''
            END AS [SERVER]
    FROM [DataWarehouse].[bronze].[pos_ac_dopdata]';
EXEC sp_executesql @sql;


SET @sql = N'
    INSERT INTO silver.aca_fiscaldata
    ([UNIQ],[CASHCODE],[CHECKNUM],[DATE],[TIME],[FSum],[FSign],[FNFD],[FSHIFT],[FNum],[FNSERIAL],[SERVER])

    SELECT
        [UNIQ]
         ,[CASHCODE]
         ,[CHECKNUM]
         ,CAST([DATE] as date) as [DATE]
         ,CAST([TIME] as time) as [TIME]
         ,[FSum]
         ,[FSign]
         ,[FNFD]
         ,[FSHIFT]
         ,[FNum]
         ,[FNSERIAL]
         ,CASE WHEN CASHCODE like ''1%'' THEN ''DC1-SRV-KC02''
               WHEN CASHCODE like ''28%'' THEN ''DC1-SRV-KC03''
               ELSE ''DC1-SRV-KC01''
        END AS [SERVER]
    FROM [DataWarehouse].[bronze].[pos_aca_fiscaldata]';
EXEC sp_executesql @sql;

SET @sql = N'
    INSERT INTO [silver].[acc_receipts]
    ([UNIQ],[TR_TYPE],[CHECKNUM],[SCODE],[CASHCODE],[SHIFT],[FSHIFT],[FSERIAL],[ECTSERIAL],[ECTCHECK]
    ,[DATE_BEG],[TIME_BEG],[DATE_END],[TIME_END],[VBRATE],[VERATE],[DISC_PERC],[DISC_ABS],[SUMB]
    ,[SUMN],[SUME],[PayType],[SERVER]
    )
    SELECT [UNIQ]
         ,CASE WHEN SUMN > 0 THEN N''Продажа''
               ELSE N''Возврат''
        END AS [TR_TYPE]
         ,[CHECKNUM]
         ,[SCODE]
         ,[CASHCODE]
         ,[SHIFT]
         ,[FSHIFT]
         ,[FSERIAL]
         ,[ECTSERIAL]
         ,[ECTCHECK]
         ,CAST([DATE_BEG] as date) as [DATE_BEG]
         ,CAST([TIME_BEG] as time) as [TIME_BEG]
         ,CAST([DATE_END] as date) as [DATE_END]
         ,CAST([TIME_END] as time) as [TIME_END]
         ,CAST([VBRATE] as decimal(10,2)) as [VBRATE]
         ,CAST([VERATE] as decimal(10,2)) as [VERATE]
         ,[DISC_PERC]
         ,[DISC_ABS]
         ,[SUMB]
         ,[SUMN]
         ,[SUME]
         ,CASE WHEN [PayType] = 0 THEN N''Наличные''
               WHEN [PayType] = 1 THEN N''Безналичный расчёт''
               ELSE N''Возврат''
        END AS [PayType]
         ,CASE WHEN CASHCODE like ''1%'' THEN ''DC1-SRV-KC02''
               WHEN CASHCODE like ''28%'' THEN ''DC1-SRV-KC03''
               ELSE ''DC1-SRV-KC01''
        END AS [SERVER]
    FROM [DataWarehouse].[bronze].[pos_acc_receipts]
    WHERE (SUMN > 0 AND PayType IS NOT NULL) OR SUMN < 0';
EXEC sp_executesql @sql;

SET @sql = N'
    INSERT INTO [silver].[acl_logins]
    ([UNIQ],[CASHCODE],[SHIFT],[SCODE],[SNAME],[OPCODE],[OPDATE],[SERVER])

    SELECT [UNIQ]
         ,[CASHCODE]
         ,[SHIFT]
         ,[SCODE]
         ,[SNAME]
         ,CASE WHEN [OPCODE] = 1 THEN N''Открытие кассы''
               WHEN [OPCODE] = 2 THEN N''Выход из кассы''
        END AS [OPCODE]
         ,[OPDATE]
         ,CASE WHEN CASHCODE like ''1%'' THEN ''DC1-SRV-KC02''
               WHEN CASHCODE like ''28%'' THEN ''DC1-SRV-KC03''
               ELSE ''DC1-SRV-KC01''
        END AS [SERVER]
    FROM [DataWarehouse].[bronze].[pos_acl_logins]';
EXEC sp_executesql @sql;

SET @sql = N'
    INSERT INTO [silver].[acm_payments]
    ([UNIQ],[CHECKNUM],[CASHCODE],[SHIFT],[FSHIFT],[FSERIAL],[DATE],[TIME],[OPCODE],[OP_TYPE]
    ,[VALCODE],[VC_TYPE],[VALTYPE],[VT_TYPE],[NRATE],[VSUM],[SUMB],[SUMN],[SUME],[CHR]
    ,[POSITION],[SERVER]
    )

    SELECT [UNIQ]
         ,[CHECKNUM]
         ,[CASHCODE]
         ,[SHIFT]
         ,[FSHIFT]
         ,[FSERIAL]
         ,CAST([DATE] as date) as [DATE]
         ,CAST([TIME] as time) as [TIME]
         ,[OPCODE]
         ,CASE WHEN [OPCODE] = 70 THEN N''Принять деньги при продаже''
               WHEN [OPCODE] = 72 THEN N''Выдать сдачу при продаже''
               WHEN [OPCODE] = 74 THEN N''Выдать деньги при возврате''
               WHEN [OPCODE] = 76 THEN N''Принять сдачу при возврате''
               WHEN [OPCODE] = 80 THEN N''Внесение денег в кассу''
               WHEN [OPCODE] = 82 THEN N''Выем денег''
        END AS [OP_TYPE]
         ,[VALCODE]
         ,CASE WHEN [VALCODE] = 1 AND [CASHCODE] NOT LIKE ''28%'' THEN N''Российский рубль''
               WHEN [VALCODE] = 1 AND [CASHCODE] LIKE ''28%'' THEN N''Тенге''
               WHEN [VALCODE] = 2 THEN N''Доллар США''
               WHEN [VALCODE] = 3 THEN N''Евро''
               WHEN [VALCODE] = 4 THEN N''Китайский Юань''
               WHEN [VALCODE] = 5 AND [CASHCODE] LIKE ''28%'' THEN N''Российский рубль''
               WHEN [VALCODE] = 10 THEN N''БанкКарты (Online)''
               WHEN [VALCODE] = 20 THEN N''БанкКарты (автономный)''
               WHEN [VALCODE] = 21 THEN N''Безнал (автономный) евро''
               WHEN [VALCODE] = 22 THEN N''Безнал (автономный) доллар США''
               WHEN [VALCODE] = 30 THEN N''Система быстрых платежей QR''
               WHEN [VALCODE] = 31 THEN N''СБП Оффлайн''
               WHEN [VALCODE] = 32 THEN N''Яндекс Пэй''
        END AS [VC_TYPE]
         ,[VALTYPE]
         ,CASE WHEN [VALTYPE] = 1 THEN N''Наличные''
               WHEN [VALTYPE] = 2 THEN N''Карты''
               WHEN [VALTYPE] = 3 THEN N''QR''
        END AS [VT_TYPE]
         ,CAST([NRATE] as decimal(10,2)) as [NRATE]
         ,[VSUM]
         ,[SUMB]
         ,[SUMN]
         ,[SUME]
         ,[CHR]
         ,[POSITION]
         ,CASE WHEN CASHCODE like ''1%'' THEN ''DC1-SRV-KC02''
               WHEN CASHCODE like ''28%'' THEN ''DC1-SRV-KC03''
               ELSE ''DC1-SRV-KC01''
        END AS [SERVER]
         ,[SNAME]
    FROM [DataWarehouse].[bronze].[pos_acm_payments]
    WHERE [OPCODE] IN (''72'',''76'',''82'',''80'',''70'',''74'')';
EXEC sp_executesql @sql;

SET @sql = N'
    INSERT INTO [silver].[acs_shifts]
    (
      [UNIQ],[CASHCODE],[STOREID],[SHIFT],[SCODE],[DATEBEGIN],[TIMEBEGIN],[DT_BEG],[DATEEND],[TIMEEND],[DT_END]
    ,[CHECKNUM1],[RECEIPTS_QTY],[FSHIFT],[FSERIAL],[ECTSERIAL],[RSSALE],[RSBACK],[RSMIN],[RSMOUT],[RCSALE]
    ,[RCBACK],[RCMIN],[RCMOUT],[FSSALE],[FSBACK],[FSMIN],[FSMOUT],[FCSALE],[FCBACK],[FCMIN]
    ,[FCMOUT],[FTOTAL],[CLOSESHIFT],[CCSALE],[CTSALE],[CMSALE],[SERVER]
    )

    SELECT [UNIQ]
         ,[CASHCODE],[STOREID],[SHIFT],[SCODE]
         ,CAST([DB] AS DATE) AS [DB]
         ,CAST([TB] AS TIME) AS [TB]
         ,[DT_BEG]
         ,CAST([DE] AS DATE) AS [DE]
         ,CAST([TE] AS TIME) AS [TE]
         ,[DT_END],[CHECKNUM1],[CHECKNUM2],[FSHIFT],[FSERIAL],[ECTSERIAL],[RSSALE]
         ,[RSBACK],[RSMIN],[RSMOUT],[RCSALE],[RCBACK],[RCMIN],[RCMOUT],[FSSALE]
         ,[FSBACK],[FSMIN],[FSMOUT],[FCSALE],[FCBACK],[FCMIN],[FCMOUT],[FTOTAL]
         ,[CLOSESHIFT],[CCSALE],[CTSALE],[CMSALE]
         ,CASE WHEN CASHCODE like ''1%'' THEN ''DC1-SRV-KC02''
               WHEN CASHCODE like ''28%'' THEN ''DC1-SRV-KC03''
               ELSE ''DC1-SRV-KC01''
        END AS [SERVER]
    FROM [DataWarehouse].[bronze].[pos_acs_shifts]
    WHERE CHECKNUM1 != 0';
EXEC sp_executesql @sql;

SET @sql = N'
INSERT INTO [silver].[act_items]
(
  [UNIQ],[CHECKNUM],[SCODE],[SName],[CASHCODE],[SHIFT],[FSHIFT],[FSERIAL],[DATE],[TIME]
,[OPCODE],[OP_TYPE],[PriceTypeName],[BCODE],[NAME],[BQUANT],[CODE],[PRICE],[DISC_PERC],[DISC_ABS]
,[SUMI],[SUMB],[SUMN],[SUME],[VATRATE1],[VATSUM1],[POSITION],[SERVER]
)

SELECT [UNIQ]
     ,[CHECKNUM],[SCODE],[SName],[CASHCODE],[SHIFT],[FSHIFT],[FSERIAL]
     ,CAST([DATE] AS DATE) AS [DATE]
     ,CAST([TIME] AS TIME) AS [TIME]
     ,[OPCODE]
     ,CASE WHEN [OPCODE] = 50 THEN N''Продажа''
           WHEN [OPCODE] = 58 THEN N''Возврат''
    END AS [OP_TYPE]
     ,[PriceTypeName],[BCODE],[NAME]
     ,CAST([BQUANT] AS INT) AS [BQUANT]
     ,[CODE],[PRICE],[DISC_PERC],[DISC_ABS]
     ,[SUMI],[SUMB],[SUMN],[SUME]
     ,[VATRATE1],[VATSUM1]
     ,[POSITION]
     ,CASE WHEN CASHCODE like ''1%'' THEN ''DC1-SRV-KC02''
           WHEN CASHCODE like ''28%'' THEN ''DC1-SRV-KC03''
           ELSE ''DC1-SRV-KC01''
    END AS [SERVER]
FROM [DataWarehouse].[bronze].[pos_act_items]';
EXEC sp_executesql @sql;

SET @sql = N'
INSERT INTO [silver].[ac_dopdata_coupons]
(
    [UNIQ],[DATE],[RECEIPT_NUMBER],[POS_NUMBER],[SHIFT_NUMBER],[VALUE],[SERVER]
)

SELECT [UNIQ]
     ,CAST([DATE] AS DATE) AS [DATE]
     ,[RECEIPT_NUMBER]
     ,[POS_NUMBER]
     ,[SHIFT_NUMBER]
     ,CASE
          WHEN [VALUE] LIKE ''CN/%'' THEN
              SUBSTRING([VALUE], 4, CHARINDEX(''/'', [VALUE], 4) - 4)
          WHEN [VALUE] LIKE ''DC/%'' THEN
              SUBSTRING([VALUE], 4, CHARINDEX(''/'', [VALUE], 4) - 4)
          WHEN [VALUE] LIKE ''SB/%'' THEN
              SUBSTRING([VALUE], 4, CHARINDEX(''/'', [VALUE], 4) - 4)
          ELSE [VALUE]
    END AS [VALUE]
     ,CASE WHEN [POS_NUMBER] like ''1%'' THEN ''DC1-SRV-KC02''
           WHEN [POS_NUMBER] like ''28%'' THEN ''DC1-SRV-KC03''
           ELSE ''DC1-SRV-KC01''
    END AS [SERVER]
FROM [DataWarehouse].[bronze].[pos_coupons_data]';
EXEC sp_executesql @sql;

SET @sql = N'
INSERT INTO [silver].[ac_dopdata_avoltaclub]
([UNIQ],[DATE],[CHECKNUM],[CASHCODE],[SHIFT],[DATA],[TYPE],[VALUE],[SERVER])

SELECT [UNIQ]
     ,CAST([DATE] AS DATE) AS [DATE]
     ,[CHECKNUM]
     ,[CASHCODE]
     ,[SHIFT]
     ,[DATA]
     ,CASE WHEN [DATA]=''LCUSID'' THEN N''Номер Клиента''
           WHEN [DATA]=''NDISC'' THEN N''Уровень Карты''
    END AS [TYPE]
     ,[VALUE]
     ,CASE WHEN [CASHCODE] like ''1%'' THEN ''DC1-SRV-KC02''
           WHEN [CASHCODE] like ''28%'' THEN ''DC1-SRV-KC03''
           ELSE ''DC1-SRV-KC01''
    END AS [SERVER]
FROM [DataWarehouse].[bronze].[pos_avoltaclub_data]';
EXEC sp_executesql @sql;

SET @sql = N'
INSERT INTO [silver].[ac_dopdata_creditcard]
(
    [UNIQ],[DATE],[RECEIPT_NUMBER],[NUMBER],[SHIFT_NUMBER],[DATA],[VALUE],[TYPE],[SERVER]
)

SELECT [UNIQ]
     ,CAST([DATE] AS DATE) AS [DATE]
     ,[RECEIPT_NUMBER]
     ,[POS_NUMBER]
     ,[SHIFT_NUMBER]
     ,[DATA]
     ,CASE WHEN [DATA]=''CARDNO'' THEN N''Номер карты''
           WHEN [DATA]=''CARDTYPE'' THEN N''Тип карты''
    END AS [TYPE]
     ,[VALUE]
     ,CASE WHEN [POS_NUMBER] like ''1%'' THEN ''DC1-SRV-KC02''
           WHEN [POS_NUMBER] like ''28%'' THEN ''DC1-SRV-KC03''
           ELSE ''DC1-SRV-KC01''
    END AS [SERVER]
FROM [DataWarehouse].[bronze].[pos_creditcard_data]';
EXEC sp_executesql @sql;

SET @sql = N'
INSERT INTO [silver].[ac_dopdata_pax]
(
    [UNIQ],[DATE],[RECEIPT_NUMBER],[NUMBER],[SHIFT_NUMBER],[DATA],[TYPE],[VALUE],[SERVER]
)

SELECT [UNIQ]
     ,CAST([DATE] AS DATE) AS [DATE]
     ,[RECEIPT_NUMBER]
     ,[POS_NUMBER]
     ,[SHIFT_NUMBER]
     ,[DATA]
     ,CASE WHEN [DATA]=''DP'' THEN N''Аэропорт вылета''
           WHEN [DATA]=''DS'' THEN N''Аэропорт назначения''
           WHEN [DATA]=''FL'' THEN N''Рейс''
           WHEN [DATA]=''NAM'' THEN N''Имя пассажира''
           WHEN [DATA]=''NPT'' THEN N''Номер посадочного талона''
           WHEN [DATA]=''NST'' THEN N''Место''
    END AS [TYPE]
     ,[VALUE]
     ,CASE WHEN [POS_NUMBER] like ''1%'' THEN ''DC1-SRV-KC02''
           WHEN [POS_NUMBER] like ''28%'' THEN ''DC1-SRV-KC03''
           ELSE ''DC1-SRV-KC01''
    END AS [SERVER]
FROM [DataWarehouse].[bronze].[pos_pax_data]';
EXEC sp_executesql @sql;

SET @sql = N'
INSERT INTO [silver].[ac_dopdata_promonumber]
(
    [UNIQ],[DATE],[RECEIPT_NUMBER],[NUMBER],[SHIFT_NUMBER],[POSITION],[DATA],[VALUE],[SERVER]
)

SELECT [UNIQ]
     ,[DATE]
     ,[RECEIPT_NUMBER]
     ,[POS_NUMBER]
     ,[SHIFT_NUMBER]
     ,[POSITION]
     ,[DATA]
     ,CASE
          WHEN CHARINDEX(''/'', [VALUE]) > 0
              THEN LEFT([VALUE], CHARINDEX(''/'', [VALUE]) - 1)
          ELSE [VALUE]
    END AS [VALUE]
     ,CASE WHEN [POS_NUMBER] like ''1%'' THEN ''DC1-SRV-KC02''
           WHEN [POS_NUMBER] like ''28%'' THEN ''DC1-SRV-KC03''
           ELSE ''DC1-SRV-KC01''
    END AS [SERVER]
FROM [DataWarehouse].[bronze].[pos_promonumber_data]';
EXEC sp_executesql @sql;

SET @sql = N'
INSERT INTO [silver].[ac_dopdata_salersip]
(
    [UNIQ],[DATE],[RECEIPT_NUMBER],[NUMBER],[SHIFT_NUMBER],[POSITION],[DATA],[VALUE],[SERVER]
)

SELECT [UNIQ]
     ,CAST([DATE] AS DATE) AS [DATE]
     ,[RECEIPT_NUMBER]
     ,[POS_NUMBER]
     ,[SHIFT_NUMBER]
     ,[POSITION]
     ,[DATA]
     ,[VALUE]
     ,CASE WHEN [POS_NUMBER] like ''1%'' THEN ''DC1-SRV-KC02''
           WHEN [POS_NUMBER] like ''28%'' THEN ''DC1-SRV-KC03''
           ELSE ''DC1-SRV-KC01''
    END AS [SERVER]
FROM [DataWarehouse].[bronze].[pos_salersip_data]';
EXEC sp_executesql @sql;

SET @sql = N'
INSERT INTO [silver].[ac_dopdata_uin]
(
    [UNIQ],[DATE],[RECEIPT_NUMBER],[NUMBER],[SHIFT_NUMBER],[POSITION],[DATA],[VALUE],[SERVER]
)

SELECT [UNIQ]
     ,CAST([DATE] AS DATE) AS [DATE]
     ,[RECEIPT_NUMBER]
     ,[POS_NUMBER]
     ,[SHIFT_NUMBER]
     ,[POSITION]
     ,[DATA]
     ,[VALUE]
     ,CASE WHEN [POS_NUMBER] like ''1%'' THEN ''DC1-SRV-KC02''
           WHEN [POS_NUMBER] like ''28%'' THEN ''DC1-SRV-KC03''
           ELSE ''DC1-SRV-KC01''
    END AS [SERVER]
FROM [DataWarehouse].[bronze].[pos_uin_data]';
EXEC sp_executesql @sql;

SET @sql = N'
INSERT INTO [silver].[ref_promoid]
(
    [PROMOID],[Description]
)

SELECT [PROMOID]
     ,[Description]
FROM [DataWarehouse].[bronze].[ref_promoid]';
EXEC sp_executesql @sql;

END
