INSERT INTO Report..DSO_Time
SELECT *
FROM DataWarehouse..FiscalTime
WHERE FiscalYear >= '2015'