USE [DataWarehouse_PIM]
GO
/****** Object:  StoredProcedure [dbo].[spd_CP_UpdateLastProductDeltaState]    Script Date: 2016-05-02 3:33:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

























-- =============================================
-- Author:		Vianney Rebetez, Junjie Tang
-- Create date: 2016-03-08
-- Description:	Update record in CP_UpdateLastProductDeltaState table if delta found (Customer Standards Product)
-- =============================================
ALTER PROCEDURE [dbo].[spd_CP_UpdateLastProductDeltaState]
	-- Add the parameters for the stored procedure here
	@DayOfMonth INT,
	@DayOffset INT,
	@CompanyCode VARCHAR(2),
	@DeltaCount INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	IF NOT @DayOfMonth BETWEEN 1 AND 31
	BEGIN
		RAISERROR('Invalid parameter { @i } }: acceptable value is 1 to 31.', 16, 1, @DayOfMonth)
		RETURN -1
	END

	IF NOT @DayOffset BETWEEN 0 AND 30
	BEGIN
		RAISERROR('Invalid parameter { @i } }: acceptable value is 1 to 31.', 16, 1, @DayOffset)
		RETURN -1
	END

	IF @CompanyCode NOT IN ('01', '02', '03', '16')
	BEGIN
		RAISERROR('Invalid parameter { %s }: acceptable value are 01, 02, 03 and 16.', 16, 1, @CompanyCode)
		RETURN -1
	END

	-- Declare local variables here
	DECLARE @LastPackageBuildDate smalldatetime

	-- Refresh delta state if it's the first day of the month
	IF DAY(GETDATE()) = @DayOfMonth
	BEGIN
		-- Check last package build date, skip if it's just before the first day of the month
		SET @LastPackageBuildDate = (SELECT MAX(UpdateTS)
									 FROM [DataWarehouse_PIM].[dbo].[CP_LastProductPriceDeltaState])
		IF DAY(DATEADD(day, @DayOffset, @LastPackageBuildDate)) = @DayOfMonth
		BEGIN
			PRINT 'Skipped due to the fact the last package build date is just before the first day of the month.'
			RETURN 0
		END

	    -- Refresh CP_LastProductPriceDeltaState table
		DELETE FROM [DataWarehouse_PIM].[dbo].[CP_LastProductCertificationDeltaState]
		WHERE CompanyCode = @CompanyCode
		
	    -- Insert new product found
		INSERT INTO [DataWarehouse_PIM].[dbo].[CP_LastProductCertificationDeltaState]
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
		WHERE prc.CompanyCode = @CompanyCode
		AND scv.CertificationLinkType = 'CertifiedStandard' 
		AND prs.ProductID <> '0'
		GROUP BY prs.ProductID
		,	prc.CompanyCode

		SET @DeltaCount += @@ROWCOUNT
	END ELSE
	BEGIN
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
		WHERE prc.CompanyCode = @CompanyCode
		AND scv.CertificationLinkType = 'CertifiedStandard' 
		AND prs.ProductID <> '0'
		AND PreviousDeltaState.ProductID IS NULL

		SET @DeltaCount += @@ROWCOUNT
	END
END

























