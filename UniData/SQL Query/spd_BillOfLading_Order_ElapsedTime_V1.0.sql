USE [DataMart_Report]
GO

/****** Object:  StoredProcedure [dbo].[spd_BillOfLading_Order_ElapsedTime]    Script Date: 13/11/2015 3:26:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO













/*

This report is used to analyze our logistic performace between sales office and distribution center (specific for NACO)
using the calulation through the OrderReleaseDateTime, OrderDeliveryByDate and OrderShippedDate 
based on the following business rules:

------------------------------------------------------------------------------------------------
Prerequisites:
	1. Populate IPEX StatutoryHoliday table yearly under Report database.
	   (http://portalseven.com/calendar/Holidays_Canada.jsp) 
	2. Populate FiscalTime table on 2020/12/31 (determing if working days or weekend days)
	3. Stakeholders userid -> chrche, natbou, rebleo (read access granted)

------------------------------------------------------------------------------------------------

Day range calulation pre-conditions:
	1. Weekend days and Statutory Holidays will be excluded from the calculation.

------------------------------------------------------------------------------------------------

Day range calulation rules:
	1. LoadAndGoFlag -> A shipper is cutting a BOL for an order/transfer that is required to be delivered the same day, and the order is loaded on a truck that will be delivering the goods to the customer on that same day (this is a new field introduced on year 2010 along with ShippingUserId).
	2. LateOrderReleaseFlag -> Order release is considered to be late if an order is released after or on the customer delivery by date.
	3. LateShipmentFlag -> Shipment is considered to be late if:
	                       a). An order is shipped after the customer delivery by date, or 
						   b). An order is shipped on the customer delivery by date and the LoadAndGoFlag is not "Y", or
						   c). However, a pick up order is NOT considered to be late if the customer picks up the order the same day as updated delivery by date regardless the shipper change the LoadAndGoFlag to Y.
	4. DayOffFlag -> Order released after 3:00PM local warehouse time will be considered to be a day off. The actual order release date would be the next working day.
	5. AppFlag -> There are 4 possible values listed and explained below:
			a). BLANK (which means no appointment was needed);
			b). Y (YES which means an appointment was needed but the deliver by date was not updated prior to the BOL being cut)
			c). U (UPDATE which means that the order was put on hold and the deliver by date needed to be updated when the customer had called to confirm the new deliver by date, but distribution did not update the system with that new date prior to the BOL being cut)
			d). C (COMPLETE which means that an appointment was needed and the DC has updated the deliver by date prior to the BOL being cut)

------------------------------------------------------------------------------------------------

Day range definitions:
	1. DelDt - RelDt -> Total number of working days required from the date the order is relased to the customer delivery by date (DeliveryByDate is not counted).
    2. ShpDt - RelDt -> Extra number of working days required from the date the order is relased to the date order is shipped out.
    3. DelDt - ShpDt -> Service number of working days required from the date the order is shipped out to the customer delivery by date (DeliveryByDate is not counted and in case the delivery by date happen to be a statutory holiday, the most last working day will be considered to be the actual delivery by date).
    4. UpdatedDelDt - InitialDelDt -> Difference days between the customer delivery by date vs DC updated delivery by date.
    5. (DelDt - RelDt) Range -> Total number of working days required summarized in range (< 0, 0 to 9, >= 10).
    6. (ShpDt - RelDt) Range -> Extra number of working days required summarized in range (< 0, 0 to 9, >= 10).
    7. (DelDt - ShpDt) Range -> Service number of working days required summarized in range (<0, 0 to 9, >= 10).

------------------------------------------------------------------------------------------------
       
Business contact: Nathalie Bouvier
Super user: Christian Chen
IT Support: Junjie Tang, Nestor Jarquin

------------------------------------------------------------------------------------------------
Version: 1.0
Last modified: 2015-11-12 by Junjie

*/


ALTER PROCEDURE [dbo].[spd_BillOfLading_Order_ElapsedTime]
	@FiscalYear VARCHAR(4),
	@FiscalPeriod VARCHAR(7),
	@CompanyCode VARCHAR(3) = 'ALL',
	@ShippingWarehouseCode VARCHAR(3) = 'ALL',
	@ReceivingWarehouseCode VARCHAR(3) = 'ALL',
	@includeMarketSegment BIT = 0
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @includeMarketSegment = 0
		SELECT FiscalMonth = BillOfLading.FiscalPeriodCode
			, ShippingWarehouseCompany.CompanyCode
			, ShippingWarehouseCompany.CompanyName
			, SalesOfficeCode = ISNULL(SalesOffice.SalesOfficeCode, '')
			, SalesOfficeName = ISNULL(SalesOffice.SalesOfficeName, '')
			, SalesRegionCode = ISNULL(ShipToCustomer.RegionCode, '')
			, SalesRegionName = ISNULL(Region.RegionName, '') 
			, AccountReceivableCustomerCode = ISNULL(AccountReceivableCustomer.AccountReceivableCustomerCode, '')
			, AccountReceivableCustomerName = ISNULL(AccountReceivableCustomer.AccountReceivableCustomerName, '')
			, BuyingGroupCode = ISNULL(ShipToCustomer.BuyingGroupCode, '') 
			, CustomerGroupCode = ISNULL(SUBSTRING(CustomerGroup.CustomerGroupCode, CHARINDEX('*', CustomerGroup.CustomerGroupCode) + 1, LEN(CustomerGroup.CustomerGroupCode)), '')
			, CustomerGroupName = ISNULL(CustomerGroup.CustomerGroupName, '')
			, CustomerShipToCode = ISNULL(SalesOrder.CustomerCode, '')
			, CustomerShipToName = ISNULL(SalesOrder.ShipToName, '')
			, CustomerShipToCity = ISNULL(ShipToCustomer.CityCode, '')
			, CustomerShipToStateProvince = ISNULL(ShipToCustomer.StateProvinceCode, '')
			, CustomerOrderRequestDate = ISNULL(SalesOrder.RequestDate, '')
			, CustomerOrderDate = ISNULL(SalesOrder.CustomerOrderDate, '')
			, BillOfLading.ShippingWarehouseCode
			, ShippingWarehouseName = ShippingWarehouse.WarehouseName
			, BillOfLading.ReceivingWarehouseCode
			, ReceivingWarehouseName = ReceivingWarehouse.WarehouseName
			, TransferOrderFlag = CASE WHEN BillOfLading.OrderNumber LIKE 'T%' THEN 'Yes' ELSE 'No' END
			, PickUpOrderFlag = CASE WHEN BillOfLading.FreightTermCode = 'PU' THEN 'Yes' ELSE 'No' END
			, LoadAndGoFlag = ISNULL(BillOfLading.LoadAndGoFlag, '')
			, LateOrderReleaseFlag = 
				CASE 
					WHEN (CASE
						WHEN ISNULL(CONVERT(DATE, SalesOrderPacking.ReleaseDateTime), CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
						OR ISNULL(SalesOrderPacking.DeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
							THEN NULL
						ELSE
							(
							SELECT
								CASE 
									WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
										THEN 
											CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
												THEN COUNT(1) - 2   -- DAY OFF -> SERVER RELEASETIME + WAREHOUSE TIME ZONE OFFSET > 3:00 PM + ORDER RELEASED ON THE DELIVERY BY DATE WILL BE CONSIDERED A LATE ORDER RELEASE
											ELSE COUNT(1) * -1      -- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
											END
								ELSE
									(COUNT(1) - 1) *
										CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
											THEN 1					-- ORDER RELEASED ON THE DELIVERY BY DATE WILL BE COUNTED AS 0 AND IT'S A LATE ORDER RELEASE
										ELSE -1						-- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
										END
								END
							FROM DataWarehouse.dbo.[Time]
							WHERE DateId BETWEEN 
										CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
											THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
										ELSE 
											CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
										END
									AND
										CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
											THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
										ELSE
											CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
										END
								AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
								AND DateId NOT IN (
													SELECT StatutoryHolidayDate
													FROM dbo.StatutoryHoliday
													WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
														AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
												  )
							)
						END) <= 0
					THEN 'Yes'
					ELSE 'No'
				END
			, LateShipmentFlag = 
				CASE
					WHEN ISNULL(BillOfLading.ShippingDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					OR ISNULL(SalesOrderPacking.DeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					OR ISNULL(CONVERT(DATE, SalesOrderPacking.ReleaseDateTime), CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
						THEN NULL
					ELSE
						CASE WHEN DATEDIFF(DAY, BillOfLading.ShippingDate, SalesOrderPacking.DeliveryByDate) < 0
						OR (DATEDIFF(DAY, BillOfLading.ShippingDate, SalesOrderPacking.DeliveryByDate) = 0 AND BillOfLading.LoadAndGoFlag <> 'Y')
							THEN 
								CASE WHEN (BillOfLading.FreightTermCode = 'PU' AND DATEDIFF(DAY, BillOfLading.ShippingDate, SalesOrderPacking.DeliveryByDate) = 0)
									THEN 'No'
								ELSE
									'Yes'
								END
						ELSE
							'No'
						END
				END
			, DayOffFlag =
				CASE 
					WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
						THEN 'Yes'
					ELSE
						'No'
				END
			, TimeZoneOffset = WarehouseTimeZone.TimeZoneOffset
			, ConsolidationFlag = ISNULL(BillOfLading.ConsolidatedFreightFlag, '')
			, ConsolidationNumber = ISNULL(BillOfLading.ConsolidatedFreightNumber, '')
			, CrossDockFlag =
				CASE
					WHEN BillOfLading.CrossDockBillOfLadingNumber <> ''
					OR BillOfLading.CrossDockWarehouseCode <> ''
						THEN 'Yes'
					ELSE
						'No'
				END
			, BillOfLading.CrossDockBillOfLadingNumber
			, BillOfLading.CrossDockWarehouseCode
			, FreightMethodCode = ISNULL(BillOfLading.FreightMethodCode, '')
			, FreightMethodName = ISNULL(FreightMethod.FreightMethodName, '')
			, FreightCarrierCode = ISNULL(BillOfLading.FreightCarrierCode, '')
			, FreightCarrierName = ISNULL(FreightCarrier.FreightCarrierName, '')
			, FreightTermCode = ISNULL(BillOfLading.FreightTermCode, '')
			, FreightTermName = ISNULL(FreightTerm.FreightTermName, '')
			, BillOfLading.BillOfLadingNumber
			, BillOfLading.ReleaseNumber
			, BillOfLading.InvoiceNumber
			, InvoiceAmount = ISNULL(CONVERT(NVARCHAR(15),SUM(Invoice.ExtendedPriceAmount + Invoice.ValueAddedTaxAmount)),'')
			, ShippingUserId = ISNULL(BillOfLading.TransactionUserCode, '')
			, BillOfLading.OrderNumber
			, OperatorCode = 
				CASE WHEN LEFT(BillOfLading.OrderNumber, 1) = 'T'
					THEN ISNULL((
						SELECT TOP 1 TransferOrder.OperatorCode
						FROM DataWarehouse.dbo.TransferOrder
						WHERE TransferOrder.OrderNumber = BillOfLading.OrderNumber
						ORDER BY TransferOrder.OperatorCode ASC
					), '')
				ELSE
					ISNULL(SalesOrder.OperatorCode, '')
				END 
			, ReleaseDate = CONVERT(VARCHAR(10), SalesOrderPacking.ReleaseDateTime, 120)
			, ReleaseTime = CONVERT(VARCHAR(8), SalesOrderPacking.ReleaseDateTime, 114)
			, InitialDeliveryByDate = 
				CASE 
					WHEN ISNULL(SalesOrderPacking.PreviousDeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
						THEN CONVERT(VARCHAR(10), SalesOrderPacking.DeliveryByDate, 120)
					ELSE
						CONVERT(VARCHAR(10), SalesOrderPacking.PreviousDeliveryByDate, 120)
				END
			, ApptFlag = SalesOrderPacking.AppointmentFlag
			, UpdatedDeliveryByDate = CONVERT(VARCHAR(10), SalesOrderPacking.DeliveryByDate, 120)
			, ShippingDate = CONVERT(VARCHAR(10), BillOfLading.ShippingDate, 120)
			, EstimatedShipmentTransitDays = CASE WHEN ISNULL(BillOfLading.ShipmentTransitDays, 0) > 0 THEN BillOfLading.ShipmentTransitDays ELSE 0 END
			, EstimatedArrivalDate = CONVERT(VARCHAR(10), DATEADD(DAY, CASE WHEN ISNULL(BillOfLading.ShipmentTransitDays, 0) > 0 THEN BillOfLading.ShipmentTransitDays ELSE 0 END, BillOfLading.ShippingDate))
			, [UpdatedDelDt - InitialDelDt] =
				CASE 
					WHEN ISNULL(SalesOrderPacking.PreviousDeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
						THEN 0
					ELSE 
						DATEDIFF(DAY, SalesOrderPacking.PreviousDeliveryByDate, SalesOrderPacking.DeliveryByDate)
				END
			, [DelDt - RelDt] = 
				CASE
					WHEN ISNULL(CONVERT(DATE, SalesOrderPacking.ReleaseDateTime), CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					OR ISNULL(SalesOrderPacking.DeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
						THEN NULL
					ELSE
						(
						SELECT
							CASE 
								WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
									THEN 
										CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
											THEN COUNT(1) - 2   -- DAY OFF -> SERVER RELEASETIME + WAREHOUSE TIME ZONE OFFSET > 3:00 PM + ORDER RELEASED ON THE DELIVERY BY DATE WILL BE CONSIDERED A LATE ORDER RELEASE
										ELSE COUNT(1) * -1      -- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
										END
							ELSE
								(COUNT(1) - 1) *
									CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
										THEN 1					-- ORDER RELEASED ON THE DELIVERY BY DATE WILL BE COUNTED AS 0 AND IT'S A LATE ORDER RELEASE
									ELSE -1						-- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
									END
							END
						FROM DataWarehouse.dbo.[Time]
						WHERE DateId BETWEEN 
									CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
										THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
									ELSE 
										CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
									END
								AND
									CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
										THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
									ELSE
										CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
									END
							AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
							AND DateId NOT IN (
												SELECT StatutoryHolidayDate
												FROM dbo.StatutoryHoliday
												WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
													AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
												)
						)
					END
			, [ShpDt - RelDt] = 
				CASE 
					WHEN ISNULL(CONVERT(DATE, SalesOrderPacking.ReleaseDateTime), CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					OR ISNULL(BillOfLading.ShippingDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
						THEN NULL 
					ELSE
						(
						SELECT 
							CASE 
								WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
									THEN
										CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
											THEN COUNT(1) - 1
										ELSE COUNT(1) * -1
										END 
							ELSE
								COUNT(1) *
									CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
										THEN 1
									ELSE -1
									END
							END
						FROM DataWarehouse.dbo.[Time]
						WHERE DateId BETWEEN
								CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
									THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
								ELSE 
									CONVERT(DATE, BillOfLading.ShippingDate)
								END 
							AND 
								CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
									THEN CONVERT(DATE, BillOfLading.ShippingDate)
								ELSE 
									CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
								END 
						AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
						AND DateId NOT IN (
												SELECT StatutoryHolidayDate
												FROM dbo.StatutoryHoliday
												WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
													AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
										  )
						)
					END
			, [DelDt - ShpDt] =
				CASE
					WHEN ISNULL(BillOfLading.ShippingDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					OR ISNULL(SalesOrderPacking.DeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
						THEN NULL
					ELSE 
						(
						SELECT 
							(COUNT(1) - 1) *
								CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, BillOfLading.ShippingDate)
									THEN 1
								ELSE -1
								END
						FROM DataWarehouse.dbo.[Time]
						WHERE DateId BETWEEN
								CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
									THEN CONVERT(DATE, BillOfLading.ShippingDate)
								ELSE 
									CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
								END 
							AND 
								CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
									THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
								ELSE 
									CONVERT(DATE, BillOfLading.ShippingDate)
								END 
						AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
						AND DateId NOT IN (
												SELECT StatutoryHolidayDate
												FROM dbo.StatutoryHoliday
												WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
													AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
										  )
						)
				END
			, [(DelDt - RelDt) Range] = 
				CASE 
					WHEN ISNULL(CONVERT(DATE, SalesOrderPacking.ReleaseDateTime), CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					OR ISNULL(SalesOrderPacking.DeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
						THEN NULL
					WHEN (
						SELECT
							CASE 
								WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
									THEN 
										CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
											THEN COUNT(1) - 2   -- DAY OFF -> SERVER RELEASETIME + WAREHOUSE TIME ZONE OFFSET > 3:00 PM + ORDER RELEASED ON THE DELIVERY BY DATE WILL BE CONSIDERED A LATE ORDER RELEASE
										ELSE COUNT(1) * -1      -- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
										END
							ELSE
								(COUNT(1) - 1) *
									CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
										THEN 1					-- ORDER RELEASED ON THE DELIVERY BY DATE WILL BE COUNTED AS 0 AND IT'S A LATE ORDER RELEASE
									ELSE -1						-- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
									END
							END
						FROM DataWarehouse.dbo.[Time]
						WHERE DateId BETWEEN 
									CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
										THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
									ELSE 
										CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
									END
								AND
									CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
										THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
									ELSE
										CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
									END
							AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
							AND DateId NOT IN (
												SELECT StatutoryHolidayDate
												FROM dbo.StatutoryHoliday
												WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
													AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
												)
						) >= 10
							THEN '>= 10'
					WHEN (
						SELECT
							CASE 
								WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
									THEN 
										CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
											THEN COUNT(1) - 2   -- DAY OFF -> SERVER RELEASETIME + WAREHOUSE TIME ZONE OFFSET > 3:00 PM + ORDER RELEASED ON THE DELIVERY BY DATE WILL BE CONSIDERED A LATE ORDER RELEASE
										ELSE COUNT(1) * -1      -- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
										END
							ELSE
								(COUNT(1) - 1) *
									CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
										THEN 1					-- ORDER RELEASED ON THE DELIVERY BY DATE WILL BE COUNTED AS 0 AND IT'S A LATE ORDER RELEASE
									ELSE -1						-- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
									END
							END
						FROM DataWarehouse.dbo.[Time]
						WHERE DateId BETWEEN 
									CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
										THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
									ELSE 
										CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
									END
								AND
									CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
										THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
									ELSE
										CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
									END
							AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
							AND DateId NOT IN (
												SELECT StatutoryHolidayDate
												FROM dbo.StatutoryHoliday
												WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
													AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
												)
						) < 0
							THEN '< 0'

					ELSE 
						CONVERT(VARCHAR(15), (
												SELECT
													CASE 
														WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
															THEN 
																CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
																	THEN COUNT(1) - 2   -- DAY OFF -> SERVER RELEASETIME + WAREHOUSE TIME ZONE OFFSET > 3:00 PM + ORDER RELEASED ON THE DELIVERY BY DATE WILL BE CONSIDERED A LATE ORDER RELEASE
																ELSE COUNT(1) * -1      -- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
																END
													ELSE
														(COUNT(1) - 1) *
															CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
																THEN 1					-- ORDER RELEASED ON THE DELIVERY BY DATE WILL BE COUNTED AS 0 AND IT'S A LATE ORDER RELEASE
															ELSE -1						-- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
															END
													END
												FROM DataWarehouse.dbo.[Time]
												WHERE DateId BETWEEN 
															CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
																THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
															ELSE 
																CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
															END
														AND
															CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
																THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
															ELSE
																CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
															END
													AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
													AND DateId NOT IN (
																		SELECT StatutoryHolidayDate
																		FROM dbo.StatutoryHoliday
																		WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
																			AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
																		)
												))
				END 
			, [(ShpDt - RelDt) Range] = 
				CASE 
					WHEN ISNULL(CONVERT(DATE, SalesOrderPacking.ReleaseDateTime), CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					OR ISNULL(BillOfLading.ShippingDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
						THEN NULL
					WHEN 
						(
						SELECT 
							CASE 
								WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
									THEN
										CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
											THEN COUNT(1) - 1
										ELSE COUNT(1) * -1
										END 
							ELSE
								COUNT(1) *
									CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
										THEN 1
									ELSE -1
									END
							END
						FROM DataWarehouse.dbo.[Time]
						WHERE DateId BETWEEN
								CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
									THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
								ELSE 
									CONVERT(DATE, BillOfLading.ShippingDate)
								END 
							AND 
								CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
									THEN CONVERT(DATE, BillOfLading.ShippingDate)
								ELSE 
									CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
								END 
						AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
						AND DateId NOT IN (
												SELECT StatutoryHolidayDate
												FROM dbo.StatutoryHoliday
												WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
													AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
										  )
						) >= 10
							THEN '>= 10'
					WHEN 
						(
						SELECT 
							CASE 
								WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
									THEN
										CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
											THEN COUNT(1) - 1
										ELSE COUNT(1) * -1
										END 
							ELSE
								COUNT(1) *
									CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
										THEN 1
									ELSE -1
									END
							END
						FROM DataWarehouse.dbo.[Time]
						WHERE DateId BETWEEN
								CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
									THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
								ELSE 
									CONVERT(DATE, BillOfLading.ShippingDate)
								END 
							AND 
								CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
									THEN CONVERT(DATE, BillOfLading.ShippingDate)
								ELSE 
									CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
								END 
						AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
						AND DateId NOT IN (
												SELECT StatutoryHolidayDate
												FROM dbo.StatutoryHoliday
												WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
													AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
										  )
						) < 0
							THEN '< 0'
					ELSE 
						CONVERT(VARCHAR(15), (
												SELECT 
													CASE 
														WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
															THEN
																CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
																	THEN COUNT(1) - 1
																ELSE COUNT(1) * -1
																END 
													ELSE
														COUNT(1) *
															CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
																THEN 1
															ELSE -1
															END
													END
												FROM DataWarehouse.dbo.[Time]
												WHERE DateId BETWEEN
														CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
															THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
														ELSE 
															CONVERT(DATE, BillOfLading.ShippingDate)
														END 
													AND 
														CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
															THEN CONVERT(DATE, BillOfLading.ShippingDate)
														ELSE 
															CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
														END 
												AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
												AND DateId NOT IN (
																		SELECT StatutoryHolidayDate
																		FROM dbo.StatutoryHoliday
																		WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
																			AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
																  )
												))
				END 
			, [(DelDt - ShpDt) Range] = 
				CASE
					WHEN ISNULL(BillOfLading.ShippingDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					OR ISNULL(SalesOrderPacking.DeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
						THEN NULL
					WHEN 
						(
						SELECT 
							(COUNT(1) - 1) *
								CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, BillOfLading.ShippingDate)
									THEN 1
								ELSE -1
								END
						FROM DataWarehouse.dbo.[Time]
						WHERE DateId BETWEEN
								CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
									THEN CONVERT(DATE, BillOfLading.ShippingDate)
								ELSE 
									CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
								END 
							AND 
								CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
									THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
								ELSE 
									CONVERT(DATE, BillOfLading.ShippingDate)
								END 
						AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
						AND DateId NOT IN (
												SELECT StatutoryHolidayDate
												FROM dbo.StatutoryHoliday
												WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
													AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
										  )
						) >= 10
							THEN '>= 10'
					WHEN 
						(
						SELECT 
							(COUNT(1) - 1) *
								CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, BillOfLading.ShippingDate)
									THEN 1
								ELSE -1
								END
						FROM DataWarehouse.dbo.[Time]
						WHERE DateId BETWEEN
								CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
									THEN CONVERT(DATE, BillOfLading.ShippingDate)
								ELSE 
									CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
								END 
							AND 
								CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
									THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
								ELSE 
									CONVERT(DATE, BillOfLading.ShippingDate)
								END 
						AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
						AND DateId NOT IN (
												SELECT StatutoryHolidayDate
												FROM dbo.StatutoryHoliday
												WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
													AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
										  )
						) < 0
							THEN '< 0'
					ELSE 
						CONVERT(VARCHAR(15), (
												SELECT 
													(COUNT(1) - 1) *
														CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, BillOfLading.ShippingDate)
															THEN 1
														ELSE -1
														END
												FROM DataWarehouse.dbo.[Time]
												WHERE DateId BETWEEN
														CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
															THEN CONVERT(DATE, BillOfLading.ShippingDate)
														ELSE 
															CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
														END 
													AND 
														CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
															THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
														ELSE 
															CONVERT(DATE, BillOfLading.ShippingDate)
														END 
												AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
												AND DateId NOT IN (
																		SELECT StatutoryHolidayDate
																		FROM dbo.StatutoryHoliday
																		WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
																			AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
																  )
												))
				END
			, NumberOfLines = COUNT(1)
			, ShippingWeight = ISNULL(CONVERT(NVARCHAR(15),SUM(BillOfLading.ShippingWeight)),'')
		FROM DataWarehouse.dbo.BillOfLading
			INNER JOIN DataWarehouse.dbo.Warehouse ShippingWarehouse ON
				BillOfLading.ShippingWarehouseCode = ShippingWarehouse.WarehouseCode
			INNER JOIN DataWarehouse.dbo.Company ShippingWarehouseCompany ON 
				BillOfLading.ShippingCompanyCode = ShippingWarehouseCompany.CompanyCode
			INNER JOIN DataWarehouse.dbo.Warehouse ReceivingWarehouse ON
				BillOfLading.ReceivingWarehouseCode = ReceivingWarehouse.WarehouseCode
			INNER JOIN DataWarehouse.dbo.FreightCarrier ON
				BillOfLading.FreightCarrierCode = FreightCarrier.FreightCarrierCode
			INNER JOIN DataWarehouse.dbo.FreightMethod ON
				BillOfLading.FreightMethodCode = FreightMethod.FreightMethodCode
			INNER JOIN DataWarehouse.dbo.FreightTerm ON
				BillOfLading.FreightTermCode = FreightTerm.FreightTermCode
			LEFT JOIN DataWarehouse.dbo.Invoice ON
				BillOfLading.InvoiceNumber = Invoice.InvoiceNumber
				AND BillOfLading.OrderNumber = Invoice.OrderNumber
				AND BillOfLading.ReleaseNumber = Invoice.ReleaseNumber
				AND BillOfLading.LineItemNumber = Invoice.LineItemNumber
			LEFT JOIN DataWarehouse.dbo.SalesOrderPacking ON
				BillOfLading.OrderNumber = SalesOrderPacking.OrderNumber
				AND BillOfLading.ReleaseNumber = SalesOrderPacking.ReleaseNumber
			LEFT JOIN DataWarehouse.dbo.SalesOrder ON
				BillOfLading.OrderNumber = SalesOrder.OrderNumber
				AND BillOfLading.LineItemNumber = SalesOrder.LineItemNumber
			LEFT JOIN DataWarehouse.dbo.SalesOffice ON
				SalesOrder.SalesOfficeCode = SalesOffice.SalesOfficeCode
			LEFT JOIN DataWarehouse.dbo.ShipToCustomer ON
				SalesOrder.CompanyCode = ShipToCustomer.CompanyCode
				AND SalesOrder.CustomerCode = ShipToCustomer.ShipToCustomerCode
			LEFT JOIN DataWarehouse.dbo.AccountReceivableCustomer ON
				ShipToCustomer.CompanyCode = AccountReceivableCustomer.CompanyCode
				AND ShipToCustomer.AccountReceivableCode = AccountReceivableCustomer.AccountReceivableCustomerCode
			LEFT JOIN DataWarehouse.dbo.CustomerGroup ON
				ShipToCustomer.CustomerGroupCode = CustomerGroup.CustomerGroupCode
			LEFT JOIN DataWarehouse.dbo.Region ON
				ShipToCustomer.RegionCode = Region.RegionCode
			LEFT JOIN dbo.WarehouseTimeZone ON
				ShippingWarehouse.WarehouseCode = WarehouseTimeZone.WarehouseCode
		WHERE BillOfLading.FreightTransactionTypeCode <> 'MB'
			AND ShippingWarehouse.PhantomWarehouse = 0
			AND ReceivingWarehouse.PhantomWarehouse = 0
			AND BillOfLading.FiscalPeriodCode LIKE CASE WHEN @FiscalPeriod = 'ALL' THEN CONCAT(@FiscalYear, '%') ELSE @FiscalPeriod END
			AND ShippingWarehouseCompany.CompanyCode = CASE WHEN UPPER(@CompanyCode) = 'ALL' THEN ShippingWarehouseCompany.CompanyCode ELSE @CompanyCode END
			AND BillOfLading.ShippingWarehouseCode = CASE WHEN UPPER(@ShippingWarehouseCode) = 'ALL' THEN BillOfLading.ShippingWarehouseCode ELSE @ShippingWarehouseCode END
			AND BillOfLading.ReceivingWarehouseCode = CASE WHEN UPPER(@ReceivingWarehouseCode) = 'ALL' THEN BillOfLading.ReceivingWarehouseCode ELSE @ReceivingWarehouseCode END	
		GROUP BY BillOfLading.FiscalPeriodCode
			, ShippingWarehouseCompany.CompanyCode
			, ShippingWarehouseCompany.CompanyName
			, SalesOffice.SalesOfficeCode
			, SalesOffice.SalesOfficeName
			, ShipToCustomer.RegionCode
			, Region.RegionName
			, AccountReceivableCustomer.AccountReceivableCustomerCode
			, AccountReceivableCustomer.AccountReceivableCustomerName
			, ShipToCustomer.BuyingGroupCode
			, CustomerGroup.CustomerGroupCode
			, CustomerGroup.CustomerGroupName
			, SalesOrder.CustomerCode
			, SalesOrder.ShipToName
			, SalesOrder.RequestDate
			, SalesOrder.CustomerOrderDate
			, BillOfLading.ShippingWarehouseCode
			, ShippingWarehouse.WarehouseName
			, BillOfLading.ReceivingWarehouseCode
			, ReceivingWarehouse.WarehouseName
			, BillOfLading.OrderNumber
			, BillOfLading.FreightTermCode
			, BillOfLading.LoadAndGoFlag
			, ShippingWarehouse.RegionCode
			, SalesOrderPacking.ReleaseDateTime
			, SalesOrderPacking.DeliveryByDate
			, WarehouseTimeZone.TimeZoneOffset
			, BillOfLading.ConsolidatedFreightFlag
			, BillOfLading.ConsolidatedFreightNumber
			, BillOfLading.ShippingDate
			, BillOfLading.CrossDockBillOfLadingNumber
			, BillOfLading.CrossDockWarehouseCode
			, BillOfLading.FreightMethodCode
			, FreightMethod.FreightMethodName
			, BillOfLading.FreightCarrierCode
			, FreightCarrier.FreightCarrierName
			, FreightTerm.FreightTermName
			, BillOfLading.BillOfLadingNumber
			, BillOfLading.ReleaseNumber
			, BillOfLading.InvoiceNumber
			, BillOfLading.TransactionUserCode
			, SalesOrder.OperatorCode
			, SalesOrderPacking.PreviousDeliveryByDate
			, SalesOrderPacking.PreviousDeliveryByDate
			, SalesOrderPacking.AppointmentFlag    
			, BillOfLading.ShipmentTransitDays
			, ShipToCustomer.CityCode
			, ShipToCustomer.StateProvinceCode
	ELSE
		SELECT FiscalMonth = BillOfLading.FiscalPeriodCode
		, ShippingWarehouseCompany.CompanyCode
		, ShippingWarehouseCompany.CompanyName
		, SalesOfficeCode = ISNULL(SalesOffice.SalesOfficeCode, '')
		, SalesOfficeName = ISNULL(SalesOffice.SalesOfficeName, '')
		, SalesRegionCode = ISNULL(ShipToCustomer.RegionCode, '')
		, SalesRegionName = ISNULL(Region.RegionName, '') 
		, MarketSegmentCode = ISNULL(MarketSegment.MarketSegmentCode, '')
		, MarketSegmentName = ISNULL(MarketSegment.MarketSegmentName, '')
		, AccountReceivableCustomerCode = ISNULL(AccountReceivableCustomer.AccountReceivableCustomerCode, '')
		, AccountReceivableCustomerName = ISNULL(AccountReceivableCustomer.AccountReceivableCustomerName, '')
		, BuyingGroupCode = ISNULL(ShipToCustomer.BuyingGroupCode, '') 
		, CustomerGroupCode = ISNULL(SUBSTRING(CustomerGroup.CustomerGroupCode, CHARINDEX('*', CustomerGroup.CustomerGroupCode) + 1, LEN(CustomerGroup.CustomerGroupCode)), '')
		, CustomerGroupName = ISNULL(CustomerGroup.CustomerGroupName, '')
		, CustomerShipToCode = ISNULL(SalesOrder.CustomerCode, '')
		, CustomerShipToName = ISNULL(SalesOrder.ShipToName, '')
		, CustomerShipToCity = ISNULL(ShipToCustomer.CityCode, '')
		, CustomerShipToStateProvince = ISNULL(ShipToCustomer.StateProvinceCode, '')
		, CustomerOrderRequestDate = ISNULL(SalesOrder.RequestDate, '')
		, CustomerOrderDate = ISNULL(SalesOrder.CustomerOrderDate, '')
		, BillOfLading.ShippingWarehouseCode
		, ShippingWarehouseName = ShippingWarehouse.WarehouseName
		, BillOfLading.ReceivingWarehouseCode
		, ReceivingWarehouseName = ReceivingWarehouse.WarehouseName
		, TransferOrderFlag = CASE WHEN BillOfLading.OrderNumber LIKE 'T%' THEN 'Yes' ELSE 'No' END
		, PickUpOrderFlag = CASE WHEN BillOfLading.FreightTermCode = 'PU' THEN 'Yes' ELSE 'No' END
		, LoadAndGoFlag = ISNULL(BillOfLading.LoadAndGoFlag, '')
		, LateOrderReleaseFlag = 
			CASE 
				WHEN (CASE
					WHEN ISNULL(CONVERT(DATE, SalesOrderPacking.ReleaseDateTime), CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					OR ISNULL(SalesOrderPacking.DeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
						THEN NULL
					ELSE
						(
						SELECT
							CASE 
								WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
									THEN 
										CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
											THEN COUNT(1) - 2   -- DAY OFF -> SERVER RELEASETIME + WAREHOUSE TIME ZONE OFFSET > 3:00 PM + ORDER RELEASED ON THE DELIVERY BY DATE WILL BE CONSIDERED A LATE ORDER RELEASE
										ELSE COUNT(1) * -1      -- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
										END
							ELSE
								(COUNT(1) - 1) *
									CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
										THEN 1					-- ORDER RELEASED ON THE DELIVERY BY DATE WILL BE COUNTED AS 0 AND IT'S A LATE ORDER RELEASE
									ELSE -1						-- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
									END
							END
						FROM DataWarehouse.dbo.[Time]
						WHERE DateId BETWEEN 
									CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
										THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
									ELSE 
										CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
									END
								AND
									CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
										THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
									ELSE
										CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
									END
							AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
							AND DateId NOT IN (
												SELECT StatutoryHolidayDate
												FROM dbo.StatutoryHoliday
												WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
													AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
											  )
						)
					END) <= 0
				THEN 'Yes'
				ELSE 'No'
			END
		, LateShipmentFlag = 
			CASE
				WHEN ISNULL(BillOfLading.ShippingDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
				OR ISNULL(SalesOrderPacking.DeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
				OR ISNULL(CONVERT(DATE, SalesOrderPacking.ReleaseDateTime), CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					THEN NULL
				ELSE
					CASE WHEN DATEDIFF(DAY, BillOfLading.ShippingDate, SalesOrderPacking.DeliveryByDate) < 0
					OR (DATEDIFF(DAY, BillOfLading.ShippingDate, SalesOrderPacking.DeliveryByDate) = 0
					AND BillOfLading.LoadAndGoFlag <> 'Y')
						THEN 'Yes'
					ELSE
						'No'
					END
			END
		, DayOffFlag =
			CASE 
				WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
					THEN 'Yes'
				ELSE
					'No'
			END
		, TimeZoneOffset = WarehouseTimeZone.TimeZoneOffset
		, ConsolidationFlag = ISNULL(BillOfLading.ConsolidatedFreightFlag, '')
		, ConsolidationNumber = ISNULL(BillOfLading.ConsolidatedFreightNumber, '')
		, CrossDockFlag =
			CASE
				WHEN BillOfLading.CrossDockBillOfLadingNumber <> ''
				OR BillOfLading.CrossDockWarehouseCode <> ''
					THEN 'Yes'
				ELSE
					'No'
			END
		, BillOfLading.CrossDockBillOfLadingNumber
		, BillOfLading.CrossDockWarehouseCode
		, FreightMethodCode = ISNULL(BillOfLading.FreightMethodCode, '')
		, FreightMethodName = ISNULL(FreightMethod.FreightMethodName, '')
		, FreightCarrierCode = ISNULL(BillOfLading.FreightCarrierCode, '')
		, FreightCarrierName = ISNULL(FreightCarrier.FreightCarrierName, '')
		, FreightTermCode = ISNULL(BillOfLading.FreightTermCode, '')
		, FreightTermName = ISNULL(FreightTerm.FreightTermName, '')
		, BillOfLading.BillOfLadingNumber
		, BillOfLading.ReleaseNumber
		, BillOfLading.InvoiceNumber
		, InvoiceAmount = ISNULL(CONVERT(NVARCHAR(15),SUM(Invoice.ExtendedPriceAmount + Invoice.ValueAddedTaxAmount)),'')
		, ShippingUserId = ISNULL(BillOfLading.TransactionUserCode, '')
		, BillOfLading.OrderNumber
		, OperatorCode = 
			CASE WHEN LEFT(BillOfLading.OrderNumber, 1) = 'T'
				THEN ISNULL((
					SELECT TOP 1 TransferOrder.OperatorCode
					FROM DataWarehouse.dbo.TransferOrder
					WHERE TransferOrder.OrderNumber = BillOfLading.OrderNumber
					ORDER BY TransferOrder.OperatorCode ASC
				), '')
			ELSE
				ISNULL(SalesOrder.OperatorCode, '')
			END 
		, ReleaseDate = CONVERT(VARCHAR(10), SalesOrderPacking.ReleaseDateTime, 120)
		, ReleaseTime = CONVERT(VARCHAR(8), SalesOrderPacking.ReleaseDateTime, 114)
		, InitialDeliveryByDate = 
			CASE 
				WHEN ISNULL(SalesOrderPacking.PreviousDeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					THEN CONVERT(VARCHAR(10), SalesOrderPacking.DeliveryByDate, 120)
				ELSE
					CONVERT(VARCHAR(10), SalesOrderPacking.PreviousDeliveryByDate, 120)
			END
		, ApptFlag = SalesOrderPacking.AppointmentFlag
		, UpdatedDeliveryByDate = CONVERT(VARCHAR(10), SalesOrderPacking.DeliveryByDate, 120)
		, ShippingDate = CONVERT(VARCHAR(10), BillOfLading.ShippingDate, 120)
		, EstimatedShipmentTransitDays = CASE WHEN ISNULL(BillOfLading.ShipmentTransitDays, 0) > 0 THEN BillOfLading.ShipmentTransitDays ELSE 0 END
		, EstimatedArrivalDate = CONVERT(VARCHAR(10), DATEADD(DAY, CASE WHEN ISNULL(BillOfLading.ShipmentTransitDays, 0) > 0 THEN BillOfLading.ShipmentTransitDays ELSE 0 END, BillOfLading.ShippingDate))
		, [UpdatedDelDt - InitialDelDt] =
			CASE 
				WHEN ISNULL(SalesOrderPacking.PreviousDeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					THEN 0
				ELSE 
					DATEDIFF(DAY, SalesOrderPacking.PreviousDeliveryByDate, SalesOrderPacking.DeliveryByDate)
			END
		, [DelDt - RelDt] = 
			CASE
				WHEN ISNULL(CONVERT(DATE, SalesOrderPacking.ReleaseDateTime), CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
				OR ISNULL(SalesOrderPacking.DeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					THEN NULL
				ELSE
					(
					SELECT
						CASE 
							WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
								THEN 
									CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
										THEN COUNT(1) - 2   -- DAY OFF -> SERVER RELEASETIME + WAREHOUSE TIME ZONE OFFSET > 3:00 PM + ORDER RELEASED ON THE DELIVERY BY DATE WILL BE CONSIDERED A LATE ORDER RELEASE
									ELSE COUNT(1) * -1      -- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
									END
						ELSE
							(COUNT(1) - 1) *
								CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
									THEN 1					-- ORDER RELEASED ON THE DELIVERY BY DATE WILL BE COUNTED AS 0 AND IT'S A LATE ORDER RELEASE
								ELSE -1						-- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
								END
						END
					FROM DataWarehouse.dbo.[Time]
					WHERE DateId BETWEEN 
								CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
									THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
								ELSE 
									CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
								END
							AND
								CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
									THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
								ELSE
									CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
								END
						AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
						AND DateId NOT IN (
											SELECT StatutoryHolidayDate
											FROM dbo.StatutoryHoliday
											WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
												AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
											)
					)
				END
		, [ShpDt - RelDt] = 
			CASE 
				WHEN ISNULL(CONVERT(DATE, SalesOrderPacking.ReleaseDateTime), CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
				OR ISNULL(BillOfLading.ShippingDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					THEN NULL 
				ELSE
					(
					SELECT 
						CASE 
							WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
								THEN
									CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
										THEN COUNT(1) - 1
									ELSE COUNT(1) * -1
									END 
						ELSE
							COUNT(1) *
								CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
									THEN 1
								ELSE -1
								END
						END
					FROM DataWarehouse.dbo.[Time]
					WHERE DateId BETWEEN
							CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
								THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
							ELSE 
								CONVERT(DATE, BillOfLading.ShippingDate)
							END 
						AND 
							CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
								THEN CONVERT(DATE, BillOfLading.ShippingDate)
							ELSE 
								CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
							END 
					AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
					AND DateId NOT IN (
											SELECT StatutoryHolidayDate
											FROM dbo.StatutoryHoliday
											WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
												AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
									  )
					)
				END
		, [DelDt - ShpDt] =
			CASE
				WHEN ISNULL(BillOfLading.ShippingDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
				OR ISNULL(SalesOrderPacking.DeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					THEN NULL
				ELSE 
					(
					SELECT 
						(COUNT(1) - 1) *
							CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, BillOfLading.ShippingDate)
								THEN 1
							ELSE -1
							END
					FROM DataWarehouse.dbo.[Time]
					WHERE DateId BETWEEN
							CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
								THEN CONVERT(DATE, BillOfLading.ShippingDate)
							ELSE 
								CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
							END 
						AND 
							CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
								THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
							ELSE 
								CONVERT(DATE, BillOfLading.ShippingDate)
							END 
					AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
					AND DateId NOT IN (
											SELECT StatutoryHolidayDate
											FROM dbo.StatutoryHoliday
											WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
												AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
									  )
					)
			END
		, [(DelDt - RelDt) Range] = 
			CASE 
				WHEN ISNULL(CONVERT(DATE, SalesOrderPacking.ReleaseDateTime), CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
				OR ISNULL(SalesOrderPacking.DeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					THEN NULL
				WHEN (
					SELECT
						CASE 
							WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
								THEN 
									CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
										THEN COUNT(1) - 2   -- DAY OFF -> SERVER RELEASETIME + WAREHOUSE TIME ZONE OFFSET > 3:00 PM + ORDER RELEASED ON THE DELIVERY BY DATE WILL BE CONSIDERED A LATE ORDER RELEASE
									ELSE COUNT(1) * -1      -- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
									END
						ELSE
							(COUNT(1) - 1) *
								CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
									THEN 1					-- ORDER RELEASED ON THE DELIVERY BY DATE WILL BE COUNTED AS 0 AND IT'S A LATE ORDER RELEASE
								ELSE -1						-- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
								END
						END
					FROM DataWarehouse.dbo.[Time]
					WHERE DateId BETWEEN 
								CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
									THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
								ELSE 
									CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
								END
							AND
								CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
									THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
								ELSE
									CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
								END
						AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
						AND DateId NOT IN (
											SELECT StatutoryHolidayDate
											FROM dbo.StatutoryHoliday
											WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
												AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
											)
					) >= 10
						THEN '>= 10'
				WHEN (
					SELECT
						CASE 
							WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
								THEN 
									CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
										THEN COUNT(1) - 2   -- DAY OFF -> SERVER RELEASETIME + WAREHOUSE TIME ZONE OFFSET > 3:00 PM + ORDER RELEASED ON THE DELIVERY BY DATE WILL BE CONSIDERED A LATE ORDER RELEASE
									ELSE COUNT(1) * -1      -- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
									END
						ELSE
							(COUNT(1) - 1) *
								CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
									THEN 1					-- ORDER RELEASED ON THE DELIVERY BY DATE WILL BE COUNTED AS 0 AND IT'S A LATE ORDER RELEASE
								ELSE -1						-- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
								END
						END
					FROM DataWarehouse.dbo.[Time]
					WHERE DateId BETWEEN 
								CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
									THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
								ELSE 
									CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
								END
							AND
								CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
									THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
								ELSE
									CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
								END
						AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
						AND DateId NOT IN (
											SELECT StatutoryHolidayDate
											FROM dbo.StatutoryHoliday
											WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
												AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
											)
					) < 0
						THEN '< 0'

				ELSE 
					CONVERT(VARCHAR(15), (
											SELECT
												CASE 
													WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
														THEN 
															CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
																THEN COUNT(1) - 2   -- DAY OFF -> SERVER RELEASETIME + WAREHOUSE TIME ZONE OFFSET > 3:00 PM + ORDER RELEASED ON THE DELIVERY BY DATE WILL BE CONSIDERED A LATE ORDER RELEASE
															ELSE COUNT(1) * -1      -- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
															END
												ELSE
													(COUNT(1) - 1) *
														CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
															THEN 1					-- ORDER RELEASED ON THE DELIVERY BY DATE WILL BE COUNTED AS 0 AND IT'S A LATE ORDER RELEASE
														ELSE -1						-- LATE ORDER RELEASE -> ReleaseDateTime < DeliveryByDate
														END
												END
											FROM DataWarehouse.dbo.[Time]
											WHERE DateId BETWEEN 
														CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
															THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
														ELSE 
															CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
														END
													AND
														CASE WHEN SalesOrderPacking.ReleaseDateTime <= SalesOrderPacking.DeliveryByDate
															THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
														ELSE
															CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
														END
												AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
												AND DateId NOT IN (
																	SELECT StatutoryHolidayDate
																	FROM dbo.StatutoryHoliday
																	WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
																		AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
																	)
											))
			END 
		, [(ShpDt - RelDt) Range] = 
			CASE 
				WHEN ISNULL(CONVERT(DATE, SalesOrderPacking.ReleaseDateTime), CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
				OR ISNULL(BillOfLading.ShippingDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					THEN NULL
				WHEN 
					(
					SELECT 
						CASE 
							WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
								THEN
									CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
										THEN COUNT(1) - 1
									ELSE COUNT(1) * -1
									END 
						ELSE
							COUNT(1) *
								CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
									THEN 1
								ELSE -1
								END
						END
					FROM DataWarehouse.dbo.[Time]
					WHERE DateId BETWEEN
							CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
								THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
							ELSE 
								CONVERT(DATE, BillOfLading.ShippingDate)
							END 
						AND 
							CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
								THEN CONVERT(DATE, BillOfLading.ShippingDate)
							ELSE 
								CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
							END 
					AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
					AND DateId NOT IN (
											SELECT StatutoryHolidayDate
											FROM dbo.StatutoryHoliday
											WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
												AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
									  )
					) >= 10
						THEN '>= 10'
				WHEN 
					(
					SELECT 
						CASE 
							WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
								THEN
									CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
										THEN COUNT(1) - 1
									ELSE COUNT(1) * -1
									END 
						ELSE
							COUNT(1) *
								CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
									THEN 1
								ELSE -1
								END
						END
					FROM DataWarehouse.dbo.[Time]
					WHERE DateId BETWEEN
							CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
								THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
							ELSE 
								CONVERT(DATE, BillOfLading.ShippingDate)
							END 
						AND 
							CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
								THEN CONVERT(DATE, BillOfLading.ShippingDate)
							ELSE 
								CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
							END 
					AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
					AND DateId NOT IN (
											SELECT StatutoryHolidayDate
											FROM dbo.StatutoryHoliday
											WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
												AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
									  )
					) < 0
						THEN '< 0'
				ELSE 
					CONVERT(VARCHAR(15), (
											SELECT 
												CASE 
													WHEN DATEADD(HOUR, WarehouseTimeZone.TimeZoneOffset, SalesOrderPacking.ReleaseDateTime) > DATEADD(HOUR, 15, CONVERT(SMALLDATETIME, DATEDIFF(DAY, 0, DATEADD(DAY, 0, SalesOrderPacking.ReleaseDateTime))))
														THEN
															CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
																THEN COUNT(1) - 1
															ELSE COUNT(1) * -1
															END 
												ELSE
													COUNT(1) *
														CASE WHEN CONVERT(DATE, BillOfLading.ShippingDate) >= CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
															THEN 1
														ELSE -1
														END
												END
											FROM DataWarehouse.dbo.[Time]
											WHERE DateId BETWEEN
													CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
														THEN CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
													ELSE 
														CONVERT(DATE, BillOfLading.ShippingDate)
													END 
												AND 
													CASE WHEN SalesOrderPacking.ReleaseDateTime <= BillOfLading.ShippingDate
														THEN CONVERT(DATE, BillOfLading.ShippingDate)
													ELSE 
														CONVERT(DATE, SalesOrderPacking.ReleaseDateTime)
													END 
											AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
											AND DateId NOT IN (
																	SELECT StatutoryHolidayDate
																	FROM dbo.StatutoryHoliday
																	WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
																		AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
															  )
											))
			END 
		, [(DelDt - ShpDt) Range] = 
			CASE
				WHEN ISNULL(BillOfLading.ShippingDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
				OR ISNULL(SalesOrderPacking.DeliveryByDate, CONVERT(DATE, '19000101')) = CONVERT(DATE, '19000101')
					THEN NULL
				WHEN 
					(
					SELECT 
						(COUNT(1) - 1) *
							CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, BillOfLading.ShippingDate)
								THEN 1
							ELSE -1
							END
					FROM DataWarehouse.dbo.[Time]
					WHERE DateId BETWEEN
							CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
								THEN CONVERT(DATE, BillOfLading.ShippingDate)
							ELSE 
								CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
							END 
						AND 
							CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
								THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
							ELSE 
								CONVERT(DATE, BillOfLading.ShippingDate)
							END 
					AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
					AND DateId NOT IN (
											SELECT StatutoryHolidayDate
											FROM dbo.StatutoryHoliday
											WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
												AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
									  )
					) >= 10
						THEN '>= 10'
				WHEN 
					(
					SELECT 
						(COUNT(1) - 1) *
							CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, BillOfLading.ShippingDate)
								THEN 1
							ELSE -1
							END
					FROM DataWarehouse.dbo.[Time]
					WHERE DateId BETWEEN
							CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
								THEN CONVERT(DATE, BillOfLading.ShippingDate)
							ELSE 
								CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
							END 
						AND 
							CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
								THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
							ELSE 
								CONVERT(DATE, BillOfLading.ShippingDate)
							END 
					AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
					AND DateId NOT IN (
											SELECT StatutoryHolidayDate
											FROM dbo.StatutoryHoliday
											WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
												AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
									  )
					) < 0
						THEN '< 0'
				ELSE 
					CONVERT(VARCHAR(15), (
											SELECT 
												(COUNT(1) - 1) *
													CASE WHEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate) >= CONVERT(DATE, BillOfLading.ShippingDate)
														THEN 1
													ELSE -1
													END
											FROM DataWarehouse.dbo.[Time]
											WHERE DateId BETWEEN
													CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
														THEN CONVERT(DATE, BillOfLading.ShippingDate)
													ELSE 
														CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
													END 
												AND 
													CASE WHEN BillOfLading.ShippingDate <= SalesOrderPacking.DeliveryByDate
														THEN CONVERT(DATE, SalesOrderPacking.DeliveryByDate)
													ELSE 
														CONVERT(DATE, BillOfLading.ShippingDate)
													END 
											AND DATEPART(WEEKDAY, DateId) NOT IN (1, 7)
											AND DateId NOT IN (
																	SELECT StatutoryHolidayDate
																	FROM dbo.StatutoryHoliday
																	WHERE StatutoryHoliday.FiscalYear = LEFT(BillOfLading.FiscalPeriodCode, 4)
																		AND CHARINDEX(ShippingWarehouse.RegionCode, StatutoryHoliday.RegionCodeList) <> 0
															  )
											))
			END
		, NumberOfLines = COUNT(1)
		, ShippingWeight = ISNULL(CONVERT(NVARCHAR(15),SUM(BillOfLading.ShippingWeight)),'')
	FROM DataWarehouse.dbo.BillOfLading
		INNER JOIN DataWarehouse.dbo.Warehouse ShippingWarehouse ON
			BillOfLading.ShippingWarehouseCode = ShippingWarehouse.WarehouseCode
		INNER JOIN DataWarehouse.dbo.Company ShippingWarehouseCompany ON 
			BillOfLading.ShippingCompanyCode = ShippingWarehouseCompany.CompanyCode
		INNER JOIN DataWarehouse.dbo.Warehouse ReceivingWarehouse ON
			BillOfLading.ReceivingWarehouseCode = ReceivingWarehouse.WarehouseCode
		INNER JOIN DataWarehouse.dbo.FreightCarrier ON
			BillOfLading.FreightCarrierCode = FreightCarrier.FreightCarrierCode
		INNER JOIN DataWarehouse.dbo.FreightMethod ON
			BillOfLading.FreightMethodCode = FreightMethod.FreightMethodCode
		INNER JOIN DataWarehouse.dbo.FreightTerm ON
			BillOfLading.FreightTermCode = FreightTerm.FreightTermCode
		LEFT JOIN DataWarehouse.dbo.Invoice ON
			BillOfLading.InvoiceNumber = Invoice.InvoiceNumber
			AND BillOfLading.OrderNumber = Invoice.OrderNumber
			AND BillOfLading.ReleaseNumber = Invoice.ReleaseNumber
			AND BillOfLading.LineItemNumber = Invoice.LineItemNumber
		LEFT JOIN DataWarehouse.dbo.SalesOrderPacking ON
			BillOfLading.OrderNumber = SalesOrderPacking.OrderNumber
			AND BillOfLading.ReleaseNumber = SalesOrderPacking.ReleaseNumber
		LEFT JOIN DataWarehouse.dbo.SalesOrder ON
			BillOfLading.OrderNumber = SalesOrder.OrderNumber
			AND BillOfLading.LineItemNumber = SalesOrder.LineItemNumber
		LEFT JOIN DataWarehouse.dbo.SalesOffice ON
			SalesOrder.SalesOfficeCode = SalesOffice.SalesOfficeCode
		LEFT JOIN DataWarehouse.dbo.ShipToCustomer ON
			SalesOrder.CompanyCode = ShipToCustomer.CompanyCode
			AND SalesOrder.CustomerCode = ShipToCustomer.ShipToCustomerCode
		LEFT JOIN DataWarehouse.dbo.AccountReceivableCustomer ON
			ShipToCustomer.CompanyCode = AccountReceivableCustomer.CompanyCode
			AND ShipToCustomer.AccountReceivableCode = AccountReceivableCustomer.AccountReceivableCustomerCode
		LEFT JOIN DataWarehouse.dbo.CustomerGroup ON
			ShipToCustomer.CustomerGroupCode = CustomerGroup.CustomerGroupCode
		LEFT JOIN DataWarehouse.dbo.Region ON
			ShipToCustomer.RegionCode = Region.RegionCode
		LEFT JOIN dbo.WarehouseTimeZone ON
			ShippingWarehouse.WarehouseCode = WarehouseTimeZone.WarehouseCode
		LEFT JOIN DataWarehouse.dbo.Product ON
			SalesOrder.ComputerizedPartNumber = Product.ComputerizedPartNumber
		LEFT JOIN DataWarehouse.dbo.MarketSegment ON
			Product.MarketSegmentCode = MarketSegment.MarketSegmentCode
	WHERE BillOfLading.FreightTransactionTypeCode <> 'MB'
		AND ShippingWarehouse.PhantomWarehouse = 0
		AND ReceivingWarehouse.PhantomWarehouse = 0
		AND BillOfLading.FiscalPeriodCode LIKE CASE WHEN @FiscalPeriod = 'ALL' THEN CONCAT(@FiscalYear, '%') ELSE @FiscalPeriod END
		AND ShippingWarehouseCompany.CompanyCode = CASE WHEN UPPER(@CompanyCode) = 'ALL' THEN ShippingWarehouseCompany.CompanyCode ELSE @CompanyCode END
		AND BillOfLading.ShippingWarehouseCode = CASE WHEN UPPER(@ShippingWarehouseCode) = 'ALL' THEN BillOfLading.ShippingWarehouseCode ELSE @ShippingWarehouseCode END
		AND BillOfLading.ReceivingWarehouseCode = CASE WHEN UPPER(@ReceivingWarehouseCode) = 'ALL' THEN BillOfLading.ReceivingWarehouseCode ELSE @ReceivingWarehouseCode END
	GROUP BY BillOfLading.FiscalPeriodCode
		, ShippingWarehouseCompany.CompanyCode
		, ShippingWarehouseCompany.CompanyName
		, SalesOffice.SalesOfficeCode
		, SalesOffice.SalesOfficeName
		, ShipToCustomer.RegionCode
		, Region.RegionName
		, AccountReceivableCustomer.AccountReceivableCustomerCode
		, AccountReceivableCustomer.AccountReceivableCustomerName
		, ShipToCustomer.BuyingGroupCode
		, CustomerGroup.CustomerGroupCode
		, CustomerGroup.CustomerGroupName
		, SalesOrder.CustomerCode
		, SalesOrder.ShipToName
		, SalesOrder.RequestDate
		, SalesOrder.CustomerOrderDate
		, BillOfLading.ShippingWarehouseCode
		, ShippingWarehouse.WarehouseName
		, BillOfLading.ReceivingWarehouseCode
		, ReceivingWarehouse.WarehouseName
		, BillOfLading.OrderNumber
		, BillOfLading.FreightTermCode
		, BillOfLading.LoadAndGoFlag
		, ShippingWarehouse.RegionCode
		, SalesOrderPacking.ReleaseDateTime
		, SalesOrderPacking.DeliveryByDate
		, WarehouseTimeZone.TimeZoneOffset
		, BillOfLading.ConsolidatedFreightFlag
		, BillOfLading.ConsolidatedFreightNumber
		, BillOfLading.ShippingDate
		, BillOfLading.CrossDockBillOfLadingNumber
		, BillOfLading.CrossDockWarehouseCode
		, BillOfLading.FreightMethodCode
		, FreightMethod.FreightMethodName
		, BillOfLading.FreightCarrierCode
		, FreightCarrier.FreightCarrierName
		, FreightTerm.FreightTermName
		, BillOfLading.BillOfLadingNumber
		, BillOfLading.ReleaseNumber
		, BillOfLading.InvoiceNumber
		, BillOfLading.TransactionUserCode
		, SalesOrder.OperatorCode
		, SalesOrderPacking.PreviousDeliveryByDate
		, SalesOrderPacking.PreviousDeliveryByDate
		, SalesOrderPacking.AppointmentFlag    
		, BillOfLading.ShipmentTransitDays
		, MarketSegment.MarketSegmentCode
		, MarketSegment.MarketSegmentName
	    , ShipToCustomer.CityCode
		, ShipToCustomer.StateProvinceCode
END













GO


