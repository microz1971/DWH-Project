USE [DataWarehouse]
GO

/****** Объект:  StoredProcedure [bronze].[usp_LoadAllBronzeTables]    Дата создания скрипта: 27.05.2026 18:47:22 ******/ 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [bronze].[usp_LoadAllBronzeTables]
    
    
    @SourceServer SYSNAME, -- Will be needed for SSIS Foreach Loop Container to retrieve data from all POS Servers
    @DateFrom DATE = '2026-01-01' -- There was agreement to start data collection from Jan, 1st 2026
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX); -- Dynamic SQL will be used
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
            [DATE] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + '''';
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
            [DATE] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + '''';
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
            [OPDATE] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + '''';
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
            [DATE] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + '''';
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
            [DATE_BEG] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + '''';
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
            [DT_BEG] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + '''';
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
            M.[DATE] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + ''' 
                AND A.[Name] = ''YAST:PAYMETHOD''';
    EXEC sp_executesql @sql;

    -- 8. PROMOID - Reference table with IDs of promo actions
   
    SET @sql = N'
INSERT INTO 
    bronze.ref_promoid
    SELECT 
        [ID], 
        [Name]
    FROM 
        OPENQUERY([' + @SourceServer + '], 
            ''SELECT [ID], [Name] FROM [CashDB51].[dbo].[PromoHeader]'')';
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
        WHERE M.[DATE_BEG] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + ''' 
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
        WHERE M.[DATE] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + ''' 
           AND A.[Name] IN (''INP:CARDNO'', ''INP:CARDTYPE'', ''SB:CARDNO'', ''SB:CARDTYPE'')';
    EXEC sp_executesql @sql;

    -- 10. ACDOPDATA Coupons Data (Vouchers)
   
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
        WHERE M.[DATE_BEG] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + ''' 
            AND A.[Name] IN (''PDCARDC'')';
    EXEC sp_executesql @sql;

    -- 11. ACDOPDATA PAX Data (Passengers)
   
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
        WHERE M.[DATE_BEG] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + ''' 
            AND A.[Name] IN (''RS:NAM'', ''RS:DP'', ''RS:DS'', ''RS:FL'', ''RS:NPT'', ''RS:NST'', ''RS:PPS'')';
    EXEC sp_executesql @sql;

    -- 12. ACDOPDATA PromoNumber Data
   
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
     WHERE M.[DATE] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + ''' 
       AND   A.[Name] IN (''PROMODISC'') and M.[DOPDATA] like ''%PROMODISC%'' and A.[Position] = M.[Position]';
 EXEC sp_executesql @sql;

    -- 13. ACDOPDATA SALER SIP Data
   
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
        WHERE M.[DATE] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + ''' 
           AND A.[Name] = (''SALER'') and M.[DOPDATA] like ''%SALER%'' and A.[Position] = M.[Position]';
    EXEC sp_executesql @sql;

     -- 13. ACDOPDATA UIN Data
   
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
        WHERE M.[DATE] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + ''' 
            AND A.[Name] = (''DMDK:UIN'') and A.[Position] = M.[Position]';
    EXEC sp_executesql @sql;

-- 14. MOL Users
SET @sql = N'
INSERT INTO 
    bronze.pos_mol_users
    SELECT 
       [CODE]
      ,[LOGIN]
      ,[NAME]
    FROM 
        [DC1-SRV-KC01].[CashDB51].[dbo].[MOL]';
EXEC sp_executesql @sql;

    SET @sql = N'
INSERT INTO 
    bronze.pos_mol_users
    SELECT 
       [CODE]
      ,[LOGIN]
      ,[NAME]
    FROM 
        [DC1-SRV-KC03].[CashDB51].[dbo].[MOL]';
EXEC sp_executesql @sql;

END
GO
