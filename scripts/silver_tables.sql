/*==============YandexPay types==============================================*/	
IF OBJECT_ID('silver.ac_dopdata_yandex', 'U') IS NOT NULL
    DROP TABLE silver.ac_dopdata_yandex;
GO
CREATE TABLE silver.ac_dopdata_yandex (
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[CHECKNUM] [int] NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[GROUP] [nvarchar](50) NULL,
	[DATA] [nvarchar](50) NULL,
	[VALUE] [nvarchar](100) NULL,
  [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
  [SERVER] [nvarchar](50)
);
GO

/*==============ACA Fiscal Data==============================================*/	
IF OBJECT_ID('silver.aca_fiscaldata', 'U') IS NOT NULL
    DROP TABLE silver.aca_fiscaldata;
GO

CREATE TABLE silver.aca_fiscaldata
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
    [CPapErr] [smallint] NULL,
    [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
    [SERVER] [nvarchar](50)
);
GO

/*==============ACC Receipts==============================================*/
IF OBJECT_ID('silver.acc_receipts', 'U') IS NOT NULL
    DROP TABLE silver.acc_receipts;
GO

CREATE TABLE silver.acc_receipts
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
    [PayType] [bit] NULL,
    [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
    [SERVER] [nvarchar](50)
);
GO

/*==============ACL Logins==============================================*/
IF OBJECT_ID('silver.acl_logins', 'U') IS NOT NULL
    DROP TABLE silver.acl_logins;
GO

CREATE TABLE silver.acl_logins
(
    [UNIQ] [uniqueidentifier] NOT NULL,
    [CASHCODE] [smallint] NULL,
    [SHIFT] [smallint] NULL,
    [SCODE] [int] NULL,
    [SNAME] [nvarchar](32) NULL,
    [OPCODE] [tinyint] NULL,
    [OPDATE] [datetime] NULL,
    [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
    [SERVER] [nvarchar](50)
);
GO

/*==============ACM Payments==============================================*/
IF OBJECT_ID('silver.acm_payments', 'U') IS NOT NULL
    DROP TABLE silver.acm_payments;
GO

CREATE TABLE silver.acm_payments
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
    [POSITION] [smallint] NULL,
    [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
    [SERVER] [nvarchar](50)
);
GO

/*==============ACS Shifts==============================================*/
IF OBJECT_ID('silver.acs_shifts', 'U') IS NOT NULL
    DROP TABLE silver.acs_shifts;
GO

CREATE TABLE silver.acs_shifts
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
    [CMSALE] [decimal](13, 2) NULL,
    [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
    [SERVER] [nvarchar](50)
);
GO

/*==============ACT Items==============================================*/
IF OBJECT_ID('silver.act_items', 'U') IS NOT NULL
    DROP TABLE silver.act_items;
GO

CREATE TABLE silver.act_items
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
    [POSITION] [smallint] NULL,
    [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
    [SERVER] [nvarchar](50)
);
GO

/*==============ACDopdata AvoltaClub==============================================*/
IF OBJECT_ID('silver.ac_dopdata_avoltaclub', 'U') IS NOT NULL
    DROP TABLE silver.ac_dopdata_avoltaclub;
GO
	
CREATE TABLE [silver].[ac_dopdata_avoltaclub](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[CHECKNUM] [int] NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[GROUP] [nvarchar](50) NULL,
	[DATA] [nvarchar](50) NULL,
	[VALUE] [nvarchar](100) NULL,
    [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
    [SERVER] [nvarchar](50)
);
GO

/*==============ACDopdata Coupons==============================================*/
IF OBJECT_ID('silver.ac_dopdata_coupons', 'U') IS NOT NULL
    DROP TABLE silver.ac_dopdata_coupons;
GO
	
CREATE TABLE [silver].[ac_dopdata_coupons](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL,
    [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
    [SERVER] [nvarchar](50)
);
GO	

/*==============ACDopdata CC data==============================================*/
IF OBJECT_ID('silver.ac_dopdata_creditcard', 'U') IS NOT NULL
    DROP TABLE silver.ac_dopdata_creditcard;
GO
	
CREATE TABLE [silver].[ac_dopdata_creditcard](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[GROUP] [nvarchar](50) NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL,
  [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
  [SERVER] [nvarchar](50)
);
GO	

/*==============ACDopdata PAX data==============================================*/
IF OBJECT_ID('silver.ac_dopdata_pax', 'U') IS NOT NULL
    DROP TABLE silver.ac_dopdata_pax;
GO
	
CREATE TABLE [silver].[ac_dopdata_pax](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[GROUP] [nvarchar](50) NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL,
  [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
  [SERVER] [nvarchar](50)
);
GO

/*==============ACDopdata Promo Number data==============================================*/
IF OBJECT_ID('silver.ac_dopdata_promonumber', 'U') IS NOT NULL
    DROP TABLE silver.ac_dopdata_promonumber;
GO
	
CREATE TABLE [silver].[ac_dopdata_promonumber](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[POSITION] [nvarchar](50) NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL,
    [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
    [SERVER] [nvarchar](50)
);
GO

/*==============ACDopdata Saler SIP data==============================================*/
IF OBJECT_ID('silver.ac_dopdata_salersip', 'U') IS NOT NULL
    DROP TABLE silver.ac_dopdata_salersip;
GO
	
CREATE TABLE [silver].[ac_dopdata_salersip](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[POSITION] [nvarchar](50) NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL,
  [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
  [SERVER] [nvarchar](50)
);
GO

/*==============ACDopdata UIN data==============================================*/
IF OBJECT_ID('silver.ac_dopdata_uin', 'U') IS NOT NULL
    DROP TABLE silver.ac_dopdata_uin;
GO
	
CREATE TABLE [silver].[ac_dopdata_uin](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[POSITION] [nvarchar](50) NULL,
	[GROUP] [nvarchar](50) NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL,
  [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
  [SERVER] [nvarchar](50)
);
GO

/*==============AC Dopdata Promo ID==============================================*/	
IF OBJECT_ID('silver.ref_promoid', 'U') IS NOT NULL
    DROP TABLE silver.ref_promoid;
GO
	
CREATE TABLE [silver].[ref_promoid](
	[PROMOID] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](200) NULL,
    [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE()
) ON [PRIMARY]
GO
