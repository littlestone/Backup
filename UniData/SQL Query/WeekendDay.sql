SELECT GETDATE() Today,
DATENAME(dw, GETDATE()) DayofWeek,
DATEPART(dw, GETDATE()) Number,
WeekendDay = CASE WHEN DATEPART(dw, GETDATE()) in (6, 7) THEN 1 ELSE 0 END