USE [SLA]
GO
/****** Object:  StoredProcedure [dbo].[spd_SLA_UpdateState]    Script Date: 2017-08-17 11:50:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













-- =============================================
-- Author:		Junjie Tang
-- Create date: 2017-05-17
-- Description:	Generic SLA Approval Process - Update SLA State
-- =============================================
ALTER PROCEDURE [dbo].[spd_SLA_UpdateState]
	-- Add the parameters for the stored procedure here
	@ApprovalWorkflowId AS INT,
	@ModifiedBy AS NVARCHAR(50),
	@ActionCode AS INT,
	@ReturnMessage AS NVARCHAR(MAX) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @request_id AS INT = 0
	DECLARE @sla_index AS INT = 0
	DECLARE @sla_level_index AS INT = 0
	DECLARE @sla_level AS INT = 0
	DECLARE @rework_index AS INT = 0
	DECLARE @status_name AS NVARCHAR(50)

	-- validate parameter
	BEGIN TRY
		IF @ActionCode IS NOT NULL AND NOT EXISTS
		(
			SELECT *
			FROM [SLA].[dbo].[ApprovalAction]
			WHERE Code = @ActionCode
		)
		BEGIN
			RAISERROR('Invalid parameter @ActionCode { %i } found.', 16, 1, @ActionCode)
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
			FROM [SLA].[dbo].[ApprovalWorkflow]
			WHERE ID = @ApprovalWorkflowId
		)
		BEGIN
			RAISERROR('Invalid parameter @ApprovalWorkflowId { %i } found.', 16, 1, @ApprovalWorkflowId)
			RETURN -1
		END
		IF @ApprovalWorkflowId IS NOT NULL AND NOT EXISTS
		(
			SELECT *
			FROM [SLA].[dbo].[ApprovalWorkflow]
			WHERE ID = @ApprovalWorkflowId
			AND (StatusCode IS NULL OR StatusCode = 1)
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

		--****************************************************
		-- Initilize @ApprovalWorkflow Result Table Variable *
		--****************************************************
		DECLARE @ApprovalWorkflow TABLE
		(
			ID INT,
			RequestId INT,
			ReworkIndex INT,
			SlaIndex INT,
			SlaLevelIndex INT,
			SlaLevel INT,
			UserId NVARCHAR(50),
			FirstName NVARCHAR(50),
			LastName NVARCHAR(50),
			Title NVARCHAR(50),
			[Role] NVARCHAR(50),
			Email NVARCHAR(50),
			OverridenEmail NVARCHAR(50),
			ManagerUserId NVARCHAR(50),
			StatusCode NVARCHAR(5),
			StatusName NVARCHAR(50),
			ModifiedBy NVARCHAR(50),
			ModifiedOn SmallDateTime,
			IsModifedBySlaAdmin Bit
		)

		-- get SLA key info
		SELECT @request_id = RequestId
		,	@sla_index = SlaIndex
		,	@sla_level_index = SlaLevelIndex
		,	@sla_level = SlaLevel
		FROM [SLA].[dbo].[ApprovalWorkflow]
		WHERE ID = @ApprovalWorkflowId

		SELECT @status_name = ApprovalStatus.Name
		FROM [SLA].[dbo].[ApprovalStatus]
		WHERE ApprovalStatus.Code = @ActionCode

		BEGIN TRANSACTION

		-- update approval status
		UPDATE [SLA].[dbo].[ApprovalWorkflow]
		SET StatusCode = @ActionCode
		,	StatusName = @status_name
		,	[ModifiedBy] = @ModifiedBy
		,	[ModifiedOn] = GETDATE()
		WHERE ID = @ApprovalWorkflowId

		-- retrieve next SLA approver(s)
		IF @ActionCode = 2  -- Approve
		BEGIN
			-- first check if there is any next same SLA index level approver(s)
			INSERT INTO @ApprovalWorkflow
			SELECT TOP 1 *
			FROM [SLA].[dbo].[ApprovalWorkflow]
			WHERE RequestId = @request_id
			AND SlaIndex = @sla_index
			AND SlaLevelIndex >= @sla_level_index
			AND (StatusCode IS NULL OR StatusCode = '1')
			ORDER BY SlaIndex
			,	SlaLevelIndex
			,	SlaLevel

			-- else check the next SLA index approver(s)
			IF @@ROWCOUNT = 0
			BEGIN
				-- get next SLA index
				SELECT @sla_index = SlaIndex
				FROM [SLA].[dbo].[ApprovalWorkflow]
				WHERE RequestId = @request_id
				AND SlaIndex IN (
					SELECT TOP 1 SlaIndex
					FROM [SLA].[dbo].[ApprovalWorkflow]
					WHERE RequestId = @request_id
					AND SlaIndex > @sla_index
					ORDER BY SlaIndex
					,	SlaLevelIndex
					,	SlaLevel
				)

				INSERT INTO @ApprovalWorkflow
				SELECT TOP 1 *
				FROM [SLA].[dbo].[ApprovalWorkflow]
				WHERE SlaIndex = @sla_index
				AND (StatusCode IS NULL OR StatusCode = '1')
				ORDER BY SlaIndex
				,	SlaLevelIndex
				,	SlaLevel

				-- return result
				SELECT *
				FROM @ApprovalWorkflow
			END
		END
		ELSE
		BEGIN
			IF @ActionCode = 4  -- Rework
			BEGIN
			    -- get next request SLA rework index
				SELECT @rework_index = CASE WHEN MAX(ReworkIndex) IS NULL 
									       THEN 1
										   ELSE MAX(ReworkIndex) + 1
									   END
				FROM [SLA].[dbo].[ApprovalWorkflow]
				WHERE RequestId = @request_id

			    -- archive
				UPDATE [SLA].[dbo].[ApprovalWorkflow]
				SET ReworkIndex = @rework_index
				WHERE RequestId = @request_id
				AND ReworkIndex IS NULL
			END
		END

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF(@@TRANCOUNT > 0) ROLLBACK TRANSACTION

		SELECT @ReturnMessage = ERROR_MESSAGE()
		RAISERROR (@ReturnMessage, 16, 1)
		RETURN -1
	END CATCH

	-- return result
	SELECT *
	FROM @ApprovalWorkflow

END













