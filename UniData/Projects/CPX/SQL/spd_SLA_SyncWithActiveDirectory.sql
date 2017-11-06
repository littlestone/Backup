USE [SLA]
GO

/****** Object:  StoredProcedure [dbo].[spd_SLA_SyncWithActiveDirectory]    Script Date: 2017-08-15 2:16:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO















-- =============================================
-- Author:		Junjie Tang
-- Create date: 2017-05-17
-- Description:	Generic SLA Approval Process - Synchronize per SLA approver userid with Active Directory
-- =============================================
ALTER PROCEDURE [dbo].[spd_SLA_SyncWithActiveDirectory]
	-- Add the parameters for the stored procedure here
	@ApprovalWorkflowId AS INT,
	@ManagerUserId AS NVARCHAR(50),
	@ModifiedBy AS NVARCHAR(50),
	@ReturnMessage AS NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @request_id AS INT
	DECLARE @sla_index AS INT
	DECLARE @sla_level AS INT
	DECLARE @old_userid AS NVARCHAR(50)

	BEGIN TRY
	    --************************
		-- Validate Parameter(s) *
		--************************
		IF @ManagerUserId IS NOT NULL AND RTRIM(LEFT(@ModifiedBy,4)) <> 'CORP' OR LEN(@ModifiedBy) < 11
		BEGIN
			RAISERROR('Invalid parameter @@ManagerUserId {%s} found.', 16, 1, @ManagerUserId)
			RETURN -1
		END
		IF @ModifiedBy IS NOT NULL AND RTRIM(LEFT(@ModifiedBy,4)) <> 'CORP' OR LEN(@ModifiedBy) < 11
		BEGIN
			RAISERROR('Invalid parameter @ModifiedBy {%s} found.', 16, 1, @ModifiedBy)
			RETURN -1
		END
		IF @ApprovalWorkflowId IS NOT NULL AND NOT EXISTS
		(
			SELECT *
			FROM [SLA].[dbo].[ApprovalWorkflow] ApprovalWorkflow
			WHERE ApprovalWorkflow.ID = @ApprovalWorkflowId
		)
		BEGIN
			RAISERROR('Invalid parameter @ApprovalWorkflowId { %i } found.', 16, 1, @ApprovalWorkflowId)
			RETURN -1
		END
		IF @ApprovalWorkflowId IS NOT NULL AND NOT EXISTS
		(
			SELECT *
			FROM [SLA].[dbo].[ApprovalWorkflow] ApprovalWorkflow
			WHERE ApprovalWorkflow.ID = @ApprovalWorkflowId
			AND (ApprovalWorkflow.StatusCode IS NULL OR ApprovalWorkflow.StatusCode = 1)
		)
		BEGIN
			RAISERROR('The status code for the SLA approval workflow id { %i } must be equal to 1 (i.e. Waiting for approval).', 16, 1, @ApprovalWorkflowId)
			RETURN -1
		END
		--IF @ActionCode <> 1 AND @ApprovalWorkflowId IS NOT NULL AND NOT EXISTS 
		--(
		--	SELECT *
		--	FROM [SLA].[dbo].[ApprovalWorkflow] ApprovalWorkflow
		--	WHERE ApprovalWorkflow.ID = @ApprovalWorkflowId
		--	AND ApprovalWorkflow.StatusCode = 1
		--	AND ApprovalWorkflow.UserId = @ModifiedBy
		--)
		--BEGIN
		--	RAISERROR('Access denied.', 16, 1, @ApprovalWorkflowId)
		--	RETURN -1
		--END

		-- get SLA key info
		SELECT @request_id = ApprovalWorkflow.RequestId
		,	@sla_index = ApprovalWorkflow.SlaIndex
		,	@sla_level = ApprovalWorkflow.SlaLevel
		,	@old_userid = ApprovalWorkflow.UserId
		FROM [SLA].[dbo].[ApprovalWorkflow] ApprovalWorkflow
		WHERE ApprovalWorkflow.ID = @ApprovalWorkflowId

		BEGIN TRANSACTION

		-- update current SLA approver's direct manager's userid
		UPDATE [SLA].[dbo].[ApprovalWorkflow]
		SET [ManagerUserId] = @ManagerUserId
		,	[ModifiedBy] = @ModifiedBy
		,	[ModifiedOn] = GETDATE()
		WHERE ID = @ApprovalWorkflowId

		-- update the userid of the above direct manager's SLA record
		UPDATE [SLA].[dbo].[ApprovalWorkflow]
		SET [UserId] = @ManagerUserId
		,	[ModifiedBy] = @ModifiedBy
		,	[ModifiedOn] = GETDATE()
		WHERE RequestId = @request_id
		AND SlaIndex = @sla_index
		AND [UserId] = @old_userid

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF(@@TRANCOUNT > 0) ROLLBACK TRANSACTION

		SELECT @ReturnMessage = ERROR_MESSAGE()
		RAISERROR (@ReturnMessage, 16, 1)
		RETURN -1
	END CATCH

END















GO


