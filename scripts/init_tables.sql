/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('bronze.pos_act_items', 'U') IS NOT NULL
    DROP TABLE bronze.pos_act_items;
GO

CREATE TABLE bronze.pos_act_items
(
    [UNIQ] [uniqueidentifier] NULL,
    [CHECKNUM] [int] NULL,
    [SCODE] [int] NULL,
    [CASHCODE] [smallint] NULL,
    [SHIFT] [smallint] NULL,
    [FSHIFT] [smallint] NULL,
    [FSERIAL] [nvarchar](20) NULL,
    [DATE] [datetime] NULL,
    [TIME] [datetime] NULL,
    [DT] [datetime] NULL,
    [OPCODE] [smallint] NULL,
    [BCODE] [nvarchar](20) NULL,
    [NAME] [nvarchar](32) NULL,
    [BQUANT] [decimal](13, 3) NULL,
    [CODE] [int] NULL,
    [PRICE] [decimal](13, 2) NULL,
    [DISC_PERC] [decimal](5, 2) NULL,
    [DISC_ABS] [decimal](13, 2) NULL,
    [SUMI] [decimal](13, 2) NULL,
    [SUMB] [decimal](13, 2) NULL,
    [SUMN] [decimal](13, 2) NULL,
    [SUME] [decimal](13, 2) NULL,
    [VATRATE1] [decimal](5, 2) NULL,
    [VATSUM1] [decimal](13, 2) NULL,
    [SName] [nvarchar](32) NULL,
    [PriceTypeName] [nvarchar](32) NULL,
    [POSITION] [smallint] NULL
);
GO

IF OBJECT_ID('bronze.pos_acc_receipts', 'U') IS NOT NULL
    DROP TABLE bronze.pos_acc_receipts;
GO

CREATE TABLE bronze.pos_acc_receipts
(
    [UNIQ] [uniqueidentifier] NOT NULL,
    [CHECKNUM] [int] NULL,
    [SCODE] [int] NULL,
    [CASHCODE] [smallint] NULL,
    [SHIFT] [smallint] NULL,
    [FSHIFT] [smallint] NULL,
    [FSERIAL] [nvarchar](20) NULL,
    [ECTSERIAL] [nvarchar](16) NULL,
    [ECTCHECK] [int] NULL,
    [DATE_BEG] [datetime] NULL,
    [TIME_BEG] [datetime] NULL,
    [DT_BEG] [datetime] NULL,
    [DATE_END] [datetime] NULL,
    [TIME_END] [datetime] NULL,
    [DT_END] [datetime] NULL,
    [VBRATE] [decimal](13, 4) NULL,
    [VERATE] [decimal](13, 4) NULL,
    [DISC_PERC] [decimal](5, 2) NULL,
    [DISC_ABS] [decimal](13, 2) NULL,
    [SUMB] [decimal](13, 2) NULL,
    [SUMN] [decimal](13, 2) NULL,
    [SUME] [decimal](13, 2) NULL,
    [PayType] [bit] NULL
);
GO

IF OBJECT_ID('bronze.pos_acm_payments', 'U') IS NOT NULL
    DROP TABLE bronze.pos_acm_payments;
GO

CREATE TABLE bronze.pos_acm_payments
(
    [UNIQ] [uniqueidentifier] NULL,
    [CHECKNUM] [int] NULL,
    [CASHCODE] [smallint] NULL,
    [SHIFT] [smallint] NULL,
    [FSHIFT] [smallint] NULL,
    [FSERIAL] [nvarchar](20) NULL,
    [DATE] [datetime] NULL,
    [TIME] [datetime] NULL,
    [DT] [datetime] NULL,
    [OPCODE] [smallint] NULL,
    [VALCODE] [smallint] NULL,
    [VALTYPE] [tinyint] NULL,
    [NRATE] [decimal](13, 4) NULL,
    [VSUM] [decimal](13, 2) NULL,
    [SUMB] [decimal](13, 2) NULL,
    [SUMN] [decimal](13, 2) NULL,
    [SUME] [decimal](13, 2) NULL,
    [CHR] [char](4) NULL,
    [POSITION] [smallint] NULL
);
GO

IF OBJECT_ID('bronze.pos_acs_shifts', 'U') IS NOT NULL
    DROP TABLE bronze.pos_acs_shifts;
GO

CREATE TABLE bronze.pos_acs_shifts
(
    [UNIQ] [uniqueidentifier] NOT NULL,
    [CASHCODE] [smallint] NULL,
    [STOREID] [smallint] NULL,
    [SHIFT] [smallint] NULL,
    [SCODE] [int] NULL,
    [DB] [datetime] NULL,
    [TB] [datetime] NULL,
    [DT_BEG] [datetime] NULL,
    [DE] [datetime] NULL,
    [TE] [datetime] NULL,
    [DT_END] [datetime] NULL,
    [CHECKNUM1] [int] NULL,
    [CHECKNUM2] [int] NULL,
    [FSHIFT] [smallint] NULL,
    [FSERIAL] [nvarchar](20) NULL,
    [ECTSERIAL] [nvarchar](16) NULL,
    [RSSALE] [decimal](13, 2) NULL,
    [RSSALEVOID] [decimal](13, 2) NULL,
    [RSBACK] [decimal](13, 2) NULL,
    [RSBACKVOID] [decimal](13, 2) NULL,
    [RSMIN] [decimal](13, 2) NULL,
    [RSMINVOID] [decimal](18, 0) NULL,
    [RSMOUT] [decimal](13, 2) NULL,
    [RSMOUTVOID] [decimal](18, 0) NULL,
    [RSMINCASS] [decimal](13, 2) NULL,
    [RSMINCASSVOID] [decimal](18, 0) NULL,
    [RCSALE] [int] NULL,
    [RCSALEVOID] [int] NULL,
    [RCBACK] [int] NULL,
    [RCBACKVOID] [int] NULL,
    [RCMIN] [int] NULL,
    [RCMINVOID] [int] NULL,
    [RCMOUT] [int] NULL,
    [RCMOUTVOID] [int] NULL,
    [RCMINCASS] [int] NULL,
    [RCMINCASSVOID] [int] NULL,
    [FSSALE] [decimal](13, 2) NULL,
    [FSSALEVOID] [decimal](18, 0) NULL,
    [FSBACK] [decimal](13, 2) NULL,
    [FSBACKVOID] [decimal](18, 0) NULL,
    [FSMIN] [decimal](18, 0) NULL,
    [FSMINVOID] [decimal](18, 0) NULL,
    [FSMOUT] [decimal](18, 0) NULL,
    [FSMOUTVOID] [decimal](18, 0) NULL,
    [FCSALE] [int] NULL,
    [FCSALEVOID] [int] NULL,
    [FCBACK] [int] NULL,
    [FCBACKVOID] [int] NULL,
    [FCMIN] [int] NULL,
    [FCMINVOID] [int] NULL,
    [FCMOUT] [int] NULL,
    [FCMOUTVOID] [int] NULL,
    [FTOTAL] [decimal](15, 2) NULL,
    [CLOSESHIFT] [datetime] NULL,
    [CCSALE] [decimal](13, 2) NULL,
    [CTSALE] [decimal](13, 2) NULL,
    [CMSALE] [decimal](13, 2) NULL
);
GO

IF OBJECT_ID('bronze.pos_aca_fiscaldata', 'U') IS NOT NULL
    DROP TABLE bronze.pos_aca_fiscaldata;
GO

CREATE TABLE bronze.pos_aca_fiscaldata
(
    [UNIQ] [uniqueidentifier] NULL,
    [CASHCODE] [smallint] NULL,
    [CHECKNUM] [int] NULL,
    [DATE] [datetime] NULL,
    [TIME] [datetime] NULL,
    [FSum] [decimal](13, 2) NULL,
    [FSign] [nvarchar](20) NULL,
    [FNFD] [int] NULL,
    [FSHIFT] [smallint] NULL,
    [FNum] [smallint] NULL,
    [FNSERIAL] [nvarchar](20) NULL,
    [NOSENDDOCDATE] [datetime] NULL,
    [NOSENDDOCTIME] [datetime] NULL,
    [OFDDocNoS] [smallint] NULL,
    [CKKMErr] [smallint] NULL,
    [CPapErr] [smallint] NULL
);
GO

IF OBJECT_ID('bronze.pos_acl_logins', 'U') IS NOT NULL
    DROP TABLE bronze.pos_acl_logins;
GO

CREATE TABLE bronze.pos_acl_logins
(
    [UNIQ] [uniqueidentifier] NOT NULL,
    [CASHCODE] [smallint] NULL,
    [SHIFT] [smallint] NULL,
    [SCODE] [int] NULL,
    [SNAME] [nvarchar](32) NULL,
    [OPCODE] [tinyint] NULL,
    [OPDATE] [datetime] NULL
);
GO

IF OBJECT_ID('bronze.pos_ac_dopdata', 'U') IS NOT NULL
    DROP TABLE bronze.pos_ac_dopdata;
GO

CREATE TABLE bronze.pos_ac_dopdata
(
    [Uniq] [uniqueidentifier] NOT NULL,
    [Position] [smallint] NOT NULL,
    [Number] [smallint] NOT NULL,
    [Name] [nvarchar](100) NULL,
    [Value] [nvarchar](500) NULL
);
GO

IF OBJECT_ID('bronze.ref_dopdata_codes', 'U') IS NOT NULL
    DROP TABLE bronze.ref_dopdata_codes;
GO
CREATE TABLE bronze.ref_dopdata_codes (
    [DataCode] NVARCHAR(50) PRIMARY KEY,
    [Description] NVARCHAR(100)
);
GO

IF OBJECT_ID('bronze.ref_locations', 'U') IS NOT NULL
    DROP TABLE bronze.ref_locations;
GO
CREATE TABLE [bronze].[ref_locations](
	[Location] [varchar](50) NOT NULL,
	[Company] [varchar](100) NOT NULL,
	[Duty] [varchar](2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Location] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE INDEX IX_LOCATION ON [bronze].[ref_locations] (location, company);
GO

IF OBJECT_ID('bronze.pos_ac_dopdata', 'U') IS NOT NULL
    DROP TABLE bronze.pos_ac_dopdata;
GO
CREATE TABLE bronze.pos_ac_dopdata (
    [ID] [int] IDENTITY(1,1) NOT NULL, 
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[CHECKNUM] [int] NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[GROUP] [nvarchar](50) NULL,
	[DATA] [nvarchar](50) NULL,
	[VALUE] [nvarchar](100) NULL,
);
GO
