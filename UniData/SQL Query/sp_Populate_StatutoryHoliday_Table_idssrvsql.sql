--INSERT INTO [Report].[dbo].[StatutoryHoliday] ([StatutoryHolidayDate], [StatutoryHolidayName], [RegionCodeList])
SELECT StatutoryHolidayDate = CONVERT(smalldatetime,DATEADD(year,1, [StatutoryHolidayDate])),
	[StatutoryHolidayName], 
	[RegionCodeList]
FROM [Report].[dbo].[StatutoryHoliday]
WHERE [FiscalYear] = '2014'