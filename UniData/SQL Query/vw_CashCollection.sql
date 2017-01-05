USE [Report]
GO

/****** Object:  View [dbo].[vw_CashCollection]    Script Date: 26/11/2013 2:03:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER	VIEW [dbo].[vw_CashCollection]
AS
SELECT CashPosting.CompanyCode
,	CashPosting.BatchNumber
,	CashPosting.EntryDate
,	CashPosting.BankCode
,	CashPosting.CurrencyCode
,	CashPosting.FiscalPeriodCode
,	[AR CustomerCode] = AccountReceivableCustomer.AccountReceivableCustomerCode
,	[AR CustomerName] = AccountReceivableCustomer.AccountReceivableCustomerName
,	CashPosting.CheckNumber
,	CashPosting.InvoiceNumber
,	[AR Amount] = CashPosting.AccountReceivableAmount
,	CashPosting.DiscountAmount
,	[CashReceiptAmount] =  CashPosting.AccountReceivableAmount - CashPosting.DiscountAmount
,	CollectorCode = ISNULL(Collector.CollectorCode, '')
,	CollectorName = ISNULL(Collector.CollectorName, '')
FROM DataWarehouse..CashPosting CashPosting
	LEFT JOIN DataWarehouse..AccountReceivableCustomer AccountReceivableCustomer
		ON CashPosting.CompanyCode = AccountReceivableCustomer.CompanyCode
		AND CashPosting.AccountReceivableCustomerCode = AccountReceivableCustomer.AccountReceivableCustomerCode
	LEFT JOIN DataWarehouse..Collector Collector
		ON AccountReceivableCustomer.CollectorCode = Collector.CollectorCode
WHERE CashPosting.CompanyCode NOT IN ('41', '42')
	





GO

