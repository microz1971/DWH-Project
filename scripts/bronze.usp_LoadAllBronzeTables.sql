CREATE OR ALTER PROCEDURE [bronze].[usp_LoadAllBronzeTables]
    @SourceServer SYSNAME,
    @DateFrom DATE = NULL,
    @DateTo DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    /*=============================================================
      1. Defining the load period

      - No dates were provided -> daily loading by default: YESTERDAY.
        If job is lounched at 07.09 -> @DateFrom = 2026-09-06, @DateTo = 2026-09-07.

      - If both dates were provided -> loading exactly the provided range of dates (for manual/initial loading).

      - If only @DateFrom was provided -> loading full month of @DateFrom.
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

    /*=============================================================
      2. Variables for Dynamic SQL
    =============================================================*/

    DECLARE @sql NVARCHAR(MAX);
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

    /*=============================================================================
      INSERT-bloks
      All source tables in all POS Servers belong to CashDB51 database, schema dbo
    ===============================================================================*/
  
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
