USE [DataWarehouse]
GO
/****** Объект:  StoredProcedure [bronze].[usp_DeletePeriod]    Дата создания скрипта: 12.10.2026 10:25:36 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [bronze].[usp_DeletePeriod]
    @DateFrom DATE,
    @DateTo DATE
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM bronze.pos_acm_payments      WHERE [DATE]     >= @DateFrom AND [DATE]     < @DateTo;
    DELETE FROM bronze.pos_aca_fiscaldata    WHERE [DATE]     >= @DateFrom AND [DATE]     < @DateTo;
    DELETE FROM bronze.pos_acl_logins        WHERE [OPDATE]   >= @DateFrom AND [OPDATE]   < @DateTo;
    DELETE FROM bronze.pos_act_items         WHERE [DATE]     >= @DateFrom AND [DATE]     < @DateTo;
    DELETE FROM bronze.pos_acc_receipts      WHERE [DATE_BEG] >= @DateFrom AND [DATE_BEG] < @DateTo;
    DELETE FROM bronze.pos_acs_shifts        WHERE [DT_BEG]   >= @DateFrom AND [DT_BEG]   < @DateTo;
    DELETE FROM bronze.pos_ac_dopdata        WHERE [DATE]     >= @DateFrom AND [DATE]     < @DateTo;
    DELETE FROM bronze.pos_avoltaclub_data   WHERE [DATE]     >= @DateFrom AND [DATE]     < @DateTo;
    DELETE FROM bronze.pos_creditcard_data   WHERE [DATE]     >= @DateFrom AND [DATE]     < @DateTo;
    DELETE FROM bronze.pos_coupons_data      WHERE [DATE]     >= @DateFrom AND [DATE]     < @DateTo;
    DELETE FROM bronze.pos_pax_data          WHERE [DATE]     >= @DateFrom AND [DATE]     < @DateTo;
    DELETE FROM bronze.pos_promonumber_data  WHERE [DATE]     >= @DateFrom AND [DATE]     < @DateTo;
    DELETE FROM bronze.pos_salersip_data     WHERE [DATE]     >= @DateFrom AND [DATE]     < @DateTo;
    DELETE FROM bronze.pos_uin_data          WHERE [DATE]     >= @DateFrom AND [DATE]     < @DateTo;
    DELETE FROM bronze.pos_ac_kyfo           WHERE [DATE]     >= @DateFrom AND [DATE]     < @DateTo;
END;
GO
/****** Объект:  StoredProcedure [bronze].[usp_LoadAllBronzeTables]    Дата создания скрипта: 12.10.2026 10:25:36 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [bronze].[usp_LoadAllBronzeTables]
    @SourceServer SYSNAME,
    @DateFrom DATE = NULL,
    @DateTo DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    /*=============================================================
      1. Определяем период загрузки

      - Даты не переданы вообще -> ежедневный режим:
        грузим ВЧЕРАШНИЙ день.
        Джоб запущен 07.09 -> @DateFrom = 2026-09-06, @DateTo = 2026-09-07.

      - Переданы обе даты -> грузим ровно их (ручная/первичная загрузка).

      - Передан только @DateFrom -> грузим полный месяц от @DateFrom.
    =============================================================*/

    IF @DateFrom IS NULL AND @DateTo IS NULL
    BEGIN
        SET @DateTo   = CAST(GETDATE() AS DATE);
        SET @DateFrom = DATEADD(DAY, -1, @DateTo);
    END;

    IF @DateFrom IS NOT NULL AND @DateTo IS NULL
    BEGIN
        SET @DateTo = DATEADD(
            MONTH, 1,
            DATEADD(MONTH, DATEDIFF(MONTH, 0, @DateFrom), 0)
        );
    END;

    --IF @DateTo <= @DateFrom
    --BEGIN
    --    THROW 50001, N'@DateTo must be greater than @DateFrom.', 1;
    --END;

    /*=============================================================
      2. Переменные для динамического SQL
    =============================================================*/

    DECLARE @sql NVARCHAR(MAX);

    --DECLARE @LinkedServer NVARCHAR(128) = QUOTENAME(@SourceServer);

    DECLARE @Flag NVARCHAR(10) = CASE @SourceServer
        WHEN 'DC1-SRV-KC01' THEN 'RUDF'
        WHEN 'DC1-SRV-KC02' THEN 'RUDP'
        WHEN 'DC1-SRV-KC03' THEN 'KZDF'
        ELSE 'UNKNOWN'
    END;

    DECLARE @Quote CHAR(1) = CHAR(39);

    DECLARE @DateFromSql NVARCHAR(20) = QUOTENAME(CONVERT(NVARCHAR(10), @DateFrom, 120), @Quote);
    DECLARE @DateToSql   NVARCHAR(20) = QUOTENAME(CONVERT(NVARCHAR(10), @DateTo, 120), @Quote);
    DECLARE @FlagSql     NVARCHAR(20) = QUOTENAME(@Flag, @Quote);

    DECLARE @msg NVARCHAR(4000) = CONCAT(
        'Bronze load: server = ', @SourceServer,
        ', period = ', @DateFromSql,
        ' - ', @DateToSql
    );

    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /*=============================================================
      Дальше идут INSERT-блоки
    =============================================================*/

    /*=============================================================
      Дальше идут твои INSERT-блоки
    =============================================================*/

    /* All source tables in all POS Servers belong to CashDB51 database, schema dbo */
  
    -- 1. ACM - info about payments
    
    SET @sql = N'
    INSERT INTO 
        bronze.pos_acm_payments
        SELECT 
            UNIQ,
            CHECKNUM,
            CASHCODE,
            [SHIFT],
            FSHIFT,
            FSERIAL,
            [DATE],
            [TIME],
            DT,
            OPCODE,
            VALCODE,
            VALTYPE,
            NRATE,
            VSUM,
            SUMB,
            SUMN,
            SUME,
            DOPDATA,
            CHR,
            POSITION,
            SNAME
        FROM 
            [' + @SourceServer + '].[CashDB51].[dbo].[ACM]
        WHERE 
            [DATE] >= ' + @DateFromSql + N'
            AND [DATE] < ' + @DateToSql + N';';
    EXEC sp_executesql @sql;
   
    -- 2. ACA - Fiscal data
    
    SET @sql = N'
    INSERT INTO 
        bronze.pos_aca_fiscaldata
        SELECT 
           [UNIQ]
          ,[CASHCODE]
          ,[CHECKNUM]
          ,[DATE]
          ,[TIME]
          ,[FSum]
          ,[FSign]
          ,[FNFD]
          ,[FSHIFT]
          ,[FNum]
          ,[FNSERIAL]
          ,[NOSENDDOCDATE]
          ,[NOSENDDOCTIME]
          ,[OFDDocNoS]
          ,[CKKMErr]
          ,[CPapErr]
      
        FROM 
            [' + @SourceServer + '].[CashDB51].[dbo].[ACA]
        WHERE 
            [DATE] >= ' + @DateFromSql + N'
            AND [DATE] < ' + @DateToSql + N';';
    EXEC sp_executesql @sql;

     
    -- 3. ACL - user logins
   
    SET @sql = N'
    INSERT INTO 
        bronze.pos_acl_logins
        SELECT 
           [UNIQ]
          ,[CASHCODE]
          ,[SHIFT]
          ,[SCODE]
          ,[SNAME]
          ,[OPCODE]
          ,[OPDATE]
        FROM 
            [' + @SourceServer + '].[CashDB51].[dbo].[ACL]
        WHERE 
            [OPDATE] >= ' + @DateFromSql + N'
            AND [OPDATE] < ' + @DateToSql + N';';
    EXEC sp_executesql @sql;

    -- 4. ACT - Sold items
    
    SET @sql = N'
    INSERT INTO 
        bronze.pos_act_items
        SELECT 
            UNIQ,
            CHECKNUM,
            SCODE,
            CASHCODE,
            [SHIFT],
            FSHIFT,
            FSERIAL,
            [DATE],
            [TIME],
            DT,
            OPCODE,
            BCODE,
            [NAME],
            BQUANT,
            CODE,
            PRICE,
            DISC_PERC,
            DISC_ABS,
            SUMI,
            SUMB,
            SUMN,
            SUME,
            VATRATE1,
            VATSUM1,
            [DOPDATA],
            SName,
            PriceTypeName,
            POSITION
        FROM 
            [' + @SourceServer + '].[CashDB51].[dbo].[ACT]
        WHERE 
            [DATE] >= ' + @DateFromSql + N'
            AND [DATE] < ' + @DateToSql + N';';
    EXEC sp_executesql @sql;

    -- 5. ACC - Receipts themselves
    
    SET @sql = N'
    INSERT INTO 
        bronze.pos_acc_receipts
        SELECT 
            UNIQ,
            CHECKNUM,
            SCODE,
            CASHCODE,
            SHIFT,
            FSHIFT,
            FSERIAL,
            ECTSERIAL,
            ECTCHECK,
            DATE_BEG,
            TIME_BEG,
            DT_BEG,
            DATE_END,
            TIME_END,
            DT_END,
            VBRATE,
            VERATE,
            DISC_PERC,
            DISC_ABS,
            SUMB,
            SUMN,
            SUME,
            PayType,
            DOPDATA
        FROM 
            [' + @SourceServer + '].[CashDB51].[dbo].[ACC]
        WHERE 
            [DATE_BEG] >= ' + @DateFromSql + N'
            AND [DATE_BEG] < ' + @DateToSql + N';';
    EXEC sp_executesql @sql;
   
    -- 6. ACS - Info about Shifts
    
    SET @sql = N'
    INSERT INTO 
        bronze.pos_acs_shifts
        SELECT 
            UNIQ,
            CASHCODE,
            STOREID,
            [SHIFT],
            [SCODE],
            [DB],
            [TB],
            DT_BEG,
            DE,
            TE,
            DT_END,
            CHECKNUM1,
            CHECKNUM2,
            FSHIFT,
            FSERIAL,
            ECTSERIAL,
            RSSALE,
            RSSALEVOID,
            RSBACK, 
            RSBACKVOID, 
            RSMIN, 
            RSMINVOID, 
            RSMOUT, 
            RSMOUTVOID, 
            RSMINCASS, 
            RSMINCASSVOID, 
            RCSALE, 
            RCSALEVOID, 
            RCBACK, 
            RCBACKVOID, 
            RCMIN, 
            RCMINVOID, 
            RCMOUT, 
            RCMOUTVOID, 
            RCMINCASS, 
            RCMINCASSVOID,
            FSSALE, 
            FSSALEVOID, 
            FSBACK, 
            FSBACKVOID, 
            FSMIN, 
            FSMINVOID, 
            FSMOUT, 
            FSMOUTVOID, 
            FCSALE, 
            FCSALEVOID, 
            FCBACK, 
            FCBACKVOID, 
            FCMIN, 
            FCMINVOID, 
            FCMOUT, 
            FCMOUTVOID,
            FTOTAL,
            CLOSESHIFT,
            CCSALE,
            CTSALE,
            CMSALE,
            DOPDATA
        FROM 
            [' + @SourceServer + '].[CashDB51].[dbo].[ACS]
        WHERE 
            [DT_BEG] >= ' + @DateFromSql + N'
            AND [DT_BEG] < ' + @DateToSql + N';';
    EXEC sp_executesql @sql;

     -- 7. ACDOPDATA YandexPay info
   
    SET @sql = N'
    INSERT INTO 
        bronze.pos_ac_dopdata
        SELECT 
           A.[UNIQ]
          ,M.[DATE]
          ,M.[CHECKNUM]
          ,M.[CASHCODE]
          ,M.[SHIFT]      
          ,LEFT(A.[Name], CHARINDEX('':'', A.[Name]) - 1) AS [Group]
          ,SUBSTRING(A.[Name], CHARINDEX('':'', A.[Name]) + 1, LEN(A.[Name])) AS [Data]
          ,[VALUE]
        FROM 
            [' + @SourceServer + '].[CashDB51].[dbo].[ACDOPDATA] A
        LEFT JOIN [' + @SourceServer + '].[CashDB51].[dbo].[ACM] M ON A.UNIQ = M.UNIQ
        WHERE 
            M.[DATE] >= ' + @DateFromSql + N'
            AND M.[DATE] < ' + @DateToSql + N'
                AND A.[Name] = ''YAST:PAYMETHOD''';
    EXEC sp_executesql @sql;

        -- 8. PROMOID
    SET @sql = N'
    DELETE FROM bronze.ref_promoid WHERE [FLAG] = ' + @FlagSql + N';
    INSERT INTO bronze.ref_promoid
    SELECT [ID], [Name], ' + @FlagSql + N' AS [FLAG]
    FROM OPENQUERY([' + @SourceServer + '], 
        ''SELECT [ID], [Name] FROM [CashDB51].[dbo].[PromoHeader]'');';
    EXEC sp_executesql @sql;

    -- 9. ACDOPDATA AvoltaClub
   
    SET @sql = N'
    INSERT INTO 
        bronze.pos_avoltaclub_data
        SELECT 
           A.[UNIQ]
          ,M.[DATE_BEG]
          ,M.[CHECKNUM]
          ,M.[CASHCODE]
          ,M.[SHIFT]  
          ,LEFT(A.[Name], CHARINDEX('':'', A.[Name]) - 1) AS [Group]
          ,SUBSTRING(A.[Name], CHARINDEX('':'', A.[Name]) + 1, LEN(A.[Name])) AS [Data]
          ,[VALUE]
        FROM 
            [' + @SourceServer + '].[CashDB51].[dbo].[ACDOPDATA] A
        LEFT JOIN [' + @SourceServer + '].[CashDB51].[dbo].[ACC] M ON A.UNIQ = M.UNIQ
        WHERE 
            M.[DATE_BEG] >= ' + @DateFromSql + N'
            AND M.[DATE_BEG] < ' + @DateToSql + N' 
            AND A.[Name] IN (''RS:LCUSID'', ''RS:NDISC'')';
    EXEC sp_executesql @sql;

    -- 10. ACDOPDATA Credit Card Data
   
    SET @sql = N'
    INSERT INTO 
        bronze.pos_creditcard_data
        SELECT 
           A.[UNIQ]
          ,M.[DATE]
          ,M.[CHECKNUM]
          ,M.[CASHCODE]
          ,M.[SHIFT]      
          ,LEFT(A.[Name], CHARINDEX('':'', A.[Name]) - 1) AS [Group]
          ,SUBSTRING(A.[Name], CHARINDEX('':'', A.[Name]) + 1, LEN(A.[Name])) AS [Data]
          ,[VALUE]
        FROM 
            [' + @SourceServer + '].[CashDB51].[dbo].[ACDOPDATA] A
        LEFT JOIN [' + @SourceServer + '].[CashDB51].[dbo].[ACM] M ON A.UNIQ = M.UNIQ
        WHERE 
            M.[DATE] >= ' + @DateFromSql + N'
            AND M.[DATE] < ' + @DateToSql + N'
           AND A.[Name] IN (''INP:CARDNO'', ''INP:CARDTYPE'', ''SB:CARDNO'', ''SB:CARDTYPE'')';
    EXEC sp_executesql @sql;

    -- 11. ACDOPDATA Coupons Data (Vouchers)
   
    SET @sql = N'
    INSERT INTO 
        bronze.pos_coupons_data
        SELECT 
           A.[UNIQ]
          ,M.[DATE_BEG]
          ,M.[CHECKNUM]
          ,M.[CASHCODE]
          ,M.[SHIFT]      
          ,SUBSTRING(A.[Name], CHARINDEX('':'', A.[Name]) + 1, LEN(A.[Name])) AS [Data]
          ,[VALUE]
        FROM 
            [' + @SourceServer + '].[CashDB51].[dbo].[ACDOPDATA] A
        LEFT JOIN [' + @SourceServer + '].[CashDB51].[dbo].[ACC] M ON A.UNIQ = M.UNIQ
        WHERE 
            M.[DATE_BEG] >= ' + @DateFromSql + N'
            AND M.[DATE_BEG] < ' + @DateToSql + N'
            AND A.[Name] IN (''PDCARDC'')';
    EXEC sp_executesql @sql;

    -- 12. ACDOPDATA PAX Data (Passengers)
   
    SET @sql = N'
    INSERT INTO 
        bronze.pos_pax_data
        SELECT 
           A.[UNIQ]
          ,M.[DATE_BEG]
          ,M.[CHECKNUM]
          ,M.[CASHCODE]
          ,M.[SHIFT] 
          ,LEFT(A.[Name], CHARINDEX('':'', A.[Name]) - 1) AS [Group]
          ,SUBSTRING(A.[Name], CHARINDEX('':'', A.[Name]) + 1, LEN(A.[Name])) AS [Data]
          ,[VALUE]
        FROM 
            [' + @SourceServer + '].[CashDB51].[dbo].[ACDOPDATA] A
        LEFT JOIN [' + @SourceServer + '].[CashDB51].[dbo].[ACC] M ON A.UNIQ = M.UNIQ
        WHERE 
            M.[DATE_BEG] >= ' + @DateFromSql + N'
            AND M.[DATE_BEG] < ' + @DateToSql + N' 
            AND A.[Name] IN (''RS:NAM'', ''RS:DP'', ''RS:DS'', ''RS:FL'', ''RS:NPT'', ''RS:NST'', ''RS:PPS'')';
    EXEC sp_executesql @sql;

    -- 13. ACDOPDATA PromoNumber Data
   
    SET @sql = N'
    INSERT INTO 
        bronze.pos_promonumber_data
        SELECT 
           A.[UNIQ]
          ,M.[DATE]
          ,M.[CHECKNUM]
          ,M.[CASHCODE]
          ,M.[SHIFT]   
          ,M.[POSITION] 
          ,SUBSTRING(A.[Name], CHARINDEX('':'', A.[Name]) + 1, LEN(A.[Name])) AS [Data]
          ,[VALUE]
        FROM 
            [' + @SourceServer + '].[CashDB51].[dbo].[ACDOPDATA] A
        LEFT JOIN [' + @SourceServer + '].[CashDB51].[dbo].[ACT] M ON A.UNIQ = M.UNIQ
        WHERE 
            M.[DATE] >= ' + @DateFromSql + N'
            AND M.[DATE] < ' + @DateToSql + N'
          AND   A.[Name] IN (''PROMODISC'') and M.[DOPDATA] like ''%PROMODISC%'' and A.[Position] = M.[Position]';
    EXEC sp_executesql @sql;

    -- 14. ACDOPDATA SALER SIP Data
   
    SET @sql = N'
    INSERT INTO 
        bronze.pos_salersip_data
        SELECT 
           A.[UNIQ]
          ,M.[DATE]
          ,M.[CHECKNUM]
          ,M.[CASHCODE]
          ,M.[SHIFT]   
          ,M.[POSITION] 
          ,SUBSTRING(A.[Name], CHARINDEX('':'', A.[Name]) + 1, LEN(A.[Name])) AS [Data]
          ,[VALUE]
        FROM 
            [' + @SourceServer + '].[CashDB51].[dbo].[ACDOPDATA] A
        INNER JOIN [' + @SourceServer + '].[CashDB51].[dbo].[ACT] M ON A.UNIQ = M.UNIQ
        WHERE 
            M.[DATE] >= ' + @DateFromSql + N'
            AND M.[DATE] < ' + @DateToSql + N' 
           AND A.[Name] = (''SALER'') and M.[DOPDATA] like ''%SALER%'' and A.[Position] = M.[Position]';
    EXEC sp_executesql @sql;

     -- 15. ACDOPDATA UIN Data
   
    SET @sql = N'
    INSERT INTO 
        bronze.pos_uin_data
        SELECT 
           A.[UNIQ]
          ,M.[DATE]
          ,M.[CHECKNUM]
          ,M.[CASHCODE]
          ,M.[SHIFT]   
          ,M.[POSITION] 
          ,LEFT(A.[Name], CHARINDEX('':'', A.[Name]) - 1) AS [Group]
          ,SUBSTRING(A.[Name], CHARINDEX('':'', A.[Name]) + 1, LEN(A.[Name])) AS [Data]
          ,[VALUE]
        FROM 
            [' + @SourceServer + '].[CashDB51].[dbo].[ACDOPDATA] A
        INNER JOIN [' + @SourceServer + '].[CashDB51].[dbo].[ACT] M ON A.UNIQ = M.UNIQ
       WHERE 
            M.[DATE] >= ' + @DateFromSql + N'
            AND M.[DATE] < ' + @DateToSql + N'
            AND A.[Name] = (''DMDK:UIN'') and A.[Position] = M.[Position]';
    EXEC sp_executesql @sql;

    -- 16. MOL Users
    SET @sql = N'
    DELETE FROM bronze.pos_mol_users WHERE [FLAG] = ' + @FlagSql + N';
    INSERT INTO bronze.pos_mol_users
    SELECT [CODE], [LOGIN], [NAME], ' + @FlagSql + N' AS [FLAG]
    FROM [' + @SourceServer + '].[CashDB51].[dbo].[MOL];';
    EXEC sp_executesql @sql;

    -- 17. AC KYFO
    SET @sql = N'
    INSERT INTO bronze.pos_ac_kyfo
    (
        [UNIQ], [DATE], [CHECKNUM], [CASHCODE], [SHIFT], [ID], [ORDER]
    )
    SELECT
        M.UNIQ,
        M.[DATE],
        M.CHECKNUM,
        M.CASHCODE,
        M.SHIFT,
        MAX(CASE WHEN D.[TYPE] = 2 AND D.[NAME] = ''KYFO:ID'' THEN D.[VALUE] END) AS [ID],
        MAX(CASE WHEN D.[NAME] = ''KYFO:ORDERUID'' THEN D.[VALUE] END) AS [ORDER]
    FROM 
        [' + @SourceServer + '].[CashDB51].[dbo].[ACM] M
    INNER JOIN 
        [' + @SourceServer + '].[CashDB51].[dbo].[ACDOPDATA] D
        ON D.UNIQ = M.UNIQ
    WHERE 
        M.VALCODE = 40
        AND M.[DATE] >= ' + @DateFromSql + N'
        AND M.[DATE] < ' + @DateToSql + N'
        AND D.[TYPE] <> 0
        AND D.[NAME] IN (''KYFO:ID'', ''KYFO:ORDERUID'')
    GROUP BY
        M.UNIQ, M.[DATE], M.CHECKNUM, M.CASHCODE, M.SHIFT;';
    EXEC sp_executesql @sql;
  
END
GO
/****** Объект:  StoredProcedure [bronze].[usp_LoadOperativeBronzeTables]    Дата создания скрипта: 12.10.2026 10:25:36 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [bronze].[usp_LoadOperativeBronzeTables]
    
    
    @SourceServer SYSNAME, -- Will be needed for SSIS Foreach Loop Container to retrieve data from all POS Servers
    @DateFrom DATE = NULL -- TODAY
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX); -- Dynamic SQL will be used
    /* All source tables in all POS Servers belong to CashDB51 database, schema dbo */
  
    -- 1. CM - info about payments
    SET @sql = N'
    INSERT INTO bronze.oper_pos_cm_payments
    SELECT
       [UNIQ]
      ,[SCODE]
      ,[CHECKNUM]
      ,[CASHCODE]
      ,[SHIFT]
      ,[FSHIFT]
      ,[FSERIAL]
      ,[DATE]
      ,[TIME]
      ,[OPCODE]
      ,[VALCODE]
      ,[NRATE]
      ,[VSUM]
      ,[SUMB]
      ,[SUMN]
      ,[SUME]
      ,[DOPDATA]
      ,[POSITION]
    FROM 
        [' + @SourceServer + '].[CashDB51].[dbo].[CM]
    WHERE 
        [DATE] >= CAST(GETDATE() AS DATE) 
        AND [DATE] < DATEADD(DAY, 1, CAST(GETDATE() AS DATE));';
        EXEC sp_executesql @sql;


-- 2. CT - info about items
    SET @sql = N'
    INSERT INTO bronze.operative_pos_ct_items
    SELECT
       [UNIQ]
      ,[CHECKNUM]  
      ,[SCODE]
      ,[CASHCODE]  
      ,[SHIFT]
      ,[FSHIFT]
      ,[FSERIAL]
      ,[DATE]
      ,[TIME]
      ,[OPCODE]
      ,[BCODE]
      ,[NAME]
      ,[BQUANT]
      ,[CODE]
      ,[PRICETYPE]
      ,[PRICE]
      ,[DISC_ABS]
      ,[SUMB]
      ,[SUMN]
      ,[VATRATE1]
      ,[VATSUM1]
    FROM 
        [' + @SourceServer + '].[CashDB51].[dbo].[CT]
    WHERE 
        [DATE] >= CAST(GETDATE() AS DATE) 
        AND [DATE] < DATEADD(DAY, 1, CAST(GETDATE() AS DATE));';
        EXEC sp_executesql @sql;
END
GO
/****** Объект:  StoredProcedure [dbo].[usp_BackfillMonth]    Дата создания скрипта: 12.10.2026 10:25:36 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_BackfillMonth]
    @MonthStart DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MonthEnd DATE = DATEADD(MONTH, 1, @MonthStart);

    /* bronze = только этот месяц */
    EXEC bronze.usp_DeletePeriod '1900-01-01', '9999-12-31';
    EXEC bronze.usp_LoadAllBronzeTables N'DC1-SRV-KC01', @MonthStart, @MonthEnd;
    EXEC bronze.usp_LoadAllBronzeTables N'DC1-SRV-KC02', @MonthStart, @MonthEnd;
    EXEC bronze.usp_LoadAllBronzeTables N'DC1-SRV-KC03', @MonthStart, @MonthEnd;

    /* silver и gold: пересобрать месяц */
    EXEC silver.usp_LoadSilverTables @MonthStart, @MonthEnd;
    EXEC gold.usp_LoadGoldTables     @MonthStart, @MonthEnd;
END;
GO
/****** Объект:  StoredProcedure [dbo].[usp_CheckDataQuality]    Дата создания скрипта: 12.10.2026 10:25:36 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_CheckDataQuality]
    @CheckDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @CheckDate = ISNULL(@CheckDate, DATEADD(DAY, -1, CAST(GETDATE() AS DATE)));

    DECLARE @Problems NVARCHAR(MAX) = N'';
    DECLARE @Total BIGINT, @KC01 BIGINT, @KC02 BIGINT, @KC03 BIGINT, @Avg7 FLOAT;

    /* 1. Вчера вообще что-то загрузилось? */
    SELECT @Total = COUNT(*) FROM bronze.pos_acm_payments WHERE [DATE] = @CheckDate;
    IF ISNULL(@Total, 0) = 0
        SET @Problems += N'- Нет данных за ' + CONVERT(NVARCHAR(10), @CheckDate, 120) + CHAR(13);

    /* 2. Все три сервера отдали данные? */
    SELECT
        @KC01 = SUM(CASE WHEN CASHCODE NOT LIKE '1%' AND CASHCODE NOT LIKE '28%' THEN 1 ELSE 0 END),
        @KC02 = SUM(CASE WHEN CASHCODE LIKE '1%'  THEN 1 ELSE 0 END),
        @KC03 = SUM(CASE WHEN CASHCODE LIKE '28%' THEN 1 ELSE 0 END)
    FROM bronze.pos_acm_payments
    WHERE [DATE] = @CheckDate;

    IF ISNULL(@KC01, 0) = 0 SET @Problems += N'- Пусто по DC1-SRV-KC01' + CHAR(13);
    IF ISNULL(@KC02, 0) = 0 SET @Problems += N'- Пусто по DC1-SRV-KC02' + CHAR(13);
    IF ISNULL(@KC03, 0) = 0 SET @Problems += N'- Пусто по DC1-SRV-KC03' + CHAR(13);

    /* 3. Объём не просел ли вдвое против средней недели? */
    SELECT @Avg7 = AVG(c)
    FROM (
        SELECT COUNT(*) AS c
        FROM bronze.pos_acm_payments
        WHERE [DATE] >= DATEADD(DAY, -8, @CheckDate) AND [DATE] < @CheckDate
        GROUP BY [DATE]
    ) t;

    IF ISNULL(@Avg7, 0) > 0 AND @Total < @Avg7 * 0.5
        SET @Problems += N'- Подозрительно мало строк: ' + CAST(@Total AS NVARCHAR(20))
                       + N' при среднем ' + CAST(CAST(@Avg7 AS INT) AS NVARCHAR(20)) + CHAR(13);

    /* 4. Ночной ETL не падал? */
    IF EXISTS (
        SELECT 1 FROM dbo.etl_execution_log
        WHERE RunDate = CAST(GETDATE() AS DATE) AND Status = 'ERROR'
    )
        SET @Problems += N'- Ночной запуск ETL завершился с ошибкой' + CHAR(13);

    /* Письмо только если есть проблемы */
    IF @Problems <> N''
    BEGIN
        EXEC msdb.dbo.sp_send_dbmail
            @profile_name = 'DBA',
            @recipients   = 'RozentsvaygMY@regstaer.ru',
            @subject      = N'[ETL] Проблемы с данными',
            @body         = @Problems;
    END
END;
GO
/****** Объект:  StoredProcedure [dbo].[usp_DailyETL]    Дата создания скрипта: 12.10.2026 10:25:36 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[usp_DailyETL]
    @DateFrom DATE = NULL,   -- NULL = вчера
    @DateTo   DATE = NULL    -- NULL = сегодня
AS
BEGIN
    SET NOCOUNT ON;

    /*--- календарь считается сам от даты запуска ---*/
    DECLARE @Today     DATE = CAST(GETDATE() AS DATE);
    DECLARE @Yesterday DATE = DATEADD(DAY, -1, @Today);

    SET @DateFrom = ISNULL(@DateFrom, @Yesterday);
    SET @DateTo   = ISNULL(@DateTo, @Today);

    DECLARE @MonthStart DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, @DateFrom), 0);
    DECLARE @MonthEnd   DATE = DATEADD(MONTH, 1, @MonthStart);

    /* Запись в журнал */
    DECLARE @LogID BIGINT;
    INSERT INTO dbo.etl_execution_log (RunDate, DateFrom, DateTo, Status)
    VALUES (@Today, @DateFrom, @DateTo, 'RUNNING');
    SET @LogID = SCOPE_IDENTITY();

    DECLARE @StepStart DATETIME2 = SYSDATETIME();
    DECLARE @Body NVARCHAR(4000);

    BEGIN TRY
    /* 1. Очистки */
        /*--- 1.1 вычистить из bronze всё старше текущего месяца (один раз!) ---*/
        EXEC bronze.usp_DeletePeriod '1900-01-01', @MonthStart;
        /*--- 1.2 удалить загружаемый день (идемпотентность, один раз!) ---*/
        EXEC bronze.usp_DeletePeriod @DateFrom, @DateTo;
    
    /* 2. Bronze */
        /*--- 2.1 загрузить "вчера" с трёх серверов ---*/
        EXEC bronze.usp_LoadAllBronzeTables N'DC1-SRV-KC01', @DateFrom, @DateTo;
        EXEC bronze.usp_LoadAllBronzeTables N'DC1-SRV-KC02', @DateFrom, @DateTo;
        EXEC bronze.usp_LoadAllBronzeTables N'DC1-SRV-KC03', @DateFrom, @DateTo;

    /* 3. Silver */
        /*--- 3.1 silver: пересобрать (получится целый месяц) ---*/
        EXEC silver.usp_LoadSilverTables @MonthStart = @MonthStart, @MonthEnd = @MonthEnd;
    
    /* 4. Gold */
        /*--- 4.1 gold: удалить текущий месяц и пересобрать ---*/
        EXEC gold.usp_LoadGoldTables @MonthStart = @MonthStart, @MonthEnd = @MonthEnd;

    /* 5. Успех + счётчики в журнал */
        DECLARE @BronzeRows BIGINT,@SilverRows BIGINT;
        SELECT @BronzeRows = COUNT(*) FROM bronze.pos_acm_payments;
        SELECT @SilverRows = COUNT(*) FROM silver.acm_payments;

        UPDATE dbo.etl_execution_log
        SET Status = 'SUCCESS',
            FinishedAt = SYSDATETIME(),
            DurationSec = DATEDIFF(SECOND, @StepStart, SYSDATETIME()),
            BronzeRows = @BronzeRows,
            SilverRows = @SilverRows
        WHERE LogID = @LogID
    END TRY

    BEGIN CATCH
        UPDATE dbo.etl_execution_log
        SET Status = 'ERROR',
            FinishedAt = SYSDATETIME(),
            DurationSec = DATEDIFF(SECOND, @StepStart, SYSDATETIME()),
            ErrorMessage = ERROR_MESSAGE()
        WHERE LogID = @LogID;

        SET @Body = N'Ошибка ETL ' + CONVERT(NVARCHAR(10), @Today, 120)
                    + CHAR(13) + N'Период: ' + CONVERT(NVARCHAR(10), @DateFrom, 120)
                    + N' - ' + CONVERT(NVARCHAR(10), @DateTo, 120)
                    + CHAR(13) + N'Ошибка: ' + ERROR_MESSAGE();

        EXEC msdb.dbo.sp_send_dbmail
            @profile_name = 'DBA',
            @recipients = 'RozentsvaygMY@regstaer.ru',
            @subject = N'[ETL] ERROR usp_DailyETL',
            @Body = @Body;

        THROW;
    
    END CATCH;
 END;
GO
/****** Объект:  StoredProcedure [gold].[usp_LoadGoldOperativeTables]    Дата создания скрипта: 12.10.2026 10:25:36 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [gold].[usp_LoadGoldOperativeTables]
    AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @sql NVARCHAR(MAX);

SET @sql = N'
    INSERT INTO [gold].[oper_cm_moneyflow_kz]
    (
        [LOCATION],[STORE],[POS_NUMBER],[SHIFT_NUMBER],[SHIFT_PART],[DATE],[EUR LOAN],[EUR SALES]
      ,[EUR REFUND],[EUR PICKUP],[USD LOAN],[USD SALES],[USD REFUND],[USD PICKUP]
      ,[KZT LOAN],[KZT SALES],[KZT REFUND],[KZT PICKUP],[RUB LOAN],[RUB SALES],[RUB REFUND],[RUB PICKUP]
      ,[CNY LOAN],[CNY SALES],[CNY REFUND],[CNY PICKUP]
      ,[CARDS SALES],[CARDS REFUND],[OFFLINE CARD SALES],[OFFLINE CARD REFUND]
    )
SELECT
    SL.Location AS Location,
    SL.StoreName AS Store,
    CM.CASHCODE,
    CM.SHIFT,
    CASE 
        WHEN CAST(CM.TIME AS TIME) BETWEEN ''00:00:01'' AND ''08:00:00'' THEN N''Утро с 00:00:01 до 08:00:00''
        WHEN CAST(CM.TIME AS TIME) BETWEEN ''08:00:01'' AND ''20:00:00'' THEN N''День с 08:00:01 до 20:00:00''
        ELSE N''Вечер с 20:00:01 до 00:00:00''
    END AS ShiftPart,
    CAST(CM.DATE AS DATE) AS SaleDate,
    SUM(CASE WHEN CM.OPCODE = 80 AND CM.VALCODE = 3 THEN CM.VSUM ELSE 0 END) AS [EUR_Loan],        
    SUM(CASE WHEN CM.OPCODE = 72 AND CM.VALCODE = 3 THEN CM.VSUM ELSE 0 END) AS [EUR_Sales],
    SUM(CASE WHEN CM.OPCODE = 74 AND CM.VALCODE = 3 THEN CM.VSUM ELSE 0 END) AS [EUR_Refund],
    SUM(CASE WHEN CM.OPCODE = 82 AND CM.VALCODE = 3 THEN CM.VSUM ELSE 0 END) AS [EUR_Pickup],
    SUM(CASE WHEN CM.OPCODE = 80 AND CM.VALCODE = 2 THEN CM.VSUM ELSE 0 END) AS [USD_Loan],       
    SUM(CASE WHEN CM.OPCODE = 72 AND CM.VALCODE = 2 THEN CM.VSUM ELSE 0 END) AS [USD_Sales],
    SUM(CASE WHEN CM.OPCODE = 74 AND CM.VALCODE = 2 THEN CM.VSUM ELSE 0 END) AS [USD_Refund],
    SUM(CASE WHEN CM.OPCODE = 82 AND CM.VALCODE = 2 THEN CM.VSUM ELSE 0 END) AS [USD_Pickup],
    SUM(CASE WHEN CM.OPCODE = 80 AND CM.VALCODE = 1 THEN CM.VSUM ELSE 0 END) AS [KZT_Loan],
    SUM(CASE WHEN CM.OPCODE = 72 AND CM.VALCODE = 1 THEN CM.VSUM ELSE 0 END) AS [KZT_Sales],
    SUM(CASE WHEN CM.OPCODE = 74 AND CM.VALCODE = 1 THEN CM.VSUM ELSE 0 END) AS [KZT_Refund],
    SUM(CASE WHEN CM.OPCODE = 82 AND CM.VALCODE = 1 THEN CM.VSUM ELSE 0 END) AS [KZT_Pickup],
    SUM(CASE WHEN CM.OPCODE = 80 AND CM.VALCODE = 5 THEN CM.VSUM ELSE 0 END) AS [RUB_Loan],
    SUM(CASE WHEN CM.OPCODE = 72 AND CM.VALCODE = 5 THEN CM.VSUM ELSE 0 END) AS [RUB_Sales],
    SUM(CASE WHEN CM.OPCODE = 74 AND CM.VALCODE = 5 THEN CM.VSUM ELSE 0 END) AS [RUB_Refund],
    SUM(CASE WHEN CM.OPCODE = 82 AND CM.VALCODE = 5 THEN CM.VSUM ELSE 0 END) AS [RUB_Pickup],
    SUM(CASE WHEN CM.OPCODE = 80 AND CM.VALCODE = 4 THEN CM.VSUM ELSE 0 END) AS [CNY_Loan],
    SUM(CASE WHEN CM.OPCODE = 72 AND CM.VALCODE = 4 THEN CM.VSUM ELSE 0 END) AS [CNY_Sales],
    SUM(CASE WHEN CM.OPCODE = 74 AND CM.VALCODE = 4 THEN CM.VSUM ELSE 0 END) AS [CNY_Refund],
    SUM(CASE WHEN CM.OPCODE = 82 AND CM.VALCODE = 4 THEN CM.VSUM ELSE 0 END) AS [CNY_Pickup],
    SUM(CASE WHEN CM.OPCODE = 70 AND CM.VALCODE = 10 THEN CM.VSUM ELSE 0 END) AS [Cards_Sales],
    SUM(CASE WHEN CM.OPCODE = 74 AND CM.VALCODE = 10 THEN CM.VSUM ELSE 0 END) AS [Cards_Refund],
    SUM(CASE WHEN CM.OPCODE = 70 AND CM.VALCODE = 20 THEN CM.VSUM ELSE 0 END) AS [Offline_Sales],
    SUM(CASE WHEN CM.OPCODE = 74 AND CM.VALCODE = 20 THEN CM.VSUM ELSE 0 END) AS [Offline_Refund]    
FROM 
    silver.oper_cm_payments CM
LEFT JOIN bronze.ref_locations SL ON SL.STORECODE = LEFT(CM.CASHCODE, 3)
WHERE 
    CM.CASHCODE like ''28%'' --cast(date as date) = @Today
GROUP BY 
    SL.Location,
    SL.StoreName,
    CM.CASHCODE,
    CM.SHIFT,
    CAST(CM.DATE AS DATE),
    CASE 
        WHEN CAST(CM.TIME AS TIME) BETWEEN ''00:00:01'' AND ''08:00:00'' THEN N''Утро с 00:00:01 до 08:00:00''
        WHEN CAST(CM.TIME AS TIME) BETWEEN ''08:00:01'' AND ''20:00:00'' THEN N''День с 08:00:01 до 20:00:00''
        ELSE N''Вечер с 20:00:01 до 00:00:00''
        END
';
EXEC sp_executesql @sql;

END
GO
/****** Объект:  StoredProcedure [gold].[usp_LoadGoldTables]    Дата создания скрипта: 12.10.2026 10:25:36 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [gold].[usp_LoadGoldTables]
    @MonthStart DATE = NULL,
    @MonthEnd   DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    /* If no dates were provided then rebuilding the month with YESTERDAY.*/
    IF @MonthStart IS NULL
        SET @MonthStart = DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(DAY, -1, GETDATE())), 0);
    IF @MonthEnd IS NULL
        SET @MonthEnd = DATEADD(MONTH, 1, @MonthStart);

    /*================= CURRENT MONTH DELETION =================================================================*/
    DELETE FROM gold.rep_yandex       WHERE [DATE]            >= @MonthStart AND [DATE]            < @MonthEnd;
    DELETE FROM gold.rep_discounts    WHERE [DATE]            >= @MonthStart AND [DATE]            < @MonthEnd;
    DELETE FROM gold.dash_discounts   WHERE [DATE]            >= @MonthStart AND [DATE]            < @MonthEnd;
    DELETE FROM gold.rep_uin          WHERE [DATE]            >= @MonthStart AND [DATE]            < @MonthEnd;
    DELETE FROM gold.rep_destinations WHERE [DATE]            >= @MonthStart AND [DATE]            < @MonthEnd;
    DELETE FROM gold.rep_shifts       WHERE SHIFT_START_DATE  >= @MonthStart AND SHIFT_START_DATE  < @MonthEnd;
    DELETE FROM gold.dash_yandex      WHERE PERIOD_START_DATE >= @MonthStart AND PERIOD_START_DATE < @MonthEnd;
    DELETE FROM gold.rep_cashiers     WHERE PERIOD_START_DATE =  @MonthStart;
    /*===========================================================================================================*/

SELECT
    UNIQ,
    MAX(CASE WHEN DATA = 'DP' THEN VALUE END) AS [DEPARTURE CODE],
    MAX(CASE WHEN DATA = 'DS' THEN VALUE END) AS [DESTINATION CODE],
    MAX(CASE WHEN DATA = 'FL' THEN VALUE END) AS [FLIGHT NUMBER]
INTO #PaxData
FROM silver.ac_dopdata_pax
WHERE silver.ac_dopdata_pax.[DATE] >= @MonthStart AND silver.ac_dopdata_pax.[DATE] < @MonthEnd
GROUP BY UNIQ;

CREATE INDEX IX_PaxData_UNIQ ON #PaxData(UNIQ);

SELECT
    UNIQ,
    MAX(PriceTypeName) AS [PRICE_TYPE]
INTO #PriceType
FROM silver.act_items
WHERE silver.act_items.[DATE] >= @MonthStart AND silver.act_items.[DATE] < @MonthEnd
GROUP BY UNIQ;

CREATE INDEX IX_PriceType_UNIQ ON #PriceType(UNIQ);

SELECT
	UNIQ,
	MAX(CASE WHEN VALCODE = 5 THEN NRATE ELSE 1 END) AS NRATE_RUB
INTO #ER
FROM
	silver.acm_payments
WHERE silver.acm_payments.[DATE] >= @MonthStart AND silver.acm_payments.[DATE] < @MonthEnd
GROUP BY UNIQ;

        DECLARE @sql NVARCHAR(MAX);
        DECLARE @Params NVARCHAR(MAX) = N'@MonthStart DATE, @MonthEnd DATE';

/*=============================== rep_cashiers ====================================================================*/
SET @sql = N'
    INSERT INTO [gold].[rep_cashiers] 
        ([PERIOD_START_DATE], [COMPANY], [LOCATION], [CASHIER], [QTY], [TOTAL])
    SELECT
        @MonthStart,
        L.COMPANY,
        L.LOCATION,
        I.SNAME,
        COUNT(DISTINCT I.CHECKNUM),
        SUM(I.SUMN)
    FROM
        silver.act_items I
    LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(I.CASHCODE, 3)
    WHERE I.[DATE] >= @MonthStart AND I.[DATE] < @MonthEnd
    GROUP BY
        I.SNAME, L.COMPANY, L.LOCATION';       
EXEC sp_executesql 
    @sql, 
    @Params, 
    @MonthStart = @MonthStart, 
    @MonthEnd   = @MonthEnd;

/*================================= rep_shifts  ==================================================================*/
SET @sql = N'
;WITH BaseShifts AS
(
	SELECT
		CASHCODE, 
        FSHIFT, 
        DATEBEGIN, 
        DATEEND, 
        FSSALE, 
        FSBACK, 
        FCSALE, 
        FCBACK, 
        ECTSERIAL 
	FROM 
		silver.acs_shifts
    WHERE DATEBEGIN >= @MonthStart AND DATEBEGIN < @MonthEnd
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
		A.CASHCODE, 
        A.FSHIFT, 
        A.SNAME,
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
  ,[REVENUE],[CASH_REVENUE],[CARD_REVENUE],[VAT22],[VAT10],[VAT20],[VAT5],[VAT7],[SALES_QTY],[REFUNDs_QTY],[CASH_REFUND],[CARD_REFUND],[FR_NUMBER],[SHIFT_START_DATE])
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
    O.Serial,
    CAST(O.DATEBEGIN AS DATE)
FROM
	ShiftOps O
LEFT JOIN ShiftVAT V ON V.CASHCODE = O.CASHCODE AND V.FSHIFT  = O.FSHIFT
LEFT JOIN CashierNames CF ON CF.CASHCODE = O.CASHCODE AND CF.FSHIFT  = O.FSHIFT AND CF.RN_FIRST = 1
LEFT JOIN CashierNames CL ON CL.CASHCODE = O.CASHCODE AND CL.FSHIFT  = O.FSHIFT AND CL.RN_LAST = 1
LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(O.CASHCODE, 3)';

EXEC sp_executesql 
    @sql, 
    @Params, 
    @MonthStart = @MonthStart, 
    @MonthEnd   = @MonthEnd;

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
	P.CHR = ''YP'' AND P.[DATE] >= @MonthStart AND P.[DATE] < @MonthEnd';

    EXEC sp_executesql 
    @sql, 
    @Params, 
    @MonthStart = @MonthStart, 
    @MonthEnd   = @MonthEnd;

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
    CHR = ''YP'' AND M.[DATE] >= @MonthStart AND M.[DATE] < @MonthEnd
)
INSERT INTO [gold].[dash_yandex]
    (
        [LOCATION],[PERIOD_START_DATE],[YEAR],[QUARTER],[MONTH],[WEEK],[SALES],[REFUNDS],[QTY_SALES],[QTY_REFUNDS],[SALES_SPLIT],[REFUNDS_SPLIT],[QTY_SALES_SPLIT],[QTY_REFUNDS_SPLIT]
        ,[REVENUE],[QTY_REVENUE],[REVENUE_SPLIT],[QTY_REVENUE_SPLIT],[SPLIT_COMM],[FSP_COMM]
    )
SELECT 
    L.[Location],
    DATEFROMPARTS(YEAR(M.DATE), MONTH(M.DATE), 1) AS PERIOD_START_DATE,
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
    L.[Location], [YEAR],[QUARTER],[MONTH],[WEEK],DATEFROMPARTS(YEAR(M.DATE), MONTH(M.DATE), 1)';

    EXEC sp_executesql 
    @sql, 
    @Params, 
    @MonthStart = @MonthStart, 
    @MonthEnd   = @MonthEnd;

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
        AND ACT.[DATE] >= @MonthStart AND ACT.[DATE] < @MonthEnd
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
LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(C.CASHCODE, 3)';
    
    EXEC sp_executesql 
    @sql, 
    @Params, 
    @MonthStart = @MonthStart, 
    @MonthEnd   = @MonthEnd;

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
        AND ACT.[DATE] >= @MonthStart AND ACT.[DATE] < @MonthEnd
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

EXEC sp_executesql 
    @sql, 
    @Params, 
    @MonthStart = @MonthStart, 
    @MonthEnd   = @MonthEnd;

/*================================= rep_uin ==================================================================*/
SET @sql = N'
;WITH FNSERIAL_CTE AS
(
	SELECT DISTINCT
		CASHCODE,
		MAX(ECTSERIAL) AS ECTSERIAL
	FROM
		silver.acc_receipts
	WHERE 
		ECTSERIAL != ''''
	GROUP BY CASHCODE
)
INSERT INTO gold.rep_uin
(
	[OP_TYPE],[ITEM_CODE],[ITEM_NAME],[UIN],[SHIFT],[RECEIPT_NUMBER],[COMPANY],[DUTY],[LOCATION]
      ,[STORE],[POS_NUMBER],[FP_SERIAL],[FN_SERIAL],[DATE],[TIME],[PRICE],[TOTAL]
)
SELECT
	ACT.OP_TYPE,
	ACT.CODE,
	ACT.NAME,
	UIN.VALUE,
	ACT.SHIFT,
	ACT.CHECKNUM,
	L.Company,
	L.Duty,
	L.Location,
	L.StoreName,
	ACT.CASHCODE,
	ACT.FSERIAL,
	CTE.ECTSERIAL,
	ACT.DATE,
	LEFT(ACT.TIME, 8) AS [TIME],
	ACT.PRICE,
	ACT.SUMB
FROM
	silver.act_items ACT
INNER JOIN silver.ac_dopdata_uin UIN ON UIN.UNIQ = ACT.UNIQ AND UIN.POSITION = ACT.POSITION
LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(ACT.CASHCODE, 3)
INNER JOIN FNSERIAL_CTE CTE ON CTE.CASHCODE = ACT.CASHCODE
WHERE ACT.[DATE] >= @MonthStart AND ACT.[DATE] < @MonthEnd';

EXEC sp_executesql 
    @sql, 
    @Params, 
    @MonthStart = @MonthStart, 
    @MonthEnd   = @MonthEnd;

/*================================= rep_destinations ==================================================================*/
SET @sql = N'
INSERT INTO [gold].[rep_destinations]
(
     [CITY]
    ,[DATE]
    ,[DIRECTION]
    ,[PRICE_TYPE]
    ,[DEPARTURE_CODE]
    ,[ARRIVAL_CODE]
    ,[DEPARTURE_CITY]
    ,[ARRIVAL_CITY]
    ,[DEPARTURE_COUNTRY]
    ,[ARRIVAL_COUNTRY]
    ,[QTY_OF_RECEIPTS]
    ,[TOTAL_RUB]
    )
SELECT
    L.CITY,
    ACC.DATE_BEG,
    CASE WHEN PAX.[DEPARTURE CODE] = L.[IATA] THEN N''Вылет''
         ELSE N''Прилёт''
    END AS [DIRECTION],
    PT.[PRICE_TYPE],
    ISNULL(PAX.[DEPARTURE CODE], ''NO BP'') AS [DEPARTURE CODE],
    ISNULL(PAX.[DESTINATION CODE], ''NO BP'') AS [DESTINATION CODE],
    ISNULL(DPC.[CITY], ''NO BP'') AS [DEP_CITY],
    ISNULL(DSC.[CITY], ''NO BP'') AS [ARR_CITY],
    ISNULL(DPC.[COUNTRY_NAME], ''NO BP'') AS [DEP_COUNTRY],
    ISNULL(DSC.[COUNTRY_NAME], ''NO BP'') AS [ARR_COUNTRY],
    COUNT(DISTINCT ACC.UNIQ) AS [QTY],  -- DISTINCT, если нужно считать уникальные чеки
    CASE WHEN L.CITY = N''Астана'' THEN (SUM(ACC.SUMN) / ER.NRATE_RUB) ELSE SUM(ACC.SUMN) END AS [TOTAL]
    
FROM silver.acc_receipts ACC
LEFT JOIN #PaxData PAX ON PAX.UNIQ = ACC.UNIQ
LEFT JOIN #PriceType PT ON PT.UNIQ = ACC.UNIQ
LEFT JOIN #ER ER ON ER.UNIQ = ACC.UNIQ
LEFT JOIN bronze.ref_locations L ON L.StoreCode = LEFT(ACC.CASHCODE, 3)
LEFT JOIN bronze.ref_destinationcodes DPC ON DPC.IATA = PAX.[DEPARTURE CODE]
LEFT JOIN bronze.ref_destinationcodes DSC ON DSC.IATA = PAX.[DESTINATION CODE]
WHERE ACC.[DATE_BEG] >= @MonthStart AND ACC.[DATE_BEG] < @MonthEnd
GROUP BY
    L.CITY,
    ACC.DATE_BEG,
    CASE WHEN PAX.[DEPARTURE CODE] = L.[IATA] THEN N''Вылет'' ELSE N''Прилёт'' END,
    PT.[PRICE_TYPE],
    ISNULL(PAX.[DEPARTURE CODE], ''NO BP''),
    ISNULL(DPC.[CITY], ''NO BP''),
    ISNULL(PAX.[DESTINATION CODE], ''NO BP''),
    ISNULL(DSC.[CITY], ''NO BP''),
    ISNULL(DPC.[COUNTRY_NAME], ''NO BP''),
    ISNULL(DSC.[COUNTRY_NAME], ''NO BP''),
    ER.NRATE_RUB';

EXEC sp_executesql 
    @sql, 
    @Params, 
    @MonthStart = @MonthStart, 
    @MonthEnd   = @MonthEnd;

DROP TABLE #PaxData;
DROP TABLE #PriceType;
DROP TABLE #ER;

END
GO
/****** Объект:  StoredProcedure [gold].[usp_SendAllYandexSplitReports]    Дата создания скрипта: 12.10.2026 10:25:36 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [gold].[usp_SendAllYandexSplitReports]
AS
BEGIN
    DECLARE @CompanyCode NVARCHAR(10);
    
    DECLARE company_cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT DISTINCT Company FROM bronze.ref_locations WHERE Company != 'DCA';
    
    OPEN company_cur;
    FETCH NEXT FROM company_cur INTO @CompanyCode;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            EXEC gold.usp_SendYandexSplitReport @CompanyCode;
        END TRY
        BEGIN CATCH
            PRINT N'❌ Ошибка для ' + @CompanyCode + N': ' + ERROR_MESSAGE();
        END CATCH
        
        FETCH NEXT FROM company_cur INTO @CompanyCode;
    END
    
    CLOSE company_cur; DEALLOCATE company_cur;
END
GO
/****** Объект:  StoredProcedure [gold].[usp_SendUINReport]    Дата создания скрипта: 12.10.2026 10:25:36 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [gold].[usp_SendUINReport]
AS BEGIN

DECLARE @Yesterday DATE = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE);
DECLARE @StartDate DATE = @Yesterday;
DECLARE @EndDate   DATE = DATEADD(DAY, 1, @Yesterday);

DECLARE @mysubject NVARCHAR(200) = N'Продажи ювелирных товаров за ' + CONVERT(NVARCHAR(10), @Yesterday, 104);
DECLARE @tableHTML NVARCHAR(MAX);
DECLARE @RowCount INT;

-- Проверяем наличие данных
SELECT @RowCount = COUNT(*) 
FROM gold.v_rep_uin U
WHERE U.[DATE] = @Yesterday;

IF @RowCount > 0
BEGIN
    -- Заголовок HTML + стили
    SET @tableHTML = 
        N'<html><head>' +
        N'<style>' +
        N'table { border-collapse: collapse; width: 100%; font-family: Arial, sans-serif; font-size: 11px; }' +
        N'th { background-color: #2E7D32; color: white; border: 1px solid #ccc; padding: 8px; text-align: left; font-weight: bold; }' +
        N'td { border: 1px solid #ccc; padding: 5px; vertical-align: top; }' +
        N'tr:hover { background-color: #f5f5f5; }' +
        N'.section-header { background-color: #1976D2; color: white; font-weight: bold; }' +
        N'.df-row { background-color: #E8F5E9; }' +
        N'.dp-row { background-color: #E3F2FD; }' +
        N'.total-row { background-color: #FFF3E0; font-weight: bold; }' +
        N'.right { text-align: right; }' +
        N'</style>' +
        N'</head><body>' +
        N'<h3 style="text-align:center; color:#333;">Продажи ювелирных товаров за ' + CONVERT(NVARCHAR(10), @Yesterday, 104) + N'</h3>' +
        N'<p style="text-align:center; color:#666;">Всего записей: <b>' + CAST(@RowCount AS NVARCHAR(10)) + N'</b></p>' +
        N'<table>' +
        N'<thead><tr>' +
        N'<th>Источник</th><th>Тип операции</th><th>Компания</th><th>Локация</th><th>Магазин</th><th>Касса</th>' +
        N'<th>Смена</th><th>Чек №</th><th>Код</th><th>Наименование</th><th>UIN</th>' +
        N'<th>Дата</th><th>Время</th><th class="right">Цена</th><th class="right">Сумма</th><th class="right">С/Н ККТ</th><th class="right">ФП</th>' +
        N'</tr></thead><tbody>';

    -- Формируем строки с курсором для группировки по секциям
    DECLARE @PrevDuty NVARCHAR(10) = '', @PrevCompany NVARCHAR(100) = '';
    DECLARE @CurDuty NVARCHAR(10), @OpType  NVARCHAR(50), @CurCompany NVARCHAR(100); 
    DECLARE @Location NVARCHAR(100), @Store NVARCHAR(100), @CashCode NVARCHAR(50);
    DECLARE @Shift NVARCHAR(20), @CheckNum NVARCHAR(20), @Code NVARCHAR(50), @Name NVARCHAR(255);
    DECLARE @UIN NVARCHAR(100), @SaleDate DATE, @SaleTime TIME, @Price NVARCHAR(50), @NetPrice NVARCHAR(50);
    DECLARE @FSerial NVARCHAR(50), @ECTSerial NVARCHAR(50);

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT 
        ISNULL(Duty, 'N/A'),
        [OPERATION TYPE],
        ISNULL(Company, 'N/A'),
        ISNULL([LOCATION], 'N/A'),
        ISNULL([STORE], 'N/A'),
        ISNULL([POS NUMBER], 0),
        ISNULL([SHIFT NUMBER], 0),
        ISNULL([RECEIPT NUMBER], 0),
        ISNULL([ITEM ID], 0),
        ISNULL([ITEM NAME], 'N/A'),
        ISNULL([UIN], 'N/A'),
        [DATE],
        [TIME],
        ISNULL([PRICE], '0'),
        ISNULL([TOTAL], '0'),
        ISNULL([FP SERIAN], 0),
        ISNULL([FM SERIAL], 'N/A')
    FROM gold.v_rep_uin U
    --LEFT JOIN bronze.ref_locations L ON L.LOCATION = U.LOCATION
    WHERE U.[DATE] = @Yesterday
    ORDER BY 
        Duty,
        Company,
        [LOCATION],
        [STORE],
        --U.[CASHCODE],
        [DATE] DESC,
        [TIME] DESC; 

    OPEN cur;
    FETCH NEXT FROM cur INTO @CurDuty, @OpType, @CurCompany, @Location, @Store, @CashCode, 
                              @Shift, @CheckNum, @Code, @Name, @UIN, @SaleDate, @SaleTime, 
                              @Price, @NetPrice, @FSerial, @ECTSerial;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Добавляем заголовок секции при смене Duty или Company
        IF @CurDuty <> @PrevDuty OR @CurCompany <> @PrevCompany
        BEGIN
            SET @tableHTML = @tableHTML + 
                N'<tr class="section-header"><td colspan="14"><b>' +
                CASE @CurDuty WHEN 'DF' THEN 'Duty Free' WHEN 'DP' THEN 'Duty Paid' ELSE @CurDuty END +
                N' — ' + @CurCompany + N'</b></td></tr>';
        END

        -- Строка с данными
        SET @tableHTML = @tableHTML + 
            N'<tr class="' + CASE @CurDuty WHEN 'DF' THEN 'df-row' WHEN 'DP' THEN 'dp-row' ELSE '' END + N'">' +
            N'<td>' + CASE @CurDuty WHEN 'DF' THEN 'DF' WHEN 'DP' THEN 'DP' ELSE @CurDuty END + N'</td>' +
            N'<td>' + @OpType + N'</td>' +
            N'<td>' + @CurCompany + N'</td>' +
            N'<td>' + @Location + N'</td>' +
            N'<td>' + @Store + N'</td>' +
            N'<td>' + @CashCode + N'</td>' +
            N'<td>' + @Shift + N'</td>' +
            N'<td>' + @CheckNum + N'</td>' +
            N'<td>' + @Code + N'</td>' +
            N'<td>' + ISNULL(@Name, '-') + N'</td>' +
            N'<td>' + ISNULL(@UIN, '-') + N'</td>' +
            N'<td>' + CONVERT(NVARCHAR(10), @SaleDate, 104) + N'</td>' +
            N'<td>' + CONVERT(NVARCHAR(8), @SaleTime, 108) + N'</td>' +
            N'<td class="right">' + @Price + N'</td>' +
            N'<td class="right">' + @NetPrice + N'</td>' +
            N'<td>' + @FSerial + N'</td>' +
            N'<td>' + @ECTSerial + N'</td>' +
            N'</tr>';

        SET @PrevDuty = @CurDuty;
        SET @PrevCompany = @CurCompany;
        FETCH NEXT FROM cur INTO @CurDuty, @OpType, @CurCompany, @Location, @Store, @CashCode, 
                                  @Shift, @CheckNum, @Code, @Name, @UIN, @SaleDate, @SaleTime, 
                                  @Price, @NetPrice, @FSerial, @ECTSerial;
    END

    CLOSE cur;
    DEALLOCATE cur;

    -- Закрываем таблицу + футер
    SET @tableHTML = @tableHTML + 
        N'</tbody></table>' +
        N'<p style="text-align:center; color:#999; font-size:10px; margin-top:20px;">' +
        N'Сформировано автоматически системой SSIS • ' + CONVERT(NVARCHAR(19), GETDATE(), 120) +
        N'</p></body></html>';

    -- Отправка письма
    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'SSIS_Mail',
        @recipients = 'cert@regstaer.ru; kolbasinai@regstaer.ru; rozentsvaygmy@regstaer.ru; TolmachevSV@regstaer.ru; Yury.Tiugulev@avolta.net; SorokinMI@regstaer.ru; VorobyevMA@regstaer.ru; KlimovMA@regstaer.ru; hammidulinrr@regstaer.ru; GalaktionovII@regstaer.ru',
        @subject = @mysubject,
        @body = @tableHTML,
        @body_format = 'HTML';
    
    PRINT 'Письмо отправлено. Записей: ' + CAST(@RowCount AS NVARCHAR(10));
END
ELSE
BEGIN
    PRINT 'Нет данных за ' + CONVERT(NVARCHAR(10), @Yesterday, 104) + ' — письмо не отправлено';
END

END
GO
/****** Объект:  StoredProcedure [gold].[usp_SendYandexSplitReport]    Дата создания скрипта: 12.10.2026 10:25:36 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [gold].[usp_SendYandexSplitReport]
    @CompanyCode NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Yesterday DATE = CAST(DATEADD(DAY, -1, GETUTCDATE()) AS DATE);
    DECLARE @TableHTML NVARCHAR(MAX);
    DECLARE @CompanyName NVARCHAR(100);
    DECLARE @Recipients NVARCHAR(500);
    DECLARE @Subject NVARCHAR(200);
    DECLARE @RowCount INT;

    -- 📋 Получаем данные о компании
    SELECT DISTINCT
        @CompanyName = Company, 
        @Recipients = Recipients
    FROM bronze.ref_locations
    WHERE IATA = @CompanyCode;

    IF @CompanyName IS NULL
    BEGIN
        RAISERROR('Компания %s не найдена в bronze.ref_locations', 16, 1, @CompanyCode);
        RETURN;
    END

    SET @Subject = N'Отчёт по оплатам Яндекс.Сплит и СБП - ' + @CompanyName + N' за ' + CONVERT(NVARCHAR(10), @Yesterday, 104);

    -- 📊 Считаем операции (фильтр по компании через ref_locations)
    SELECT @RowCount = COUNT(*) 
    FROM gold.v_rep_yandex V
    INNER JOIN bronze.ref_locations L ON L.StoreCode = LEFT(V.CASHCODE, 3)
    WHERE V.[DATE] >= @Yesterday 
      AND V.[DATE] < DATEADD(DAY, 1, @Yesterday) 
      AND L.Company = @CompanyName;

    -- 🎨 CSS (без изменений)
    SET @TableHTML = N'<html><head><style>' +
        N'table { border-collapse: collapse; width: 100%; font-family: Arial, sans-serif; font-size: 12px; }' +
        N'th { background-color: #2E7D32; color: white; border: 1px solid #ccc; padding: 8px; text-align: left; font-weight: bold; }' +
        N'td { border: 1px solid #ccc; padding: 6px; vertical-align: top; }' +
        N'tr:hover { background-color: #f9f9f9; }' +
        N'.section-header { background-color: #E3F2FD; color: #1565C0; font-weight: bold; font-size: 14px; }' +
        N'.cashier-header { background-color: #F5F5F5; font-weight: bold; color: #333; }' +
        N'.cashier-total { background-color: #FFF3E0; font-weight: bold; color: #E65100; }' +
        N'.section-total { background-color: #C8E6C9; font-weight: bold; color: #2E7D32; font-size: 13px; }' +
        N'.no-data { text-align: center; padding: 50px; color: #999; font-size: 16px; }' +
        N'.right { text-align: right; }' +
        N'</style></head><body>' +
        N'<h2 style="text-align:center; color:#333;">Отчёт по Яндекс.Сплит и СБП за ' + CONVERT(NVARCHAR(10), @Yesterday, 104) + N'</h2>' +
        N'<p style="text-align:center; color:#888; font-size:13px;">Компания: <b>' + @CompanyName + N'</b></p>';

    IF @RowCount > 0
    BEGIN
        SET @TableHTML = @TableHTML + N'<p style="text-align:center; color:#666;">Всего операций: <b>' + CAST(@RowCount AS NVARCHAR(10)) + N'</b></p>' +
            N'<table><thead><tr>' +
            N'<th>Дата</th><th>Тип оплаты</th><th>Операция</th><th>№ Чека</th><th>Магазин</th><th>Сумма</th>' +
            N'</tr></thead><tbody>';

        DECLARE @CurType NVARCHAR(50), @PrevType NVARCHAR(50) = '';
        DECLARE @CurCashier NVARCHAR(100), @PrevCashier NVARCHAR(100) = '';
        DECLARE @CurTRType NVARCHAR(50);
        DECLARE @CurDate DATETIME, @CurCheck INT, @CurStore NVARCHAR(100), @CurSum DECIMAL(18,2);
        DECLARE @CashierTotal DECIMAL(18,2) = 0;
        DECLARE @SectionTotal DECIMAL(18,2) = 0;
        DECLARE @GrandTotal DECIMAL(18,2) = 0;

        DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT 
            V.[PAYMENT_TYPE],
            ISNULL(V.[SNAME], N'Не указан') AS SNAME,
            V.TR_TYPE,
            V.[DATE],
            V.CHECKNUM,
            ISNULL(L.StoreName, N'-') AS STOREDESC,
            CAST(V.[SUMN] AS DECIMAL(18,2)) AS SUMN
        FROM gold.v_rep_yandex V
        INNER JOIN bronze.ref_locations L ON L.StoreCode = LEFT(V.CASHCODE, 3)
        WHERE V.[DATE] >= @Yesterday 
          AND V.[DATE] < DATEADD(DAY, 1, @Yesterday) 
          AND L.Company = @CompanyName
        ORDER BY 
            CASE WHEN V.[PAYMENT_TYPE] IN ('SBP','UNIQR_REUSABLE') THEN 1 ELSE 2 END,
            ISNULL(V.[SNAME], N'Не указан'),
            V.[DATE], V.TR_TYPE, V.CHECKNUM;

        OPEN cur;
        FETCH NEXT FROM cur INTO @CurType, @CurCashier, @CurTRType, @CurDate, @CurCheck, @CurStore, @CurSum;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @SignedSum DECIMAL(18,2) = CASE WHEN @CurTRType = N'Продажа' THEN @CurSum ELSE -@CurSum END;

            IF @CurType <> @PrevType
            BEGIN
                IF @PrevType <> ''
                BEGIN
                    SET @TableHTML = @TableHTML + N'<tr class="section-total"><td colspan="5" style="text-align:right;">Итого по разделу "' + @PrevType + '":</td><td class="right">' + FORMAT(@SectionTotal, 'N2', 'ru-ru') + N' ₽</td></tr>';
                    SET @SectionTotal = 0;
                END
                SET @TableHTML = @TableHTML + N'<tr class="section-header"><td colspan="6">📦 ' + @CurType + N'</td></tr>';
                SET @PrevType = @CurType;
                SET @PrevCashier = '';
            END

            IF @CurCashier <> @PrevCashier
            BEGIN
                IF @PrevCashier <> ''
                BEGIN
                    SET @TableHTML = @TableHTML + N'<tr class="cashier-total"><td colspan="5" style="text-align:right;">Итого по кассиру "' + @PrevCashier + '":</td><td class="right">' + FORMAT(@CashierTotal, 'N2', 'ru-ru') + N' ₽</td></tr>';
                END
                SET @CashierTotal = 0;
                SET @TableHTML = @TableHTML + N'<tr class="cashier-header"><td colspan="6">👤 Кассир: ' + @CurCashier + N'</td></tr>';
                SET @PrevCashier = @CurCashier;
            END

            SET @TableHTML = @TableHTML + N'<tr>' +
                N'<td>' + CONVERT(NVARCHAR(10), @CurDate, 104) + N' ' + CONVERT(NVARCHAR(5), @CurDate, 108) + N'</td>' +
                N'<td>' + @CurType + N'</td>' +
                N'<td style="color:' + CASE WHEN @CurTRType = N'Возврат' THEN '#d32f2f' ELSE '#2E7D32' END + N'; font-weight:bold;">' + @CurTRType + N'</td>' +
                N'<td>' + CAST(@CurCheck AS NVARCHAR) + N'</td>' +
                N'<td>' + @CurStore + N'</td>' +
                N'<td class="right" style="color:' + CASE WHEN @SignedSum < 0 THEN '#d32f2f' ELSE 'inherit' END + N';">' + FORMAT(@SignedSum, 'N2', 'ru-ru') + N' ₽</td>' +
                N'</tr>';

            SET @CashierTotal = @CashierTotal + @SignedSum;
            SET @SectionTotal = @SectionTotal + @SignedSum;
            SET @GrandTotal = @GrandTotal + @SignedSum;

            FETCH NEXT FROM cur INTO @CurType, @CurCashier, @CurTRType, @CurDate, @CurCheck, @CurStore, @CurSum;
        END

        IF @PrevCashier <> ''
            SET @TableHTML = @TableHTML + N'<tr class="cashier-total"><td colspan="5" style="text-align:right;">Итого по кассиру "' + @PrevCashier + '":</td><td class="right">' + FORMAT(@CashierTotal, 'N2', 'ru-ru') + N' ₽</td></tr>';
        
        IF @PrevType <> ''
            SET @TableHTML = @TableHTML + N'<tr class="section-total"><td colspan="5" style="text-align:right;">Итого по разделу "' + @PrevType + '":</td><td class="right">' + FORMAT(@SectionTotal, 'N2', 'ru-ru') + N' ₽</td></tr>';

        SET @TableHTML = @TableHTML + N'<tr style="background-color: #FFCDD2; font-weight: bold; font-size: 14px;"><td colspan="5" style="text-align:right;">ОБЩИЙ ИТОГ (нетто):</td><td class="right">' + FORMAT(@GrandTotal, 'N2', 'ru-ru') + N' ₽</td></tr>';

        CLOSE cur; DEALLOCATE cur;
        SET @TableHTML = @TableHTML + N'</tbody></table>';
    END
    ELSE
    BEGIN
        SET @TableHTML = @TableHTML + 
            N'<div class="no-data">' +
            N'<h3 style="color: #F44336;">😔 Продаж по Яндекс.Сплит и СБП не было</h3>' +
            N'<p>За ' + CONVERT(NVARCHAR(10), @Yesterday, 104) + N' не зафиксировано ни одной операции.</p>' +
            N'</div>';
    END

    SET @TableHTML = @TableHTML + 
        N'<p style="text-align:center; color:#999; font-size:10px; margin-top:20px;">' +
        N'Сформировано автоматически SSIS • ' + CONVERT(NVARCHAR(19), GETDATE(), 120) +
        N'</p></body></html>';

    -- 📧 Отправка
    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'Yandex',
        @recipients = @Recipients,
        @subject = @Subject,
        @body = @TableHTML,
        @body_format = 'HTML';

    PRINT N'✅ ' + @CompanyName + N': отправлено. Операций: ' + CAST(@RowCount AS NVARCHAR(10)) + N'. Итого: ' + FORMAT(ISNULL(@GrandTotal, 0), 'N2', 'ru-ru') + N' ₽';
END
GO
/****** Объект:  StoredProcedure [gold].[usp_SendYandexSplitReports_AllCompanies]    Дата создания скрипта: 12.10.2026 10:25:36 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [gold].[usp_SendYandexSplitReports_AllCompanies]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Yesterday DATE = CAST(DATEADD(DAY, -1, GETUTCDATE()) AS DATE);
    DECLARE @Company NVARCHAR(100);
    DECLARE @Recipients NVARCHAR(500);
    DECLARE @Subject NVARCHAR(200);
    DECLARE @TableHTML NVARCHAR(MAX);
    DECLARE @RowCount INT;
    DECLARE @GrandTotal DECIMAL(18,2);

    -- 📋 Курсор по всем компаниям
    DECLARE company_cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT DISTINCT COMPANY, RECIPIENTS
    FROM bronze.ref_locations
    --WHERE RECIPIENTS IS NOT NULL AND RECIPIENTS <> '';

    OPEN company_cur;
    FETCH NEXT FROM company_cur INTO @Company, @Recipients;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT N'📧 Обработка компании: ' + @Company;

        SET @Subject = N'Отчёт по оплатам Яндекс.Сплит и СБП - ' + @Company + N' за ' + CONVERT(NVARCHAR(10), @Yesterday, 104);
        SET @GrandTotal = 0;

        -- 📊 Считаем количество операций для этой компании
        SELECT @RowCount = COUNT(*) 
        FROM gold.v_rep_yandex V
        INNER JOIN bronze.ref_locations L ON L.StoreCode = LEFT(V.CASHCODE, 3)
        WHERE V.[DATE] >= @Yesterday 
          AND V.[DATE] < DATEADD(DAY, 1, @Yesterday) 
          AND L.COMPANY = @Company AND L.Company != 'DCA';

        -- 🎨 Формируем HTML
        SET @TableHTML = N'<html><head><style>' +
            N'table { border-collapse: collapse; width: 100%; font-family: Arial, sans-serif; font-size: 12px; }' +
            N'th { background-color: #2E7D32; color: white; border: 1px solid #ccc; padding: 8px; text-align: left; font-weight: bold; }' +
            N'td { border: 1px solid #ccc; padding: 6px; vertical-align: top; }' +
            N'tr:hover { background-color: #f9f9f9; }' +
            N'.section-header { background-color: #E3F2FD; color: #1565C0; font-weight: bold; font-size: 14px; }' +
            N'.cashier-header { background-color: #F5F5F5; font-weight: bold; color: #333; }' +
            N'.cashier-total { background-color: #FFF3E0; font-weight: bold; color: #E65100; }' +
            N'.section-total { background-color: #C8E6C9; font-weight: bold; color: #2E7D32; font-size: 13px; }' +
            N'.no-data { text-align: center; padding: 50px; color: #999; font-size: 16px; }' +
            N'.right { text-align: right; }' +
            N'.location-badge { background-color: #E3F2FD; padding: 2px 8px; border-radius: 4px; font-size: 11px; margin-right: 5px; }' +
            N'</style></head><body>' +
            N'<h2 style="text-align:center; color:#333;">Отчёт по Яндекс.Сплит и СБП за ' + CONVERT(NVARCHAR(10), @Yesterday, 104) + N'</h2>' +
            N'<p style="text-align:center; color:#888; font-size:13px;">Компания: <b>' + @Company + N'</b></p>';

        IF @RowCount > 0
        BEGIN
            SET @TableHTML = @TableHTML + N'<p style="text-align:center; color:#666;">Всего операций: <b>' + CAST(@RowCount AS NVARCHAR(10)) + N'</b></p>' +
                N'<table><thead><tr>' +
                N'<th>Дата</th><th>Локация</th><th>Тип оплаты</th><th>Операция</th><th>№ Чека</th><th>Кассир</th><th>Сумма</th>' +
                N'</tr></thead><tbody>';

            DECLARE @CurType NVARCHAR(50), @PrevType NVARCHAR(50) = '';
            DECLARE @CurCashier NVARCHAR(100), @PrevCashier NVARCHAR(100) = '';
            DECLARE @CurTRType NVARCHAR(50);
            DECLARE @CurDate DATETIME, @CurCheck INT, @CurLocation NVARCHAR(100), @CurCashierName NVARCHAR(100), @CurSum DECIMAL(18,2);
            DECLARE @CashierTotal DECIMAL(18,2) = 0;
            DECLARE @SectionTotal DECIMAL(18,2) = 0;

            DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
            SELECT 
                V.[PAYMENT_TYPE],
                ISNULL(V.[SNAME], N'Не указан') AS SNAME,
                V.TR_TYPE,
                V.[DATE],
                V.CHECKNUM,
                ISNULL(L.StoreName, N'-') AS LOCATION,
                CAST(V.[SUMN] AS DECIMAL(18,2)) AS SUMN
            FROM gold.v_rep_yandex V
            INNER JOIN bronze.ref_locations L ON L.StoreCode = LEFT(V.CASHCODE, 3)
            WHERE V.[DATE] >= @Yesterday 
              AND V.[DATE] < DATEADD(DAY, 1, @Yesterday) 
              AND L.COMPANY = @Company AND L.Company != 'DCA'
            ORDER BY 
                CASE WHEN V.[PAYMENT_TYPE] IN ('SBP','UNIQR_REUSABLE') THEN 1 ELSE 2 END,
                L.IATA,
                ISNULL(V.[SNAME], N'Не указан'),
                V.[DATE], V.TR_TYPE, V.CHECKNUM;

            OPEN cur;
            FETCH NEXT FROM cur INTO @CurType, @CurCashierName, @CurTRType, @CurDate, @CurCheck, @CurLocation, @CurSum;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE @SignedSum DECIMAL(18,2) = CASE WHEN @CurTRType = N'Продажа' THEN @CurSum ELSE -@CurSum END;

                -- 🔵 Заголовок секции при смене типа оплаты
                IF @CurType <> @PrevType
                BEGIN
                    IF @PrevType <> ''
                    BEGIN
                        SET @TableHTML = @TableHTML + N'<tr class="section-total"><td colspan="6" style="text-align:right;">Итого по разделу "' + @PrevType + '":</td><td class="right">' + FORMAT(@SectionTotal, 'N2', 'ru-ru') + N' ₽</td></tr>';
                        SET @SectionTotal = 0;
                    END
                    SET @TableHTML = @TableHTML + N'<tr class="section-header"><td colspan="7">📦 ' + @CurType + N'</td></tr>';
                    SET @PrevType = @CurType;
                    SET @PrevCashier = '';
                END

                -- 👤 Заголовок кассира при смене имени
                IF @CurCashierName <> @PrevCashier
                BEGIN
                    IF @PrevCashier <> ''
                    BEGIN
                        SET @TableHTML = @TableHTML + N'<tr class="cashier-total"><td colspan="6" style="text-align:right;">Итого по кассиру "' + @PrevCashier + '":</td><td class="right">' + FORMAT(@CashierTotal, 'N2', 'ru-ru') + N' ₽</td></tr>';
                    END
                    SET @CashierTotal = 0;
                    SET @TableHTML = @TableHTML + N'<tr class="cashier-header"><td colspan="7">👤 Кассир: ' + @CurCashierName + N'</td></tr>';
                    SET @PrevCashier = @CurCashierName;
                END

                -- 📝 Строка с данными
                SET @TableHTML = @TableHTML + N'<tr>' +
                    N'<td>' + CONVERT(NVARCHAR(10), @CurDate, 104) + N' ' + CONVERT(NVARCHAR(5), @CurDate, 108) + N'</td>' +
                    N'<td><span class="location-badge">' + @CurLocation + N'</span></td>' +
                    N'<td>' + @CurType + N'</td>' +
                    N'<td style="color:' + CASE WHEN @CurTRType = N'Возврат' THEN '#d32f2f' ELSE '#2E7D32' END + N'; font-weight:bold;">' + @CurTRType + N'</td>' +
                    N'<td>' + CAST(@CurCheck AS NVARCHAR) + N'</td>' +
                    N'<td>' + @CurCashierName + N'</td>' +
                    N'<td class="right" style="color:' + CASE WHEN @SignedSum < 0 THEN '#d32f2f' ELSE 'inherit' END + N';">' + FORMAT(@SignedSum, 'N2', 'ru-ru') + N' ₽</td>' +
                    N'</tr>';

                SET @CashierTotal = @CashierTotal + @SignedSum;
                SET @SectionTotal = @SectionTotal + @SignedSum;
                SET @GrandTotal = @GrandTotal + @SignedSum;

                FETCH NEXT FROM cur INTO @CurType, @CurCashierName, @CurTRType, @CurDate, @CurCheck, @CurLocation, @CurSum;
            END

            -- 🔚 Последние итоги
            IF @PrevCashier <> ''
                SET @TableHTML = @TableHTML + N'<tr class="cashier-total"><td colspan="6" style="text-align:right;">Итого по кассиру "' + @PrevCashier + '":</td><td class="right">' + FORMAT(@CashierTotal, 'N2', 'ru-ru') + N' ₽</td></tr>';
            
            IF @PrevType <> ''
                SET @TableHTML = @TableHTML + N'<tr class="section-total"><td colspan="6" style="text-align:right;">Итого по разделу "' + @PrevType + '":</td><td class="right">' + FORMAT(@SectionTotal, 'N2', 'ru-ru') + N' ₽</td></tr>';

            SET @TableHTML = @TableHTML + N'<tr style="background-color: #FFCDD2; font-weight: bold; font-size: 14px;"><td colspan="6" style="text-align:right;">ОБЩИЙ ИТОГ (нетто):</td><td class="right">' + FORMAT(@GrandTotal, 'N2', 'ru-ru') + N' ₽</td></tr>';

            CLOSE cur; DEALLOCATE cur;
            SET @TableHTML = @TableHTML + N'</tbody></table>';
        END
        ELSE
        BEGIN
            SET @TableHTML = @TableHTML + 
                N'<div class="no-data">' +
                N'<h3 style="color: #F44336;">😔 Продаж по Яндекс.Сплит и СБП не было</h3>' +
                N'<p>За ' + CONVERT(NVARCHAR(10), @Yesterday, 104) + N' не зафиксировано ни одной операции.</p>' +
                N'</div>';
        END

        SET @TableHTML = @TableHTML + 
            N'<p style="text-align:center; color:#999; font-size:10px; margin-top:20px;">' +
            N'Сформировано автоматически SSIS • ' + CONVERT(NVARCHAR(19), GETDATE(), 120) +
            N'</p></body></html>';

        -- 📧 Отправка письма
        BEGIN TRY
            EXEC msdb.dbo.sp_send_dbmail
                @profile_name = 'Yandex',
                @recipients = @Recipients,
                @subject = @Subject,
                @body = @TableHTML,
                @body_format = 'HTML';
            
            PRINT N'✅ ' + @Company + N': отправлено. Операций: ' + CAST(@RowCount AS NVARCHAR(10)) + N'. Итого: ' + FORMAT(@GrandTotal, 'N2', 'ru-ru') + N' ₽';
        END TRY
        BEGIN CATCH
            PRINT N'❌ Ошибка отправки для ' + @Company + N': ' + ERROR_MESSAGE();
        END CATCH

        FETCH NEXT FROM company_cur INTO @Company, @Recipients;
    END

    CLOSE company_cur;
    DEALLOCATE company_cur;

    PRINT N'🎉 Все отчёты отправлены!';
END
GO
/****** Объект:  StoredProcedure [silver].[usp_LoadSilverOperativeTables]    Дата создания скрипта: 12.10.2026 10:25:36 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [silver].[usp_LoadSilverOperativeTables]
    AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @sql NVARCHAR(MAX);

SET @sql = N'
    INSERT INTO [silver].[oper_cm_payments]
    (
        [UNIQ],[SCODE],[CHECKNUM],[CASHCODE],[SHIFT],[FSHIFT],[FSERIAL],[DATE],[TIME]
      ,[OPCODE],[OP_TYPE],[VALCODE],[VC_TYPE],[VALTYPE],[VT_TYPE]
      ,[NRATE],[VSUM],[SUMB],[SUMN],[SUME],[POSITION],[SERVER],[SNAME]
    )
SELECT P.[UNIQ]
      ,P.[SCODE]
      ,P.[CHECKNUM]
      ,P.[CASHCODE]
      ,P.[SHIFT]
      ,P.[FSHIFT]
      ,P.[FSERIAL]
      ,CAST(P.[DATE] AS DATE) AS [DATE]
      ,LEFT(CAST(P.[TIME] AS TIME), 8) AS [TIME]
      ,P.[OPCODE]
      ,CASE WHEN P.[OPCODE] = 70 THEN N''Принять деньги при продаже''
            WHEN P.[OPCODE] = 72 THEN N''Выдать сдачу при продаже''
            WHEN P.[OPCODE] = 74 THEN N''Выдать деньги при возврате''
            WHEN P.[OPCODE] = 76 THEN N''Принять сдачу при возврате''
            WHEN P.[OPCODE] = 80 THEN N''Внесение денег в кассу''
            WHEN P.[OPCODE] = 82 THEN N''Выем денег''
        END AS [OP_TYPE]
      ,[VALCODE]
      ,CASE WHEN P.[VALCODE] = 1 AND [CASHCODE] NOT LIKE ''28%'' THEN N''Российский рубль''
            WHEN P.[VALCODE] = 1 AND [CASHCODE] LIKE ''28%'' THEN N''Тенге''
            WHEN P.[VALCODE] = 2 THEN N''Доллар США''
            WHEN P.[VALCODE] = 3 THEN N''Евро''
            WHEN P.[VALCODE] = 4 THEN N''Китайский Юань''
            WHEN P.[VALCODE] = 5 AND [CASHCODE] LIKE ''28%'' THEN N''Российский рубль''
            WHEN P.[VALCODE] = 10 THEN N''БанкКарты (Online)''
            WHEN P.[VALCODE] = 20 THEN N''БанкКарты (автономный)''
            WHEN P.[VALCODE] = 21 THEN N''Безнал (автономный) евро''
            WHEN P.[VALCODE] = 22 THEN N''Безнал (автономный) доллар США''
            WHEN P.[VALCODE] = 30 THEN N''Система быстрых платежей QR''
            WHEN P.[VALCODE] = 31 THEN N''СБП Оффлайн''
            WHEN P.[VALCODE] = 32 THEN N''Яндекс Пэй''
        END AS [VC_TYPE]
      ,CASE WHEN P.[VALCODE] IN (1,2,3,4,5) THEN ''1''
            WHEN P.[VALCODE] IN (10,20,21,22) THEN ''2''
            WHEN P.[VALCODE] IN (30,31,32) THEN ''3''
       END AS [VALTYPE]
      ,CASE WHEN P.[VALCODE] IN (1,2,3,4,5) THEN N''Наличные''
            WHEN P.[VALCODE] IN (10,20,21,22) THEN N''Карты''
            WHEN P.[VALCODE] IN (30,31,32) THEN N''QR''
       END AS [VT_TYPE]
      ,CAST(P.[NRATE] AS decimal(10,2)) AS [NRATE]
      ,P.[VSUM]
      ,P.[SUMB]
      ,P.[SUMN]
      ,P.[SUME]
      ,P.[POSITION]
      ,CASE WHEN P.CASHCODE like ''1%'' THEN ''DC1-SRV-KC02''
            WHEN P.CASHCODE like ''28%'' THEN ''DC1-SRV-KC03''
            ELSE ''DC1-SRV-KC01''
        END AS [SERVER]
        ,U.[NAME]
  FROM [DataWarehouse].[bronze].[oper_pos_cm_payments] P
  LEFT JOIN bronze.pos_mol_users U ON U.CODE = P.SCODE AND U.FLAG = (CASE WHEN P.CASHCODE like ''1%'' THEN ''RUDP''
                                                                           WHEN P.CASHCODE like ''28%'' THEN ''KZDF''
                                                                           ELSE ''RUDF'' END)';
EXEC sp_executesql @sql;

SET @sql = N'
INSERT INTO silver.operative_ct_items
(
	[UNIQ],[CHECKNUM],[SCODE],[CASHCODE],[SHIFT],[FSHIFT],[FSERIAL],[DATE],[TIME]
    ,[OPCODE],[OP_TYPE],[BCODE],[NAME],[BQUANT],[CODE],[PRICETYPE_CODE],[PRICETYPE]
    ,[PRICE],[DISC_ABS],[SUMB],[SUMN],[VATRATE1],[VATSUM1],[SERVER]
)
SELECT
     [UNIQ]
    ,[CHECKNUM]
    ,[SCODE]
    ,[CASHCODE]
    ,[SHIFT]
    ,[FSHIFT]
    ,[FSERIAL]
    ,CAST([DATE] AS DATE)
    ,LEFT(CAST([TIME] AS TIME), 8)
    ,[OPCODE]
    ,CASE WHEN [OPCODE] = 50 THEN N''Продажа''
          WHEN [OPCODE] = 58 THEN N''Возврат''
     END AS [OP_TYPE]
    ,[BCODE]
    ,[NAME]
    ,[BQUANT]
    ,[CODE]
    ,[PRICETYPE]
    ,CASE WHEN [PRICETYPE] = ''1'' THEN N''Duty Free''
          WHEN [PRICETYPE] = ''4'' THEN N''Duty Paid''
          WHEN [PRICETYPE] = ''64'' THEN N''Таможенный Союз''
     END AS [PT]
    ,CAST([PRICE] AS decimal(10,2)) AS [PRICE]
    ,CAST([DISC_ABS] AS decimal(10,2)) AS [DISC_ABS]
    ,CAST([SUMB] AS decimal(10,2)) AS [SUMB]
    ,CAST([SUMN] AS decimal(10,2)) AS [SUMN]
    ,[VATRATE1]
    ,CAST([VATSUM1] AS decimal(10,2)) AS [VATSUM1]
    ,CASE WHEN CASHCODE like ''1%'' THEN ''DC1-SRV-KC02''
          WHEN CASHCODE like ''28%'' THEN ''DC1-SRV-KC03''
          ELSE ''DC1-SRV-KC01''
    END AS [SERVER]
FROM
    bronze.operative_pos_ct_items';
EXEC sp_executesql @sql;

END
GO
/****** Объект:  StoredProcedure [silver].[usp_LoadSilverTables]    Дата создания скрипта: 12.10.2026 10:25:36 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [silver].[usp_LoadSilverTables]
    @MonthStart DATE = NULL,
    @MonthEnd   DATE = NULL
    AS
    BEGIN
        SET NOCOUNT ON;
        
        IF @MonthStart IS NULL
            SET @MonthStart = DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(DAY, -1, GETDATE())), 0);
        IF @MonthEnd IS NULL
            SET @MonthEnd = DATEADD(MONTH, 1, @MonthStart);

        DECLARE @sql NVARCHAR(MAX);
        /*================= CURRENT MONTH DELETION =================================================================*/
            DELETE FROM silver.ac_dopdata_yandex     WHERE [DATE]      >= @MonthStart AND [DATE]      < @MonthEnd;
            DELETE FROM silver.aca_fiscaldata        WHERE [DATE]      >= @MonthStart AND [DATE]      < @MonthEnd;
            DELETE FROM silver.acc_receipts          WHERE [DATE_BEG]  >= @MonthStart AND [DATE_BEG]  < @MonthEnd;
            DELETE FROM silver.acl_logins            WHERE [OPDATE]    >= @MonthStart AND [OPDATE]    < @MonthEnd;
            DELETE FROM silver.acm_payments          WHERE [DATE]      >= @MonthStart AND [DATE]      < @MonthEnd;
            DELETE FROM silver.acs_shifts            WHERE [DATEBEGIN] >= @MonthStart AND [DATEBEGIN] < @MonthEnd;
            DELETE FROM silver.act_items             WHERE [DATE]      >= @MonthStart AND [DATE]      < @MonthEnd;
            DELETE FROM silver.ac_dopdata_coupons    WHERE [DATE]      >= @MonthStart AND [DATE]      < @MonthEnd;
            DELETE FROM silver.ac_dopdata_avoltaclub WHERE [DATE]      >= @MonthStart AND [DATE]      < @MonthEnd;
            DELETE FROM silver.ac_dopdata_creditcard WHERE [DATE]      >= @MonthStart AND [DATE]      < @MonthEnd;
            DELETE FROM silver.ac_dopdata_pax        WHERE [DATE]      >= @MonthStart AND [DATE]      < @MonthEnd;
            DELETE FROM silver.ac_dopdata_promonumber WHERE [DATE]     >= @MonthStart AND [DATE]      < @MonthEnd;
            DELETE FROM silver.ac_dopdata_salersip   WHERE [DATE]      >= @MonthStart AND [DATE]      < @MonthEnd;
            DELETE FROM silver.ac_dopdata_uin        WHERE [DATE]      >= @MonthStart AND [DATE]      < @MonthEnd;
            DELETE FROM silver.ac_dopdata_kyfo       WHERE [DATE]      >= @MonthStart AND [DATE]      < @MonthEnd;
        /*===========================================================================================================*/
            TRUNCATE TABLE silver.ref_promoid;   -- full reload for ref table
/*=================================================
INSERT-bloks from Bronze layer to Silver layer
===================================================*/

/*=====1. Yandex data=====*/
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

/*=====2. Fiscal data=====*/
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

/*=====3. Receipts=====*/
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

/*=====4. Cashier logins=====*/
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

/*=====5. Payments=====*/
SET @sql = N'
    INSERT INTO [silver].[acm_payments]
    ([UNIQ],[CHECKNUM],[CASHCODE],[SHIFT],[FSHIFT],[FSERIAL],[DATE],[TIME],[OPCODE],[OP_TYPE]
    ,[VALCODE],[VC_TYPE],[VALTYPE],[VT_TYPE],[NRATE],[VSUM],[SUMB],[SUMN],[SUME],[CHR]
    ,[POSITION],[SERVER],[SNAME]
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
               WHEN [VALCODE] = 40 THEN N''KYFO''
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

/*=====6. Shifts=====*/
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

/*=====7. Sold/Returned items=====*/
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

/*=====8. Promo coupons=====*/
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

/*=====9. Promo AvoltaClub=====*/
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

/*=====10. Credit Card's info=====*/
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

/*=====11. Passenger's data=====*/
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

/*=====12. Promo number=====*/
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

/*=====13. SIP data=====*/
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

/*=====14. UIN data=====*/
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

/*=====15. Reference data for promo=====*/
SET @sql = N'
INSERT INTO [silver].[ref_promoid]
(
    [PROMOID],[Description],[FLAG]
)

SELECT [PROMOID]
     ,[Description]
     ,[FLAG]
FROM [DataWarehouse].[bronze].[ref_promoid]';
EXEC sp_executesql @sql;

/*=====16. KYFO payment data=====*/
SET @sql = N'
INSERT INTO [silver].[ac_dopdata_kyfo]
(
    [UNIQ],[DATE],[CHECKNUM],[CASHCODE],[SHIFT],[ID],[ORDER],[SERVER]
)

SELECT [UNIQ]
     ,CAST([DATE] AS DATE) AS [DATE]
     ,[CHECKNUM]
     ,[CASHCODE]
     ,[SHIFT]
     ,[ID]
     ,[ORDER]
     ,CASE WHEN [CASHCODE] like ''1%'' THEN ''DC1-SRV-KC02''
           WHEN [CASHCODE] like ''28%'' THEN ''DC1-SRV-KC03''
           ELSE ''DC1-SRV-KC01''
    END AS [SERVER]
FROM [DataWarehouse].[bronze].[pos_ac_kyfo]';
EXEC sp_executesql @sql;

END
GO

