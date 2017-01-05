USE [PIM]
GO

--CREATE TABLE [dbo].[All3DigitRoots](
--	[ProductCode] [nvarchar](3) NOT NULL,
-- CONSTRAINT [PK_All3DigitRoots] PRIMARY KEY CLUSTERED 
--(
--	[ProductCode] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--) ON [PRIMARY]

TRUNCATE TABLE [PIM].[dbo].[All3DigitRoots]

DECLARE @I INT = 0

WHILE @I < 999
BEGIN
  SET @I += 1;
  INSERT INTO [PIM].[dbo].[All3DigitRoots]
  SELECT CASE WHEN LEN(@I) = 3 THEN CONVERT(varchar(3), @I)
			  WHEN LEN(@I) = 2 THEN '0' + CONVERT(varchar(2), @I)
			  WHEN LEN(@I) = 1 THEN '00' + CONVERT(varchar(1), @I)
		 END AS ProductCode
END

SELECT *
FROM [PIM].[dbo].[All3DigitRoots]

