USE [SLA]
GO

/****** Object:  StoredProcedure [dbo].[spd_SLA_GetState]    Script Date: 2017-08-15 2:16:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		Junjie Tang
-- Create date: 2017-05-17
-- Description:	Generic SLA Approval Process - Get SLA State
-- =============================================
ALTER PROCEDURE [dbo].[spd_SLA_GetState]
	-- Add the parameters for the stored procedure here
	@ID AS INT = NULL,
	@RequestId AS NVARCHAR(50) = '',
	@OptionCode AS int = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- initialization
	DECLARE @request_id AS INT = CAST(RTRIM(@RequestId) AS INT)
	DECLARE @sla_index AS INT = 0
	DECLARE @sla_level_index AS INT = 0
	DECLARE @sla_level AS INT = 0

	-- validate parameter
	IF @ID IS NULL AND (RTRIM(@RequestId) = '' OR NOT EXISTS
	(
		SELECT *
		FROM [CPX].[AFE].[AFE] AFE
		WHERE AFE.id = @request_id
	))
	BEGIN
		RAISERROR('Invalid parameter @RequestId { %s } found.', 16, 1, @RequestId)
		RETURN -1
	END

	IF @OptionCode NOT IN (-1, 0, 1)
	BEGIN
		RAISERROR('Invalid parameter @OptionCode { %s } found.', 16, 1, @OptionCode)
		RETURN -1
	END

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
		ModifiedOn DateTime,
		IsModifedBySlaAdmin Bit
	)

    -- Insert statements for procedure here
	IF @ID IS NOT NULL
	BEGIN
		-- return specific SLA states
		SELECT *
		FROM [SLA].[dbo].[ApprovalWorkflow]
		WHERE ID = @ID
	END
	ELSE
	BEGIN
		-- return all SLA states
	    IF @OptionCode IS NULL
		BEGIN 
			SELECT *
			FROM [SLA].[dbo].[ApprovalWorkflow]
			WHERE RequestId = @request_id
			ORDER BY SlaIndex
			,	SlaLevelIndex
			,	SlaLevel
		END
		
		-- return current SLA state
		IF @OptionCode = 0
		BEGIN
			SELECT *
			FROM [SLA].[dbo].[ApprovalWorkflow]
			WHERE RequestId = @request_id
			AND StatusCode = '1'
			ORDER BY SlaIndex
			,	SlaLevelIndex
			,	SlaLevel
		END
		
		-- return prevous SLA state(s)
		IF @OptionCode = -1
		BEGIN
			-- get SLA rework historical state(s)
			INSERT @ApprovalWorkflow
			SELECT *
			FROM [SLA].[dbo].[ApprovalWorkflow]
			WHERE RequestId = @request_id
			AND StatusCode IS NOT NULL
			AND StatusCode <> '1'
			AND ReworkIndex IS NOT NULL

			-- get current historical state(s)
			INSERT @ApprovalWorkflow
			SELECT *
			FROM [SLA].[dbo].[ApprovalWorkflow]
			WHERE RequestId = @request_id
			AND StatusCode IS NOT NULL
			AND StatusCode <> '1'
			AND ReworkIndex IS NULL

			-- return result
			SELECT *
			FROM @ApprovalWorkflow
			ORDER BY ID
			DESC
		END

		-- return next SLA state(s)
		IF @OptionCode = 1
		BEGIN
			-- get current SLA key info
			SELECT @sla_index = CurrentSla.SlaIndex
			,	@sla_level_index = CurrentSla.SlaLevelIndex
			FROM 
			(
				SELECT TOP 1 *
				FROM [SLA].[dbo].[ApprovalWorkflow]
				WHERE RequestId = @request_id
				AND (StatusCode IS NULL OR StatusCode = '1')
				AND ReworkIndex IS NULL
			) CurrentSla

			-- check if next same SLA index level is available
			INSERT @ApprovalWorkflow
			SELECT TOP 1 *
			FROM [SLA].[dbo].[ApprovalWorkflow]
			WHERE RequestId = @request_id
			AND SlaIndex = @sla_index
			AND SlaLevelIndex >= @sla_level_index
			AND StatusCode = '1'
			AND ReworkIndex IS NULL
			ORDER BY SlaIndex
			,	SlaLevelIndex
			,	SlaLevel

			-- else return next SLA index
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
					AND ReworkIndex IS NULL
					ORDER BY SlaIndex
					,	SlaLevelIndex
					,	SlaLevel
				)

				-- check last SLA index
				IF @sla_index <> ''
				BEGIN
					INSERT @ApprovalWorkflow
					SELECT TOP 1 *
					FROM [SLA].[dbo].[ApprovalWorkflow]
					WHERE RequestId = @request_id
					AND SlaIndex = @sla_index
					AND (StatusCode IS NULL OR StatusCode = '1')
					AND ReworkIndex IS NULL
				END
			END
		
			-- return result
			SELECT *
			FROM @ApprovalWorkflow
		END
	END
END







GO


