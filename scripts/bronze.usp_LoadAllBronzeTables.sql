CREATE PROCEDURE bronze.usp_LoadAllBronzeTables
    @SourceServer SYSNAME,
    @DateFrom DATE = '2026-01-01'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX);
  
    -- 1. ACM
    TRUNCATE TABLE bronze.pos_acm_payments;
    SET @sql = N'
    INSERT INTO bronze.pos_acm_payments
    SELECT UNIQ,
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
    POSITION
    
    FROM [' + @SourceServer + '].[CashDB51].[dbo].[ACM]
    WHERE [DATE] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + '''';
    EXEC sp_executesql @sql;
   
    -- 2. ACA
    TRUNCATE TABLE bronze.pos_aca_fiscaldata;
    SET @sql = N'
    INSERT INTO bronze.pos_aca_fiscaldata
    SELECT [UNIQ]
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
      
    FROM [' + @SourceServer + '].[CashDB51].[dbo].[ACA]
    WHERE [DATE] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + '''';
    EXEC sp_executesql @sql;

     
    -- 3. ACL
    TRUNCATE TABLE bronze.pos_acl_logins;
    SET @sql = N'
    INSERT INTO bronze.pos_acl_logins
    SELECT [UNIQ]
      ,[CASHCODE]
      ,[SHIFT]
      ,[SCODE]
      ,[SNAME]
      ,[OPCODE]
      ,[OPDATE]
    FROM [' + @SourceServer + '].[CashDB51].[dbo].[ACL]
    WHERE [OPDATE] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + '''';
    EXEC sp_executesql @sql;

    -- 4. ACT
    TRUNCATE TABLE bronze.pos_act_items;
    SET @sql = N'
    INSERT INTO bronze.pos_act_items
    SELECT UNIQ,
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
    FROM [' + @SourceServer + '].[CashDB51].[dbo].[ACT]
    WHERE [DATE] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + '''';
    EXEC sp_executesql @sql;

    -- 5. ACC
    TRUNCATE TABLE bronze.pos_acc_receipts;
    SET @sql = N'
    INSERT INTO bronze.pos_acc_receipts
    SELECT UNIQ,
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
    FROM [' + @SourceServer + '].[CashDB51].[dbo].[ACC]
    WHERE [DATE_BEG] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + '''';
    EXEC sp_executesql @sql;
   
    -- 6. ACS
    TRUNCATE TABLE bronze.pos_acs_shifts;
    SET @sql = N'
    INSERT INTO bronze.pos_acs_shifts
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
    FROM [' + @SourceServer + '].[CashDB51].[dbo].[ACS]
    WHERE [DT_BEG] >= ''' + CONVERT(NVARCHAR(10), @DateFrom, 120) + '''';
    EXEC sp_executesql @sql;
  
END
