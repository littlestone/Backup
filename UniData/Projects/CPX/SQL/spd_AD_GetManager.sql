USE [SLA]
GO

/****** Object:  StoredProcedure [dbo].[spd_AD_GetManager]    Script Date: 2017-08-15 2:09:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Junjie Tang
-- Create date: 2017-05-17
-- Description:	Get immediate manager based on given AD name
-- =============================================
ALTER PROCEDURE [dbo].[spd_AD_GetManager]
	-- Add the parameters for the stored procedure here
	@ad_name VARCHAR(100),
	@manager_ad_name VARCHAR(100) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @manager_ad_name = Manager.FQN
	FROM SQL11.DataWarehouse.ActiveDirectory.Users Users
		INNER JOIN (SELECT [AccountName]
						  ,[DomainName] + '\' + [UserName] AS FQN
						  ,[DisplayName]
						  ,[Active]
						  ,[InActiveDirectory]
					FROM SQL11.DataWarehouse.ActiveDirectory.Users Users
					WHERE [Active] = 1 AND [InActiveDirectory] = 1 ) as Manager
			ON users.ManagerAccountName = Manager.AccountName
			WHERE Users.[Active] = 1 AND Users.[InActiveDirectory] = 1
			AND DomainName + '\' + UserName = @ad_name
END


GO


