CREATE        PROCEDURE sp_Insert_SalesOrderBacklogBooked
WITH RECOMPILE
AS

-- Initializtion
DECLARE @FiscalYear	varchar(100)
DECLARE @StartDate 	smalldatetime
DECLARE	@EndDate 	smalldatetime
DECLARE @WeekNumber 	int
DECLARE @FETCH_STATUS 	int

SET @FiscalYear = '2012'
SET @StartDate = '2012/01/07' -- Must be set to the fisrt Saturday's date of the year.
SET @EndDate = '2012/12/31'
SET @WeekNumber = 1

-- Temporary table to hold fiscal week info
CREATE TABLE	#FiscalWeekLive
(	StartDate	smalldatetime
,	WeekNumber	int
)

-- Populate Fiscal Weeks
WHILE @StartDate < @EndDate
BEGIN
	INSERT #FiscalWeekLive VALUES(@StartDate, @WeekNumber)
	SET @StartDate = @StartDate + 7
	SET @WeekNumber = @WeekNumber + 1
END

-- Get last fiscal week number
SET @WeekNumber = (SELECT WeekNumber
		   FROM #FiscalWeekLive
		   WHERE GETDATE() >= StartDate + 7
		   AND	GETDATE() <= StartDate + 8)	-- can be run on Saturday or Sunday

-- Get the start date of the last fiscal week 
SET @StartDate = (SELECT StartDate
		  FROM #FiscalWeekLive
		  WHERE GETDATE() >= StartDate + 7
		  AND	GETDATE() <= StartDate + 8)	-- can be run on Saturday or Sunday

-- Can only be run either on Saturday or Sunday right after the end of the last fiscal week
BEGIN
	IF @WeekNumber IS NULL OR @StartDate IS NULL
	BEGIN
		DROP TABLE #FiscalWeekLive
		RETURN
	END
END

-- Temporary table to hold sales order info as per fiscal week
CREATE TABLE	#SalesOrder_Backlog_Booked_Live
(	OrderDate		smalldatetime
,	CompleteDate		smalldatetime
,	OrderNumber		varchar(100)
,	LineItemNumber		varchar(100)
,	LineItemStatusCode	varchar(100)
,	CompanyCode		varchar(100)
,	DivisionCode		varchar(100)
,	BusinessUnitCode	varchar(100)
,	RegionCode		varchar(100)
,	SalesOfficeCode		varchar(100)
,	MarketSegmentCode	varchar(100)
,	ProductCategoryCode	varchar(100)
,	ProductGroupCode	varchar(100)
,	LineItemOrderQuantity	numeric(21,2)
,	LineItemShipQuantity	numeric(21,2)
,	OrderWeight		numeric(21,3)
,	ExtendedPriceAmount	numeric(21,3)
)

-- Sales Order 2008
INSERT INTO #SalesOrder_Backlog_Booked_Live
SELECT 	SalesOrder.OrderDate
,	SalesOrder.CompleteDate
,	SalesOrder.OrderNumber
,	SalesOrder.LineItemNumber
,	SalesOrder.LineItemStatusCode
,	SalesOrder.CompanyCode
,	SalesOrder.DivisionCode
,	ShipToCustomer.BusinessUnitCode 
,	ShipToCustomer.RegionCode
,	SalesOrder.SalesOfficeCode
,	Product.MarketSegmentCode
,	Product.ProductCategoryCode
,	Product.ProductGroupCode
,	SalesOrder.LineItemOrderQuantity
,	SalesOrder.LineItemShipQuantity
,	SalesOrder.OrderWeight
,	SalesOrder.ExtendedPriceAmount
FROM 	DataWarehouse..SalesOrder_2008 SalesOrder
	LEFT JOIN DataWarehouse..ShipToCustomer ShipToCustomer
		ON SalesOrder.CompanyCode = ShipToCustomer.CompanyCode
		AND SalesOrder.CustomerCode = ShipToCustomer.ShipToCustomerCode
	LEFT JOIN DataWarehouse..Product Product
		ON SalesOrder.ComputerizedPartNumber = Product.ComputerizedPartNumber
WHERE 	SalesOrder.TransactionTypeCode NOT IN ('12','51','52') 	-- Exclude Direct Sales Orders, Credit Orders & Debit Orders
AND	SalesOrder.OrderStatusCode <> 'C'			-- Exclude Cancelled Order
AND	SalesOrder.DeliveryNumber = '1'
AND	(SalesOrder.CompleteDate = '' OR SalesOrder.CompleteDate >= @StartDate)

-- Sales Order 2009
INSERT INTO #SalesOrder_Backlog_Booked_Live
SELECT SalesOrder.OrderDate
,	SalesOrder.CompleteDate
,	SalesOrder.OrderNumber
,	SalesOrder.LineItemNumber
,	SalesOrder.LineItemStatusCode
,	SalesOrder.CompanyCode
,	SalesOrder.DivisionCode
,	ShipToCustomer.BusinessUnitCode 
,	ShipToCustomer.RegionCode
,	SalesOrder.SalesOfficeCode
,	Product.MarketSegmentCode
,	Product.ProductCategoryCode
,	Product.ProductGroupCode
,	SalesOrder.LineItemOrderQuantity
,	SalesOrder.LineItemShipQuantity
,	SalesOrder.OrderWeight
,	SalesOrder.ExtendedPriceAmount
FROM 	DataWarehouse..SalesOrder_2009 SalesOrder
	LEFT JOIN DataWarehouse..ShipToCustomer ShipToCustomer
		ON SalesOrder.CompanyCode = ShipToCustomer.CompanyCode
		AND SalesOrder.CustomerCode = ShipToCustomer.ShipToCustomerCode
	LEFT JOIN DataWarehouse..Product Product
		ON SalesOrder.ComputerizedPartNumber = Product.ComputerizedPartNumber
WHERE 	SalesOrder.TransactionTypeCode NOT IN ('12','51','52') 	-- Exclude Direct Sales Orders, Credit Orders & Debit Orders
AND	SalesOrder.OrderStatusCode <> 'C'			-- Exclude Cancelled Order
AND	SalesOrder.DeliveryNumber = '1'
AND	(SalesOrder.CompleteDate = '' OR SalesOrder.CompleteDate >= @StartDate)

-- Sales Order 2010
INSERT INTO #SalesOrder_Backlog_Booked_Live
SELECT  SalesOrder.OrderDate
,	SalesOrder.CompleteDate
,	SalesOrder.OrderNumber
,	SalesOrder.LineItemNumber
,	SalesOrder.LineItemStatusCode
,	SalesOrder.CompanyCode
,	SalesOrder.DivisionCode
,	ShipToCustomer.BusinessUnitCode 
,	ShipToCustomer.RegionCode
,	SalesOrder.SalesOfficeCode
,	Product.MarketSegmentCode
,	Product.ProductCategoryCode
,	Product.ProductGroupCode
,	SalesOrder.LineItemOrderQuantity
,	SalesOrder.LineItemShipQuantity
,	SalesOrder.OrderWeight
,	SalesOrder.ExtendedPriceAmount
FROM 	DataWarehouse..SalesOrder_2010 SalesOrder
	LEFT JOIN DataWarehouse..ShipToCustomer ShipToCustomer
		ON SalesOrder.CompanyCode = ShipToCustomer.CompanyCode
		AND SalesOrder.CustomerCode = ShipToCustomer.ShipToCustomerCode
	LEFT JOIN DataWarehouse..Product Product
		ON SalesOrder.ComputerizedPartNumber = Product.ComputerizedPartNumber
WHERE 	SalesOrder.TransactionTypeCode NOT IN ('12','51','52') 	-- Exclude Direct Sales Orders, Credit Orders & Debit Orders
AND	SalesOrder.OrderStatusCode <> 'C'			-- Exclude Cancelled Order
AND	SalesOrder.DeliveryNumber = '1'
AND	(SalesOrder.CompleteDate = '' OR SalesOrder.CompleteDate >= @StartDate)

-- Sales Order 2011
INSERT INTO #SalesOrder_Backlog_Booked_Live
SELECT 	SalesOrder.OrderDate
,	SalesOrder.CompleteDate
,	SalesOrder.OrderNumber
,	SalesOrder.LineItemNumber
,	SalesOrder.LineItemStatusCode
,	SalesOrder.CompanyCode
,	SalesOrder.DivisionCode
,	ShipToCustomer.BusinessUnitCode 
,	ShipToCustomer.RegionCode
,	SalesOrder.SalesOfficeCode
,	Product.MarketSegmentCode
,	Product.ProductCategoryCode
,	Product.ProductGroupCode
,	SalesOrder.LineItemOrderQuantity
,	SalesOrder.LineItemShipQuantity
,	SalesOrder.OrderWeight
,	SalesOrder.ExtendedPriceAmount
FROM 	DataWarehouse..SalesOrder_2011 SalesOrder
	LEFT JOIN DataWarehouse..ShipToCustomer ShipToCustomer
		ON SalesOrder.CompanyCode = ShipToCustomer.CompanyCode
		AND SalesOrder.CustomerCode = ShipToCustomer.ShipToCustomerCode
	LEFT JOIN DataWarehouse..Product Product
		ON SalesOrder.ComputerizedPartNumber = Product.ComputerizedPartNumber
WHERE 	SalesOrder.TransactionTypeCode NOT IN ('12','51','52') 	-- Exclude Direct Sales Orders, Credit Orders & Debit Orders
AND	SalesOrder.OrderStatusCode <> 'C'			-- Exclude Cancelled Order
AND	SalesOrder.DeliveryNumber = '1'
AND	(SalesOrder.CompleteDate = '' OR SalesOrder.CompleteDate >= @StartDate)


-- Sales Order 2012
INSERT INTO #SalesOrder_Backlog_Booked_Live
SELECT 	SalesOrder.OrderDate
,	SalesOrder.CompleteDate
,	SalesOrder.OrderNumber
,	SalesOrder.LineItemNumber
,	SalesOrder.LineItemStatusCode
,	SalesOrder.CompanyCode
,	SalesOrder.DivisionCode
,	ShipToCustomer.BusinessUnitCode 
,	ShipToCustomer.RegionCode
,	SalesOrder.SalesOfficeCode
,	Product.MarketSegmentCode
,	Product.ProductCategoryCode
,	Product.ProductGroupCode
,	SalesOrder.LineItemOrderQuantity
,	SalesOrder.LineItemShipQuantity
,	SalesOrder.OrderWeight
,	SalesOrder.ExtendedPriceAmount
FROM 	DataWarehouse..SalesOrder_2012 SalesOrder
	LEFT JOIN DataWarehouse..ShipToCustomer ShipToCustomer
		ON SalesOrder.CompanyCode = ShipToCustomer.CompanyCode
		AND SalesOrder.CustomerCode = ShipToCustomer.ShipToCustomerCode
	LEFT JOIN DataWarehouse..Product Product
		ON SalesOrder.ComputerizedPartNumber = Product.ComputerizedPartNumber
WHERE 	SalesOrder.TransactionTypeCode NOT IN ('12','51','52') 	-- Exclude Direct Sales Orders, Credit Orders & Debit Orders
AND	SalesOrder.OrderStatusCode <> 'C'			-- Exclude Cancelled Order
AND	SalesOrder.DeliveryNumber = '1'
AND	(SalesOrder.CompleteDate = '' OR SalesOrder.CompleteDate >= @StartDate)


-- Sales Order Backlog & Booked
INSERT INTO DataWarehouse..SalesOrderBacklogBooked
SELECT  FiscalYear = @FiscalYear
,	WeekNumber = @WeekNumber
,	FromDate = @StartDate
,	ToDate = @StartDate + 7
,	CompanyCode
,	DivisionCode
,	BusinessUnitCode
,	RegionCode
,	SalesOfficeCode
,	MarketSegmentCode
,	ProductCategoryCode
, 	ProductGroupCode
,	BookedQuantity = SUM(CASE WHEN OrderDate >= @StartDate AND OrderDate <= @StartDate + 7 THEN
				       LineItemOrderQuantity
				  ELSE
				       0
			     END)
,	ShippedQuantity = SUM(LineItemShipQuantity)
,	BacklogQuantity = SUM(LineItemOrderQuantity - LineItemShipQuantity)
,	BookedWeight = SUM(CASE WHEN OrderDate >= @StartDate AND OrderDate <= @StartDate + 7 THEN
				     LineItemOrderQuantity * OrderWeight
				ELSE
				     0
			   END)
,	ShippedWeight = SUM(LineItemShipQuantity * OrderWeight)
,	BacklogWeight = SUM((LineItemOrderQuantity - LineItemShipQuantity) * OrderWeight)
,	BookedGrossAmount = SUM(CASE WHEN OrderDate >= @StartDate AND OrderDate <= @StartDate + 7 THEN
					  ExtendedPriceAmount
				     ELSE
					  0
				END)
,	ShippedGrossAmount = SUM(CASE WHEN LineItemOrderQuantity > 0 THEN
					   LineItemShipQuantity * (ExtendedPriceAmount / LineItemOrderQuantity)
				      ELSE
					   0
				 END)
,	BacklogGrossAmount = SUM(CASE WHEN LineItemOrderQuantity > 0 THEN
					   (LineItemOrderQuantity - LineItemShipQuantity) * (ExtendedPriceAmount / LineItemOrderQuantity)
				      ELSE
					   0
				 END)
FROM 	#SalesOrder_Backlog_Booked_Live
WHERE	LineItemStatusCode <> 'C'
GROUP BY CompanyCode
,	DivisionCode
,	BusinessUnitCode
,	RegionCode
,	SalesOfficeCode
,	MarketSegmentCode
,	ProductCategoryCode
, 	ProductGroupCode
ORDER BY CompanyCode
,	DivisionCode
,	BusinessUnitCode
,	RegionCode
,	SalesOfficeCode
,	MarketSegmentCode
,	ProductCategoryCode
, 	ProductGroupCode

DROP TABLE #FiscalWeekLive
DROP TABLE #SalesOrder_Backlog_Booked_Live

GO
