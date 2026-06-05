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
