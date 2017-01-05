USE [Report]
GO

/****** Object:  View [dbo].[vw_DaysSalesOutstandingCorporate]    Script Date: 26/11/2013 2:01:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER	VIEW [dbo].[vw_DaysSalesOutstandingCorporate]
AS

SELECT DSO.FiscalPeriodCode
,	DSO.CompanyCode
,	Company.CompanyName
,	DSO.CollectorCode
,	CollectorName = ISNULL(Collector.CollectorName, '')
,	CustomerCode = DSO.AccountReceivableCustomerCode
,	CustomerName = DSO.AccountReceivableCustomerName
,	[AR BalanceAmount] = SUM(DSO.[AR BalanceAmount])
,	SalesAmount = SUM(DSO.SalesAmount)
FROM (
	SELECT RollingThreeMonthDSOAR.FiscalPeriodCode
	,	RollingThreeMonthDSOAR.CompanyCode
	,	RollingThreeMonthDSOAR.CollectorCode
	,	RollingThreeMonthDSOAR.AccountReceivableCustomerCode
	,	RollingThreeMonthDSOAR.AccountReceivableCustomerName
	,	RollingThreeMonthDSOAR.[AR BalanceAmount]
	,	SalesAmount = ISNULL(RollingThreeMonthDSOSales.SalesAmount, 0)
	FROM (
		SELECT AccountReceivableBalance.FiscalPeriodCode
		,	AccountReceivableBalance.CompanyCode
		,	AccountReceivableCustomer.CollectorCode
		,	AccountReceivableCustomer.AccountReceivableCustomerCode
		,	AccountReceivableCustomer.AccountReceivableCustomerName
		,	[AR BalanceAmount] = SUM(AccountReceivableBalance.BalanceAmount)
		FROM DataWarehouse..AccountReceivableBalance AccountReceivableBalance
			LEFT JOIN DataWarehouse..AccountReceivableCustomer AccountReceivableCustomer
				ON AccountReceivableBalance.CompanyCode = AccountReceivableCustomer.CompanyCode
				AND AccountReceivableBalance.AccountReceivableCustomerCode = AccountReceivableCustomer.AccountReceivableCustomerCode
		WHERE 	AccountReceivableCustomer.AccountReceivableCustomerCode <> ''
		AND	AccountReceivableBalance.FiscalPeriodCode IN (SELECT DISTINCT TOP 3 AccountReceivableBalance.FiscalPeriodCode
								      FROM DataWarehouse..AccountReceivableBalance AccountReceivableBalance
								      ORDER BY AccountReceivableBalance.FiscalPeriodCode DESC)
		GROUP BY AccountReceivableBalance.FiscalPeriodCode
		,	AccountReceivableBalance.CompanyCode
		,	AccountReceivableCustomer.CollectorCode
		,	AccountReceivableCustomer.AccountReceivableCustomerCode
		,	AccountReceivableCustomer.AccountReceivableCustomerName
	     ) RollingThreeMonthDSOAR
	     	LEFT JOIN (
			     SELECT DSOSales.FiscalPeriodCode
			     ,	DSOSales.CompanyCode
			     ,	DSOSales.CollectorCode
			     ,	DSOSales.AccountReceivableCustomerCode
			     ,	DSOSales.AccountReceivableCustomerName
			     ,	SalesAmount = SUM(DSOSales.SalesAmount)
			     FROM (
				     SELECT Invoice.FiscalPeriodCode
				     ,	Invoice.CompanyCode
				     ,	Invoice.InvoiceType
			  	     ,	CollectorCode = ISNULL(AccountReceivableCustomer.CollectorCode, '')
				     ,	AccountReceivableCustomer.AccountReceivableCustomerCode
				     ,	AccountReceivableCustomer.AccountReceivableCustomerName
				     ,	SalesAmount = CASE WHEN Invoice.InvoiceType = 3 THEN
							        SUM((Invoice.ExtendedPriceAmount + Invoice.CustomerChargeFreightAmount - Invoice.DiscountAmount + Invoice.ValueAddedTaxAmount + Invoice.ProvincialSalesTaxAmount + Invoice.HandlingChargeAmount) * -1)
				   			   ELSE
								SUM(Invoice.ExtendedPriceAmount + Invoice.CustomerChargeFreightAmount - Invoice.DiscountAmount + Invoice.ValueAddedTaxAmount + Invoice.ProvincialSalesTaxAmount + Invoice.HandlingChargeAmount)
			                              END
				     FROM (
					     SELECT *
      	      				     FROM DataWarehouse..Invoice_2013
			 	             WHERE FiscalPeriodCode IN (SELECT DISTINCT TOP 3 AccountReceivableBalance.FiscalPeriodCode
								        FROM DataWarehouse..AccountReceivableBalance AccountReceivableBalance
								        ORDER BY AccountReceivableBalance.FiscalPeriodCode DESC)
      	      				     UNION ALL
      	      				     SELECT *
      	      				     FROM DataWarehouse..Invoice_2012
			 	             WHERE FiscalPeriodCode IN (SELECT DISTINCT TOP 3 AccountReceivableBalance.FiscalPeriodCode
								        FROM DataWarehouse..AccountReceivableBalance AccountReceivableBalance
								        ORDER BY AccountReceivableBalance.FiscalPeriodCode DESC)
					  ) Invoice
					  	LEFT JOIN DataWarehouse..BillToCustomer BillToCustomer
							ON Invoice.CompanyCode = BillToCustomer.CompanyCode
							AND Invoice.BillToCustomerCode = BillToCustomer.BillToCustomerCode
						LEFT JOIN DataWarehouse..AccountReceivableCustomer AccountReceivableCustomer
							ON BillToCustomer.CompanyCode = AccountReceivableCustomer.CompanyCode
							AND BillToCustomer.AccountReceivableCustomerCode = AccountReceivableCustomer.AccountReceivableCustomerCode
						GROUP BY Invoice.FiscalPeriodCode
						,	Invoice.CompanyCode
						,	Invoice.InvoiceType
						,	AccountReceivableCustomer.CollectorCode
						,	AccountReceivableCustomer.AccountReceivableCustomerCode
						,	AccountReceivableCustomer.AccountReceivableCustomerName
				  ) DSOSales
				  GROUP BY DSOSales.FiscalPeriodCode
				  ,	DSOSales.CompanyCode
				  ,	DSOSales.CollectorCode
				  ,	DSOSales.AccountReceivableCustomerCode
				  ,	DSOSales.AccountReceivableCustomerName
			  ) RollingThreeMonthDSOSales
			  	ON RollingThreeMonthDSOAR.FiscalPeriodCode = RollingThreeMonthDSOSales.FiscalPeriodCode
				AND RollingThreeMonthDSOAR.CompanyCode = RollingThreeMonthDSOSales.CompanyCode
				AND RollingThreeMonthDSOAR.CollectorCode = RollingThreeMonthDSOSales.CollectorCode
				AND RollingThreeMonthDSOAR.AccountReceivableCustomerCode = RollingThreeMonthDSOSales.AccountReceivableCustomerCode
     ) DSO
     	LEFT JOIN DataWarehouse..Company Company
		ON DSO.CompanyCode = Company.CompanyCode
     	LEFT JOIN DataWarehouse..Collector Collector
		ON DSO.CollectorCode = Collector.CollectorCode
WHERE 	DSO.CompanyCode NOT IN ('41', '42')
AND 	DSO.CollectorCode <> ''
AND 	ISNULL(Collector.CollectorName, '') <> 'DO NOT USE'
GROUP BY DSO.FiscalPeriodCode
,  	DSO.CompanyCode
,	Company.CompanyName
,	DSO.CollectorCode
,	Collector.CollectorName
,  	DSO.AccountReceivableCustomerCode
,  	DSO.AccountReceivableCustomerName



















GO

