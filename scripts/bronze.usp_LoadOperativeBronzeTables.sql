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
      ,[SUME]
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
