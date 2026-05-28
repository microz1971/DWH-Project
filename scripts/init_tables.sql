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
/*
===========For SSIS Connection Strings=========================================
*/
CREATE TABLE [bronze].[etl_servers](
	[ServerName] [varchar](50) NOT NULL,
	[ConnectionString] [nvarchar](500) NOT NULL,
	[IsActive] [bit] NULL,
	[HomeCountry] [nvarchar](2) NULL,
	[AirportList] [nvarchar](max) NULL,
	[CISList] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ServerName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

INSERT INTO 
	[bronze].[etl_servers]
	([ServerName], [ConnectionString],[IsActive], [HomeCountry], [AirportList], [CISList])
	VALUES
	('DC1-SRV-KC01', 'Data Source=DC1-SRV-KC01;Initial Catalog=CashDB51;Provider=SQLOLEDB;Integrated Security=SSPI;Auto Translate=False;', 1, 'RU',	'DME,LED,VKO,AER,KRR,OVB,MRV,KGD,KJA,STW,VVO',	'AM,KZ,KG,BY')
	('DC1-SRV-KC02', 'Data Source=DC1-SRV-KC02;Initial Catalog=CashDB51;Provider=SQLOLEDB;Integrated Security=SSPI;Auto Translate=False;', 1, 'RU',	'DME,LED,VKO,AER,KRR,OVB,MRV,KGD,KJA,STW,VVO',	'AM,KZ,KG,BY')
	('DC1-SRV-KC03', 'Data Source=DC1-SRV-KC03;Initial Catalog=CashDB51;Provider=SQLOLEDB;Integrated Security=SSPI;Auto Translate=False;', 1, 'KZ',	'NQZ',	'AM,RU,KG,BY')
	
ALTER TABLE [bronze].[etl_servers] ADD  DEFAULT ((1)) FOR [IsActive]
GO

/*==============YandexPay types==============================================*/	
IF OBJECT_ID('bronze.pos_ac_dopdata', 'U') IS NOT NULL
    DROP TABLE bronze.pos_ac_dopdata;
GO
CREATE TABLE bronze.pos_ac_dopdata (
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

/*==============ACA Fiscal Data==============================================*/	
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

/*==============ACC Receipts==============================================*/
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

/*==============ACL Logins==============================================*/
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

/*==============ACM Payments==============================================*/
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

/*==============ACS Shifts==============================================*/
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

/*==============ACT Items==============================================*/
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

/*==============ACDopdata AvoltaClub==============================================*/
IF OBJECT_ID('bronze.pos_avoltaclub_data', 'U') IS NOT NULL
    DROP TABLE bronze.pos_avoltaclub_data;
GO
	
CREATE TABLE [bronze].[pos_avoltaclub_data](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[CHECKNUM] [int] NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[GROUP] [nvarchar](50) NULL,
	[DATA] [nvarchar](50) NULL,
	[VALUE] [nvarchar](100) NULL
);
GO

/*==============ACDopdata Coupons==============================================*/
IF OBJECT_ID('bronze.pos_coupons_data', 'U') IS NOT NULL
    DROP TABLE bronze.pos_coupons_data;
GO
	
CREATE TABLE [bronze].[pos_coupons_data](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[POS_NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL
);
GO	

/*==============ACDopdata CC data==============================================*/
IF OBJECT_ID('bronze.pos_creditcard_data', 'U') IS NOT NULL
    DROP TABLE bronze.pos_creditcard_data;
GO
	
CREATE TABLE [bronze].[pos_creditcard_data](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[POS_NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[GROUP] [nvarchar](50) NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL
);
GO	

/*==============ACDopdata PAX data==============================================*/
IF OBJECT_ID('bronze.pos_pax_data', 'U') IS NOT NULL
    DROP TABLE bronze.pos_pax_data;
GO
	
CREATE TABLE [bronze].[pos_pax_data](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[POS_NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[GROUP] [nvarchar](50) NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL
);
GO

/*==============ACDopdata Promo Number data==============================================*/
IF OBJECT_ID('bronze.pos_promonumber_data', 'U') IS NOT NULL
    DROP TABLE bronze.pos_promonumber_data;
GO
	
CREATE TABLE [bronze].[pos_promonumber_data](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[POS_NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[POSITION] [nvarchar](50) NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL
);
GO

/*==============ACDopdata Saler SIP data==============================================*/
IF OBJECT_ID('bronze.pos_salersip_data', 'U') IS NOT NULL
    DROP TABLE bronze.pos_salersip_data;
GO
	
CREATE TABLE [bronze].[pos_salersip_data](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[POS_NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[POSITION] [nvarchar](50) NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL
);
GO

/*==============ACDopdata UIN data==============================================*/
IF OBJECT_ID('bronze.pos_uin_data', 'U') IS NOT NULL
    DROP TABLE bronze.pos_uin_data;
GO
	
CREATE TABLE [bronze].[pos_uin_data](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[POS_NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[POSITION] [nvarchar](50) NULL,
	[GROUP] [nvarchar](50) NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL
);
GO

/*==============Item Category data==============================================*/	
CREATE TABLE [bronze].[ref_item_category](
	[ITEM_ID] [nvarchar](50) NOT NULL,
	[ITEM_NAME] [nvarchar](255) NOT NULL,
	[CATEGORY_CODE] [int] NOT NULL,
	[CATEGORY_NAME] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_ref_item_category] PRIMARY KEY CLUSTERED 
(
	[ITEM_ID] ASC,
	[CATEGORY_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/*==============Locations List==============================================*/	
CREATE TABLE [bronze].[ref_locations](
	[LOCATION] [varchar](50) NOT NULL,
	[COMPANY] [varchar](100) NOT NULL,
	[DUTY] [varchar](2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LOCATION] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

INSERT INTO [bronze].[ref_locations]
	([LOCATION], [COMPANY], [DUTY])
VALUES
	('AER Sochi Airport DF', 'Регстаэр-СК',	'DF')
	('AER Sochi Airport DP', 'Регстаэр-СК',	'DP')
	('Airport NQZ',	'DCA',	'DF')
	('Diplomatic Shop',	'DCA',	'DF')
	('DME Domodedovo Airport DF', 'Регстаэр-В',	'DF')
	('DME Domodedovo Airport DP', 'Регстаэр-В',	'DP')
	('KGD Kaliningrad Airport DP', 'Регстаэр-Р', 'DP')
	('KJA Krasnoyarsk Airport DP', 'Регстаэр-Р', 'DP')
	('KRR Krasnodar Airport DF', 'Регстаэр-СК',	'DF')
	('KRR Krasnodar Airport DP', 'Регстаэр-СК',	'DP')
	('LED Pulkovo SPb Airport DF', 'Регстаэр-СП', 'DF')
	('LED Pulkovo SPb Airport DP', 'Регстаэр-СП', 'DP')
	('LED VIP Shop', 'Регстаэр-СП',	'DF')
	('MRV Mineralny Vody Airport DF', 'АэроРегион',	'DF')
	('MRV Mineralny Vody Airport DP', 'АэроРегион',	'DP')
	('OVB Novosibirsk Airport DF', 'Регстаэр-Р', 'DF')
	('OVB Novosibirsk Airport DP', 'Регстаэр-Р', 'DP')
	('STW Stavropol Airport DP', 'АэроРегион', 'DP')
	('VKO Vnukovo Airport DF', 'Регстаэр-М', 'DF')
	('VKO Vnukovo Airport DP', 'Регстаэр-М', 'DP')
	('VVO Vladivostok Airport DP', 'Регстаэр-СК', 'DP')

/*==============AC Dopdata Promo ID==============================================*/	
IF OBJECT_ID('bronze.ref_promoid', 'U') IS NOT NULL
    DROP TABLE bronze.ref_promoid;
GO
	
CREATE TABLE [bronze].[ref_promoid](
	[PROMOID] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](200) NULL
) ON [PRIMARY]
GO
