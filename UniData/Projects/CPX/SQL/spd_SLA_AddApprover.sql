USE [SLA]
GO

/****** Object:  StoredProcedure [dbo].[spd_SLA_AddApprover]    Script Date: 2017-08-15 2:15:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO














-- =============================================
-- Author:		Junjie Tang
-- Create date: 2017-05-17
-- Description:	Generic SLA Approval Process - Add Additional Approver(s)
-- =============================================
ALTER PROCEDURE [dbo].[spd_SLA_AddApprover]
	-- Add the parameters for the stored procedure here
	@RequestId AS NVARCHAR(50) = '',
	@Approvers AS NVARCHAR(MAX) = '',
	@ModifiedBy AS NVARCHAR(50) = '',
	@LevelNumber AS INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- initialization
	DECLARE @sla_index AS INT = 0
	DECLARE @sla_level_index AS INT = 0
	DECLARE @sla_level AS INT = 0
	DECLARE @rework_index AS INT = 0
	DECLARE @request_id AS INT = CAST(RTRIM(@RequestId) AS INT)
	DECLARE @approver AS NVARCHAR(50) = ''
	DECLARE @approver_email AS NVARCHAR(50) = ''
	DECLARE @approver_first_name AS NVARCHAR(50) = ''
	DECLARE @approver_last_name AS NVARCHAR(50) = ''
	DECLARE @approver_title AS NVARCHAR(50) = ''

	-- temporty table
	DECLARE @AdditionalApprovers TABLE
	(
		TableID INT IDENTITY(1,1) PRIMARY KEY,
		UserId VARCHAR(100)
	)

	-- validate parameter
	IF RTRIM(@RequestId) = '' OR NOT EXISTS
	(
		SELECT *
		FROM [CPX].[AFE].[AFE] AFE
		WHERE AFE.id = @request_id
	)
	BEGIN
		RAISERROR('Invalid parameter @RequestId {%s} found.', 16, 1, @RequestId)
		RETURN -1
	END
	IF @Approvers = ''
	BEGIN
		RAISERROR('Invalid parameter @Approvers {%s} found.', 16, 1, @Approvers)
		RETURN -1
	END
	IF @LevelNumber NOT IN (1, 2, 3)
	BEGIN
		RAISERROR('Invalid parameter @LevelNumber {%s} found.', 16, 1, @LevelNumber)
		RETURN -1
	END

	-- get current key info
	SELECT @sla_index = SlaIndex
	,	@sla_level_index = SlaLevelIndex
	,	@sla_level = SlaLevel
	,	@rework_index = ReworkIndex
	FROM 
	(
		SELECT TOP 1 *
		FROM [SLA].[dbo].[ApprovalWorkflow] ApprovalWorkflow
		WHERE ApprovalWorkflow.RequestId = @request_id
		AND (ApprovalWorkflow.StatusCode IS NULL OR ApprovalWorkflow.StatusCode = '1')
		ORDER BY ApprovalWorkflow.SlaIndex
		,	ApprovalWorkflow.SlaLevel
	) CurrentSla

	-- set next SLA level
	IF @LevelNumber = 1 SET @sla_index += 1
	IF @LevelNumber = 2 SET @sla_level_index += 1
	IF @LevelNumber = 3 SET @sla_level += 1

	-- add approver(s) into temporary table
	INSERT INTO @AdditionalApprovers
	SELECT * 
	FROM [dbo].[BreakStringIntoRows](@Approvers)

	-- for each additional approver
	WHILE EXISTS (SELECT * FROM @AdditionalApprovers)
	BEGIN
		-- retrieve each approver's AD userid
		SELECT TOP 1 @approver = UserId
		FROM @AdditionalApprovers
		ORDER BY TableID ASC

		-- bypass if the approver userid already exists
		SELECT *
		FROM [SLA].[dbo].[ApprovalWorkflow]
		WHERE RequestId = @request_id
		AND SlaIndex = @sla_index
		AND (StatusCode IS NULL OR StatusCode = '1')
		AND UserId = @approver

		IF @@ROWCOUNT = 0
		BEGIN
			-- retrieve each approver's AD user email
			SELECT @approver_email = Users.Email
			,	@approver_first_name = Users.FirstName
			,	@approver_last_name = Users.LastName
			,	@approver_title = Users.Title
			FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
			WHERE Users.Active = 1
			AND Users.InActiveDirectory = 1 
			--ND Users.IsEmployeeAccount = 1
			AND @approver = Users.DomainName + '\' + Users.UserName

			-- add the approver to current SLA level
			INSERT INTO [SLA].[dbo].[ApprovalWorkflow] VALUES(@request_id, @sla_index, @rework_index, @sla_level_index, @sla_level, @approver, @approver_first_name, @approver_last_name, @approver_title, @approver_title, @approver_email, NULL, NULL, NULL, NULL, @ModifiedBy, GETDATE(), 1)
		END

		-- clean up
		DELETE @AdditionalApprovers
		WHERE UserId = @approver
	END
END














GO


