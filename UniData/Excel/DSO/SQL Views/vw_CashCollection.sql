USE [DataMart_Report]
GO

/****** Object:  View [dbo].[vw_CashCollection]    Script Date: 2016-04-08 1:35:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [dbo].[vw_CashCollection]
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
FROM DataWarehouse.dbo.CashPosting CashPosting
	LEFT JOIN DataWarehouse.dbo.AccountReceivableCustomer AccountReceivableCustomer
		ON CashPosting.CompanyCode = AccountReceivableCustomer.CompanyCode
		AND CashPosting.AccountReceivableCustomerCode = AccountReceivableCustomer.AccountReceivableCustomerCode
	LEFT JOIN DataWarehouse.dbo.Collector Collector
		ON AccountReceivableCustomer.CollectorCode = Collector.CollectorCode
WHERE CashPosting.CompanyCode NOT IN ('42')



GO


