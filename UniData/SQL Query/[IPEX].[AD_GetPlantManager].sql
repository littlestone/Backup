USE [K2Dev_Content]
GO
/****** Object:  StoredProcedure [IPEX].[AD_GetPlantManager]    Script Date: 2017-03-20 8:24:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Junjie Tang & Eric Gauthier
-- Create date: 2015-08-09
-- Description:	Get plant manager based on given AD name
-- =============================================
ALTER PROCEDURE [IPEX].[AD_GetPlantManager]
	-- Add the parameters for the stored procedure here
	@ad_name VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- initialization
	DECLARE @MAX_LOOP INT = 10, @LOOP_COUNTER INT = 1
	DECLARE @op_mgr_found INT = 0, @role_id int
	DECLARE @manager_ad_name VARCHAR(100)

	-- traverse AD hierarchy until we find an plant manager
	WHILE @op_mgr_found <> 1 AND @LOOP_COUNTER <= @MAX_LOOP
	BEGIN
		  EXECUTE IPEX.AD_GetManager @ad_name, @manager_ad_name OUTPUT

	      --check if the found @manager_ad_name is plant manager
	      IF EXISTS( 
	          SELECT TOP 1 * 
	          FROM IPEX.Role_names a
	          WHERE a.ad_name = @manager_ad_name 
			  AND a.role_id = 10 -- Plant Manager
	      )
	      BEGIN 
	        SET @role_id = 10 -- Plant Manager
	        SET @op_mgr_found = 1
			SELECT @manager_ad_name as ManagerADName, @role_id as RoleID
			BREAK
	      END
	
	      IF @op_mgr_found <> 1
	      BEGIN
			SET @ad_name = @manager_ad_name
			SET @role_id = 0
			SET @LOOP_COUNTER = @LOOP_COUNTER + 1
	      END
	END
END

