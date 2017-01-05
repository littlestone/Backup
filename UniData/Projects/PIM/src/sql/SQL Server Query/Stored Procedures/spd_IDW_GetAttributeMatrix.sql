USE [DataWarehouse_PIM]
GO
/****** Object:  StoredProcedure [dbo].[spd_IDW_GetAttributeMatrix]    Script Date: 2016-05-02 3:33:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Vianney Rebetez, Junjie Tang
-- Create date: 2016-04-18
-- Description:	Generate Product Attribute Temporary Table Based On UNSPSC Number
-- =============================================
ALTER PROCEDURE [dbo].[spd_IDW_GetAttributeMatrix]
	-- Add the parameters for the stored procedure here
	@CompanyCode VARCHAR(2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	CREATE TABLE #ProductAttribute(
		[ProductID] [nvarchar] (255) NULL,
		[AttributeName] [nvarchar](255) NULL,
		[AttributeValue] [nvarchar](255) NULL,
		[AttributeUOM] [nvarchar](255) NULL
	)

	INSERT INTO #ProductAttribute
	SELECT prc.ProductID
	,	'Brand Name' AS [name]
	,	prc.Brand AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
		LEFT JOIN ProductCompanyView prc
			ON prd.ProductID = prc.ProductID
	WHERE prc.Brand IS NOT NULL
	AND prc.CompanyCode = @CompanyCode

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Angle' AS [name]
	,	CASE RIGHT(prd.Angle, 1) WHEN 'D' THEN LEFT(prd.Angle, LEN(prd.Angle) - 1) ELSE prd.Angle END AS [value]
	,	'DEG' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.Angle IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('39121420', '27112501')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID
	,	'Type' AS [name]
	,	prd.ProductType AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.ProductType IS NOT NULL

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID
	,	'Application' AS [name]
	,	prd.[Application] AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.[Application] IS NOT NULL

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID
	,	'Special Features' AS [name]
	,	prd.Options AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.Options IS NOT NULL

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID
	,	'Standard' AS [name]
	,	psc.CertifiedStandards AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd
		LEFT JOIN (SELECT prs.ProductID
				   ,	STUFF((SELECT DISTINCT ';' + [Standard]
					   		   FROM ProductSourceCertificationView x 
					   		       INNER JOIN ProductSourceView y 
					   			       ON x.ProductSourceID = y.ProductSourceID
					   		   WHERE x.CertificationLinkType = 'CertifiedStandard' 
					   		   AND y.ProductID = prs.ProductID FOR xml path('')), 1, 1, '') CertifiedStandards
				   FROM ProductSourceCertificationView scv 
				       INNER JOIN ProductSourceView prs 
					       ON prs.ProductSourceID = scv.ProductSourceID
				   WHERE scv.CertificationLinkType = 'CertifiedStandard' 
				   AND prs.ProductID <> '0'
				   GROUP BY prs.ProductID) psc 
			ON psc.ProductID = prd.ProductID
	WHERE psc.CertifiedStandards IS NOT NULL

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Color' AS [name]
	,	prd.Color AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.Color IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) NOT IN ('23241610', '27112501', '39111906', '39131709', '39131717')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Housing Color' AS [name]
	,	prd.Color AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.Color IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('39111906')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Connection' AS [name]
	,	prd.Connection AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.Connection IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('39121311', '39121312', '39121332', '39121420', '39131706', '39131707', '39131708', '39131717')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'End Connection' AS [name]
	,	prd.Connection AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.Connection IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('27112501')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Connection Type' AS [name]
	,	prd.Connection AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.Connection IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('39121420', '39131707')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Cutting Material' AS [name]
	,	prd.Material AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.Material IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('23241610')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Housing Material' AS [name]
	,	prd.Material AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.Material IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('39111906')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Material' AS [name]
	,	prd.Material AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.Material IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) NOT IN ('31201617', '41106402', '23241610', '39131709')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Gang' AS [name]
	,	prd.NumberOfGangs + ' Gang' AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.NumberOfGangs IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('39121704')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Number Of Lamps' AS [name]
	,	prd.NumberOfLamps AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.NumberOfLamps IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('39111501', '39111525', '39111906')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Lamp Included' AS [name]
	,	prd.LampIncluded AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.LampIncluded IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('39111501', '39111525')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Lamp Type' AS [name]
	,	prd.LampType AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.LampType IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('39101802', '39111501', '39111525', '39111906')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Lamp Wattage' AS [name]
	,	CASE RIGHT(prd.Watt, 2) WHEN 'KW' THEN LEFT(prd.Watt, LEN(prd.Watt) - 2) ELSE CASE RIGHT(prd.Watt, 1) WHEN 'W' THEN LEFT(prd.Watt, LEN(prd.Watt) - 1) ELSE prd.Watt END END AS [value]
	,	CASE RIGHT(prd.Watt, 2) WHEN 'KW' THEN 'KW' ELSE CASE RIGHT(prd.Watt, 1) WHEN 'W' THEN 'WTT' ELSE '' END END AS [UOM]
	FROM  ProductView prd 
	WHERE prd.Watt IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('39111906')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Wattage' AS [name]
	,	CASE RIGHT(prd.Watt, 2) WHEN 'KW' THEN LEFT(prd.Watt, LEN(prd.Watt) - 2) ELSE CASE RIGHT(prd.Watt, 1) WHEN 'W' THEN LEFT(prd.Watt, LEN(prd.Watt) - 1) ELSE prd.Watt END END AS [value]
	,	CASE RIGHT(prd.Watt, 2) WHEN 'KW' THEN 'KW' ELSE CASE RIGHT(prd.Watt, 1) WHEN 'W' THEN 'WTT' ELSE '' END END AS [UOM]
	FROM  ProductView prd 
	WHERE prd.Watt IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('39101802', '39111501', '39111525', '39131708')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Mounting' AS [name]
	,	prd.MountType AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.MountType IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) NOT IN ('31201617', '39111906', '39131706', '39131707', '39131717', '41106402', '23241610', '27112501', '39131709')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Number Of Outlet' AS [name]
	,	prd.NumberOfOutlets AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.NumberOfOutlets IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('39121301', '39121303', '39121304', '39121305', '39121307', '39121320', '39121332', '39121308')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Schedule' AS [name]
	,	prd.Class AS [value]
	,	'' AS [UOM]
	FROM  ProductView prd 
	WHERE prd.Class IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('39131707')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Size' AS [name]
	,	CASE WHEN ISNULL(prd.SizeI, '') = '' THEN 
			CASE WHEN prd.Diameter1I = '' THEN '' ELSE
				CASE WHEN ISNULL(prd.Diameter2I, '') = '' THEN prd.Diameter1I ELSE	
					CASE WHEN ISNULL(prd.Diameter3I, '') = '' THEN prd.Diameter1I + ' x ' + prd.Diameter2I ELSE
						CASE WHEN ISNULL(prd.Diameter4I, '') = '' THEN prd.Diameter1I + ' x ' + prd.Diameter2I + ' x ' + prd.Diameter3I ELSE
							prd.Diameter1I + ' x ' + prd.Diameter2I + ' x ' + prd.Diameter3I + ' x ' + prd.Diameter4I
						END
					END
				END
			END
			ELSE prd.SizeI
		END [value]
	,	'IN' AS [UOM]
	FROM  ProductView prd 
	WHERE (prd.SizeI IS NOT NULL OR prd.Diameter1I IS NOT NULL)
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('31201617', '39121301', '39121303', '39121304', '39121305', '39121307', '39121311', '39121312', '39121320', '39121332', '39121701', '39121704', '41106402', '39121308')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Trade Size' AS [name]
	,	CASE WHEN ISNULL(prd.SizeI, '') = '' THEN 
			CASE WHEN prd.Diameter1I = '' THEN '' ELSE
				CASE WHEN ISNULL(prd.Diameter2I, '') = '' THEN prd.Diameter1I ELSE	
					CASE WHEN ISNULL(prd.Diameter3I, '') = '' THEN prd.Diameter1I + ' x ' + prd.Diameter2I ELSE
						CASE WHEN ISNULL(prd.Diameter4I, '') = '' THEN prd.Diameter1I + ' x ' + prd.Diameter2I + ' x ' + prd.Diameter3I ELSE
							prd.Diameter1I + ' x ' + prd.Diameter2I + ' x ' + prd.Diameter3I + ' x ' + prd.Diameter4I
						END
					END
				END
			END
			ELSE prd.SizeI
		END [value]
	,	'IN' AS [UOM]
	FROM  ProductView prd 
	WHERE (prd.SizeI IS NOT NULL OR prd.Diameter1I IS NOT NULL)
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('39121420', '39121719', '39131706', '39131707', '39131717')

	INSERT INTO #ProductAttribute
	SELECT prd.ProductID 
	,	'Voltage Rating' AS [name]
	,	CASE RIGHT(prd.Voltage, 3) WHEN 'VAC' THEN LEFT(prd.Voltage, LEN(prd.Voltage) - 3) ELSE '' END AS [value]
	,	CASE RIGHT(prd.Voltage, 3) WHEN 'VAC' THEN 'VAC' ELSE '' END AS [UOM]
	FROM  ProductView prd 
	WHERE prd.Voltage IS NOT NULL
	AND LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC) - 1) IN ('39111501', '39111525', '39111906', '39131706', '39131707', '39131708', '39131709')

	SELECT * 
	FROM #ProductAttribute
END




