--INSERT INTO [DataMart_Report].[dbo].[StatutoryHoliday] ([StatutoryHolidayDate], [StatutoryHolidayName], [RegionCodeList])
SELECT StatutoryHolidayDate = CONVERT(smalldatetime,DATEADD(year,1, [StatutoryHolidayDate])),
	[StatutoryHolidayName], 
	[RegionCodeList]
FROM [DataMart_Report].[dbo].[StatutoryHoliday]
WHERE [FiscalYear] = YEAR(GETDATE())