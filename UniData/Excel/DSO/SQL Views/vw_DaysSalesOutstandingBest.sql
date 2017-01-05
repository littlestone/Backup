USE [DataMart_Report]
GO

/****** Object:  View [dbo].[vw_DaysSalesOutstandingBest]    Script Date: 2016-04-08 1:33:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER VIEW [dbo].[vw_DaysSalesOutstandingBest]
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
			,	[AR BalanceAmount] = SUM(CASE WHEN ISNULL(NULLIF(AccountReceivableInvoice.CashFlowNetDueDate, CONVERT(DATE, '19000101')), AccountReceivableInvoice.DueDate) > FiscalTime.EndDate THEN
								   ISNULL(AccountReceivableInvoice.BalanceDueAmount, 0)
								  ELSE 
								   0
							 END)
			FROM DataWarehouse.dbo.AccountReceivableBalance AccountReceivableBalance
				LEFT JOIN DataWarehouse.dbo.AccountReceivableCustomer AccountReceivableCustomer
					ON AccountReceivableBalance.CompanyCode = AccountReceivableCustomer.CompanyCode
					AND AccountReceivableBalance.AccountReceivableCustomerCode = AccountReceivableCustomer.AccountReceivableCustomerCode
				LEFT JOIN DataWarehouse.dbo.AccountReceivableInvoice AccountReceivableInvoice
					ON AccountReceivableBalance.FiscalPeriodCode = AccountReceivableInvoice.FiscalPeriodCode
					AND AccountReceivableCustomer.CompanyCode = AccountReceivableInvoice.CompanyCode
					AND AccountReceivableCustomer.AccountReceivableCustomerCode = AccountReceivableInvoice.CustomerCode
				LEFT JOIN DataWarehouse.dbo.FiscalTime
					ON AccountReceivableInvoice.FiscalPeriodCode = FiscalTime.FiscalPeriodCode
			WHERE 	AccountReceivableCustomer.AccountReceivableCustomerCode <> ''
			AND	AccountReceivableBalance.FiscalPeriodCode IN (SELECT DISTINCT TOP 3 AccountReceivableBalance.FiscalPeriodCode
										  FROM DataWarehouse.dbo.AccountReceivableBalance AccountReceivableBalance
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
      	      						 FROM DataWarehouse.dbo.Invoice
			 					 WHERE FiscalPeriodCode IN (SELECT DISTINCT TOP 3 AccountReceivableBalance.FiscalPeriodCode
											FROM DataWarehouse.dbo.AccountReceivableBalance AccountReceivableBalance
											ORDER BY AccountReceivableBalance.FiscalPeriodCode DESC)
						  ) Invoice
					  		LEFT JOIN DataWarehouse.dbo.BillToCustomer BillToCustomer
								ON Invoice.CompanyCode = BillToCustomer.CompanyCode
								AND Invoice.BillToCustomerCode = BillToCustomer.BillToCustomerCode
							LEFT JOIN DataWarehouse.dbo.AccountReceivableCustomer AccountReceivableCustomer
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
     		LEFT JOIN DataWarehouse.dbo.Company Company
			ON DSO.CompanyCode = Company.CompanyCode
     		LEFT JOIN DataWarehouse.dbo.Collector Collector
			ON DSO.CollectorCode = Collector.CollectorCode
	WHERE 	DSO.CollectorCode <> ''
	AND		DSO.CompanyCode NOT IN ('42')
	AND 	ISNULL(Collector.CollectorName, '') <> 'DO NOT USE'
	GROUP BY DSO.FiscalPeriodCode
	,  	DSO.CompanyCode
	,	Company.CompanyName
	,	DSO.CollectorCode
	,	Collector.CollectorName
	,  	DSO.AccountReceivableCustomerCode
	,  	DSO.AccountReceivableCustomerName






GO


