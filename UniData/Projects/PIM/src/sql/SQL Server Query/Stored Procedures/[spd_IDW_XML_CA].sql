USE [DataWarehouse_PIM]
GO

/****** Object:  StoredProcedure [dbo].[spd_IDW_XML_CA]    Script Date: 2016-04-18 4:01:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









































-- =============================================
-- Author:		Vianney Rebetez, Junjie Tang
-- Create date: 2016-04-12
-- Description:	Generate IDW XML File (PIM)
-- =============================================
ALTER PROCEDURE [dbo].[spd_IDW_XML_CA]
	-- Add the parameters for the stored procedure here
	@CompanyCode VARCHAR(2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Parameters validations
	IF @CompanyCode NOT IN ('16')
	BEGIN
		RAISERROR('Invalid parameter { %s }: acceptable value is 16.', 16, 1, @CompanyCode)
		RETURN -1
	END

	-- Generate #ProductAttribueMatrix Temporary Matrix Table
	CREATE TABLE #ProductAttributeMatrix(
		[ProductID] [nvarchar] (255) NULL,
		[AttributeName] [nvarchar](255) NULL,
		[AttributeValue] [nvarchar](255) NULL,
		[AttributeUOM] [nvarchar](255) NULL
	)
	INSERT INTO #ProductAttributeMatrix
	EXEC [dbo].[spd_IDW_GetAttributeMatrix]

	-- Generate IDW XML Document
	SELECT 'T' AS [usage]
	,	'IDEAALLB' AS [doctype]
	,	'05.04' AS [version]
	,	CASE WHEN prc.CompanyCode = '02' THEN '856' 
	    	 WHEN prc.CompanyCode = '03' THEN '1190' 
			 WHEN prc.CompanyCode = '16' THEN '965'
		END AS "manufacturer/idwPrivateId"
	,	(SELECT ISNULL(prd.ProductCode, '') AS [catalog]
		 ,	 ISNULL(prd.UPCCode, '') AS [idwItemCtrl]
		 ,	 ISNULL(prd.UPCCode, '') AS [upc]
		 ,	 ISNULL('00' + prd.UPCCode, '') AS [gtin]
		 ,   ISNULL(LEFT(prd.UNSPSC, CHARINDEX(' - ', prd.UNSPSC)-1), '') AS [unspsc]
		 ,	 ISNULL(LEFT(prd.IGCC, CHARINDEX(' - ', prd.IGCC)-1), '') AS [igcc]
		 ,	 ISNULL(LEFT(prd.ETIM, CHARINDEX(' - ', prd.ETIM)-1), '') AS [etim]
	-- <product>
		 ,	  (SELECT 'C' AS [updateFlag]
		       ,    ISNULL(prd.AltProductCode, '') AS [altCatalog]
		       ,	CASE prd.ProductStatus WHEN 'No Longer Replenished' THEN 'P' ELSE CASE prd.ProductStatus WHEN 'Obsolete' THEN 'D' ELSE 'A' END END AS [status]
		       ,	CONVERT(VARCHAR(10), GETDATE(), 112) AS [statusDT]
			   ,	ISNULL(prd.CountryOfOriginCode,'') AS [cntryOfOrg]
			   ,	CASE ISNULL(MSDS.AssetID,'') WHEN '' THEN 'N' ELSE 'Y' END AS [msdsFlag]
			   ,	ISNULL(prd.BaseQty, '') AS [ordMin]
		       ,	CASE ISNULL(prd.BaseUOM, '') 
						WHEN 'FEET' THEN 'FT' 
						WHEN 'LINEAR FEET' THEN 'LF' 
						WHEN 'METER' THEN 'MR' 
						WHEN 'POUND' THEN 'LB'
						WHEN 'KILOGRAM' THEN 'KG'
						WHEN 'LITER' THEN 'LT'
						ELSE 'EA' 
					END AS [ordMinUOM]
		       ,	ISNULL(prd.BaseQty, '') AS [ordMult]
		       ,	CASE ISNULL(prd.BaseUOM, '') 
						WHEN 'FEET' THEN 'FT' 
						WHEN 'LINEAR FEET' THEN 'LF' 
						WHEN 'METER' THEN 'MR' 
						WHEN 'POUND' THEN 'LB'
						WHEN 'KILOGRAM' THEN 'KG'
						WHEN 'LITER' THEN 'LT'
						ELSE 'EA' 
					END AS [ordMultUOM]
		       ,	CASE WHEN isnull(PKG.OPT1,'')='YES' THEN PKG.QTY1
						 WHEN isnull(PKG.OPT2,'')='YES' THEN PKG.QTY2 
						 WHEN isnull(PKG.OPT3,'')='YES' THEN PKG.QTY3 
						 WHEN isnull(PKG.OPT4,'')='YES' THEN PKG.QTY4 
						 WHEN isnull(PKG.OPT5,'')='YES' THEN PKG.QTY5
						 ELSE ISNULL(prd.BaseQty, '') 
					END AS [optOrdMult]
		       ,	CASE ISNULL(prd.BaseUOM, '') 
						WHEN 'FEET' THEN 'FT' 
						WHEN 'LINEAR FEET' THEN 'LF' 
						WHEN 'METER' THEN 'MR' 
						WHEN 'POUND' THEN 'LB'
						WHEN 'KILOGRAM' THEN 'KG'
						WHEN 'LITER' THEN 'LT'
						ELSE 'EA' 
					END AS [optOrdMultUOM]
		       ,	ISNULL(LEFT(iih.ProductGroup, CHARINDEX(' - ', iih.ProductGroup)-1), '') AS [class]
		       ,	ISNULL(LEFT(iih.ProductLine, CHARINDEX(' - ', iih.ProductLine)-1), '') AS [subClass]
		       ,	'X' AS [rohsInd]
		       ,	'Y' AS [arra]
		       ,	'Y' AS [baa]
		       ,	'N' AS [serialized]
		       ,	'S' AS [sktInd]
			   ,	'EN' AS "brandLabel/@lang"
			   ,	ISNULL(prc.Brand, '') AS "brandLabel"
			   ,	'EN' AS "invoiceDesc/@lang"
			   ,	CASE prc.CompanyCode 
						WHEN '16' THEN 
							CASE prd.BaseUOM
								WHEN 'METER' THEN ISNULL(prd.AttributeBasedDescM, '')
								WHEN 'LITER' THEN ISNULL(prd.AttributeBasedDescM, '')
								WHEN 'KILOGRAM' THEN ISNULL(prd.AttributeBasedDescM, '')
								ELSE ISNULL(prd.AttributeBasedDescI, '') 
							END
						ELSE ISNULL(prd.AttributeBasedDescI, '') 
					END AS "invoiceDesc"
		       FOR XML PATH('product'), TYPE)
	-- <msds>
		 ,    (SELECT 'C' AS "updateFlag"
		       ,	'EN' as "msdsURL/@lang"
			   ,	'http://pim.itinfonet.com/web/idw/' 
					+ CASE WHEN prc.CompanyCode = '02' THEN '11992/' 
	    				   WHEN prc.CompanyCode = '03' THEN '12527/' 
						   WHEN prc.CompanyCode = '16' THEN '12202/' 
					  END
					+ MSDS.TargetFileName AS [msdsURL]
			   FOR XML PATH('msds'), TYPE)
	-- <text>
		 ,    (SELECT 'C' AS "updateFlag"
			   ,    'EN' AS "catalogDesc/@lang"
			   ,	ISNULL(mh.[Description], '') AS "catalogDesc"
			   ,	'EN' AS "marketingMsg/@lang"
			   ,	ISNULL(mh.FeaturesAndBenefits,'') + CASE WHEN mh.FeaturesAndBenefits IS NOT NULL AND prd.FeaturesAndBenefits IS NOT NULL THEN ';' ELSE '' END + ISNULL(prd.FeaturesAndBenefits,'') AS "marketingMsg"
			   FOR XML PATH('text'), TYPE)
	-- <packages>
	     ,	  (SELECT 'C' AS [updateFlag]
				,	(SELECT 'G39' AS [pakType]
					   ,	ISNULL(pcv.LongDescription, ISNULL(pcv.ShortDescription, '')) AS [pakDesc]
					   ,	ISNULL(pcv.PackageType, '') AS [pakUOM]
					   ,	'1' AS [ordMinPak]
					   ,	'1' AS [ordMultPak]
					   ,    ISNULL(prdpck.I2OF5, '') AS [gtinPak]
					   ,	ISNULL(prd.AlternateUPCCode, '') AS [altUpc]
					   ,    ISNULL(CAST(prdpck.Quantity AS numeric(10,3)), 0) AS [subPaks]
					   ,    ISNULL('00' + prd.UPCCode, '') AS [gtinSubPak]
					   ,	ISNULL(CAST(prdpck.Quantity AS numeric(10,3)), 0) AS [totalUnits]
					   ,	ISNULL(prd.BaseUOM, '') AS [lowestLvlUOM]
					   ,	ISNULL(CAST(CAST(prd.ShippingWeight AS float) * CAST(prdpck.Quantity AS float) + CAST(prdpck.[Weight] AS float) AS numeric(10,3)), 0) AS [grossWt]
					   ,    'KG' AS [grossWtUOM]
					   ,	ISNULL(CAST(prdpck.[Length] AS numeric(10,3)), 0) AS [len]
					   ,    'IN' [lenUOM]
					   ,	ISNULL(CAST(prdpck.[Width] AS numeric(10,3)), 0) AS [wid]
					   ,    'IN' AS [widUOM]
					   ,	ISNULL(CAST(prdpck.Height AS numeric(10,3)), 0) AS [hgt]
					   ,    'IN' AS [hgtUOM]
					   FROM dbo.PackageView AS prdpck
						   LEFT JOIN dbo.PackageCodeView AS pcv 
							   ON pcv.PackageCodeID = prdpck.PackageCodeID
					   WHERE prdpck.ChildID = prd.ProductID 
					   AND ISNULL(prdpck.IsDefaultBranch,'') = 'Yes' 
					   AND prdpck.PackageID IS NOT NULL
					FOR XML PATH('pak'), TYPE)
				,	(SELECT 'G39' AS [pakType]
					   ,	ISNULL(pc2.LongDescription, ISNULL(pc2.ShortDescription, '')) AS [pakDesc]
					   ,	ISNULL(pc2.PackageType, '') AS [pakUOM]
					   ,	'1' AS [ordMinPak]
					   ,	'1' AS [ordMultPak]
					   ,    ISNULL(pck2.I2OF5, '') AS [gtinPak]
					   ,	ISNULL(prd.AlternateUPCCode, '') AS [altUpc]
					   ,    ISNULL(CAST(pck2.Quantity AS numeric(10,3)), 0) AS [subPaks]
					   ,    ISNULL(prdpck.I2OF5, '') AS [gtinSubPak]
					   ,	ISNULL(CAST(pck2.Quantity AS numeric(10,3)) * CAST(prdpck.Quantity AS numeric(10,3)), 0) AS [totalUnits]
					   ,	ISNULL(prd.BaseUOM, '') AS [lowestLvlUOM]
					   ,	ISNULL(CAST((CAST(prd.ShippingWeight AS float) * CAST(prdpck.Quantity AS float) + CAST(prdpck.[Weight] AS float)) * CAST(pck2.Quantity AS float) + CAST(pck2.[Weight] AS float) AS numeric(10,3)), 0) AS [grossWt]
					   ,    'KG' AS [grossWtUOM]
					   ,	ISNULL(CAST(pck2.[Length] AS numeric(10,3)), 0) AS [len]
					   ,    'IN' [lenUOM]
					   ,	ISNULL(CAST(pck2.[Width] AS numeric(10,3)), 0) AS [wid]
					   ,    'IN' AS [widUOM]
					   ,	CAST(CASE ISNULL(pc2.PackageType,'')
								WHEN 'PALLETS' THEN 
									CASE CAST(pck2.Width AS float) * CAST(pck2.[Length] AS float) * CAST(prdpck.Width AS float) * CAST(prdpck.[Length] AS float)
									WHEN 0 THEN pck2.Height
									ELSE cast(pck2.Height as float) + cast(prdpck.Height as float) * ceiling(cast(pck2.Quantity as float) / (select max(z.x) from (select floor((cast(pck2.Width as float)*cast(pck2.[Length] as float))/(cast(prdpck.Width as float)*cast(prdpck.[Length] as float))) as x union select 1 as x) z))
									END
								ELSE pck2.Height
								END
							AS numeric(10,3)) AS [hgt]
					   ,    'IN' AS [hgtUOM]
					   FROM dbo.PackageView AS prdpck
						   LEFT JOIN dbo.PackageCodeView AS pc1 
							   ON pc1.PackageCodeID = prdpck.PackageCodeID
						   LEFT JOIN dbo.PackageView AS pck2 
							   ON pck2.ChildID = prdpck.PackageID 
						   LEFT JOIN dbo.PackageCodeView AS pc2 
							   ON pc2.PackageCodeID = pck2.PackageCodeID 
					   WHERE pck2.PackageID IS NOT NULL 
					   AND prdpck.ChildID = prd.ProductID
					   AND prdpck.IsDefaultBranch = 'Yes'
					FOR XML PATH('pak'), TYPE)
				,	(SELECT 'G39' AS [pakType]
					   ,	ISNULL(pc3.LongDescription, ISNULL(pc3.ShortDescription, '')) AS [pakDesc]
					   ,	ISNULL(pc3.PackageType, '') AS [pakUOM]
					   ,	'1' AS [ordMinPak]
					   ,	'1' AS [ordMultPak]
					   ,    ISNULL(pck3.I2OF5, '') AS [gtinPak]
					   ,	ISNULL(prd.AlternateUPCCode, '') AS [altUpc]
					   ,    ISNULL(CAST(pck3.Quantity AS numeric(10,3)), 0) AS [subPaks]
					   ,    ISNULL(pck2.I2OF5, '') AS [gtinSubPak]
					   ,	ISNULL(CAST(pck3.Quantity AS numeric(10,3)) * CAST(pck2.Quantity AS numeric(10,3)) * CAST(prdpck.Quantity AS numeric(10,3)), 0) AS [totalUnits]
					   ,	ISNULL(prd.BaseUOM, '') AS [lowestLvlUOM]
					   ,	ISNULL(CAST((CAST(prd.ShippingWeight AS float) * CAST(prdpck.Quantity AS float) + CAST(prdpck.[Weight] AS float) * CAST(pck2.Quantity AS float) + CAST(pck2.[Weight] AS float)) * CAST(pck3.Quantity AS float) + CAST(pck3.[Weight] AS float) AS numeric(10,3)), 0) AS [grossWt]
					   ,    'KG' AS [grossWtUOM]
					   ,	ISNULL(CAST(pck3.[Length] AS numeric(10,3)), 0) AS [len]
					   ,    'IN' [lenUOM]
					   ,	ISNULL(CAST(pck3.[Width] AS numeric(10,3)), 0) AS [wid]
					   ,    'IN' AS [widUOM]
					   ,	CAST(CASE ISNULL(pc3.PackageType,'')
								WHEN 'PALLETS' THEN 
									CASE CAST(pck3.Width AS float) * CAST(pck3.[Length] AS float) * CAST(pck2.Width AS float) * CAST(pck2.[Length] AS float)
									WHEN 0 THEN pck3.Height
									ELSE cast(pck3.Height as float) + cast(pck2.Height as float) * ceiling(cast(pck3.Quantity as float) / (select max(z.x) from (select floor((cast(pck3.Width as float)*cast(pck3.[Length] as float))/(cast(pck2.Width as float)*cast(pck2.[Length] as float))) as x union select 1 as x) z))
									END
								ELSE pck3.Height
								END
							AS numeric(10,3)) AS [hgt]
					   ,    'IN' AS [hgtUOM]
					   FROM dbo.PackageView AS prdpck
						   LEFT JOIN dbo.PackageCodeView AS pc1 
							   ON pc1.PackageCodeID = prdpck.PackageCodeID
						   LEFT JOIN dbo.PackageView AS pck2 
							   ON pck2.ChildID = prdpck.PackageID 
						   LEFT JOIN dbo.PackageCodeView AS pc2 
							   ON pc2.PackageCodeID = pck2.PackageCodeID 
						   LEFT JOIN dbo.PackageView AS pck3 
							   ON pck3.ChildID = pck2.PackageID 
						   LEFT JOIN dbo.PackageCodeView AS pc3
							   ON pc3.PackageCodeID = pck3.PackageCodeID 
					   WHERE pck3.PackageID IS NOT NULL 
					   AND prdpck.ChildID = prd.ProductID 
					   AND prdpck.IsDefaultBranch = 'Yes'
					FOR XML PATH('pak'), TYPE)
				,	(SELECT 'G39' AS [pakType]
					   ,	ISNULL(pc4.LongDescription, ISNULL(pc4.ShortDescription, '')) AS [pakDesc]
					   ,	ISNULL(pc4.PackageType, '') AS [pakUOM]
					   ,	'1' AS [ordMinPak]
					   ,	'1' AS [ordMultPak]
					   ,    ISNULL(pck4.I2OF5, '') AS [gtinPak]
					   ,	ISNULL(prd.AlternateUPCCode, '') AS [altUpc]
					   ,    ISNULL(CAST(pck4.Quantity AS numeric(10,3)), 0) AS [subPaks]
					   ,    ISNULL(pck3.I2OF5, '') AS [gtinSubPak]
					   ,	ISNULL(CAST(pck4.Quantity AS numeric(10,3)) * CAST(pck3.Quantity AS numeric(10,3)) * CAST(pck2.Quantity AS numeric(10,3)) * CAST(prdpck.Quantity AS numeric(10,3)), 0) AS [totalUnits]
					   ,	ISNULL(prd.BaseUOM, '') AS [lowestLvlUOM]
					   ,	ISNULL(CAST((((CAST(prd.ShippingWeight AS float) * CAST(prdpck.Quantity AS float) + CAST(prdpck.[Weight] AS float)) * CAST(pck2.Quantity AS float) + CAST(pck2.[Weight] AS float)) * CAST(pck3.Quantity AS float) + CAST(pck3.[Weight] AS float)) * CAST(pck4.Quantity AS float) + CAST(pck4.[Weight] AS float) AS numeric(10,3)), 0) AS [grossWt]
					   ,    'KG' AS [grossWtUOM]
					   ,	ISNULL(CAST(pck4.[Length] AS numeric(10,3)), 0) AS [len]
					   ,    'IN' [lenUOM]
					   ,	ISNULL(CAST(pck4.[Width] AS numeric(10,3)), 0) AS [wid]
					   ,    'IN' AS [widUOM]
					   ,	CAST(CASE ISNULL(pc4.PackageType,'')
								WHEN 'PALLETS' THEN 
									CASE CAST(pck4.Width AS float) * CAST(pck4.[Length] AS float) * CAST(pck3.Width AS float) * CAST(pck3.[Length] AS float)
									WHEN 0 THEN pck4.Height
									ELSE cast(pck4.Height as float) + cast(pck3.Height as float) * ceiling(cast(pck4.Quantity as float) / (select max(z.x) from (select floor((cast(pck4.Width as float)*cast(pck4.[Length] as float))/(cast(pck3.Width as float)*cast(pck3.[Length] as float))) as x union select 1 as x) z))
									END
								ELSE pck4.Height
								END
							AS numeric(10,3)) AS [hgt]
					   ,    'IN' AS [hgtUOM]
					   FROM dbo.PackageView AS prdpck
						   LEFT JOIN dbo.PackageCodeView AS pc1 
							   ON pc1.PackageCodeID = prdpck.PackageCodeID
						   LEFT JOIN dbo.PackageView AS pck2 
							   ON pck2.ChildID = prdpck.PackageID 
						   LEFT JOIN dbo.PackageCodeView AS pc2 
							   ON pc2.PackageCodeID = pck2.PackageCodeID 
						   LEFT JOIN dbo.PackageView AS pck3
							   ON pck3.ChildID = pck2.PackageID 
						   LEFT JOIN dbo.PackageCodeView AS pc3
							   ON pc3.PackageCodeID = pck3.PackageCodeID 
						   LEFT JOIN dbo.PackageView AS pck4 
							   ON pck4.ChildID = pck3.PackageID 
						   LEFT JOIN dbo.PackageCodeView AS pc4
							   ON pc4.PackageCodeID = pck4.PackageCodeID 
					   WHERE pck4.PackageID IS NOT NULL 
					   AND prdpck.ChildID = prd.ProductID 
					   AND prdpck.IsDefaultBranch = 'Yes'
					FOR XML PATH('pak'), TYPE)
				,	(SELECT 'G39' AS [pakType]
					   ,	ISNULL(pc5.LongDescription, ISNULL(pc5.ShortDescription, '')) [pakDesc]
					   ,	ISNULL(pc5.PackageType, '') AS [pakUOM]
					   ,	'1' AS [ordMinPak]
					   ,	'1' AS [ordMultPak]
					   ,    ISNULL(pck5.I2OF5, '') AS [gtinPak]
					   ,	ISNULL(prd.AlternateUPCCode, '') AS [altUpc]
					   ,    ISNULL(CAST(pck5.Quantity AS numeric(10,3)), 0) AS [subPaks]
					   ,    ISNULL(pck4.I2OF5, '') AS [gtinSubPak]
					   ,	ISNULL(CAST(pck5.Quantity AS numeric(10,3)) * CAST(pck4.Quantity AS numeric(10,3)) * CAST(pck3.Quantity AS numeric(10,3)) * CAST(pck2.Quantity AS numeric(10,3)) * CAST(prdpck.Quantity AS numeric(10,3)), 0) AS [totalUnits]
					   ,	ISNULL(prd.BaseUOM, '') AS [lowestLvlUOM]
					   ,	ISNULL(CAST(((((CAST(prd.ShippingWeight AS float) * CAST(prdpck.Quantity AS float) + CAST(prdpck.[Weight] AS float)) * CAST(pck2.Quantity AS float) + CAST(pck2.[Weight] AS float)) * CAST(pck3.Quantity AS float) + CAST(pck3.[Weight] AS float)) * CAST(pck4.Quantity AS float) + CAST(pck4.[Weight] AS float)) * CAST(pck5.Quantity AS float) + CAST(pck5.[Weight] AS float) AS numeric(10,3)),0) AS [grossWt]
					   ,    'KG' AS [grossWtUOM]
					   ,	ISNULL(CAST(pck5.[Length] AS numeric(10,3)), 0) AS [len]
					   ,    'IN' [lenUOM]
					   ,	ISNULL(CAST(pck5.[Width] AS numeric(10,3)), 0) AS [wid]
					   ,    'IN' AS [widUOM]
					   ,	CAST(CASE ISNULL(pc5.PackageType,'')
								WHEN 'PALLETS' THEN 
									CASE cast(pck5.Width AS float) * CAST(pck5.[Length] AS float) * CAST(pck4.Width AS float) * CAST(pck4.[Length] AS float)
									WHEN 0 THEN pck5.Height
									ELSE cast(pck5.Height as float) + cast(pck4.Height as float) * ceiling(cast(pck5.Quantity as float) / (select max(z.x) from (select floor((cast(pck5.Width as float)*cast(pck5.[Length] as float))/(cast(pck4.Width as float)*cast(pck4.[Length] as float))) as x union select 1 as x) z))
									END
								ELSE pck5.Height
								END
							AS numeric(10,3)) AS [hgt]
					   ,    'IN' AS [hgtUOM]
					   FROM dbo.PackageView AS prdpck
						   LEFT JOIN dbo.PackageCodeView AS pc1 
							   ON pc1.PackageCodeID = prdpck.PackageCodeID
						   LEFT JOIN dbo.PackageView AS pck2 
							   ON pck2.ChildID = prdpck.PackageID 
						   LEFT JOIN dbo.PackageCodeView AS pc2 
							   ON pc2.PackageCodeID = pck2.PackageCodeID 
						   LEFT JOIN dbo.PackageView AS pck3
							   ON pck3.ChildID = pck2.PackageID 
						   LEFT JOIN dbo.PackageCodeView AS pc3
							   ON pc3.PackageCodeID = pck3.PackageCodeID 
						   LEFT JOIN dbo.PackageView AS pck4 
							   ON pck4.ChildID = pck3.PackageID 
						   LEFT JOIN dbo.PackageCodeView AS pc4
							   ON pc4.PackageCodeID = pck4.PackageCodeID 
						   LEFT JOIN dbo.PackageView AS pck5 
							   ON pck5.ChildID = pck4.PackageID 
						   LEFT JOIN dbo.PackageCodeView AS pc5
							   ON pc5.PackageCodeID = pck5.PackageCodeID 
					   WHERE pck5.PackageID IS NOT NULL 
					   AND prdpck.ChildID = prd.ProductID 
					   AND prdpck.IsDefaultBranch = 'Yes'
					FOR XML PATH('pak'), TYPE)
			   FOR XML PATH('packages'), TYPE)
	-- <prices>
		 ,    (SELECT ISNULL(prc.TradeListName, '') AS [prcShtNo]
			   ,	case prc.CompanyCode WHEN '16' THEN 'CAN' ELSE 'USA' END AS [zone]
			   ,	ISNULL(REPLACE(prc.CurrentListPriceEffectiveDate, '-', ''), '') AS [prcShtEffDt]
			   ,	ISNULL(prc.TradeListDescription, '') AS [prcShtDesc]
			   ,	'C' AS [updateFlag]
			   ,    (SELECT	ISNULL(REPLACE(prc.CurrentListPriceEffectiveDate, '-', ''), '') AS [prcEffDt]
					,	ISNULL(CASE WHEN LEFT(prc.Currency, 2) = 'US' THEN 'USD' WHEN LEFT(prc.Currency, 2) = 'CA' THEN 'CAD' ELSE '' END, '') AS [prcCrncy]
					,	'LIST' AS [prcCol]
					,	ISNULL(prc.CurrentListPrice, 0) AS [prc]
					,	CASE prc.PricePer WHEN 1 THEN 'PE' WHEN 10 THEN 'PN' WHEN 100 THEN 'HP' WHEN 1000 THEN 'TP' ELSE '' END AS [prcUOM]
					,	'NETPP0' AS [typeOfPrc]
					,	'NECTUSR' AS [classOfTrade]
					,	'L' AS [outPrcCol]
					FOR XML PATH('price'), TYPE)
			   ,    (SELECT	ISNULL(REPLACE(prc.CurrentListPriceEffectiveDate, '-', ''), '') AS [prcEffDt]
					,	ISNULL(CASE WHEN LEFT(prc.Currency, 2) = 'US' THEN 'USD' WHEN LEFT(prc.Currency, 2) = 'CA' THEN 'CAD' ELSE '' END, '') AS [prcCrncy]
					,	'T3' AS [prcCol]
					,	ISNULL(prc.CurrentListPrice, 0) AS [prc]
					,	CASE prc.PricePer WHEN 1 THEN 'PE' WHEN 10 THEN 'PN' WHEN 100 THEN 'HP' WHEN 1000 THEN 'TP' ELSE '' END AS [prcUOM]
					,	'NETPP3' AS [typeOfPrc]
					,	'NECTUSR' AS [classOfTrade]
					,	'T3' AS [outPrcCol]
					FOR XML PATH('price'), TYPE)
		       FOR XML PATH('prcSht'), ROOT('prices'), TYPE)
	-- <files>
	     ,	 (SELECT 'C' AS [updateFlag]
				,	(SELECT 'http://pim.itinfonet.com/web/idw/' 
							+ CASE WHEN prc.CompanyCode = '02' THEN '11992/' 
	    						   WHEN prc.CompanyCode = '03' THEN '12527/' 
								   WHEN prc.CompanyCode = '16' THEN '12202/' 
							  END
							+ ISNULL(assdir.IDWDirectory + '/', '')
							+ REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'),',','_'),' ','_')
					 FROM dbo.ProductAssetView AS prdass 
						 LEFT JOIN dbo.AssetView AS ass 
							 ON ass.AssetID = prdass.AssetID 
						 LEFT JOIN dbo.AssetLibraryView AS asslib 
							 ON asslib.AssetID = ass.AssetID 
							 AND asslib.AssetPushQueue = 'Main Asset Push Queue'
							 AND asslib.AssetPushConfiguration = 'IDW Digital Images'
						 LEFT JOIN dbo.AssetDirectories assdir 
							 ON assdir.AssetLibraryDirectory = LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)-1)
					 WHERE prdass.ProductID = prd.ProductID 
					 AND prdass.AssetType = 'PrimaryProductImage') AS [imageURL]
				,	(SELECT 'http://pim.itinfonet.com/web/idw/' 
							+ CASE WHEN prc.CompanyCode = '02' THEN '11992/' 
	    						   WHEN prc.CompanyCode = '03' THEN '12527/' 
								   WHEN prc.CompanyCode = '16' THEN '12202/' 
							  END
							+ ISNULL(assdir.IDWDirectory + '/', '')
							+ REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'),',','_'),' ','_')
					 FROM dbo.ProductAssetView AS prdass 
						 LEFT JOIN dbo.AssetView AS ass 
							 ON ass.AssetID = prdass.AssetID 
						 LEFT JOIN dbo.AssetLibraryView AS asslib 
							 ON asslib.AssetID = ass.AssetID 
							 AND asslib.AssetPushQueue = 'Main Asset Push Queue'
							 AND asslib.AssetPushConfiguration = 'IDW Thumbnails'
						 LEFT JOIN dbo.AssetDirectories assdir 
							 ON assdir.AssetLibraryDirectory = LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)-1)
					 WHERE prdass.ProductID = prd.ProductID 
					 AND prdass.AssetType = 'PrimaryProductImage') AS [imageThmbURL]
				,	(SELECT TOP 1
							'http://pim.itinfonet.com/web/idw/' 
							+ CASE WHEN prc.CompanyCode = '02' THEN '11992/' 
	    						   WHEN prc.CompanyCode = '03' THEN '12527/' 
								   WHEN prc.CompanyCode = '16' THEN '12202/' 
							  END
							+ ISNULL(assdir.IDWDirectory + '/', '')
							+ REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'),',','_'),' ','_')
					 FROM dbo.ProductSourceView prs
						 LEFT JOIN dbo.ProductSourceAssetView AS prsass 
							 ON prsass.ProductSourceID = prs.ProductSourceID
						 LEFT JOIN dbo.AssetView AS ass 
							 ON ass.AssetID = prsass.AssetID 
						 LEFT JOIN dbo.AssetLibraryView AS asslib 
							 ON asslib.AssetID = ass.AssetID 
							 AND asslib.AssetPushQueue = 'Main Asset Push Queue'
						 LEFT JOIN dbo.AssetDirectories assdir 
							 ON assdir.AssetLibraryDirectory = LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)-1)
					 WHERE prs.ProductID = prd.ProductID 
					 AND prsass.AssetType = '2D Drawing'
					 FOR XML PATH('specShtURL'), TYPE)
				,	(SELECT 'EN' as "brochureURL/@lang",
							'http://pim.itinfonet.com/web/idw/' 
							+ CASE WHEN prc.CompanyCode = '02' THEN '11992/' 
	    						   WHEN prc.CompanyCode = '03' THEN '12527/' 
								   WHEN prc.CompanyCode = '16' THEN '12202/' 
							  END
							+ ISNULL(assdir.IDWDirectory + '/', '')
							+ REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'),',','_'),' ','_')
					 FROM dbo.ProductCompanyAssetView AS prcass 
						 LEFT JOIN dbo.AssetView AS ass 
							 ON ass.AssetID = prcass.AssetID 
						 LEFT JOIN dbo.AssetLibraryView AS asslib 
							 ON asslib.AssetID = ass.AssetID 
							 AND asslib.AssetPushQueue = 'Main Asset Push Queue'
						 LEFT JOIN dbo.AssetDirectories assdir 
							 ON assdir.AssetLibraryDirectory = LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)-1)
					 WHERE prcass.ProductCompanyID = prc.ProductCompanyID 
					 AND prcass.AssetType = 'Brochure'
					 FOR XML PATH('brochureURL'), TYPE)
				,	(SELECT 'EN' as "techBullURL/@lang",
							'http://pim.itinfonet.com/web/idw/' 
							+ CASE WHEN prc.CompanyCode = '02' THEN '11992/' 
	    						   WHEN prc.CompanyCode = '03' THEN '12527/' 
								   WHEN prc.CompanyCode = '16' THEN '12202/' 
							  END
							+ ISNULL(assdir.IDWDirectory + '/', '')
							+ REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'),',','_'),' ','_')
					 FROM dbo.ProductCompanyAssetView AS prcass 
						 LEFT JOIN dbo.AssetView AS ass 
							 ON ass.AssetID = prcass.AssetID 
						 LEFT JOIN dbo.AssetLibraryView AS asslib 
							 ON asslib.AssetID = ass.AssetID 
							 AND asslib.AssetPushQueue = 'Main Asset Push Queue'
						 LEFT JOIN dbo.AssetDirectories assdir 
							 ON assdir.AssetLibraryDirectory = LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)-1)
					 WHERE prcass.ProductCompanyID = prc.ProductCompanyID 
					 AND prcass.AssetType = 'InformationBulletin'
					 FOR XML PATH('techBullURL'), TYPE)
				,	(SELECT 'EN' as "instlInstrURL/@lang",
							'http://pim.itinfonet.com/web/idw/' 
							+ CASE WHEN prc.CompanyCode = '02' THEN '11992/' 
	    						   WHEN prc.CompanyCode = '03' THEN '12527/' 
								   WHEN prc.CompanyCode = '16' THEN '12202/' 
							  END
							+ ISNULL(assdir.IDWDirectory + '/', '')
							+ REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'),',','_'),' ','_')
					 FROM dbo.ProductCompanyAssetView AS prcass 
						 LEFT JOIN dbo.AssetView AS ass 
							 ON ass.AssetID = prcass.AssetID 
						 LEFT JOIN dbo.AssetLibraryView AS asslib 
							 ON asslib.AssetID = ass.AssetID 
							 AND asslib.AssetPushQueue = 'Main Asset Push Queue'
						 LEFT JOIN dbo.AssetDirectories assdir 
							 ON assdir.AssetLibraryDirectory = LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)-1)
					 WHERE prcass.ProductCompanyID = prc.ProductCompanyID 
					 AND prcass.AssetType = 'InstallationSheet'
					 FOR XML PATH('instlInstrURL'), TYPE)
				,	(SELECT 'EN' as "userManualURL/@lang",
							'http://pim.itinfonet.com/web/idw/' 
							+ CASE WHEN prc.CompanyCode = '02' THEN '11992/' 
	    						   WHEN prc.CompanyCode = '03' THEN '12527/' 
								   WHEN prc.CompanyCode = '16' THEN '12202/' 
							  END
							+ ISNULL(assdir.IDWDirectory + '/', '')
							+ REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'),',','_'),' ','_')
					 FROM dbo.ProductCompanyAssetView AS prcass 
						 LEFT JOIN dbo.AssetView AS ass 
							 ON ass.AssetID = prcass.AssetID 
						 LEFT JOIN dbo.AssetLibraryView AS asslib 
							 ON asslib.AssetID = ass.AssetID 
							 AND asslib.AssetPushQueue = 'Main Asset Push Queue'
						 LEFT JOIN dbo.AssetDirectories assdir 
							 ON assdir.AssetLibraryDirectory = LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)-1)
					 WHERE prcass.ProductCompanyID = prc.ProductCompanyID 
					 AND prcass.AssetType = 'TechnicalManual'
					 FOR XML PATH('userManualURL'), TYPE)
				,	(SELECT 'EN' as "warrantyURL/@lang",
							'http://pim.itinfonet.com/web/idw/' 
							+ CASE WHEN prc.CompanyCode = '02' THEN '11992/' 
	    						   WHEN prc.CompanyCode = '03' THEN '12527/' 
								   WHEN prc.CompanyCode = '16' THEN '12202/' 
							  END
							+ ISNULL(assdir.IDWDirectory + '/', '')
							+ REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'),',','_'),' ','_')
					 FROM dbo.ProductCompanyAssetView AS prcass 
						 LEFT JOIN dbo.AssetView AS ass 
							 ON ass.AssetID = prcass.AssetID 
						 LEFT JOIN dbo.AssetLibraryView AS asslib 
							 ON asslib.AssetID = ass.AssetID 
							 AND asslib.AssetPushQueue = 'Main Asset Push Queue'
						 LEFT JOIN dbo.AssetDirectories assdir 
							 ON assdir.AssetLibraryDirectory = LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)-1)
					 WHERE prcass.ProductCompanyID = prc.ProductCompanyID 
					 AND prcass.AssetType = 'Terms&Conditions'
					 FOR XML PATH('warrantyURL'), TYPE)
			  FOR XML PATH('files'), TYPE)
	-- <attributes>
		 ,    (SELECT 'C' AS [updateFlag]
		       ,	(SELECT pam.AttributeName AS [name]
					 ,    pam.AttributeValue AS [value]
					 ,	  pam.AttributeUOM AS [uom]
					 FROM #ProductAttributeMatrix pam
					 WHERE prd.ProductID = pam.ProductID
					 FOR XML PATH('attribute'), TYPE)
			   FOR XML PATH('attributes'), TYPE)
		 FOR XML PATH('item'), TYPE)
	FROM  ProductView prd
		LEFT JOIN IDW_DeletedProducts delprd
			ON delprd.ProductID = prd.ProductID
		LEFT JOIN ProductCompanyView prc
			ON prd.ProductID = prc.ProductID
		LEFT JOIN InfofloHierarchyView iih 
		    ON iih.ProductLineID = prd.ProductLineID 
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
		OUTER APPLY (
			SELECT TOP 1 [Description]
			,	[FeaturesAndBenefits] 
			FROM MarketingHierarchyView
			WHERE ProductLineID = prc.ProductLineID
		) mh
		OUTER APPLY (
			SELECT prdpck.IsDefaultOption as OPT1
			,	CAST(prdpck.Quantity AS numeric(10,3)) AS [QTY1]
			,	pck2.IsDefaultOption AS OPT2
			,	CAST(CAST(prdpck.Quantity AS float) * CAST(pck2.Quantity AS float) AS numeric(10,3)) AS [QTY2]
			,	pck3.IsDefaultOption AS OPT3
			,	CAST(CAST(prdpck.Quantity AS float) * CAST(pck2.Quantity AS float) * CAST(pck3.Quantity AS float) AS numeric(10,3)) AS [QTY3]
			,	pck4.IsDefaultOption AS OPT4
			,	CAST(CAST(prdpck.Quantity AS float) * CAST(pck2.Quantity AS float) * CAST(pck3.Quantity AS float) * CAST(pck4.Quantity AS float) AS numeric(10,3)) AS [QTY4]
			,	pck5.IsDefaultOption AS OPT5
			,	CAST(CAST(prdpck.Quantity AS float) * CAST(pck2.Quantity AS float) * CAST(pck3.Quantity AS float) * CAST(pck4.Quantity AS float) * CAST(pck5.Quantity AS float) AS numeric(10,3)) AS [QTY5]
			FROM dbo.PackageView AS prdpck 
				LEFT JOIN dbo.PackageCodeView AS pc1 
					ON pc1.PackageCodeID = prdpck.PackageCodeID 
				LEFT JOIN dbo.PackageView AS pck2 
					ON pck2.ChildID = prdpck.PackageID 
				LEFT JOIN dbo.PackageCodeView AS pc2 
					ON pc2.PackageCodeID = pck2.PackageCodeID 
				LEFT JOIN dbo.PackageView AS pck3 
					ON pck3.ChildID = pck2.PackageID 
				LEFT JOIN dbo.PackageCodeView AS pc3 
					ON pc3.PackageCodeID = pck3.PackageCodeID 
				LEFT JOIN dbo.PackageView AS pck4 
					ON pck4.ChildID = pck3.PackageID 
				LEFT JOIN dbo.PackageCodeView AS pc4 
					ON pc4.PackageCodeID = pck4.PackageCodeID 
				LEFT JOIN dbo.PackageView AS pck5 
					ON pck5.ChildID = pck4.PackageID 
				LEFT JOIN dbo.PackageCodeView AS pc5 
					ON pc5.PackageCodeID = pck5.PackageCodeID
			WHERE prdpck.ChildID = prd.ProductID and prdpck.IsDefaultBranch = 'Yes'
		) PKG
		OUTER APPLY (
			SELECT TOP 1 X.* 
			FROM (
				SELECT prdass.AssetID
				,	case prdass.AssetLevel when 'Product' then 1 else 2 end as MSDSPriority
				,   ISNULL(assdir.IDWDirectory + '/','') + REPLACE(REPLACE(REPLACE(CASE ISNULL(ass.AssetLongName, '') WHEN '' THEN ass.AssetName ELSE ass.AssetLongName END + LOWER(RIGHT(ass.AssetFilename, 4)),'/','_'),',','_'),' ','_') AS TargetFileName
				FROM dbo.ProductAssetView AS prdass 
					LEFT JOIN dbo.AssetView AS ass 
						ON ass.AssetID = prdass.AssetID 
					LEFT JOIN dbo.AssetLibraryView AS asslib 
						ON asslib.AssetID = ass.AssetID AND asslib.AssetPushQueue = 'Main Asset Push Queue'
					LEFT JOIN dbo.AssetDirectories assdir 
						ON assdir.AssetLibraryDirectory = LEFT(asslib.AssetLibraryPath, CHARINDEX('/', asslib.AssetLibraryPath)-1)
				WHERE prdass.ProductID = prd.ProductID AND prdass.AssetType = 'MSDS'
			) X ORDER BY X.MSDSPriority
		) MSDS
	WHERE  prd.ProductID IS NOT NULL
	AND delprd.ProductID IS NULL
	AND prc.CompanyCode = @CompanyCode
	AND ISNULL(prd.[SupersededByProductCode], '') = '' 
	AND prd.ProductStatus IN ('New','Regular','No Longer Replenished', 'Obsolete')
	AND ISNULL(prc.IsOEMBrand, 'No') = 'No' 
	AND ISNULL(prd.ProductIsOEM, 'No') = 'No' 
	AND ISNULL(prc.LastSoldDate,GETDATE()) > DATEADD(YEAR, -3, GetDate())
	AND prc.CurrentListPrice IS NOT NULL
	AND prc.TradeListName IS NOT NULL
	AND (LEFT(iih.MarketSegment, 1) = '3') -- OR ISNULL(mh.MarketSegment,'') = 'ELECTRICAL'
	AND prd.ProductCode = '074713' --'012000'
	FOR XML PATH('envelope'), TYPE
	
	-- Update IDW_DeletedProducts Table
	INSERT IDW_DeletedProducts
	SELECT prd.ProductID
	FROM  ProductView prd
		LEFT JOIN IDW_DeletedProducts delprd
			ON delprd.ProductID = prd.ProductID
		LEFT JOIN ProductCompanyView prc
			ON prd.ProductID = prc.ProductID
	WHERE  prd.ProductID IS NOT NULL
	AND delprd.ProductID IS NULL
	AND prd.ProductStatus = 'Obsolete'
	AND prc.CompanyCode = @CompanyCode

END









































GO


