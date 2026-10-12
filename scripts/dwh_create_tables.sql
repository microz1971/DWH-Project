USE [DataWarehouse]
GO
/****** Объект:  Table [bronze].[etl_servers]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Объект:  Table [bronze].[oper_pos_cm_payments]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
	[POSITION] [smallint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[operative_pos_ct_items]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[operative_pos_ct_items](
	[UNIQ] [uniqueidentifier] NULL,
	[CHECKNUM] [int] NULL,
	[SCODE] [int] NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[FSHIFT] [smallint] NULL,
	[FSERIAL] [nvarchar](20) NULL,
	[DATE] [datetime] NULL,
	[TIME] [datetime] NULL,
	[OPCODE] [smallint] NULL,
	[BCODE] [nvarchar](20) NULL,
	[NAME] [nvarchar](32) NULL,
	[BQUANT] [decimal](13, 3) NULL,
	[CODE] [int] NULL,
	[PRICETYPE] [nvarchar](32) NULL,
	[PRICE] [decimal](13, 2) NULL,
	[DISC_ABS] [decimal](13, 2) NULL,
	[SUMB] [decimal](13, 2) NULL,
	[SUMN] [decimal](13, 2) NULL,
	[VATRATE1] [decimal](5, 2) NULL,
	[VATSUM1] [decimal](13, 2) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_ac_dopdata]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[pos_ac_dopdata](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[CHECKNUM] [int] NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[GROUP] [nvarchar](50) NULL,
	[DATA] [nvarchar](50) NULL,
	[VALUE] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_ac_kyfo]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[pos_ac_kyfo](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[CHECKNUM] [int] NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[ID] [nvarchar](50) NULL,
	[ORDER] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_aca_fiscaldata]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[pos_aca_fiscaldata](
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
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_acc_receipts]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[pos_acc_receipts](
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
	[DOPDATA] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_acl_logins]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[pos_acl_logins](
	[UNIQ] [uniqueidentifier] NOT NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[SCODE] [int] NULL,
	[SNAME] [nvarchar](32) NULL,
	[OPCODE] [tinyint] NULL,
	[OPDATE] [datetime] NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_acm_payments]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[pos_acm_payments](
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
	[DOPDATA] [nvarchar](max) NULL,
	[CHR] [char](4) NULL,
	[POSITION] [smallint] NULL,
	[SNAME] [nvarchar](150) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_acs_shifts]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[pos_acs_shifts](
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
	[DOPDATA] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_act_items]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[pos_act_items](
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
	[DOPDATA] [nvarchar](max) NULL,
	[SName] [nvarchar](32) NULL,
	[PriceTypeName] [nvarchar](32) NULL,
	[POSITION] [smallint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_avoltaclub_data]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_coupons_data]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[pos_coupons_data](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[POS_NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_creditcard_data]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_mol_users]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[pos_mol_users](
	[CODE] [int] NULL,
	[LOGIN] [nvarchar](20) NULL,
	[NAME] [nvarchar](255) NULL,
	[FLAG] [nvarchar](4) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_pax_data]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[pos_pax_data](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[POS_NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[GROUP] [nvarchar](10) NULL,
	[DATA] [nvarchar](50) NULL,
	[VALUE] [nvarchar](200) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_promonumber_data]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[pos_promonumber_data](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[POS_NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[POSITION] [int] NULL,
	[DATA] [nvarchar](10) NULL,
	[VALUE] [nvarchar](200) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_salersip_data]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[pos_salersip_data](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[POS_NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[POSITION] [int] NULL,
	[DATA] [nvarchar](10) NULL,
	[VALUE] [nvarchar](20) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[pos_uin_data]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[pos_uin_data](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [datetime] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[POS_NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[POSITION] [int] NULL,
	[GROUP] [nvarchar](20) NULL,
	[DATA] [nvarchar](20) NULL,
	[VALUE] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[ref_airlines]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[ref_airlines](
	[CODE] [varchar](2) NOT NULL,
	[Company] [varchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[ref_budgets]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[ref_budgets](
	[Company] [nvarchar](100) NOT NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[BudgetAmount] [bigint] NULL,
 CONSTRAINT [PK_ref_budgets] PRIMARY KEY CLUSTERED 
(
	[Company] ASC,
	[Year] ASC,
	[Month] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[ref_destinationcodes]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[ref_destinationcodes](
	[IATA] [varchar](3) NOT NULL,
	[CITY] [varchar](100) NULL,
	[COUNTRY_CODE] [varchar](2) NULL,
	[COUNTRY_NAME] [varchar](100) NULL,
	[DUTY] [varchar](2) NULL,
PRIMARY KEY CLUSTERED 
(
	[IATA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[ref_item_category]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Объект:  Table [bronze].[ref_locations]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[ref_locations](
	[Location] [varchar](50) NOT NULL,
	[Company] [varchar](100) NOT NULL,
	[Duty] [varchar](2) NOT NULL,
	[StoreCode] [int] NOT NULL,
	[StoreName] [varchar](100) NOT NULL,
	[IATA] [nvarchar](3) NULL,
	[CITY] [nvarchar](50) NULL,
	[RECIPIENTS] [nvarchar](500) NULL,
	[RECIPIENTS_CARDS] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[StoreCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[ref_promoid]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[ref_promoid](
	[PROMOID] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](200) NULL,
	[FLAG] [nvarchar](4) NOT NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [bronze].[ref_sipcoefficient]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [bronze].[ref_sipcoefficient](
	[STORE_CODE] [int] NOT NULL,
	[STORE_NAME] [nvarchar](100) NOT NULL,
	[COEFFICIENT] [float] NULL,
	[PERCENT]  AS ([COEFFICIENT]/(100))
) ON [PRIMARY]
GO
/****** Объект:  Table [dbo].[etl_execution_log]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_execution_log](
	[LogID] [bigint] IDENTITY(1,1) NOT NULL,
	[RunDate] [date] NOT NULL,
	[DateFrom] [date] NULL,
	[DateTo] [date] NULL,
	[Status] [nvarchar](20) NOT NULL,
	[StartedAt] [datetime2](7) NOT NULL,
	[FinishedAt] [datetime2](7) NULL,
	[DurationSec] [int] NULL,
	[BronzeRows] [bigint] NULL,
	[SilverRows] [bigint] NULL,
	[ErrorMessage] [nvarchar](4000) NULL,
PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Объект:  Table [dbo].[refresh_tokens]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[refresh_tokens](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[token_hash] [nvarchar](128) NOT NULL,
	[username] [nvarchar](64) NOT NULL,
	[expires_at] [datetime2](7) NOT NULL,
	[revoked] [bit] NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[token_hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Объект:  Table [gold].[dash_discounts]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [gold].[dash_discounts](
	[YEAR] [int] NULL,
	[QUARTER] [int] NULL,
	[MONTH] [nvarchar](10) NULL,
	[WEEK] [int] NULL,
	[COMPANY] [nvarchar](100) NULL,
	[DUTY] [nvarchar](2) NULL,
	[LOCATION] [nvarchar](100) NULL,
	[STORE] [nvarchar](100) NULL,
	[DATE] [date] NULL,
	[PRICE RUB] [decimal](10, 2) NULL,
	[DISCOUNT RUB] [decimal](10, 2) NULL,
	[TOTAL RUB] [decimal](10, 2) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [gold].[dash_yandex]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [gold].[dash_yandex](
	[YEAR] [int] NULL,
	[QUARTER] [int] NULL,
	[MONTH] [nvarchar](10) NULL,
	[WEEK] [int] NULL,
	[LOCATION] [nvarchar](100) NULL,
	[SALES] [decimal](10, 2) NULL,
	[REFUNDS] [decimal](10, 2) NULL,
	[QTY_SALES] [int] NULL,
	[QTY_REFUNDS] [int] NULL,
	[SALES_SPLIT] [decimal](10, 2) NULL,
	[REFUNDS_SPLIT] [decimal](10, 2) NULL,
	[QTY_SALES_SPLIT] [int] NULL,
	[QTY_REFUNDS_SPLIT] [int] NULL,
	[REVENUE] [decimal](10, 2) NULL,
	[QTY_REVENUE] [int] NULL,
	[REVENUE_SPLIT] [decimal](10, 2) NULL,
	[QTY_REVENUE_SPLIT] [int] NULL,
	[SPLIT_COMM] [decimal](10, 2) NULL,
	[FSP_COMM] [decimal](10, 2) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL,
	[PERIOD_START_DATE] [date] NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [gold].[oper_cm_moneyflow_kz]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [gold].[oper_cm_moneyflow_kz](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LOCATION] [nvarchar](50) NOT NULL,
	[STORE] [nvarchar](50) NOT NULL,
	[POS_NUMBER] [nvarchar](5) NOT NULL,
	[SHIFT_NUMBER] [int] NOT NULL,
	[SHIFT_PART] [nvarchar](100) NULL,
	[DATE] [date] NOT NULL,
	[EUR LOAN] [decimal](10, 2) NULL,
	[EUR SALES] [decimal](10, 2) NULL,
	[EUR REFUND] [decimal](10, 2) NULL,
	[EUR PICKUP] [decimal](10, 2) NULL,
	[USD LOAN] [decimal](10, 2) NULL,
	[USD SALES] [decimal](10, 2) NULL,
	[USD REFUND] [decimal](10, 2) NULL,
	[USD PICKUP] [decimal](10, 2) NULL,
	[KZT LOAN] [decimal](10, 2) NULL,
	[KZT SALES] [decimal](10, 2) NULL,
	[KZT REFUND] [decimal](10, 2) NULL,
	[KZT PICKUP] [decimal](10, 2) NULL,
	[RUB LOAN] [decimal](10, 2) NULL,
	[RUB SALES] [decimal](10, 2) NULL,
	[RUB REFUND] [decimal](10, 2) NULL,
	[RUB PICKUP] [decimal](10, 2) NULL,
	[CNY LOAN] [decimal](10, 2) NULL,
	[CNY SALES] [decimal](10, 2) NULL,
	[CNY REFUND] [decimal](10, 2) NULL,
	[CNY PICKUP] [decimal](10, 2) NULL,
	[CARDS SALES] [decimal](10, 2) NULL,
	[CARDS REFUND] [decimal](10, 2) NULL,
	[OFFLINE CARD SALES] [decimal](10, 2) NULL,
	[OFFLINE CARD REFUND] [decimal](10, 2) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Объект:  Table [gold].[rep_cashiers]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [gold].[rep_cashiers](
	[COMPANY] [nvarchar](30) NULL,
	[LOCATION] [nvarchar](100) NULL,
	[CASHIER] [nvarchar](150) NULL,
	[QTY] [int] NULL,
	[TOTAL] [decimal](20, 2) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL,
	[PERIOD_START_DATE] [date] NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [gold].[rep_destinations]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [gold].[rep_destinations](
	[CITY] [nvarchar](30) NULL,
	[DATE] [date] NULL,
	[DIRECTION] [nvarchar](10) NULL,
	[PRICE_TYPE] [nvarchar](50) NULL,
	[DEPARTURE_CODE] [nvarchar](10) NULL,
	[ARRIVAL_CODE] [nvarchar](10) NULL,
	[DEPARTURE_CITY] [nvarchar](100) NULL,
	[ARRIVAL_CITY] [nvarchar](100) NULL,
	[DEPARTURE_COUNTRY] [nvarchar](100) NULL,
	[ARRIVAL_COUNTRY] [nvarchar](100) NULL,
	[QTY_OF_RECEIPTS] [int] NULL,
	[TOTAL_RUB] [decimal](10, 2) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [gold].[rep_discounts]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [gold].[rep_discounts](
	[COMPANY] [nvarchar](30) NULL,
	[DUTY] [nvarchar](2) NULL,
	[LOCATION] [nvarchar](100) NULL,
	[STORE] [nvarchar](100) NULL,
	[CASHCODE] [nvarchar](10) NULL,
	[CASHIER] [nvarchar](200) NULL,
	[DISCOUNT_CARD] [nvarchar](100) NULL,
	[CHECKNUM] [int] NULL,
	[DATE] [date] NULL,
	[TIME] [nvarchar](8) NULL,
	[ITEM_NAME] [nvarchar](200) NULL,
	[ITEM_CODE] [nvarchar](20) NULL,
	[QUANTITY] [int] NULL,
	[ITEM_PRICE] [decimal](10, 2) NULL,
	[PRICE_AFTER_DISCOUNT] [decimal](10, 2) NULL,
	[DISCOUNT_AMOUNT] [decimal](10, 2) NULL,
	[TOTAL_IN_NATIONAL] [decimal](10, 2) NULL,
	[PROMO_NAME] [nvarchar](200) NULL,
	[AVOLTA_LEVEL] [nvarchar](20) NULL,
	[AVOLTA_ID] [nvarchar](20) NULL,
	[VIP_VOUCHER_CODE] [nvarchar](50) NULL,
	[PARTNER_VOUCHER_CODE] [nvarchar](50) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [gold].[rep_shifts]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [gold].[rep_shifts](
	[DUTY] [nvarchar](2) NULL,
	[COMPANY] [nvarchar](30) NULL,
	[LOCATION] [nvarchar](100) NULL,
	[CASHCODE] [nvarchar](10) NULL,
	[SERIAL_NUMBER] [nvarchar](150) NULL,
	[FISCALSHIFT_NUMBER] [int] NULL,
	[FIRST_CASHIER] [nvarchar](150) NULL,
	[LAST_CASHIER] [nvarchar](150) NULL,
	[SHIFT_STARTED] [date] NULL,
	[SHIFT_ENDED] [date] NULL,
	[REVENUE] [decimal](20, 2) NULL,
	[CASH_REVENUE] [decimal](20, 2) NULL,
	[CARD_REVENUE] [decimal](20, 2) NULL,
	[VAT22] [decimal](20, 2) NULL,
	[VAT10] [decimal](20, 2) NULL,
	[VAT20] [decimal](20, 2) NULL,
	[VAT5] [decimal](20, 2) NULL,
	[VAT7] [decimal](20, 2) NULL,
	[SALES_QTY] [int] NULL,
	[REFUNDs_QTY] [int] NULL,
	[CASH_REFUND] [decimal](20, 2) NULL,
	[CARD_REFUND] [decimal](20, 2) NULL,
	[FR_NUMBER] [nvarchar](10) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL,
	[SHIFT_START_DATE] [date] NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [gold].[rep_uin]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [gold].[rep_uin](
	[OP_TYPE] [nvarchar](10) NULL,
	[ITEM_CODE] [nvarchar](20) NULL,
	[ITEM_NAME] [nvarchar](200) NULL,
	[UIN] [nvarchar](30) NULL,
	[SHIFT] [int] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[COMPANY] [nvarchar](30) NULL,
	[DUTY] [nvarchar](2) NULL,
	[LOCATION] [nvarchar](100) NULL,
	[STORE] [nvarchar](100) NULL,
	[POS_NUMBER] [nvarchar](5) NULL,
	[FP_SERIAL] [nvarchar](20) NULL,
	[FN_SERIAL] [nvarchar](20) NULL,
	[DATE] [date] NULL,
	[TIME] [nvarchar](8) NULL,
	[PRICE] [decimal](10, 2) NULL,
	[TOTAL] [decimal](10, 2) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [gold].[rep_yandex]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [gold].[rep_yandex](
	[DATE] [date] NULL,
	[TIME] [nvarchar](8) NULL,
	[TR_TYPE] [nvarchar](10) NULL,
	[PAYMENT_TYPE] [nvarchar](20) NULL,
	[COMPANY] [nvarchar](30) NULL,
	[DUTY] [nvarchar](2) NULL,
	[LOCATION] [nvarchar](100) NULL,
	[STORE] [nvarchar](100) NULL,
	[CHECKNUM] [int] NULL,
	[CASHCODE] [nvarchar](10) NULL,
	[TOTAL] [decimal](20, 2) NULL,
	[CASHIER] [nvarchar](150) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[ac_dopdata_avoltaclub]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[ac_dopdata_coupons]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [silver].[ac_dopdata_coupons](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [date] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[POS_NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[VALUE] [nvarchar](100) NULL,
	[SERVER] [nvarchar](50) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[ac_dopdata_creditcard]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [silver].[ac_dopdata_creditcard](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [date] NULL,
	[RECEIPT_NUMBER] [int] NULL,
	[NUMBER] [int] NULL,
	[SHIFT_NUMBER] [int] NULL,
	[DATA] [nvarchar](100) NULL,
	[VALUE] [nvarchar](100) NULL,
	[TYPE] [nvarchar](100) NULL,
	[SERVER] [nvarchar](50) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[ac_dopdata_kyfo]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [silver].[ac_dopdata_kyfo](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [date] NULL,
	[CHECKNUM] [int] NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[ID] [nvarchar](100) NULL,
	[ORDER] [nvarchar](100) NULL,
	[SERVER] [nvarchar](50) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[ac_dopdata_pax]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[ac_dopdata_promonumber]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
	[SERVER] [nvarchar](50) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[ac_dopdata_salersip]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
	[SERVER] [nvarchar](50) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[ac_dopdata_uin]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
	[SERVER] [nvarchar](50) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[ac_dopdata_yandex]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [silver].[ac_dopdata_yandex](
	[UNIQ] [uniqueidentifier] NULL,
	[DATE] [date] NULL,
	[CHECKNUM] [int] NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[VALUE] [nvarchar](100) NULL,
	[SERVER] [nvarchar](50) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[aca_fiscaldata]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [silver].[aca_fiscaldata](
	[UNIQ] [uniqueidentifier] NULL,
	[CASHCODE] [smallint] NULL,
	[CHECKNUM] [int] NULL,
	[DATE] [date] NULL,
	[TIME] [time](7) NULL,
	[FSum] [decimal](13, 2) NULL,
	[FSign] [nvarchar](20) NULL,
	[FNFD] [int] NULL,
	[FSHIFT] [smallint] NULL,
	[FNum] [smallint] NULL,
	[FNSERIAL] [nvarchar](20) NULL,
	[SERVER] [nvarchar](50) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[acc_receipts]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [silver].[acc_receipts](
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
	[TIME_BEG] [time](7) NULL,
	[DATE_END] [date] NULL,
	[TIME_END] [time](7) NULL,
	[VBRATE] [decimal](10, 2) NULL,
	[VERATE] [decimal](10, 2) NULL,
	[DISC_PERC] [decimal](5, 2) NULL,
	[DISC_ABS] [decimal](13, 2) NULL,
	[SUMB] [decimal](13, 2) NULL,
	[SUMN] [decimal](13, 2) NULL,
	[SUME] [decimal](13, 2) NULL,
	[PayType] [nvarchar](20) NULL,
	[SERVER] [nvarchar](50) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[acl_logins]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [silver].[acl_logins](
	[UNIQ] [uniqueidentifier] NOT NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[SCODE] [int] NULL,
	[SNAME] [nvarchar](32) NULL,
	[OPCODE] [nvarchar](50) NULL,
	[OPDATE] [datetime] NULL,
	[SERVER] [nvarchar](50) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[acm_payments]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [silver].[acm_payments](
	[UNIQ] [uniqueidentifier] NULL,
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
	[CHR] [char](4) NULL,
	[POSITION] [smallint] NULL,
	[SERVER] [nvarchar](50) NULL,
	[SNAME] [nvarchar](150) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[acs_shifts]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [silver].[acs_shifts](
	[UNIQ] [uniqueidentifier] NOT NULL,
	[CASHCODE] [smallint] NULL,
	[STOREID] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[SCODE] [int] NULL,
	[DATEBEGIN] [date] NULL,
	[TIMEBEGIN] [time](7) NULL,
	[DT_BEG] [datetime] NULL,
	[DATEEND] [date] NULL,
	[TIMEEND] [time](7) NULL,
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
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[act_items]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [silver].[act_items](
	[UNIQ] [uniqueidentifier] NULL,
	[CHECKNUM] [int] NULL,
	[SCODE] [int] NULL,
	[SName] [nvarchar](32) NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[FSHIFT] [smallint] NULL,
	[FSERIAL] [nvarchar](20) NULL,
	[DATE] [date] NULL,
	[TIME] [time](7) NULL,
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
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[oper_cm_payments]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Объект:  Table [silver].[operative_ct_items]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [silver].[operative_ct_items](
	[UNIQ] [uniqueidentifier] NULL,
	[CHECKNUM] [int] NULL,
	[SCODE] [int] NULL,
	[CASHCODE] [smallint] NULL,
	[SHIFT] [smallint] NULL,
	[FSHIFT] [smallint] NULL,
	[FSERIAL] [nvarchar](20) NULL,
	[DATE] [date] NULL,
	[TIME] [time](7) NULL,
	[OPCODE] [smallint] NULL,
	[OP_TYPE] [nvarchar](20) NULL,
	[BCODE] [nvarchar](20) NULL,
	[NAME] [nvarchar](32) NULL,
	[BQUANT] [int] NULL,
	[CODE] [int] NULL,
	[PRICETYPE_CODE] [nvarchar](32) NULL,
	[PRICETYPE] [nvarchar](32) NULL,
	[PRICE] [decimal](13, 2) NULL,
	[DISC_ABS] [decimal](13, 2) NULL,
	[SUMB] [decimal](13, 2) NULL,
	[SUMN] [decimal](13, 2) NULL,
	[VATRATE1] [decimal](5, 2) NULL,
	[VATSUM1] [decimal](13, 2) NULL,
	[SERVER] [nvarchar](50) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Объект:  Table [silver].[ref_promoid]    Дата создания скрипта: 12.10.2026 10:19:25 ******/ 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [silver].[ref_promoid](
	[PROMOID] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](200) NULL,
	[FLAG] [nvarchar](4) NOT NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY]
GO
ALTER TABLE [bronze].[etl_servers] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[etl_execution_log] ADD  DEFAULT (sysdatetime()) FOR [StartedAt]
GO
ALTER TABLE [dbo].[refresh_tokens] ADD  DEFAULT ((0)) FOR [revoked]
GO
ALTER TABLE [dbo].[refresh_tokens] ADD  DEFAULT (sysdatetime()) FOR [created_at]
GO
ALTER TABLE [gold].[dash_discounts] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [gold].[dash_yandex] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [gold].[oper_cm_moneyflow_kz] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [gold].[rep_cashiers] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [gold].[rep_destinations] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [gold].[rep_discounts] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [gold].[rep_shifts] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [gold].[rep_uin] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [gold].[rep_yandex] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[ac_dopdata_avoltaclub] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[ac_dopdata_coupons] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[ac_dopdata_creditcard] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[ac_dopdata_kyfo] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[ac_dopdata_pax] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[ac_dopdata_promonumber] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[ac_dopdata_salersip] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[ac_dopdata_uin] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[ac_dopdata_yandex] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[aca_fiscaldata] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[acc_receipts] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[acl_logins] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[acm_payments] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[acs_shifts] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[act_items] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[oper_cm_payments] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[operative_ct_items] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
ALTER TABLE [silver].[ref_promoid] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO

