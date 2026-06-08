/*==============REPORT: Cashiers==============================================*/	
IF OBJECT_ID('[gold].[rep_cashiers]', 'U') IS NOT NULL
    DROP TABLE [gold].[rep_cashiers];
GO
CREATE TABLE [gold].[rep_cashiers](
    [COMPANY] [nvarchar](30) NULL,
    [LOCATION] [nvarchar](100) NULL,
    [CASHIER] [nvarchar](150) NULL,
    [QTY] [int] NULL,
    [TOTAL] [decimal](20, 2) NULL,
    [DWH_CREATE_DATE] [datetime2] NULL
) ON [PRIMARY];
GO
ALTER TABLE [gold].[rep_cashiers] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE];
GO
CREATE INDEX IX_COMPANY_CASHIER ON gold.rep_cashiers(COMPANY, CASHIER);
GO

/*==============REPORT: Shifts==============================================*/	
IF OBJECT_ID('[gold].[rep_shifts]', 'U') IS NOT NULL
    DROP TABLE [gold].[rep_shifts];
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
  [DWH_CREATE_DATE] [datetime2](7) NULL

) ON [PRIMARY];
GO
ALTER TABLE [gold].[rep_shifts] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE];
GO
CREATE INDEX IX_FSHIFT_COMPANY ON [gold].[rep_shifts](FISCALSHIFT_NUMBER, COMPANY);
GO

/*==============REPORT: Yandex==============================================*/	
IF OBJECT_ID('[gold].[rep_yandex]', 'U') IS NOT NULL
    DROP TABLE [gold].[rep_yandex];
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
ALTER TABLE [gold].[rep_yandex] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO
CREATE INDEX IX_YandexTable ON [gold].[rep_yandex]([COMPANY], [DATE], [CASHIER])

/*==============DASH: Yandex==============================================*/	
IF OBJECT_ID('[gold].[dash_yandex]', 'U') IS NOT NULL
    DROP TABLE [gold].[dash_yandex];
GO
CREATE TABLE [gold].[dash_yandex](
  [LOCATION] [nvarchar](100) NULL,
  [SALES] [decimal](10,2) NULL,
  [REFUNDS] [decimal](10,2) NULL,
  [QTY_SALES] [int] NULL,
  [QTY_REFUNDS] [int] NULL,
  [SALES_SPLIT] [decimal](10,2) NULL,
  [REFUNDS_SPLIT] [decimal](10,2) NULL,
  [QTY_SALES_SPLIT] [int] NULL,
  [QTY_REFUNDS_SPLIT] [int] NULL,
  [REVENUE] [decimal](10,2) NULL,
  [QTY_REVENUE] [int] NULL,
  [REVENUE_SPLIT] [decimal](10,2) NULL,
  [QTY_REVENUE_SPLIT] [int] NULL,
  [SPLIT_COMM] [decimal](10,2) NULL,
  [FSP_COMM] [decimal](10,2) NULL,
  [DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY];
GO
ALTER TABLE [gold].[dash_yandex] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE];
GO
CREATE INDEX IX_Y_Location ON [gold].[dash_yandex]([LOCATION]);
GO

/*==============OPERATIVE: Money Flow for KZ==============================================*/	
IF OBJECT_ID('[gold].[oper_cm_moneyflow_kz]', 'U') IS NOT NULL
    DROP TABLE [gold].[oper_cm_moneyflow_kz];
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
ALTER TABLE [gold].[oper_cm_moneyflow_kz] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE]
GO

/*==============REPORT: UIN==============================================*/	
IF OBJECT_ID('[gold].[rep_uin]', 'U') IS NOT NULL
    DROP TABLE [gold].[rep_uin];
USE [DataWarehouse]
GO
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
	[FP_SERIAL] [nvarchar](6) NULL,
	[FN_SERIAL] [nvarchar](20) NULL,
	[DATE] [date] NULL,
	[TIME] [nvarchar](8) NULL,
	[PRICE] [decimal](10,2) NULL,
	[TOTAL] [decimal](10,2) NULL,
	[DWH_CREATE_DATE] [datetime2](7) NULL
) ON [PRIMARY];
GO

ALTER TABLE [gold].[rep_uin] ADD  DEFAULT (getdate()) FOR [DWH_CREATE_DATE];
GO

CREATE INDEX IX_UIN ON [gold].[rep_uin]([ITEM_CODE],[UIN],[DATE],[COMPANY]);
GO
