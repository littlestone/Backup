USE [SLA]
GO

/****** Object:  StoredProcedure [dbo].[spd_AD_GetRoleUserId]    Script Date: 2017-08-15 2:10:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Junjie Tang
-- Create date: 2017-05-17
-- Description:	Get the given role's AD name for the given userid 
-- =============================================
ALTER PROCEDURE [dbo].[spd_AD_GetRoleUserId]
	-- Add the parameters for the stored procedure here
	@userid VARCHAR(50),
	@roleid VARCHAR(50),
	@role_ad_name VARCHAR(50) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Declare local variables
	DECLARE @MAX_LOOP AS INT = 10, @LOOP_COUNTER AS INT = 1
	DECLARE @role_found AS BIT = 0
	DECLARE @originator AS VARCHAR(50) = @userid
	DECLARE @next_level_approver AS VARCHAR(50) = ''

	WHILE @role_found <> 1 AND @LOOP_COUNTER <= @MAX_LOOP
	BEGIN

		-- get next level approver (i.e. manager's userid)
		EXECUTE [dbo].[spd_AD_GetManager] @originator, @next_level_approver OUTPUT

		---- check if there is a next level approver
		IF @next_level_approver = '' OR @next_level_approver = @userid
		BEGIN
			SET @role_ad_name = ''
			SET @LOOP_COUNTER = @MAX_LOOP + 1
			BREAK
		END
		ELSE
		BEGIN
		   SET @role_ad_name = @next_level_approver
		END

		-- check if next level approver's role id matches the given role id
		SELECT @role_ad_name = Users.userName
		FROM [CPX].[USERS].[UserRole] UserRole
			INNER JOIN [CPX].[USERS].[Users] Users
				ON UserRole.userId = Users.id
		WHERE UserRole.roleId = @roleid

		IF @role_ad_name IS NOT NULL AND @role_ad_name <> '' 
		BEGIN 
			SET @role_found = 1
			BREAK
		END
		ELSE
		BEGIN
			SET @role_ad_name = @next_level_approver			
		    SET @LOOP_COUNTER += 1
		END
	END
END




GO


