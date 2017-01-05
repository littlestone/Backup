USE [DataWarehouse_PIM]
GO
/****** Object:  StoredProcedure [dbo].[spd_TS_UpdateLastProductDeltaState]    Script Date: 2016-05-02 3:35:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

























-- =============================================
-- Author:		Vianney Rebetez, Junjie Tang
-- Create date: 2016-03-08
-- Description:	Update record in TS_UpdateLastProductDeltaState table if delta found (Trade Services)
-- =============================================
ALTER PROCEDURE [dbo].[spd_TS_UpdateLastProductDeltaState]
	-- Add the parameters for the stored procedure here
	@DayOfMonth INT,
	@DayOffset INT,
	@DeltaCount INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

	-- Insert statements for procedure here
	IF NOT @DayOfMonth BETWEEN 1 AND 31
	BEGIN
		RAISERROR('Invalid parameter { @i } }: acceptable value is 1 to 31.', 16, 1, @DayOfMonth)
		RETURN -1
	END

	IF NOT @DayOffset BETWEEN 1 AND 31
	BEGIN
		RAISERROR('Invalid parameter { @i } }: acceptable value is 1 to 31.', 16, 1, @DayOffset)
		RETURN -1
	END

	-- Declare local variables here
	DECLARE @LastPackageBuildDate smalldatetime

	-- Refresh delta state if it's the first day of the month
	IF DAY(GETDATE())= @DayOfMonth
	BEGIN
		-- Check last package build date, skip if it's just before the first day of the month
		SET @LastPackageBuildDate = (SELECT MAX(UpdateTS)
		                             FROM [DataWarehouse_PIM].[dbo].[TS_LastProductPriceDeltaState])
		IF DAY(DATEADD(day, @DayOffset, @LastPackageBuildDate)) = 1
		BEGIN
			PRINT 'Skipped due to the fact the last package build date is just before the first day of the month (Price Change).'
			RETURN 0
		END

		SET @LastPackageBuildDate = (SELECT MAX(UpdateTS)
		                             FROM [DataWarehouse_PIM].[dbo].[TS_LastProductCertificationDeltaState])
		IF DAY(DATEADD(day, 1, @LastPackageBuildDate)) = 1
		BEGIN
			PRINT 'Skipped due to the fact the last package build date is just before the first day of the month (Certification Change).'
			RETURN 0
		END

		-- Refresh TS_LastProductPriceDeltaState table
		TRUNCATE TABLE [DataWarehouse_PIM].[dbo].[TS_LastProductPriceDeltaState]

		INSERT INTO [DataWarehouse_PIM].[dbo].[TS_LastProductPriceDeltaState]
		SELECT ProductCompanyID
		,	CompanyCode
		,	CurrentListPrice
		,	CurrentListPriceEffectiveDate
		,	CURRENT_TIMESTAMP AS CreateTS
		,	NULL AS UpdateTS
		FROM [DataWarehouse_PIM].[dbo].[ProductCompanyView]
		WHERE CompanyCode IN ('01', '02', '03', '16')

		SET @DeltaCount += @@ROWCOUNT

		-- Refresh TS_LastProductCertificationDeltaState table
		TRUNCATE TABLE [DataWarehouse_PIM].[dbo].[TS_LastProductCertificationDeltaState]

		INSERT INTO [DataWarehouse_PIM].[dbo].[TS_LastProductCertificationDeltaState]
		SELECT prs.ProductID
		,	prc.CompanyCode
		,	STUFF((SELECT DISTINCT ';' + [Standard]
				   FROM ProductSourceCertificationView x 
				       INNER JOIN ProductSourceView y 
					       ON x.ProductSourceID = y.ProductSourceID
				   WHERE x.CertificationLinkType = 'CertifiedStandard' 
				   AND y.ProductID = prs.ProductID 
				   ORDER BY ';' + [Standard] FOR xml path('')), 1, 1, '') CertifiedStandard
		,	CURRENT_TIMESTAMP AS CreateTS
		,	NULL AS ModifiedTS
		FROM [DataWarehouse_PIM].[dbo].[ProductSourceCertificationView] scv
			INNER JOIN ProductSourceView prs 
				ON prs.ProductSourceID = scv.ProductSourceID
			LEFT JOIN [DataWarehouse_PIM].[dbo].[ProductCompanyView] prc 
				ON prc.ProductID = prs.ProductID
		WHERE prc.CompanyCode IN ('01', '02', '03', '16')
		AND scv.CertificationLinkType = 'CertifiedStandard' 
		AND prs.ProductID <> '0'
		GROUP BY prs.ProductID
		,	prc.CompanyCode

		SET @DeltaCount += @@ROWCOUNT
	END ELSE
	BEGIN
		-- Update existing product if product price change found
		UPDATE [DataWarehouse_PIM].[dbo].[TS_LastProductPriceDeltaState] 
		SET CompanyCode = CurrentDeltaState.CompanyCode
		,	CurrentListPrice = CurrentDeltaState.CurrentListPrice
		,	CurrentListPriceEffectiveDate = CurrentDeltaState.CurrentListPriceEffectiveDate
		,	UpdateTS = CURRENT_TIMESTAMP
		FROM [DataWarehouse_PIM].[dbo].[ProductCompanyView] CurrentDeltaState
			INNER JOIN [DataWarehouse_PIM].[dbo].[TS_LastProductPriceDeltaState] PreviousDeltaState
				ON CurrentDeltaState.ProductCompanyID = PreviousDeltaState.ProductCompanyID
				AND (CurrentDeltaState.CurrentListPrice <> PreviousDeltaState.CurrentListPrice
				OR CurrentDeltaState.CurrentListPriceEffectiveDate <> PreviousDeltaState.CurrentListPriceEffectiveDate)
		WHERE CurrentDeltaState.CompanyCode IN ('01', '02', '03', '16')

		-- Update existing product if product certification change found
		UPDATE [DataWarehouse_PIM].[dbo].[TS_LastProductCertificationDeltaState]
		SET ProductID = prs.ProductID
		,	CompanyCode = prc.CompanyCode
		,	CertifiedStandard = STUFF((SELECT DISTINCT ';' + [Standard]
									   FROM ProductSourceCertificationView x 
									       INNER JOIN ProductSourceView y 
									           ON x.ProductSourceID = y.ProductSourceID
									   WHERE x.CertificationLinkType = 'CertifiedStandard' 
									   AND y.ProductID = prs.ProductID 
									   ORDER BY ';' + [Standard] FOR xml path('')), 1, 1, '')
		,	UpdateTS = CURRENT_TIMESTAMP
		FROM [DataWarehouse_PIM].[dbo].[ProductSourceCertificationView] scv
			INNER JOIN ProductSourceView prs 
		        ON prs.ProductSourceID = scv.ProductSourceID
			LEFT JOIN [DataWarehouse_PIM].[dbo].[ProductCompanyView] prc 
				ON prc.ProductID = prs.ProductID
			INNER JOIN [DataWarehouse_PIM].[dbo].[TS_LastProductCertificationDeltaState] PreviousDeltaState
				ON prs.ProductID = PreviousDeltaState.ProductID
		WHERE prc.CompanyCode IN ('01', '02', '03', '16')
		AND scv.CertificationLinkType = 'CertifiedStandard' 
		AND prs.ProductID <> '0'
		AND PreviousDeltaState.ProductID IS NULL

		SET @DeltaCount += @@ROWCOUNT
	END
END

























