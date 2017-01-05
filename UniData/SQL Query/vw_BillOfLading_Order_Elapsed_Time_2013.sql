USE [Report]
GO

/****** Object:  View [dbo].[vw_BillOfLading_Order_Elapsed_Time_2013]    Script Date: 26/11/2013 2:01:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***********************************************************************************************

This report is aimed to analyzie our logistic performace between sales and distribution center
using the calulation though the OrderReleaseDateTime, OrderDeliveryByDate and OrderShippedDate 
based on the following business rules:

------------------------------------------------------------------------------------------------
Prerequisites:
	1. Populate IPEX StatutoryHoliday table yearly under Report database.
	   (http://portalseven.com/calendar/Holidays_Canada.jsp) 
	2. Populate FiscalTime table on 2020/12/31 (determing if working days or weekend days)
	3. Setup user access security -> grant read access for users chrche, natbou, rebleo

------------------------------------------------------------------------------------------------

Day range calulation pre-conditions:
	1. Weekend days and Statutory Holidays will be excluded from the calculation.
	2. Look back only 1 year in case a realeased order is actually issued on the prior year.

------------------------------------------------------------------------------------------------

Day range calulation rules:
	1. LoadAndGoFlag -> A shipper is cutting a BOL for an order/transfer that is required to be delivered the same day, and the order is loaded on a truck that will be delivering the goods to the customer on that same day (this is a new field introduced on year 2010 along with ShippingUserId).
	2. LateOrderReleaseFlag -> Order release is considered to be late if an order is released after or on the customer delivery by date.
	3. LateShipmentFlag -> Shipment is considered to be late if an order release is shipped after the customer delivery by date, or on the customer delivery by date but the LoadAndGoFlag is not "Y".
	4. DayOffFlag -> Order release after 3:00PM local warehouse time will be considered to be a day off. The actual order release date would be the next working day.
	5. AppFlag -> There are 4 possible values listed and explained below:
			a). BLANK (which means no appointment was needed);
			b). Y (YES which means an appointment was needed but the deliver by date was not updated prior to the BOL being cut)
			c). U (UPDATE which means that the order was put on hold and the deliver by date needed to be updated when the customer had called to confirm the new deliver by date, but distribution did not update the system with that new date prior to the BOL being cut)
			d). C (COMPLETE which means that an appointment was needed and the DC has updated the deliver by date prior to the BOL being cut)

------------------------------------------------------------------------------------------------

Day range definations:
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
IT Support and Maintenance: Junjie Tang

************************************************************************************************/
ALTER	VIEW [dbo].[vw_BillOfLading_Order_Elapsed_Time_2013]
AS

SELECT	FiscalMonth = BillOfLading.FiscalPeriodCode
,	CompanyCode = ShippingWarehouse.CompanyCode
,	CompanyName = ShippingWarehouseCompany.CompanyName
,	SalesOfficeCode = CASE WHEN ISNULL(SalesOrder_2013.SalesOfficeCode, '') != ''
			       THEN SalesOrder_2013.SalesOfficeCode
			       ELSE ISNULL(SalesOrder_2012.SalesOfficeCode, '')
			  END
,	SalesOfficeName = CASE WHEN ISNULL(SalesOffice_2013.SalesOfficeName, '') != ''
			       THEN SalesOffice_2013.SalesOfficeName
			       ELSE ISNULL(SalesOffice_2012.SalesOfficeName, '')
			  END
,	SalesRegionCode = CASE WHEN ISNULL(ShipToCustomer_2013.RegionCode, '') != ''
			       THEN ShipToCustomer_2013.RegionCode
			       ELSE ISNULL(ShipToCustomer_2012.RegionCode, '')
			  END
,	SalesRegionName = CASE WHEN ISNULL(ShipToCustomer_2013.RegionCode, '') != ''
			       THEN Region_2013.RegionName
			       ELSE ISNULL(Region_2012.RegionName, '')
			  END
,	AccountReceivableCustomerCode = CASE WHEN ISNULL(AccountReceivableCustomer_2013.AccountReceivableCustomerCode, '') != ''
			         	     THEN AccountReceivableCustomer_2013.AccountReceivableCustomerCode
			                     ELSE ISNULL(AccountReceivableCustomer_2012.AccountReceivableCustomerCode, '')
			                END
,	AccountReceivableCustomerName = CASE WHEN ISNULL(AccountReceivableCustomer_2013.AccountReceivableCustomerCode, '') != ''
			         	     THEN AccountReceivableCustomer_2013.AccountReceivableCustomerName
			                     ELSE ISNULL(AccountReceivableCustomer_2012.AccountReceivableCustomerName, '')
			                END
,	BuyingGroupCode = CASE WHEN ISNULL(ShipToCustomer_2013.BuyingGroupCode, '') != ''
			         THEN ShipToCustomer_2013.BuyingGroupCode
			         ELSE ISNULL(ShipToCustomer_2012.BuyingGroupCode, '')
			    END
,	CustomerGroupCode = CASE WHEN ISNULL(ShipToCustomer_2013.CustomerGroupCode, '') != ''
			         THEN CASE WHEN CHARINDEX('*', ShipToCustomer_2013.CustomerGroupCode) != 0
                                           THEN RIGHT(ShipToCustomer_2013.CustomerGroupCode, LEN(ShipToCustomer_2013.CustomerGroupCode) - 3)
                                           ELSE
                                                ShipToCustomer_2013.CustomerGroupCode
                                      END
			         ELSE CASE WHEN CHARINDEX('*', ShipToCustomer_2012.CustomerGroupCode) != 0
                                           THEN ISNULL(RIGHT(ShipToCustomer_2012.CustomerGroupCode, LEN(ShipToCustomer_2012.CustomerGroupCode) - 3), '')
                                           ELSE
                                                ISNULL(ShipToCustomer_2012.CustomerGroupCode, '')
                                      END
			    END
,	CustomerGroupName = CASE WHEN ISNULL(ShipToCustomer_2013.CustomerGroupCode, '') != ''
			         THEN CustomerGroup_2013.CustomerGroupName
			         ELSE ISNULL(CustomerGroup_2012.CustomerGroupName, '')
			    END
,	CustomerShipToCode = CASE WHEN ISNULL(SalesOrder_2013.CustomerCode, '') != ''
			          THEN SalesOrder_2013.CustomerCode
			          ELSE ISNULL(SalesOrder_2012.CustomerCode, '')
			     END
,	CustomerShipToName = CASE WHEN ISNULL(SalesOrder_2013.CustomerCode, '') != ''
			          THEN SalesOrder_2013.ShipToName
			          ELSE ISNULL(SalesOrder_2012.ShipToName, '')
			     END
,	BillOfLading.ShippingWarehouseCode
,	ShippingWarehouseName = ShippingWarehouse.WarehouseName
,	BillOfLading.ReceivingWarehouseCode
,	ReceivingWarehouseName = ReceivingWarehouse.WarehouseName
,	TransferOrderFlag = CASE WHEN LEFT(BillOfLading.OrderNumber, 1) = 'T'
                                 THEN 'Yes'
                                 ELSE 'No'
                            END
,	PickUpOrderFlag = CASE WHEN BillOfLading.FreightTermCode = 'PU'
                               THEN 'Yes'
                               ELSE 'No'
                          END
,	LoadAndGoFlag = ISNULL(BillOfLading.LoadAndGoFlag, '')
,	LateOrderReleaseFlag = CASE WHEN (CASE WHEN ISNULL(NULLIF(SalesOrderpacking.ReleaseDateTime, ''), '') = '' OR ISNULL(NULLIF(SalesOrderpacking.DeliveryByDate, ''), '') = ''
				               THEN NULL
                                               ELSE (SELECT CASE WHEN DATEADD(hh, WarehouseTimeZone.TimeZoneOffset, SalesOrderpacking.ReleaseDateTime) > CAST(CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120) + ' 15:00:00' AS SMALLDATETIME)
                                                                 THEN CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, SalesOrderpacking.DeliveryByDate) >= 0
                                                                           THEN COUNT(*) - 2
                                                                           ELSE COUNT(*) * -1
                                                                      END
                                                                 ELSE
                                                                      CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, SalesOrderpacking.DeliveryByDate) >= 0
                                                                           THEN COUNT(*) - 1
                                                                           ELSE (COUNT(*) - 1) * -1
                                                                      END
                                                            END
                                                     FROM  DataWarehouse..FiscalDate
		 			             WHERE FiscalDate >= CASE WHEN SalesOrderpacking.ReleaseDateTime <= SalesOrderpacking.DeliveryByDate
								              THEN CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
					   		      	              ELSE CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
				      		      	                 END
		 			             AND   FiscalDate <= CASE WHEN SalesOrderpacking.ReleaseDateTime <= SalesOrderpacking.DeliveryByDate
								              THEN CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
					   		   	              ELSE CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
				      		      	                 END
		 			             AND   [WeekDay] = 1
			                             AND   FiscalDate NOT IN (SELECT StatutoryHolidayDate
								              FROM  Report..StatutoryHoliday
							                      WHERE FiscalYear = '2013'
							                      AND   CHARINDEX(ShippingWarehouse.RegionCode, RegionCodeList) <> 0))
                                          END) <= 0
                                    THEN 'Yes'
                                    ELSE 'No'
                               END
,	LateShipmentFlag = CASE WHEN ISNULL(NULLIF(BillOfLading.ShippingDate, ''), '') = '' OR ISNULL(NULLIF(SalesOrderpacking.DeliveryByDate, ''), '') = ''
				THEN NULL
                                ELSE CASE WHEN ISNULL(NULLIF(SalesOrderpacking.ReleaseDateTime, ''), '') = '' OR ISNULL(NULLIF(SalesOrderpacking.DeliveryByDate, ''), '') = ''
				          THEN NULL
                                          ELSE CASE WHEN DATEDIFF(dd, BillOfLading.ShippingDate, SalesOrderpacking.DeliveryByDate) < 0 OR (DATEDIFF(dd, BillOfLading.ShippingDate, SalesOrderpacking.DeliveryByDate) = 0 AND BillOfLading.LoadAndGoFlag <> 'Y')
                                	            THEN 'Yes'
                                	            ELSE 'No'
				               END
                                     END
                           END
,	DayOffFlag = CASE WHEN DATEADD(hh, WarehouseTimeZone.TimeZoneOffset, SalesOrderpacking.ReleaseDateTime) > CAST(CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120) + ' 15:00:00' AS SMALLDATETIME)
                          THEN 'Yes'
		          ELSE 'No'
                     END
,	TimeZoneOffset = WarehouseTimeZone.TimeZoneOffset
,	ConsolidationFlag = ISNULL(BillOfLading.ConsolidatedFreightFlag, '')
,	ConsolidationNumber = ISNULL(BillOfLading.ConsolidatedFreightNumber, '')
,	CrossDockFlag = CASE WHEN BillOfLading.CrossDockBillOfLadingNumber <> '' OR BillOfLading.CrossDockWarehouseCode <> ''
                             THEN 'Yes'
			     ELSE 'No'
			END
,	BillOfLading.CrossDockBillOfLadingNumber
,	BillOfLading.CrossDockWarehouseCode
,	FreightMethodCode = ISNULL(BillOfLading.FreightMethodCode, '')
,	FreightMethodName = ISNULL(FreightMethod.FreightMethodName, '')
,	FreightCarrierCode = ISNULL(BillOfLading.FreightCarrierCode, '')
,	FreightCarrierName = ISNULL(FreightCarrier.FreightCarrierName, '')
,	FreightTermCode = ISNULL(BillOfLading.FreightTermCode, '')
,	FreightTermName = ISNULL(FreightTerm.FreightTermName, '')
,	BillOfLading.BillOfLadingNumber
,	BillOfLading.ReleaseNumber
,	ShippingUserId = ISNULL(BillOfLading.TransactionUserCode, '')
,	BillOfLading.OrderNumber
,	OperatorCode = CASE WHEN LEFT(BillOfLading.OrderNumber, 1) = 'T'
		            THEN CASE WHEN ISNULL((SELECT TOP 1 TransferOrder_2013.OperatorCode
 		       				   FROM DataWarehouse..TransferOrder_2013 TransferOrder_2013
		       				   WHERE BillOfLading.OrderNumber = TransferOrder_2013.OrderNumber
		       				   GROUP BY TransferOrder_2013.OperatorCode), '') != ''
				      THEN (SELECT TOP 1 TransferOrder_2013.OperatorCode
 		       			    FROM DataWarehouse..TransferOrder_2013 TransferOrder_2013
		       		 	    WHERE BillOfLading.OrderNumber = TransferOrder_2013.OrderNumber
		       			    GROUP BY TransferOrder_2013.OperatorCode)
				      ELSE ISNULL((SELECT TOP 1 TransferOrder_2012.OperatorCode
 		       				   FROM DataWarehouse..TransferOrder_2012 TransferOrder_2012
		       				   WHERE BillOfLading.OrderNumber = TransferOrder_2012.OrderNumber
		       				   GROUP BY TransferOrder_2012.OperatorCode), '')
				 END
			    ELSE CASE WHEN ISNULL(SalesOrder_2013.OperatorCode, '') != ''
				      THEN SalesOrder_2013.OperatorCode
				      ELSE ISNULL(SalesOrder_2012.OperatorCode, '')
				 END
		       END
,       ReleaseDate = CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
,       ReleaseTime = CONVERT(CHAR(8), SalesOrderpacking.ReleaseDateTime, 114)
,	InitialDeliveryByDate = CASE WHEN CONVERT(CHAR(10), SalesOrderpacking.PreviousDeliveryByDate, 120) = '1900-01-01'
				     THEN CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
				     ELSE CONVERT(CHAR(10), SalesOrderpacking.PreviousDeliveryByDate, 120)
				END
,	ApptFlag = SalesOrderpacking.AppointmentFlag
,      	UpdatedDeliveryByDate = CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
,       ShippingDate = CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
,	[UpdatedDelDt - InitialDelDt] = CASE WHEN CONVERT(CHAR(10), SalesOrderpacking.PreviousDeliveryByDate, 120) = '1900-01-01'
				     	     THEN 0
				     	     ELSE DATEDIFF(dd, SalesOrderpacking.PreviousDeliveryByDate, SalesOrderpacking.DeliveryByDate)
					END
,	[DelDt - RelDt] = CASE WHEN ISNULL(NULLIF(SalesOrderpacking.ReleaseDateTime, ''), '') = '' OR ISNULL(NULLIF(SalesOrderpacking.DeliveryByDate, ''), '') = ''
			       THEN NULL
                               ELSE (SELECT CASE WHEN DATEADD(hh, WarehouseTimeZone.TimeZoneOffset, SalesOrderpacking.ReleaseDateTime) > CAST(CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120) + ' 15:00:00' AS SMALLDATETIME)
                                                 THEN CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, SalesOrderpacking.DeliveryByDate) >= 0
                                                           THEN COUNT(*) - 2		-- day off -> Server ReleaseTime + Warehouse TimeZoneOffset > 3:00PM + order released on the delivery by date will be considered to be a late order release
                                                           ELSE COUNT(*) * -1		-- late order release -> ReleaseDateTime < DeliveryByDate
                                                      END
                                                 ELSE
                                                      CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, SalesOrderpacking.DeliveryByDate) >= 0
                                                           THEN COUNT(*) - 1		-- order released on the delivery by date will be counted as 0 and it's a late order release
                                                           ELSE (COUNT(*) - 1) * -1	-- late order release -> OrderReleaseTime < DeliveryByDate
                                                      END
                                            END
                                     FROM  DataWarehouse..FiscalDate
		                     WHERE FiscalDate >= CASE WHEN SalesOrderpacking.ReleaseDateTime <= SalesOrderpacking.DeliveryByDate
							      THEN CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
					   		      ELSE CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
				      		      	 END
		 	             AND   FiscalDate <= CASE WHEN SalesOrderpacking.ReleaseDateTime <= SalesOrderpacking.DeliveryByDate
						              THEN CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
					   		      ELSE CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
				      		      	 END
		 		     AND   [WeekDay] = 1				-- exclude weekend days
			             AND   FiscalDate NOT IN (SELECT StatutoryHolidayDate
							      FROM  Report..StatutoryHoliday
							      WHERE FiscalYear = '2013'	-- exclude statutory holiday
							      AND   CHARINDEX(ShippingWarehouse.RegionCode, RegionCodeList) <> 0))
                          END
,	[ShpDt - RelDt] = CASE WHEN ISNULL(NULLIF(SalesOrderpacking.ReleaseDateTime, ''), '') = '' OR ISNULL(NULLIF(BillOfLading.ShippingDate, ''), '') = ''
			       THEN NULL
                               ELSE (SELECT CASE WHEN DATEADD(hh, WarehouseTimeZone.TimeZoneOffset, SalesOrderpacking.ReleaseDateTime) > CAST(CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120) + ' 15:00:00' AS SMALLDATETIME)
                                                 THEN CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, BillOfLading.ShippingDate) >= 0
                                                           THEN COUNT(*) - 1		-- server ReleaseTime + warehouse TimeZoneOffset > 3:00PM is considered to be a day off
                                                           ELSE COUNT(*) * -1		-- late order release -> ReleaseDateTime < DeliveryByDate
                                                      END
                                                 ELSE
                                                      CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, BillOfLading.ShippingDate) >= 0
                                                           THEN COUNT(*) 		
                                                           ELSE COUNT(*)  * -1		
                                                      END
                                            END
                                     FROM  DataWarehouse..FiscalDate
		 		     WHERE FiscalDate >= CASE WHEN SalesOrderpacking.ReleaseDateTime <= BillOfLading.ShippingDate
							      THEN CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
					   		      ELSE CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
				      		      	 END
		 		     AND   FiscalDate <= CASE WHEN SalesOrderpacking.ReleaseDateTime <= BillOfLading.ShippingDate
							      THEN CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
					   		      ELSE CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
				      		      	 END
		 		     AND   [WeekDay] = 1
			             AND   FiscalDate NOT IN (SELECT StatutoryHolidayDate
						              FROM  Report..StatutoryHoliday
							      WHERE FiscalYear = '2013'
							      AND   CHARINDEX(ShippingWarehouse.RegionCode, RegionCodeList) <> 0))
                          END
,	[DelDt - ShpDt] = CASE WHEN ISNULL(NULLIF(BillOfLading.ShippingDate, ''), '') = '' OR ISNULL(NULLIF(SalesOrderpacking.DeliveryByDate, ''), '') = ''
			       THEN NULL
                               ELSE (SELECT CASE WHEN DATEDIFF(dd, BillOfLading.ShippingDate, SalesOrderpacking.DeliveryByDate) >= 0
                                                 THEN COUNT(*) - 1		-- order released on the delivery by date will be counted as 0, if LoadAndGoFlag is not 'Y', it will be considered to be a late shipment
                                                 ELSE (COUNT(*) - 1) * -1	-- late shipment -> ShippingDate < DeliveryByDate
                                            END
                                     FROM  DataWarehouse..FiscalDate
		 	             WHERE FiscalDate >= CASE WHEN BillOfLading.ShippingDate <= SalesOrderpacking.DeliveryByDate
							      THEN CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
					   		      ELSE CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
				      		      	 END
		 	             AND   FiscalDate <= CASE WHEN BillOfLading.ShippingDate <= SalesOrderpacking.DeliveryByDate
							      THEN CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
					   		      ELSE CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
				      		      	 END
		 		     AND   [WeekDay] = 1
			             AND   FiscalDate NOT IN (SELECT StatutoryHolidayDate
							      FROM  Report..StatutoryHoliday
							      WHERE FiscalYear = '2013'
							      AND   CHARINDEX(ShippingWarehouse.RegionCode, RegionCodeList) <> 0))
			  END
,	[(DelDt - RelDt) Range] = CASE WHEN ISNULL(NULLIF(SalesOrderpacking.ReleaseDateTime, ''), '') = '' OR ISNULL(NULLIF(SalesOrderpacking.DeliveryByDate, ''), '') = ''
				       THEN NULL
                                       ELSE CASE WHEN (SELECT CASE WHEN DATEADD(hh, WarehouseTimeZone.TimeZoneOffset, SalesOrderpacking.ReleaseDateTime) > CAST(CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120) + ' 15:00:00' AS SMALLDATETIME)
                                                                   THEN CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, SalesOrderpacking.DeliveryByDate) >= 0
                                                                             THEN COUNT(*) - 2
                                                                             ELSE COUNT(*) * -1
                                                                        END
                                                                   ELSE
                                                                        CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, SalesOrderpacking.DeliveryByDate) >= 0
                                                                             THEN COUNT(*) - 1
                                                                             ELSE (COUNT(*) - 1) * -1
                                                                        END
                                                              END
                                                        FROM  DataWarehouse..FiscalDate
		 			                WHERE FiscalDate >= CASE WHEN SalesOrderpacking.ReleaseDateTime <= SalesOrderpacking.DeliveryByDate
								                 THEN CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
					   		      	                 ELSE CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
				      		      	                    END
		 			                AND   FiscalDate <= CASE WHEN SalesOrderpacking.ReleaseDateTime <= SalesOrderpacking.DeliveryByDate
								                 THEN CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
					   		   	                 ELSE CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
				      		      	                    END
		 			                AND   [WeekDay] = 1
			                                AND   FiscalDate NOT IN (SELECT StatutoryHolidayDate
								                 FROM  Report..StatutoryHoliday
							                         WHERE FiscalYear = '2013'
							                         AND   CHARINDEX(ShippingWarehouse.RegionCode, RegionCodeList) <> 0)) >= 10
				                 THEN '>= 10'
						 WHEN (SELECT CASE WHEN DATEADD(hh, WarehouseTimeZone.TimeZoneOffset, SalesOrderpacking.ReleaseDateTime) > CAST(CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120) + ' 15:00:00' AS SMALLDATETIME)
                                                                   THEN CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, SalesOrderpacking.DeliveryByDate) >= 0
                                                                               THEN COUNT(*) - 2
                                                                               ELSE COUNT(*) * -1
                                                                        END
                                                                   ELSE
                                                                        CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, SalesOrderpacking.DeliveryByDate) >= 0
                                                                             THEN COUNT(*) - 1
                                                                             ELSE (COUNT(*) - 1) * -1
                                                                        END
                                                              END
                                                       FROM  DataWarehouse..FiscalDate
		 			               WHERE FiscalDate >= CASE WHEN SalesOrderpacking.ReleaseDateTime <= SalesOrderpacking.DeliveryByDate
								                THEN CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
					   		      	                ELSE CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
				      		      	                   END
		 			               AND   FiscalDate <= CASE WHEN SalesOrderpacking.ReleaseDateTime <= SalesOrderpacking.DeliveryByDate
								                THEN CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
					   		   	                ELSE CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
				      		      	                   END
		 			               AND   [WeekDay] = 1
			                               AND   FiscalDate NOT IN (SELECT StatutoryHolidayDate
								                FROM  Report..StatutoryHoliday
							                        WHERE FiscalYear = '2013'
							                        AND   CHARINDEX(ShippingWarehouse.RegionCode, RegionCodeList) <> 0)) < 0
						 THEN '< 0'
						 ELSE CONVERT(VARCHAR, (SELECT CASE WHEN DATEADD(hh, WarehouseTimeZone.TimeZoneOffset, SalesOrderpacking.ReleaseDateTime) > CAST(CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120) + ' 15:00:00' AS SMALLDATETIME)
                                                                     		    THEN CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, SalesOrderpacking.DeliveryByDate) >= 0
                                                                                              THEN COUNT(*) - 2
                                                                                              ELSE COUNT(*) * -1
                                                                                         END
                                                                                    ELSE
                                                                                         CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, SalesOrderpacking.DeliveryByDate) >= 0
                                                                                              THEN COUNT(*) - 1
                                                                                              ELSE (COUNT(*) - 1) * -1
                                                                                         END
                                                                                 END
                                                                        FROM  DataWarehouse..FiscalDate
		 			                                WHERE FiscalDate >= CASE WHEN SalesOrderpacking.ReleaseDateTime <= SalesOrderpacking.DeliveryByDate
								                                 THEN CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
					   		      	                                 ELSE CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
				      		      	                                    END
		 			                                AND   FiscalDate <= CASE WHEN SalesOrderpacking.ReleaseDateTime <= SalesOrderpacking.DeliveryByDate
								                                 THEN CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
					   		   	                                 ELSE CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
				      		      	                                    END
		 			                                AND   [WeekDay] = 1
			                                                AND   FiscalDate NOT IN (SELECT StatutoryHolidayDate
								                                 FROM  Report..StatutoryHoliday
							                                         WHERE FiscalYear = '2013'
							                                         AND   CHARINDEX(ShippingWarehouse.RegionCode, RegionCodeList) <> 0)))
                                            END
                                  END
,	[(ShpDt - RelDt) Range] = CASE WHEN ISNULL(NULLIF(SalesOrderpacking.ReleaseDateTime, ''), '') = '' OR ISNULL(NULLIF(BillOfLading.ShippingDate, ''), '') = ''
				       THEN NULL
                                       ELSE CASE WHEN (SELECT CASE WHEN DATEADD(hh, WarehouseTimeZone.TimeZoneOffset, SalesOrderpacking.ReleaseDateTime) > CAST(CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120) + ' 15:00:00' AS SMALLDATETIME)
                                                                   THEN CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, BillOfLading.ShippingDate) >= 0
                                                                             THEN COUNT(*) - 2
                                                                             ELSE COUNT(*) * -1
                                                                        END
                                                                   ELSE
                                                                        CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, BillOfLading.ShippingDate) >= 0
                                                                             THEN COUNT(*) - 1
                                                                        ELSE (COUNT(*) - 1) * -1
                                                                   END
                                                              END
                                                       FROM  DataWarehouse..FiscalDate
		 		                       WHERE FiscalDate >= CASE WHEN SalesOrderpacking.ReleaseDateTime <= BillOfLading.ShippingDate
							                        THEN CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
					   		                        ELSE CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
				      		      	                   END
		 		                       AND   FiscalDate <= CASE WHEN SalesOrderpacking.ReleaseDateTime <= BillOfLading.ShippingDate
							                        THEN CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
					   		                        ELSE CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
				      		      	                   END
		 		                       AND   [WeekDay] = 1
			                               AND   FiscalDate NOT IN (SELECT StatutoryHolidayDate
						                                FROM  Report..StatutoryHoliday
							                        WHERE FiscalYear = '2013'
							                        AND   CHARINDEX(ShippingWarehouse.RegionCode, RegionCodeList) <> 0)) >= 10
				                 THEN '>= 10'
						 WHEN (SELECT CASE WHEN DATEADD(hh, WarehouseTimeZone.TimeZoneOffset, SalesOrderpacking.ReleaseDateTime) > CAST(CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120) + ' 15:00:00' AS SMALLDATETIME)
                                                                   THEN CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, BillOfLading.ShippingDate) >= 0
                                                                             THEN COUNT(*) - 2
                                                                             ELSE COUNT(*) * -1
                                                                        END
                                                                   ELSE
                                                                        CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, BillOfLading.ShippingDate) >= 0
                                                                             THEN COUNT(*) - 1
                                                                        ELSE (COUNT(*) - 1) * -1
                                                                   END
                                                              END
                                                       FROM  DataWarehouse..FiscalDate
		 		                       WHERE FiscalDate >= CASE WHEN SalesOrderpacking.ReleaseDateTime <= BillOfLading.ShippingDate
							                        THEN CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
					   		                        ELSE CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
				      		      	                   END
		 		                       AND   FiscalDate <= CASE WHEN SalesOrderpacking.ReleaseDateTime <= BillOfLading.ShippingDate
							                        THEN CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
					   		                        ELSE CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
				      		      	                   END
		 		                       AND   [WeekDay] = 1
			                               AND   FiscalDate NOT IN (SELECT StatutoryHolidayDate
						                                FROM  Report..StatutoryHoliday
							                        WHERE FiscalYear = '2013'
							                        AND   CHARINDEX(ShippingWarehouse.RegionCode, RegionCodeList) <> 0)) < 0
						 THEN '< 0'
						 ELSE CONVERT(VARCHAR, (SELECT CASE WHEN DATEADD(hh, WarehouseTimeZone.TimeZoneOffset, SalesOrderpacking.ReleaseDateTime) > CAST(CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120) + ' 15:00:00' AS SMALLDATETIME)
                                                                                    THEN CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, BillOfLading.ShippingDate) >= 0
                                                                                              THEN COUNT(*) - 2
                                                                                              ELSE COUNT(*) * -1
                                                                                         END
                                                                                    ELSE
                                                                                         CASE WHEN DATEDIFF(dd, SalesOrderpacking.ReleaseDateTime, BillOfLading.ShippingDate) >= 0
                                                                                              THEN COUNT(*) - 1
                                                                                              ELSE (COUNT(*) - 1) * -1
                                                                                         END
                                                                               END
                                                                        FROM  DataWarehouse..FiscalDate
		 		                                        WHERE FiscalDate >= CASE WHEN SalesOrderpacking.ReleaseDateTime <= BillOfLading.ShippingDate
							                                         THEN CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
					   		                                         ELSE CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
				      		      	                                    END
		 		                                        AND   FiscalDate <= CASE WHEN SalesOrderpacking.ReleaseDateTime <= BillOfLading.ShippingDate
							                                         THEN CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
					   		                                         ELSE CONVERT(CHAR(10), SalesOrderpacking.ReleaseDateTime, 120)
				      		      	                                    END
		 		                                        AND   [WeekDay] = 1
			                                                AND   FiscalDate NOT IN (SELECT StatutoryHolidayDate
						                                                 FROM  Report..StatutoryHoliday
							                                         WHERE FiscalYear = '2013'
							                                         AND   CHARINDEX(ShippingWarehouse.RegionCode, RegionCodeList) <> 0)))
                                            END
                                  END
,	[(DelDt - ShpDt) Range] = CASE WHEN ISNULL(NULLIF(BillOfLading.ShippingDate, ''), '') = '' OR ISNULL(NULLIF(SalesOrderpacking.DeliveryByDate, ''), '') = ''
			               THEN NULL
                                       ELSE CASE WHEN (SELECT CASE WHEN DATEDIFF(dd, BillOfLading.ShippingDate, SalesOrderpacking.DeliveryByDate) >= 0
                                                                   THEN COUNT(*) - 1
                                                                   ELSE (COUNT(*) - 1) * -1
                                                              END
                                                       FROM  DataWarehouse..FiscalDate
		 	                               WHERE FiscalDate >= CASE WHEN BillOfLading.ShippingDate <= SalesOrderpacking.DeliveryByDate
							                        THEN CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
					   		                        ELSE CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
				      		      	                   END
		 	                               AND   FiscalDate <= CASE WHEN BillOfLading.ShippingDate <= SalesOrderpacking.DeliveryByDate
							                        THEN CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
					   		                        ELSE CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
				      		      	                   END
		 		                       AND   [WeekDay] = 1
			                               AND   FiscalDate NOT IN (SELECT StatutoryHolidayDate
							                        FROM  Report..StatutoryHoliday
							                        WHERE FiscalYear = '2013'
							                        AND   CHARINDEX(ShippingWarehouse.RegionCode, RegionCodeList) <> 0)) >= 10
				                 THEN '>= 10'
						 WHEN (SELECT CASE WHEN DATEDIFF(dd, BillOfLading.ShippingDate, SalesOrderpacking.DeliveryByDate) >= 0
                                                                   THEN COUNT(*) - 1
                                                                   ELSE (COUNT(*) - 1) * -1
                                                              END
                                                       FROM  DataWarehouse..FiscalDate
		 	                               WHERE FiscalDate >= CASE WHEN BillOfLading.ShippingDate <= SalesOrderpacking.DeliveryByDate
							                        THEN CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
					   		                        ELSE CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
				      		      	                   END
		 	                               AND   FiscalDate <= CASE WHEN BillOfLading.ShippingDate <= SalesOrderpacking.DeliveryByDate
							                        THEN CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
					   		                        ELSE CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
				      		      	                   END
		 		                       AND   [WeekDay] = 1
			                               AND   FiscalDate NOT IN (SELECT StatutoryHolidayDate
							                        FROM  Report..StatutoryHoliday
							                        WHERE FiscalYear = '2013'
							                        AND   CHARINDEX(ShippingWarehouse.RegionCode, RegionCodeList) <> 0)) < 0
						 THEN '< 0'
						 ELSE CONVERT(VARCHAR, (SELECT CASE WHEN DATEDIFF(dd, BillOfLading.ShippingDate, SalesOrderpacking.DeliveryByDate) >= 0
                                                                                    THEN COUNT(*) - 1
                                                                                    ELSE (COUNT(*) - 1) * -1
                                                                               END
                                                                        FROM  DataWarehouse..FiscalDate
		 	                                                WHERE FiscalDate >= CASE WHEN BillOfLading.ShippingDate <= SalesOrderpacking.DeliveryByDate
							                                         THEN CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
					   		                                         ELSE CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
				      		      	                                    END
		 	                                                AND   FiscalDate <= CASE WHEN BillOfLading.ShippingDate <= SalesOrderpacking.DeliveryByDate
							                                         THEN CONVERT(CHAR(10), SalesOrderpacking.DeliveryByDate, 120)
					   		                                         ELSE CONVERT(CHAR(10), BillOfLading.ShippingDate, 120)
				      		      	                                    END
		 		                                        AND   [WeekDay] = 1
			                                                AND   FiscalDate NOT IN (SELECT StatutoryHolidayDate
							                                         FROM  Report..StatutoryHoliday
							                                         WHERE FiscalYear = '2013'
							                                         AND   CHARINDEX(ShippingWarehouse.RegionCode, RegionCodeList) <> 0)))
                                            END
                                  END
,	NumberOfLines = COUNT(*)
,	ShippingWeight = SUM(BillOfLading.ShippingWeight)
FROM	DataWarehouse..BillOfLading_2013 BillOfLading
       	INNER JOIN DataWarehouse..Warehouse ShippingWarehouse
		ON BillOfLading.ShippingWarehouseCode = ShippingWarehouse.WarehouseCode
	INNER JOIN DataWarehouse..Warehouse ReceivingWarehouse
		ON BillOfLading.ReceivingWarehouseCode = ReceivingWarehouse.WarehouseCode
	INNER JOIN DataWarehouse..FreightCarrier FreightCarrier
                ON BillOfLading.FreightCarrierCode = FreightCarrier.FreightCarrierCode
	INNER JOIN DataWarehouse..FreightMethod FreightMethod
		ON BillOfLading.FreightMethodCode = FreightMethod.FreightMethodCode
	INNER JOIN DataWarehouse..FreightTerm FreightTerm
                ON BillOfLading.FreightTermCode = FreightTerm.FreightTermCode
	LEFT JOIN DataWarehouse..SalesOrderpacking SalesOrderpacking
		ON BillOfLading.OrderNumber = SalesOrderpacking.OrderNumber
 		AND BillOfLading.ReleaseNumber = SalesOrderpacking.ReleaseNumber
	LEFT JOIN DataWarehouse..SalesOrder_2013 SalesOrder_2013
		ON BillOfLading.OrderNumber = SalesOrder_2013.OrderNumber
		AND BillOfLading.LineItemNumber = SalesOrder_2013.LineItemNumber
	LEFT JOIN DataWarehouse..SalesOrder_2012 SalesOrder_2012
		ON BillOfLading.OrderNumber = SalesOrder_2012.OrderNumber
		AND BillOfLading.LineItemNumber = SalesOrder_2012.LineItemNumber
	LEFT JOIN DataWarehouse..Company ShippingWarehouseCompany
		ON ShippingWarehouse.CompanyCode = ShippingWarehouseCompany.CompanyCode
	LEFT JOIN DataWarehouse..SalesOffice SalesOffice_2013
		ON SalesOrder_2013.SalesOfficeCode = SalesOffice_2013.SalesOfficeCode
	LEFT JOIN DataWarehouse..SalesOffice SalesOffice_2012
		ON SalesOrder_2012.SalesOfficeCode = SalesOffice_2012.SalesOfficeCode
	LEFT JOIN DataWarehouse..ShipToCustomer ShipToCustomer_2013
		ON SalesOrder_2013.CompanyCode = ShipToCustomer_2013.CompanyCode
		AND SalesOrder_2013.CustomerCode = ShipToCustomer_2013.ShipToCustomerCode
	LEFT JOIN DataWarehouse..ShipToCustomer ShipToCustomer_2012
		ON SalesOrder_2012.CompanyCode = ShipToCustomer_2012.CompanyCode
		AND SalesOrder_2012.CustomerCode = ShipToCustomer_2012.ShipToCustomerCode
	LEFT JOIN DataWarehouse..AccountReceivableCustomer AccountReceivableCustomer_2013
		ON ShipToCustomer_2013.CompanyCode = AccountReceivableCustomer_2013.CompanyCode
		AND ShipToCustomer_2013.AccountReceivableCode = AccountReceivableCustomer_2013.AccountReceivableCustomerCode
	LEFT JOIN DataWarehouse..AccountReceivableCustomer AccountReceivableCustomer_2012
		ON ShipToCustomer_2012.CompanyCode = AccountReceivableCustomer_2012.CompanyCode
		AND ShipToCustomer_2012.AccountReceivableCode = AccountReceivableCustomer_2012.AccountReceivableCustomerCode
	LEFT JOIN DataWarehouse..Region Region_2013
		ON ShipToCustomer_2013.RegionCode = Region_2013.RegionCode
	LEFT JOIN DataWarehouse..Region Region_2012
		ON ShipToCustomer_2012.RegionCode = Region_2012.RegionCode
	LEFT JOIN DataWarehouse..CustomerGroup CustomerGroup_2013
		ON ShipToCustomer_2013.CustomerGroupCode = CustomerGroup_2013.CustomerGroupCode
	LEFT JOIN DataWarehouse..CustomerGroup CustomerGroup_2012
		ON ShipToCustomer_2012.CustomerGroupCode = CustomerGroup_2012.CustomerGroupCode
	LEFT JOIN Report..WarehouseTimeZone WarehouseTimeZone
                ON WarehouseTimeZone.WarehouseCode = ShippingWarehouse.WarehouseCode
WHERE	ShippingWarehouse.PhantomWarehouse = 0
AND	ReceivingWarehouse.PhantomWarehouse = 0
AND	BillOfLading.FreightTransactionTypeCode != 'MB'
GROUP BY BillOfLading.FiscalPeriodCode
,	ShippingWarehouse.CompanyCode
,	ShippingWarehouseCompany.CompanyName
,	SalesOrder_2013.SalesOfficeCode
,	SalesOrder_2012.SalesOfficeCode
,	SalesOffice_2013.SalesOfficeName
,	SalesOffice_2012.SalesOfficeName
,	ShipToCustomer_2013.RegionCode
,	ShipToCustomer_2012.RegionCode
,	Region_2013.RegionName
,	Region_2012.RegionName
,	AccountReceivableCustomer_2013.AccountReceivableCustomerCode
,	AccountReceivableCustomer_2012.AccountReceivableCustomerCode
,	AccountReceivableCustomer_2013.AccountReceivableCustomerName
,	AccountReceivableCustomer_2012.AccountReceivableCustomerName
,	ShipToCustomer_2013.BuyingGroupCode
,	ShipToCustomer_2012.BuyingGroupCode
,	ShipToCustomer_2013.CustomerGroupCode
,	ShipToCustomer_2012.CustomerGroupCode
,	CustomerGroup_2013.CustomerGroupName
,	CustomerGroup_2012.CustomerGroupName
,	SalesOrder_2013.CustomerCode
,	SalesOrder_2012.CustomerCode
,	SalesOrder_2013.ShipToName
,	SalesOrder_2012.ShipToName
,	BillOfLading.ShippingWarehouseCode
,	ShippingWarehouse.WarehouseName
,	BillOfLading.ReceivingWarehouseCode
,	ReceivingWarehouse.WarehouseName
,	BillOfLading.ShipToName
,	BillOfLading.OrderNumber
,	BillOfLading.ReleaseNumber
,	SalesOrder_2013.OperatorCode
,	SalesOrder_2012.OperatorCode
,	SalesOrderpacking.ReleaseDateTime
,	SalesOrderpacking.PreviousDeliveryByDate
,	SalesOrderpacking.AppointmentFlag
,	SalesOrderpacking.DeliveryByDate
,	BillOfLading.ShippingDate
,	BillOfLading.BillOfLadingNumber
,	BillOfLading.FreightMethodCode
,	FreightMethod.FreightMethodName
,	BillOfLading.FreightCarrierCode
,	FreightCarrier.FreightCarrierName
,	BillOfLading.FreightTermCode
,	FreightTerm.FreightTermName
,	BillOfLading.ConsolidatedFreightFlag
,	BillOfLading.ConsolidatedFreightNumber
,	BillOfLading.LoadAndGoFlag
,	ShippingWarehouse.RegionCode
,	WarehouseTimeZone.TimeZoneOffset
,	BillOfLading.TransactionUserCode
,	BillOfLading.CrossDockBillOfLadingNumber
,	BillOfLading.CrossDockWarehouseCode














































GO

