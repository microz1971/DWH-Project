USE [DataWarehouse]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [silver].[usp_LoadSilverOperativeTables]
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

END
GO
