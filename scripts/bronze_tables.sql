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
CREATE TABLE [bronze].[pos_mol_users](
	[CODE] [int] NULL,
	[LOGIN] [nvarchar](20) NULL,
	[NAME] [nvarchar](255) NULL,
	[FLAG] [nvarchar](4) NULL
) ON [PRIMARY]
GO

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
    [POSITION] [smallint] NULL,
	[SNAME] [nvarchar](20) NULL
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

CREATE INDEX IX_pos_salersip_data_UNIQ_POSITION 
ON bronze.pos_salersip_data(UNIQ, [POSITION]) 
INCLUDE ([VALUE]);

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

CREATE INDEX IX_ref_item_category_ITEM_ID 
ON bronze.ref_item_category(ITEM_ID) 
INCLUDE (CATEGORY_CODE, CATEGORY_NAME);

/*==============Locations List==============================================*/	
CREATE TABLE [bronze].[ref_locations](
	[LOCATION] [varchar](50) NOT NULL,
	[COMPANY] [varchar](100) NOT NULL,
	[DUTY] [varchar](2) NOT NULL,
	[StoreCode] [int] NOT NULL,
	[StoreName] [varchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LOCATION] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

INSERT INTO [bronze].[ref_locations]
	([LOCATION], [COMPANY], [DUTY], [StoreCode], [StoreName])
VALUES
('VKO Vnukovo Airport DP','Регстаэр-М','DP',100,'А1516'),
('VKO Vnukovo Airport DP','Регстаэр-М','DP',101,'А19'),
('VKO Vnukovo Airport DP','Регстаэр-М','DP',102,'А20'),
('VKO Vnukovo Airport DP','Регстаэр-М','DP',103,'А21'),
('VKO Vnukovo Airport DP','Регстаэр-М','DP',104,'А22'),
('VKO Vnukovo Airport DP','Регстаэр-М','DP',105,'А23'),
('VKO Vnukovo Airport DP','Регстаэр-М','DP',106,'А24'),
('VKO Vnukovo Airport DP','Регстаэр-М','DP',107,'А25'),
('VKO Vnukovo Airport DP','Регстаэр-М','DP',108,'А26'),
('VKO Vnukovo Airport DP','Регстаэр-М','DP',109,'А27'),
('VKO Vnukovo Airport DP','Регстаэр-М','DP',110,'А29 (Прилет)'),
('VKO Vnukovo Airport DP','Регстаэр-М','DP',111,'А31'),
('DME Domodedovo Airport DP','Регстаэр-В','DP',120,'Arrival Store DP'),
('DME Domodedovo Airport DP','Регстаэр-В','DP',121,'Walkthrough store'),
('DME Domodedovo Airport DP','Регстаэр-В','DP',122,'Sunglasses'),
('DME Domodedovo Airport DP','Регстаэр-В','DP',123,'World of Presents'),
('DME Domodedovo Airport DP','Регстаэр-В','DP',124,'Toys'),
('DME Domodedovo Airport DP','Регстаэр-В','DP',125,'Souvenirs'),
('DME Domodedovo Airport DP','Регстаэр-В','DP',126,'Swarovski C'),
('DME Domodedovo Airport DP','Регстаэр-В','DP',127,'Swarovski D'),
('DME Domodedovo Airport DP','Регстаэр-В','DP',128,'Beauty 1'),
('LED Pulkovo SPb Airport DP','Регстаэр-СП','DP',130,'Walkthrough DP shop'),
('OVB Novosibirsk Airport DP','Регстаэр-Р','DP',140,'Walkthrough store'),
('KGD Kaliningrad Airport DP','Регстаэр-Р','DP',141,'Калининград Магазин'),
('KJA Krasnoyarsk Airport DP','Регстаэр-Р','DP',142,'Duty Paid Shop'),
('MRV Mineralny Vody Airport DP','АэроРегион','DP',151,'Магазин Минводы ДП'),
('STW Stavropol Airport DP','АэроРегион','DP',152,'Duty Paid Shop'),
('MRV Mineralny Vody Airport DP','АэроРегион','DP',153,'MRV Duty&Trendy DP'),
('MRV Mineralny Vody Airport DP','АэроРегион','DP',154,'MRV Duty&Happy DP'),
('AER Sochi Airport DP','Регстаэр-СК','DP',160,'VIP terminal shop'),
('AER Sochi Airport DP','Регстаэр-СК','DP',161,'Sochi Duty Paid Shop'),
('AER Sochi Airport DP','Регстаэр-СК','DP',162,'Sochi Time Box'),
('AER Sochi Airport DP','Регстаэр-СК','DP',163,'Hudson  Common Area'),
('AER Sochi Airport DP','Регстаэр-СК','DP',164,'Hudson Airside'),
('KRR Krasnodar Airport DP','Регстаэр-СК','DP',165,'Krasnodar WT DP'),
('VVO Vladivostok Airport DP','Регстаэр-СК','DP',166,'Vladivostok'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',200,'Внуково АВК А2'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',201,'Внуково АВК А3'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',202,'Внуково АВК А4'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',203,'Внуково АВК А5'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',204,'Внуково АВК А6'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',205,'Внуково АВК А7'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',206,'Внуково АВК А8'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',207,'Внуково АВК А9'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',208,'Внуково АВК А10'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',209,'Внуково АВК А11'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',210,'Внуково АВК А12'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',211,'Внуково АВК А13'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',212,'Внуково АВК А28'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',213,'Внуково АВК А30'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',214,'Внуково-ПШ'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',215,'Внуково 3-1'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',216,'Внуково 3-2'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',217,'Внуково АВК А1'),
('VKO Vnukovo Airport DF','Регстаэр-М','DF',218,'Внуково А6 НОУ СИКРЕТ'),
('DME Domodedovo Airport DF','Регстаэр-В','DF',220,'Core Categories'),
('DME Domodedovo Airport DF','Регстаэр-В','DF',221,'Buy&Fly (63)'),
('DME Domodedovo Airport DF','Регстаэр-В','DF',222,'Arrival store DF'),
('DME Domodedovo Airport DF','Регстаэр-В','DF',223,'P&C, Fashion, LTC'),
('DME Domodedovo Airport DF','Регстаэр-В','DF',224,'Last Minute'),
('LED Pulkovo SPb Airport DF','Регстаэр-СП','DF',230,'Walkthrough DF'),
('LED Pulkovo SPb Airport DF','Регстаэр-СП','DF',231,'Express DF'),
('LED Pulkovo SPb Airport DF','Регстаэр-СП','DF',232,'No Secret DF'),
('LED Pulkovo SPb Airport DF','Регстаэр-СП','DF',233,'Atelier DF'),
('LED Pulkovo SPb Airport DF','Регстаэр-СП','DF',234,'Collection DF'),
('LED Pulkovo SPb Airport DF','Регстаэр-СП','DF',235,'Kids’ Store DF'),
('LED Pulkovo SPb Airport DF','Регстаэр-СП','DF',236,'Hudson DF'),
('LED VIP Shop','Регстаэр-СП','DF',237,'VIP DF'),
('LED Pulkovo SPb Airport DF','Регстаэр-СП','DF',238,'Arrival DF'),
('OVB Novosibirsk Airport DF','Регстаэр-Р','DF',240,'OVB DF store'),
('OVB Novosibirsk Airport DF','Регстаэр-Р','DF',241,'Arrival DF'),
('MRV Mineralny Vody Airport DF','АэроРегион','DF',253,'Минеральные Воды'),
('AER Sochi Airport DF','Регстаэр-СК','DF',260,'DF WT'),
('AER Sochi Airport DF','Регстаэр-СК','DF',261,'Arrival DF'),
('KRR Krasnodar Airport DF','Регстаэр-СК','DF',262,'Krasnodar DF WT'),
('Diplomatic Shop','DCA','DF',280,'Astana Diplomatic Shop'),
('Airport NQZ','DCA','DF',281,'Astana VIP Shop'),
('Airport NQZ','DCA','DF',282,'Astana Spirit of Kazakhstan'),
('Airport NQZ','DCA','DF',283,'Astana Major Shop'),
('Airport NQZ','DCA','DF',284,'Astana DF Arrival')

/*==============PromoHeader Promo ID==============================================*/	
IF OBJECT_ID('bronze.ref_promoid', 'U') IS NOT NULL
    DROP TABLE bronze.ref_promoid;
GO
	
CREATE TABLE [bronze].[ref_promoid](
	[PROMOID] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](200) NULL,
	[FLAG] [nvarchar](4) NULL
) ON [PRIMARY]
GO

/*==============OPERATIVE CM==============================================*/	
CREATE TABLE [bronze].[oper_pos_cm_payments](
	[UNIQ] [uniqueidentifier] NULL,
	[SCODE] [int] NULL,
	[CHECKNUM] [int] NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[FSHIFT] [smallint] NULL,
	[FSERIAL] [nvarchar](20) NULL,
	[DATE] [datetime] NULL,
	[TIME] [datetime] NULL,
	[OPCODE] [smallint] NULL,
	[VALCODE] [smallint] NULL,
	[NRATE] [decimal](13, 4) NULL,
	[VSUM] [decimal](13, 2) NULL,
	[SUMB] [decimal](13, 2) NULL,
	[SUMN] [decimal](13, 2) NULL,
	[SUME] [decimal](13, 2) NULL,
	[DOPDATA] [nvarchar](max) NULL,
	[POSITION] [smallint] NULL,
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/*==============REF IATA Codes==============================================*/
CREATE TABLE [bronze].[ref_destinationcodes](
	[IATA] [varchar](3) NOT NULL,
	[CITY] [varchar](100) NOT NULL,
	[COUNTRY_CODE] [varchar](2) NOT NULL,
	[COUNTRY_NAME] [varchar](100) NOT NULL,
	[DUTY] [varchar](2) NOT NULL

PRIMARY KEY CLUSTERED 
(
	[IATA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/*==============REF Airline Codes==============================================*/
CREATE TABLE [bronze].[ref_airlines](
	[CODE] [varchar](2) NOT NULL,
	[Company] [varchar](100) NOT NULL,
PRIMARY KEY
(
	[CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
