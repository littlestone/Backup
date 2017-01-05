SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
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
					     SELECT Invoice_2015.*  -- Normal 2015 data
      	      				     FROM DataWarehouse..Invoice_2015 Invoice_2015
					     	LEFT JOIN Report..DSO_Time FiscalTime
					     		ON Invoice_2015.InvoiceDate >= FiscalTime.StartDate
							AND Invoice_2015.InvoiceDate <= FiscalTime.EndDate
			 				WHERE Invoice_2015.FiscalPeriodCode IN (SELECT DISTINCT TOP 3 AccountReceivableBalance.FiscalPeriodCode
												FROM DataWarehouse..AccountReceivableBalance AccountReceivableBalance
												ORDER BY AccountReceivableBalance.FiscalPeriodCode DESC)

      	      				     UNION ALL  -- Data that falls into calendar year 2014 because fiscal year 2015 actually start on caldendar date 31/12/2014

					     SELECT [InvoiceNumber]
					            ,[OrderNumber]
						    ,[ReleaseNumber]
						    ,[CompanyCode]
						    ,[DivisionCode]
                         			    ,[FiscalPeriodCode] = '2015-01'
						    ,[CustomerCode]
						    ,[InvoiceType]
						    ,[InvoiceDate]
						    ,[BillOfLadingNumber]
						    ,[FinancialPeriodCode]
						    ,[LineItemNumber]
						    ,[ComputerizedPartNumber]
						    ,[WarehouseCode]
						    ,[AdjustmentType]
						    ,[ShippingWeight]
						    ,[ExtendedPriceAmount]
						    ,[DiscountAmount]
						    ,[HandlingChargeAmount]
						    ,[ExtendedCostAmount]
						    ,[CashDiscountAmount]
						    ,[PrepaidFreightAmount]
						    ,[VolumeRebateAmount]
						    ,[FreightAllowanceAmount]
						    ,[WarehouseAllowanceAmount]
						    ,[CommissionAmount]
						    ,[CompetitiveMonthlyAllowanceAmount]
						    ,[CompanyShippingQuantity]
						    ,[StateTaxAmount]
						    ,[CountyTaxAmount]
						    ,[CityTaxAmount]
						    ,[ValueAddedTaxAmount]
						    ,[ProvincialSalesTaxAmount]
						    ,[CustomerChargeFreightAmount]
						    ,[CustomerShippingQuantity]
						    ,[SalesPostingCode]
						    ,[GeneralLedgerGroupCode]
						    ,[CustomerPurchaseOrderNumber]
						    ,[SalesOfficeCode]
						    ,[OrderReasonCode]
						    ,[CompanyCodeDivisionCode]
						    ,[CompanyCodeCustomerCode]
						    ,[ShipToName]
						    ,[ShipToAddressLine1]
						    ,[ShipToAddressLine2]
					            ,[ShipToAddressLine3]
						    ,[ShipToAddressLine4]
						    ,[ShipToCountryCode]
						    ,[ShipToCityStateProvinceZipPostalCode]
						    ,[ShipToContactName]
						    ,[FreightOnBoardCode]
						    ,[VendorConcessionAmount]
						    ,[WarehouseCodeComputerizedPartNumber]
						    ,[CompanyCodeCustomerCodeComputerizedPartNumber]
						    ,[GrossAmount]
						    ,[GrossDiscountedAmount]
						    ,[FinancialCostAmount]
						    ,[NetAmount]
						    ,[MarginAmount]
						    ,[BillToCustomerCode]
						    ,[BillToCustomerName]
						    ,[BillToCustomerAddressLine1]
						    ,[BillToCustomerAddressLine2]
						    ,[BillToCustomerAddressLine3]
						    ,[BillToCustomerCityCode]
						    ,[BillToCustomerCountryCode]
						    ,[BillToCustomerStateProvinceCode]
						    ,[BillToCustomerZipPostalCode]
						    ,[BillToCustomerContactName]
						    ,[ShipToStateProvinceCode]
						    ,[RoyaltyBaseAmount]
						    ,[RoyaltyExtraAmount]
						    ,[RoyaltyAmount]
						    ,[ShipDebitAmount]
						    ,[MultiplierRate]
						    ,[PricePerQuantity]
						    ,[AgentCode]
						    ,[ListPriceAmount]
						    ,[ExchangeRate]
      	      				     FROM DataWarehouse..Invoice_2014 Invoice_2014	
					     	LEFT JOIN Report..DSO_Time FiscalTime
					     		ON Invoice_2014.InvoiceDate >= FiscalTime.StartDate
							AND Invoice_2014.InvoiceDate <= FiscalTime.EndDate
			 				WHERE FiscalTime.FiscalPeriodCode = '2015-01'

					     UNION ALL  -- cross year data due to the rolling 3 months calulation rules

      	      				     SELECT *
      	      				     FROM DataWarehouse..Invoice_2014
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

