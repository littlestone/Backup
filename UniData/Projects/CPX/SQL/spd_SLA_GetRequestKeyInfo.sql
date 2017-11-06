USE [SLA]
GO

/****** Object:  StoredProcedure [dbo].[spd_SLA_GetRequestKeyInfo]    Script Date: 2017-08-15 2:16:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		Junjie Tang
-- Create date: 2017-05-17
-- Description:	Get AFE Key Information
-- =============================================
ALTER PROCEDURE [dbo].[spd_SLA_GetRequestKeyInfo]
	-- Add the parameters for the stored procedure here
	@RequestId AS NVARCHAR(50) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- initialization
	DECLARE @request_id AS INT = CAST(RTRIM(@RequestId) AS INT)

	-- validate parameter
	IF RTRIM(@RequestId) = '' OR NOT EXISTS
	(
		SELECT *
		FROM [CPX].[AFE].[AFE] AFE
		WHERE AFE.id = @request_id
	)
	BEGIN
		RAISERROR('Invalid parameter @RequestId { %s } found.', 16, 1, @RequestId)
		RETURN -1
	END

	-- return result
    SELECT AFE.ID 
	,	AfeNumber = AFE.ID
	,	AfeTitle = AFE.title
	,	AfeRequestor = AFE.createdBy
	,	AfeRequestorFirstName = (
									SELECT Users.FirstName
									FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
									WHERE Users.Active = 1
									AND Users.InActiveDirectory = 1 
									--AND Users.IsEmployeeAccount = 1
									AND AFE.createdBy = Users.DomainName + '\' + Users.UserName
								)
	,	AfeRequestorLastName = (
									SELECT Users.LastName
									FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
									WHERE Users.Active = 1
									AND Users.InActiveDirectory = 1 
									--AND Users.IsEmployeeAccount = 1
									AND AFE.createdBy = Users.DomainName + '\' + Users.UserName
								)							
	,	AfeOwner = AFE.owner
	,	AfeOwnerFirstName = (
								SELECT Users.FirstName
								FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
								WHERE Users.Active = 1
								AND Users.InActiveDirectory = 1 
								--AND Users.IsEmployeeAccount = 1
								AND AFE.owner = Users.DomainName + '\' + Users.UserName
							)
	,	AfeOwnerLastName = (
								SELECT Users.LastName
								FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
								WHERE Users.Active = 1
								AND Users.InActiveDirectory = 1 
								--AND Users.IsEmployeeAccount = 1
								AND AFE.owner = Users.DomainName + '\' + Users.UserName
							)
	,	Project.ProjectNumber
	,	ProjectTitle = Project.description
	,   ProjectOwner = Project.owner
	,	ProjectOwnerFirstName = (
									SELECT Users.FirstName
									FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
									WHERE Users.Active = 1
									AND Users.InActiveDirectory = 1 
									--AND Users.IsEmployeeAccount = 1
									AND Project.owner = Users.DomainName + '\' + Users.UserName
								)
	,	ProjectOwnerLastName = (
									SELECT Users.LastName
									FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
									WHERE Users.Active = 1
									AND Users.InActiveDirectory = 1 
									--AND Users.IsEmployeeAccount = 1
									AND Project.owner = Users.DomainName + '\' + Users.UserName
								)
	,	AFE.AfeAmount
	,	CompanyCode = Company.company_no
	,	CompanyName = Company.description
	,	CompanyLogoColor = CASE 
						      WHEN Company.company_no = '16' THEN '#6FBF44'
							  ELSE 'blue'
						  END
	FROM [CPX].[AFE].[AFE] AFE
		LEFT JOIN [CPX].[PRJ].[Project] Project
			ON Project.id = AFE.projectId
		LEFT JOIN [CPX].[REF].[Company_all] Company
			ON Company.id = AFE.companyId
	WHERE AFE.id = @request_id

END







GO


