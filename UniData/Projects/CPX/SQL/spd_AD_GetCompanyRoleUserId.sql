USE [SLA]
GO

/****** Object:  StoredProcedure [dbo].[spd_AD_GetCompanyRoleUserId]    Script Date: 2017-08-15 2:08:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Junjie Tang
-- Create date: 2017-05-17
-- Description:	Get the given company's role userid
-- =============================================
ALTER PROCEDURE [dbo].[spd_AD_GetCompanyRoleUserId]
	-- Add the parameters for the stored procedure here
	@company_id VARCHAR(50),
	@role_id VARCHAR(50),
	@role_ad_name VARCHAR(50) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--**********************
	-- Validate parameters *
	--**********************
	IF @company_id = '' OR UPPER(@company_id) NOT IN ('ALL', '01' ,'02', '03', '05', '12', '15', '16')
	BEGIN
		RAISERROR('Invalid parameter @company_id {%s} found.', 16, 1, @company_id)
		RETURN -1
	END

	IF @role_id = ''
	BEGIN
		RAISERROR('Invalid parameter @role_id {%s} found.', 16, 1, @role_id)
		RETURN -1
	END

	-- Declare local variables
	DECLARE @role_found AS BIT = 0

	-- Resolve the userid for the gvien role id
	SELECT @role_ad_name = Users.userName
	FROM [CPX].[USERS].[UserRole] UserRole
		INNER JOIN [CPX].[USERS].[Users] Users
			ON UserRole.userId = Users.id
		INNER JOIN [CPX].[USERS].[Roles] Roles
			ON Roles.id = UserRole.roleId
	WHERE UserRole.roleId = @role_id
	AND (UPPER(@company_id) = 'ALL' OR CHARINDEX(@company_id, Roles.company) > 0)

	IF @role_ad_name IS NOT NULL AND @role_ad_name <> '' 
	BEGIN 
		SET @role_found = 1
	END
END




GO


