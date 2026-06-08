/*==============YandexPay types==============================================*/	
IF OBJECT_ID('silver.ac_dopdata_yandex', 'U') IS NOT NULL
    DROP TABLE silver.ac_dopdata_yandex;
GO
CREATE TABLE silver.ac_dopdata_yandex (
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [date] NULL,
	[CHECKNUM] [int] NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[VALUE] [nvarchar](100) NULL,
	[SERVER] [nvarchar](50),
    [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
  
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
    [DATE] [date] NULL,
    [TIME] [time] NULL,
    [FSum] [decimal](13, 2) NULL,
    [FSign] [nvarchar](20) NULL,
    [FNFD] [int] NULL,
    [FSHIFT] [smallint] NULL,
    [FNum] [smallint] NULL,
    [FNSERIAL] [nvarchar](20) NULL,
    [SERVER] [nvarchar](50),
    [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE()  
);
GO
/*==============ACC Receipts==============================================*/
IF OBJECT_ID('silver.acc_receipts', 'U') IS NOT NULL
    DROP TABLE silver.acc_receipts;
GO

CREATE TABLE silver.acc_receipts
(
    [UNIQ] [uniqueidentifier] NOT NULL,
[TR_TYPE] [nvarchar](20) NULL,
[CHECKNUM] [int] NULL,
[SCODE] [int] NULL,
[CASHCODE] [smallint] NULL,
[SHIFT] [smallint] NULL,
[FSHIFT] [smallint] NULL,
[FSERIAL] [nvarchar](20) NULL,
[ECTSERIAL] [nvarchar](16) NULL,
[ECTCHECK] [int] NULL,
[DATE_BEG] [date] NULL,
[TIME_BEG] [time] NULL,
[DATE_END] [date] NULL,
[TIME_END] [time] NULL,
[VBRATE] [decimal](10, 2) NULL,
[VERATE] [decimal](10, 2) NULL,
[DISC_PERC] [decimal](5, 2) NULL,
[DISC_ABS] [decimal](13, 2) NULL,
[SUMB] [decimal](13, 2) NULL,
[SUMN] [decimal](13, 2) NULL,
[SUME] [decimal](13, 2) NULL,
[PayType] [nvarchar](20) NULL,
[SERVER] [nvarchar](50) NULL,
[DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE()
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
[OPCODE] [nvarchar](50) NULL,
[OPDATE] [datetime] NULL,
[SERVER] [nvarchar](50) NULL,
[DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE()	
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
[DATE] [date] NULL,
[TIME] [time] NULL,
[OPCODE] [smallint] NULL,
[OP_TYPE] [nvarchar](200) NULL,
[VALCODE] [smallint] NULL,
[VC_TYPE] [nvarchar](200) NULL,
[VALTYPE] [tinyint] NULL,
[VT_TYPE] [nvarchar](50) NULL,
[NRATE] [decimal](10, 2) NULL,
[VSUM] [decimal](13, 2) NULL,
[SUMB] [decimal](13, 2) NULL,
[SUMN] [decimal](13, 2) NULL,
[SUME] [decimal](13, 2) NULL,
[CHR] [char](4) NULL,
[POSITION] [smallint] NULL,
[SNAME] [nvarchar](150) NULL,
[SERVER] [nvarchar](50) NULL,
[DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE()
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
[DATEBEGIN] [date] NULL,
[TIMEBEGIN] [time] NULL,
[DT_BEG] [datetime] NULL,
[DATEEND] [date] NULL,
[TIMEEND] [time] NULL,
[DT_END] [datetime] NULL,
[CHECKNUM1] [int] NULL,
[RECEIPTS_QTY] [int] NULL,
[FSHIFT] [smallint] NULL,
[FSERIAL] [nvarchar](20) NULL,
[ECTSERIAL] [nvarchar](16) NULL,
[RSSALE] [decimal](13, 2) NULL,
[RSBACK] [decimal](13, 2) NULL,
[RSMIN] [decimal](13, 2) NULL,
[RSMOUT] [decimal](13, 2) NULL,
[RCSALE] [int] NULL,
[RCBACK] [int] NULL,
[RCMIN] [int] NULL,
[RCMOUT] [int] NULL,
[FSSALE] [decimal](13, 2) NULL,
[FSBACK] [decimal](13, 2) NULL,
[FSMIN] [decimal](18, 0) NULL,
[FSMOUT] [decimal](18, 0) NULL,
[FCSALE] [int] NULL,
[FCBACK] [int] NULL,
[FCMIN] [int] NULL,
[FCMOUT] [int] NULL,
[FTOTAL] [decimal](15, 2) NULL,
[CLOSESHIFT] [datetime] NULL,
[CCSALE] [decimal](13, 2) NULL,
[CTSALE] [decimal](13, 2) NULL,
[CMSALE] [decimal](13, 2) NULL,
[SERVER] [nvarchar](50) NULL,
[DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE()
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
[SName] [nvarchar](32) NULL,
[CASHCODE] [smallint] NULL,
[SHIFT] [smallint] NULL,
[FSHIFT] [smallint] NULL,
[FSERIAL] [nvarchar](20) NULL,
[DATE] [date] NULL,
[TIME] [time] NULL,
[OPCODE] [smallint] NULL,
[OP_TYPE] [nvarchar](20) NULL,
[PriceTypeName] [nvarchar](32) NULL,
[BCODE] [nvarchar](20) NULL,
[NAME] [nvarchar](32) NULL,
[BQUANT] [int] NULL,
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
[POSITION] [smallint] NULL,
[SERVER] [nvarchar](50) NULL,
[DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE()
);
GO
/*==============ACDopdata AvoltaClub==============================================*/
IF OBJECT_ID('silver.ac_dopdata_avoltaclub', 'U') IS NOT NULL
    DROP TABLE silver.ac_dopdata_avoltaclub;
GO
	
CREATE TABLE [silver].[ac_dopdata_avoltaclub](
	[UNIQ] [uniqueidentifier] NULL,
[DATE] [date] NULL,
[CHECKNUM] [int] NULL,
[CASHCODE] [smallint] NULL,
[SHIFT] [smallint] NULL,
[DATA] [nvarchar](50) NULL,
[TYPE] [nvarchar](50) NULL,
[VALUE] [nvarchar](100) NULL,
[SERVER] [nvarchar](50) NULL,
[DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE()
);
GO
/*==============ACDopdata Coupons==============================================*/
IF OBJECT_ID('silver.ac_dopdata_coupons', 'U') IS NOT NULL
    DROP TABLE silver.ac_dopdata_coupons;
GO
	
CREATE TABLE [silver].[ac_dopdata_coupons](
	[UNIQ] [uniqueidentifier] NULL,
[DATE] [date] NULL,
[RECEIPT_NUMBER] [int] NULL,
[POS_NUMBER] [int] NULL,
[SHIFT_NUMBER] [int] NULL,
[VALUE] [nvarchar](100) NULL,
[SERVER] [nvarchar](50) NULL,
[DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE()
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
	[DATA] [nvarchar](100) NULL,
	[TYPE] [nvarchar](50) NULL,
	[VALUE] [nvarchar](100) NULL,
	[SERVER] [nvarchar](50),
  [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE()
  
);
GO	
/*==============ACDopdata PAX data==============================================*/
IF OBJECT_ID('silver.ac_dopdata_pax', 'U') IS NOT NULL
    DROP TABLE silver.ac_dopdata_pax;
GO
	
CREATE TABLE [silver].[ac_dopdata_pax](
	[UNIQ] [uniqueidentifier] NULL,
[DATE] [date] NULL,
[RECEIPT_NUMBER] [int] NULL,
[NUMBER] [int] NULL,
[SHIFT_NUMBER] [int] NULL,
[DATA] [nvarchar](100) NULL,
[TYPE] [nvarchar](100) NULL,
[VALUE] [nvarchar](100) NULL,
[SERVER] [nvarchar](50) NULL,
[DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE()
);
GO
/*==============ACDopdata Promo Number data==============================================*/
IF OBJECT_ID('silver.ac_dopdata_promonumber', 'U') IS NOT NULL
    DROP TABLE silver.ac_dopdata_promonumber;
GO
	
CREATE TABLE [silver].[ac_dopdata_promonumber](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [date] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[POSITION] [nvarchar](50) NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL,
	[SERVER] [nvarchar](50),
    [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
    
);
GO
/*==============ACDopdata Saler SIP data==============================================*/
IF OBJECT_ID('silver.ac_dopdata_salersip', 'U') IS NOT NULL
    DROP TABLE silver.ac_dopdata_salersip;
GO
	
CREATE TABLE [silver].[ac_dopdata_salersip](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [date] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[POSITION] [nvarchar](50) NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL,
	[SERVER] [nvarchar](50),
  [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
  
);
GO
/*==============ACDopdata UIN data==============================================*/
IF OBJECT_ID('silver.ac_dopdata_uin', 'U') IS NOT NULL
    DROP TABLE silver.ac_dopdata_uin;
GO
	
CREATE TABLE [silver].[ac_dopdata_uin](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [date] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[POSITION] [nvarchar](50) NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL,
	[SERVER] [nvarchar](50),
  [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE(),
  
);
GO
/*==============AC Dopdata Promo ID==============================================*/	
IF OBJECT_ID('silver.ref_promoid', 'U') IS NOT NULL
    DROP TABLE silver.ref_promoid;
GO
	
CREATE TABLE [silver].[ref_promoid](
	[PROMOID] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](200) NULL,
	[FLAG] [nvarchar](4) NULL,
    [DWH_CREATE_DATE] [datetime2] DEFAULT GETDATE()
) ON [PRIMARY]
GO
/*==============OPER CM==============================================*/	
CREATE TABLE [silver].[oper_cm_payments](
	[UNIQ] [uniqueidentifier] NULL,
	[SCODE] [int] NULL,
	[CHECKNUM] [int] NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[FSHIFT] [smallint] NULL,
	[FSERIAL] [nvarchar](20) NULL,
	[DATE] [date] NULL,
	[TIME] [time](7) NULL,
	[OPCODE] [smallint] NULL,
	[OP_TYPE] [nvarchar](200) NULL,
	[VALCODE] [smallint] NULL,
	[VC_TYPE] [nvarchar](200) NULL,
	[VALTYPE] [tinyint] NULL,
	[VT_TYPE] [nvarchar](50) NULL,
	[NRATE] [decimal](10, 2) NULL,
	[VSUM] [decimal](13, 2) NULL,
	[SUMB] [decimal](13, 2) NULL,
	[SUMN] [decimal](13, 2) NULL,
	[SUME] [decimal](13, 2) NULL,
	[POSITION] [smallint] NULL,
	[SERVER] [nvarchar](50) NULL,
	[SNAME] [nvarchar](150) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO

ALTER TABLE [silver].[oper_cm_payments] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
