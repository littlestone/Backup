/****** Script for SelectTopNRows command from SSMS  ******/
--INSERT INTO [Report].[dbo].[StatutoryHoliday]
SELECT REPLACE([StatutoryHolidayDate],'2014','2015') AS [StatutoryHoliday]
      ,[StatutoryHolidayName]
      ,[RegionCodeList]
      ,'2015' AS [FiscalYear]
  FROM [Report].[dbo].[StatutoryHoliday]
  WHERE [StatutoryHolidayDate] > '2014'