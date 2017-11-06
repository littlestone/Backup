USE [SLA]
GO

/****** Object:  StoredProcedure [dbo].[spd_SLA_Initialize]    Script Date: 2017-08-17 11:50:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO















-- =============================================
-- Author:		Junjie Tang
-- Create date: 2017-05-17
-- Description:	Generic SLA Approval Process - STEP Initialize
-- =============================================
ALTER PROCEDURE [dbo].[spd_SLA_Initialize]
	-- Add the parameters for the stored procedure here
	@RequestId AS NVARCHAR(50) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--*****************
	-- Initialization *
	--*****************
	DECLARE @MAX_LOOP AS INT = 10, @LOOP_COUNTER AS INT = 0, @CNT AS INT = 0
	DECLARE @role_found AS INT = 0, @role_id AS INT = 0
	DECLARE @sla_index AS INT = 0
	DECLARE @sla_level_index AS INT = 0, @sla_level AS INT = 0
	DECLARE @last_sla_id AS INT = 0
	DECLARE @last_sla_status_code AS INT = 0
	DECLARE @request_id AS INT = CAST(RTRIM(@RequestId) AS INT)
	DECLARE @afe_department_id AS INT
	DECLARE @afe_location_id AS INT
	DECLARE @originator AS NVARCHAR(50) = ''
	DECLARE @requestor AS NVARCHAR(50) = ''
	DECLARE @afe_owner AS NVARCHAR(50) = ''
	DECLARE @project_owner AS NVARCHAR(50) = ''
	DECLARE @department_manager AS NVARCHAR(50) = ''
	DECLARE @immediate_manager AS NVARCHAR(50) = ''
	DECLARE @next_level_approver NVARCHAR(50) = ''
	DECLARE @role_name AS NVARCHAR(50) = ''
	DECLARE @role_ad_name NVARCHAR(50) = ''
	DECLARE @approver AS NVARCHAR(50) = ''
	DECLARE @approver_first_name AS NVARCHAR(50) = ''
	DECLARE @approver_last_name AS NVARCHAR(50) = ''
	DECLARE @approver_title AS NVARCHAR(50) = ''
	DECLARE @approver_email AS NVARCHAR(50) = ''
	DECLARE @company_no AS NVARCHAR(50) = ''
	DECLARE @is_stagegate AS BIT = 0
	DECLARE @is_us_company AS BIT = 0
	DECLARE @is_executives AS BIT = 0
	DECLARE @afe_category_id AS INT = 0
	DECLARE @afe_aliaxis_type_id AS INT = 0
	DECLARE @afe_amount AS NUMERIC = 0.0

	-- Debug
	--TRUNCATE TABLE [SLA].[dbo].[ApprovalWorkflowHistory]
	--TRUNCATE TABLE [SLA].[dbo].[ApprovalWorkflow]
	DECLARE @overriden_email AS NVARCHAR(50) = 'juntan@ipexna.com'

	--**********************
	-- Validate parameters *
	--**********************
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

	--*******************
	-- Get AFE key info *
	--*******************
	SELECT @requestor = AFE.createdBy
	,	@afe_owner = AFE.owner
	,   @project_owner = Project.owner
	,   @is_stagegate = AFE.stageGate
	,   @afe_category_id = Project.categoryId
	,	@afe_department_id = AFE.departmentId
	,	@afe_aliaxis_type_id = AliaxisType.Id
	,	@afe_location_id = AFE.locationId
	,	@afe_amount = AFE.afeAmount
	,	@company_no = company_no
	,	@is_us_company = Company.us
	FROM [CPX].[AFE].[AFE] AFE
		LEFT JOIN [CPX].[PRJ].[Project] Project
			ON Project.id = AFE.projectId
		LEFT JOIN [CPX].[REF].[Company_all] Company
			ON Company.id = AFE.companyId
		LEFT JOIN [CPX].[REF].[Aliaxis_type] AliaxisType
			ON AFE.aliaxisTypeId = AliaxisType.Id
	WHERE AFE.id = @request_id

	--****************************************************
	-- Initilize @ApprovalWorkflow Result Table Variable *
	--****************************************************
	DECLARE @ApprovalWorkflow TABLE
	(
		ID INT IDENTITY(1,1),
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
		ManagerUserId NVARCHAR(50),  -- NULL = AD N/A, Empty Value = AD terminated role, Else = approver's manager in AD
		StatusCode NVARCHAR(5),
		StatusName NVARCHAR(50),
		ModifiedBy NVARCHAR(50),
		ModifiedOn SmallDateTime,
		IsModifedBySlaAdmin Bit
	)

	--************
	-- Archiving *
	--************
	-- get most recent completed SLA workflow id
	SELECT @last_sla_id = MAX(ID)
	FROM [SLA].[dbo].[ApprovalWorkflow]
	WHERE RequestId = @request_id
	AND StatusCode IS NOT NULL
	AND ReworkIndex IS NOT NULL

	-- get most recent completed SLA workflow status
	SELECT @last_sla_status_code = StatusCode
	FROM [SLA].[dbo].[ApprovalWorkflow]
	WHERE ID = @last_sla_id
	AND RequestId = @request_id

	-- archive if it was either approved or rejected
	IF @last_sla_status_code <> 3
	BEGIN
	    INSERT [SLA].[dbo].[ApprovalWorkflowHistory]
		SELECT RequestId
		,	ReworkIndex
		,	SlaIndex
		,	SlaLevelIndex
		,	SlaLevel
		,	UserId
		,   FirstName
		,	LastName
		,	Title
		,	[Role]
		,	Email
		,	OverridenEmail
		,	ManagerUserId
		,	StatusCode
		,	StatusName
		,	ModifiedBy
		,	ModifiedOn
		,	IsModifedBySlaAdmin
		FROM [SLA].[dbo].[ApprovalWorkflow]
		WHERE RequestId = @request_id

		-- clean up
		DELETE [SLA].[dbo].[ApprovalWorkflow]
		WHERE RequestId = @request_id
	END

	IF @requestor <> @afe_owner
	BEGIN
		--******************************************************************************
		-- AFE SLA Approval Workflow Step #1: Request approval of Originator’s manager *
		--******************************************************************************

		-- get Requestor's immediate manager userid
		EXECUTE [dbo].[spd_AD_GetManager] @requestor, @next_level_approver OUTPUT
		IF @next_level_approver <> ''
			BEGIN
			-- increase SLA index and initialize SLA level
			SET @sla_index += 1
			SET @sla_level_index = 1
			SET @sla_level = 10

			-- set role name
			SET @role_name = 'Requestor''s Manager'

			-- retrieve each approver's AD user email
			SELECT @approver_email = Users.Email
			,	@approver_first_name = Users.FirstName
			,	@approver_last_name = Users.LastName
			,	@approver_title = Users.Title
			FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
			WHERE Users.Active = 1
			AND Users.InActiveDirectory = 1 
			--AND Users.IsEmployeeAccount = 1
			AND @next_level_approver = Users.DomainName + '\' + Users.UserName

			-- create SLA approval record
			INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, NULL, NULL, NULL, NULL, NULL, 0)
			SET @next_level_approver = ''
		END

		--*******************************************************************
		-- AFE SLA Approval Workflow Step #2: Request approval of AFE Owner *
		--*******************************************************************

		-- increase SLA index and initialize SLA level
		SET @sla_index += 1
		SET @sla_level_index = 1	
		SET @sla_level = 10

		-- set role name
		SET @role_name = 'AFE Owner'

		-- retrieve each approver's AD user email
		SELECT @approver_email = Users.Email
		,	@approver_first_name = Users.FirstName
		,	@approver_last_name = Users.LastName
		,	@approver_title = Users.Title
		FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
		WHERE Users.Active = 1
		AND Users.InActiveDirectory = 1 
		--AND Users.IsEmployeeAccount = 1
		AND @afe_owner = Users.DomainName + '\' + Users.UserName

		-- create SLA approval record
		INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @afe_owner, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, NULL, NULL, NULL, NULL, NULL, 0)
		-- do not reset @next_level_approver since we will use the value which should be the AFE Owner's userid to retrieve AFE Owner's manager userid in the next step

		-- get AFE Owner's immediate manager userid
		EXECUTE [dbo].[spd_AD_GetManager] @afe_owner, @next_level_approver OUTPUT
		IF @next_level_approver <> ''
			BEGIN
			-- increase SLA index and initialize SLA level
			SET @sla_index += 1
			SET @sla_level_index = 1	
			SET @sla_level = 10

			-- set role name
			SET @role_name = 'AFE Owner''s Manager'

			-- retrieve each approver's AD user email
			SELECT @approver_email = Users.Email
			,	@approver_first_name = Users.FirstName
			,	@approver_last_name = Users.LastName
			,	@approver_title = Users.Title
			FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
			WHERE Users.Active = 1
			AND Users.InActiveDirectory = 1 
			--AND Users.IsEmployeeAccount = 1
			AND @next_level_approver = Users.DomainName + '\' + Users.UserName

			-- create SLA approval record
			INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, NULL, NULL, NULL, NULL, NULL, 0)
			SET @next_level_approver = ''
		END
	END
	
	--*****************************************************************************
	-- AFE SLA Approval Workflow Step #3: Request approval of AFE Owner’s manager *
	--*****************************************************************************
	IF @afe_owner <> @project_owner
	BEGIN
		-- get AFE Owner's immediate manager userid
		EXECUTE [dbo].[spd_AD_GetManager] @next_level_approver, @next_level_approver OUTPUT
		SET @next_level_approver = ''

		IF @next_level_approver <> ''
			BEGIN
			-- increase SLA index and initialize SLA level
			SET @sla_index += 1
			SET @sla_level_index = 1	
			SET @sla_level = 10

			-- set role name
			SET @role_name = 'AFE Owner''s Manager'

			-- retrieve each approver's AD user email
			SELECT @approver_email = Users.Email
			,	@approver_first_name = Users.FirstName
			,	@approver_last_name = Users.LastName
			,	@approver_title = Users.Title
			FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
			WHERE Users.Active = 1
			AND Users.InActiveDirectory = 1 
			--AND Users.IsEmployeeAccount = 1
			AND @next_level_approver = Users.DomainName + '\' + Users.UserName

			-- create SLA approval record
			INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, NULL, NULL, NULL, NULL, NULL, 0)
			SET @next_level_approver = ''
		END
	END

	--*****************************************************************
	-- AFE SLA Approval Workflow Step #4: Request approval of Finance *
	--*****************************************************************
	IF @afe_department_id = 2  -- 052 - Distribution
	BEGIN
	    -- get role AD userid & name
		SET @role_id = 7  -- Finance Distribution
		SELECT @next_level_approver = Users.userName
		,	@role_name = Roles.description
		FROM [CPX].[USERS].[UserRole] UserRole
			INNER JOIN [CPX].[USERS].[Users] Users
				ON UserRole.userId = Users.id
			INNER JOIN [CPX].[USERS].[Roles] Roles
				ON Roles.id = UserRole.roleId
		WHERE UserRole.roleId = @role_id
	END
	ELSE
	BEGIN
		IF @afe_department_id = 23  -- 408 -  M.I.S.
		BEGIN
			-- get role AD userid & name
			SET @role_id = 6  -- Finance IT
			SELECT @next_level_approver = Users.userName
			,	@role_name = Roles.description
			FROM [CPX].[USERS].[UserRole] UserRole
				INNER JOIN [CPX].[USERS].[Users] Users
					ON UserRole.userId = Users.id
				INNER JOIN [CPX].[USERS].[Roles] Roles
					ON Roles.id = UserRole.roleId
			WHERE UserRole.roleId = @role_id
		END
		ELSE  -- request approval from Finace1
		BEGIN
			-- get AD role userid & name
			SET @role_id = 5  -- Finance2
			SELECT @next_level_approver = Users.userName
			,	@role_name = Roles.description
			FROM [CPX].[USERS].[UserRole] UserRole
				INNER JOIN [CPX].[USERS].[Users] Users
					ON UserRole.userId = Users.id
				INNER JOIN [CPX].[USERS].[Roles] Roles
					ON Roles.id = UserRole.roleId
			WHERE UserRole.roleId = @role_id
		END
	END

	IF @next_level_approver <> ''
	BEGIN
		-- increase SLA index and initialize SLA level
		SET @sla_index += 1
		SET @sla_level_index = 1	
		SET @sla_level = 10

		-- retrieve each approver's AD user email
		SELECT @approver_email = Users.Email
		,	@approver_first_name = Users.FirstName
		,	@approver_last_name = Users.LastName
		,	@approver_title = Users.Title
		FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
		WHERE Users.Active = 1
		AND Users.InActiveDirectory = 1 
		--AND Users.IsEmployeeAccount = 1
		AND @next_level_approver = Users.DomainName + '\' + Users.UserName

		-- create SLA approval record
		INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, NULL, NULL, NULL, NULL, NULL, 0)
		SET @next_level_approver = ''
	END

	--******************************************************************************
	--* AFE SLA Approval Workflow Process: STEP #5 - Request approval of SLA Admin *
	--******************************************************************************

	-- get AD role userid & name
	SET @role_id = 13  -- SLA Admin
	SELECT @next_level_approver = Users.userName
	,	@role_name = Roles.description
	FROM [CPX].[USERS].[UserRole] UserRole
		INNER JOIN [CPX].[USERS].[Users] Users
			ON UserRole.userId = Users.id
		INNER JOIN [CPX].[USERS].[Roles] Roles
			ON Roles.id = UserRole.roleId
	WHERE UserRole.roleId = @role_id

	IF @next_level_approver <> ''
	BEGIN
		-- increase SLA index and initialize SLA level
		SET @sla_index += 1
		SET @sla_level_index = 1	
		SET @sla_level = 10

		-- retrieve each approver's AD user email
		SELECT @approver_email = Users.Email
		,	@approver_first_name = Users.FirstName
		,	@approver_last_name = Users.LastName
		,	@approver_title = Users.Title
		FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
		WHERE Users.Active = 1
		AND Users.InActiveDirectory = 1 
		--AND Users.IsEmployeeAccount = 1
		AND @next_level_approver = Users.DomainName + '\' + Users.UserName

		-- create SLA approval record
		INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, NULL, NULL, NULL, NULL, NULL, 0)
		SET @next_level_approver = ''
	END

	--***************************************************************************************
	--* AFE SLA Approval Workflow Process: STEP #6 - Request approval of Department Manager *
	--***************************************************************************************

	SELECT @next_level_approver = ManagerUserId
	FROM [CPX].[REF].[DepartmentWarehouseManagerByCompanies]
	WHERE DepartmentId = @afe_department_id
	AND LocationId = @afe_location_id

	-- increase SLA index and initialize SLA level
	SET @sla_index += 1
	SET @sla_level_index = 1
	SET @sla_level = 10

	-- set role name
	SET @role_name = 'Department Manager'

	-- retrieve each approver's AD user email
	SELECT @approver_email = Users.Email
	,	@approver_first_name = Users.FirstName
	,	@approver_last_name = Users.LastName
	,	@approver_title = Users.Title
	FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
	WHERE Users.Active = 1
	AND Users.InActiveDirectory = 1 
	--AND Users.IsEmployeeAccount = 1
	AND @next_level_approver = Users.DomainName + '\' + Users.UserName

	-- create SLA approval record
	INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, NULL, NULL, NULL, NULL, NULL, 0)
	SET @department_manager = @next_level_approver
	SET @next_level_approver = ''

	--****************************************************************************************************
	--* AFE SLA Approval Workflow Process: STEP #7 - Active Directory Hierarchy (Level Below Executives) *
	--****************************************************************************************************

	-- set next SLA index
	SET @sla_index += 1

	-- identify request SLA approver(s)
	SET @CNT = 1
	WHILE @CNT <= 2
	BEGIN
		-- initialize SLA level
		SET @sla_level_index = 1
		SET @sla_level = 10

		-- identify originator
		SELECT @originator =
			CASE   
				WHEN @CNT = 1 THEN @project_owner
				WHEN @CNT = 2 THEN @department_manager
			END

		-- identify role name
		SELECT @role_name =
			CASE   
				WHEN @CNT = 1 THEN 'Project Owner'
				WHEN @CNT = 2 THEN 'Department Manager'
			END

		-- retrieve originator's email
		SELECT @approver_email = Users.Email
		,	@approver_first_name = Users.FirstName
		,	@approver_last_name = Users.LastName
		,	@approver_title = Users.Title
		FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
		WHERE Users.Active = 1
		AND Users.InActiveDirectory = 1 
		--AND Users.IsEmployeeAccount = 1
		AND @originator = Users.DomainName + '\' + Users.UserName

		-- add per originator to temporary table
		SET @immediate_manager = ''
		EXECUTE [dbo].[spd_AD_GetManager] @originator, @immediate_manager OUTPUT
		INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @originator, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, @immediate_manager, NULL, NULL, NULL, NULL, 0)
		SET @next_level_approver = ''
		SET @last_sla_id = @@IDENTITY

		-- traverse AD hierarchy to look up next level approver until the given role id to stop
		SET @LOOP_COUNTER = 1
		WHILE @role_found <> 1 AND @LOOP_COUNTER <= @MAX_LOOP
		BEGIN
			-- get next level approver (i.e. manager's userid)
			EXECUTE [dbo].[spd_AD_GetManager] @originator, @next_level_approver OUTPUT

			-- check if there is a next level approver
			IF @next_level_approver = '' OR @next_level_approver = @originator
			BEGIN
				SET @LOOP_COUNTER = @MAX_LOOP + 1
				BREAK
			END

			-- stop before Executives level
			IF EXISTS( 
				SELECT TOP 1 * 
				FROM [CPX].[USERS].[UserRole] UserRole
					INNER JOIN [CPX].[USERS].[Users] Users
						ON UserRole.userId = Users.id
					INNER JOIN [CPX].[USERS].[Roles] Roles
						ON UserRole.roleId = Roles.id
				WHERE Users.userName = @next_level_approver
				AND (Roles.IsExecutives = 1 OR UserRole.roleId IN (20, 21, 22, 23, 24, 25))  -- VP or Executives
			)
			BEGIN			    
				SET @role_found = 1
				BREAK
			END

			-- set next SLA level
			SET @sla_level_index += 1
			SET @sla_level += 10

			-- retrieve each approver's AD user email
			SELECT @approver_email = Users.Email
			,	@approver_first_name = Users.FirstName
			,	@approver_last_name = Users.LastName
			,	@approver_title = Users.Title
			FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
			WHERE Users.Active = 1
			AND Users.InActiveDirectory = 1 
			--AND Users.IsEmployeeAccount = 1
			AND @next_level_approver = Users.DomainName + '\' + Users.UserName

			-- set role name
			SET @role_name = @approver_title

			-- create SLA approval record
			SET @immediate_manager = ''
			EXECUTE [dbo].[spd_AD_GetManager] @next_level_approver, @immediate_manager OUTPUT
			INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, @immediate_manager, NULL, NULL, NULL, NULL, 0)
			SET @next_level_approver = ''
			SET @last_sla_id = @@IDENTITY

			-- look up for the new next level approver
			IF @role_found <> 1
			BEGIN
				SET @originator = @next_level_approver
				SET @LOOP_COUNTER = @LOOP_COUNTER + 1
			END
		END

		-- unset manager userid of per last SLA approver of the hierachy
		UPDATE @ApprovalWorkflow
		SET ManagerUserId = ''
		WHERE ID = @last_sla_id

		-- reset for next iteration
		SET @CNT += 1
		SET @role_found = 0
	END

	--***********************************************************
	--* AFE SLA Approval Workflow Process: STEP #8 - Exceptions *
	--***********************************************************

	-- #2.1: [TODO] add GL account exception (how to link GL exception with AFE request???) 

	-- #2.2: request approval of Special Projects Director if it's a stagegate AFE
	IF @is_stagegate = 1
	BEGIN
		-- get role AD userid & name
		SET @role_id = 8 -- Special Projects Director
		SELECT @next_level_approver = Users.userName
		,	@role_name = Roles.description
		FROM [CPX].[USERS].[UserRole] UserRole
			INNER JOIN [CPX].[USERS].[Users] Users
				ON UserRole.userId = Users.id
			INNER JOIN [CPX].[USERS].[Roles] Roles
				ON Roles.id = UserRole.roleId
		WHERE UserRole.roleId = @role_id

		IF @next_level_approver <> ''
		BEGIN
			-- increase SLA index and initialize SLA level
			SET @sla_index += 1
			SET @sla_level_index = 1	
			SET @sla_level = 10

			-- retrieve each approver's AD user email
			SELECT @approver_email = Users.Email
			,	@approver_first_name = Users.FirstName
			,	@approver_last_name = Users.LastName
			,	@approver_title = Users.Title
			FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
			WHERE Users.Active = 1
			AND Users.InActiveDirectory = 1 
			--AND Users.IsEmployeeAccount = 1
			AND @next_level_approver = Users.DomainName + '\' + Users.UserName

			-- create SLA approval record
			SET @immediate_manager = ''
			EXECUTE [dbo].[spd_AD_GetManager] @next_level_approver, @immediate_manager OUTPUT
			INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, @immediate_manager, NULL, NULL, NULL, NULL, 0)
			SET @next_level_approver = ''
		END
	END

	--**************************************************************************************
	--* AFE SLA Approval Workflow Process: STEP #9 - Controllers, VP Engineering, Amount 1 *
	--**************************************************************************************

	-- #3.1: Request approval of the Controller of the request company
	IF @is_us_company = 1
	BEGIN
		SET @role_id = 17  -- Controller US
	END
	ELSE
	BEGIN
	    SET @role_id = 18 -- Controller CA
	END

	-- get role AD userid & name
	SELECT @next_level_approver = Users.userName
	,	@role_name = Roles.description
	FROM [CPX].[USERS].[UserRole] UserRole
		INNER JOIN [CPX].[USERS].[Users] Users
			ON UserRole.userId = Users.id
		INNER JOIN [CPX].[USERS].[Roles] Roles
			ON Roles.id = UserRole.roleId
	WHERE UserRole.roleId = @role_id
	AND CHARINDEX(@company_no, Roles.company) > 0

	IF @next_level_approver <> ''
	BEGIN
		-- increase SLA index and initialize SLA level
		SET @sla_index += 1
		SET @sla_level_index = 1
		SET @sla_level = 10

		-- retrieve each approver's AD user email
		SELECT @approver_email = Users.Email
		,	@approver_first_name = Users.FirstName
		,	@approver_last_name = Users.LastName
		,	@approver_title = Users.Title
		FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
		WHERE Users.Active = 1
		AND Users.InActiveDirectory = 1 
		--AND Users.IsEmployeeAccount = 1
		AND @next_level_approver = Users.DomainName + '\' + Users.UserName

		-- create SLA approval record
		SET @immediate_manager = ''
		INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, @immediate_manager, NULL, NULL, NULL, NULL, 0)
		SET @next_level_approver = ''
	END

	-- #3.2: Request approval of the VP Engineering

	-- get role AD userid & name
	SET @role_id = 19  -- VP Engineering
	SELECT @next_level_approver = Users.userName
	,	@role_name = Roles.description
	FROM [CPX].[USERS].[UserRole] UserRole
		INNER JOIN [CPX].[USERS].[Users] Users
			ON UserRole.userId = Users.id
		INNER JOIN [CPX].[USERS].[Roles] Roles
			ON Roles.id = UserRole.roleId
	WHERE UserRole.roleId = @role_id

	IF @next_level_approver <> ''
	BEGIN
		-- increase SLA index and initialize SLA level
		SET @sla_index += 1
		SET @sla_level_index = 1	
		SET @sla_level = 10

		-- retrieve each approver's AD user email
		SELECT @approver_email = Users.Email
		,	@approver_first_name = Users.FirstName
		,	@approver_last_name = Users.LastName
		,	@approver_title = Users.Title
		FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
		WHERE Users.Active = 1
		AND Users.InActiveDirectory = 1 
		--AND Users.IsEmployeeAccount = 1
		AND @next_level_approver = Users.DomainName + '\' + Users.UserName

		-- create SLA approval record
		SET @immediate_manager = ''
		INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, @immediate_manager, NULL, NULL, NULL, NULL, 0)
		SET @next_level_approver = ''
	END

	-- #3.3: Check AFE dollar amount to stop
	--IF @afe_amount <= 24999
	--BEGIN
	--	SELECT *
	--	FROM [SLA].[dbo].[ApprovalWorkflow] ApprovalWorkflow
	--	WHERE ApprovalWorkflow.RequestId = @request_id
	--	AND ApprovalWorkflow.StatusCode IS NULL
	--	AND ApprovalWorkflow.SlaIndex = 1
	--	AND ApprovalWorkflow.SlaLevel = 10
	--	ORDER BY ApprovalWorkflow.SlaLevel
	--	RETURN 0
	--END

	--****************************************************************
	--* AFE SLA Approval Workflow Process: STEP #10 - Executives VPs *
	--****************************************************************

	-- check AFE dollar amount
	IF @afe_amount >= 25000
	BEGIN
		---- 4.1 request approval from the ’s VP through the active directory structure 
		--EXECUTE [dbo].[spd_AD_GetVPRoleUserId] @requestor, @next_level_approver OUTPUT

		---- get role name
		--SELECT @role_name = Roles.description
		--FROM [CPX].[USERS].[Roles] Roles
		--WHERE Roles.id = @role_id

		--IF @next_level_approver <> ''
		--BEGIN
		--	-- increase SLA index and initialize SLA level
		--	SET @sla_index += 1
		--  SET @sla_level_index = 1	
		--	SET @sla_level = 10

		--	-- retrieve each approver's AD user email
		--	SELECT @approver_email = Users.Email
		--	,	@approver_first_name = Users.FirstName
		--	,	@approver_last_name = Users.LastName
		--	,	@approver_title = Users.Title
		--	FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
		--	WHERE Users.Active = 1
		--	AND Users.InActiveDirectory = 1 
		--	--AND Users.IsEmployeeAccount = 1
		--	AND @next_level_approver = Users.DomainName + '\' + Users.UserName

		--	-- create SLA approval record
		--	SET @immediate_manager = ''
		--	EXECUTE [dbo].[spd_AD_GetManager] @originator, @immediate_manager OUTPUT
		--	INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, @immediate_manager, NULL, NULL, NULL, NULL, 0)
		--END

		-- 4.2.1 Request approval from the Department/Warehouse Manager’s VP through the active directory structure
		EXECUTE [dbo].[spd_AD_GetVPRoleUserId] @department_manager, @next_level_approver OUTPUT
		
		-- get role name
		SET @role_name = 'Department/Warehouse Manager''s VP'
		--SELECT @role_name = Roles.description
		--FROM [CPX].[USERS].[Users] Users
		--	INNER JOIN [CPX].[USERS].[UserRole] UserRole
		--		ON UserRole.userId = Users.id
		--	INNER JOIN [CPX].[USERS].[Roles] Roles
		--		ON Roles.id = UserRole.roleId
		--WHERE Users.userName = @next_level_approver

		IF @next_level_approver <> ''
		BEGIN
			-- increase SLA index and initialize SLA level
			SET @sla_index += 1
			SET @sla_level_index = 1	
			SET @sla_level = 10

			-- retrieve each approver's AD user email
			SELECT @approver_email = Users.Email
			,	@approver_first_name = Users.FirstName
			,	@approver_last_name = Users.LastName
			,	@approver_title = Users.Title
			FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
			WHERE Users.Active = 1
			AND Users.InActiveDirectory = 1 
			--AND Users.IsEmployeeAccount = 1
			AND @next_level_approver = Users.DomainName + '\' + Users.UserName

			-- create SLA approval record
			SET @immediate_manager = ''
			INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, @immediate_manager, NULL, NULL, NULL, NULL, 0)
			SET @next_level_approver = ''
		END

		-- 4.2.2 Request approval from the Project Owner’s VP through the active directory structure
		EXECUTE [dbo].[spd_AD_GetVPRoleUserId] @project_owner, @next_level_approver OUTPUT

		-- get role name
		SELECT @role_name = Roles.description
		FROM [CPX].[USERS].[Users] Users
			INNER JOIN [CPX].[USERS].[UserRole] UserRole
				ON UserRole.userId = Users.id
			INNER JOIN [CPX].[USERS].[Roles] Roles
				ON Roles.id = UserRole.roleId
		WHERE Users.userName = @next_level_approver

		IF @next_level_approver <> ''
		BEGIN
			-- increase SLA index and initialize SLA level
			SET @sla_index += 1
			SET @sla_level_index = 1
			SET @sla_level = 10

			-- retrieve each approver's AD user email
			SELECT @approver_email = Users.Email
			,	@approver_first_name = Users.FirstName
			,	@approver_last_name = Users.LastName
			,	@approver_title = Users.Title
			FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
			WHERE Users.Active = 1
			AND Users.InActiveDirectory = 1 
			--AND Users.IsEmployeeAccount = 1
			AND @next_level_approver = Users.DomainName + '\' + Users.UserName

			-- create SLA approval record
			SET @immediate_manager = ''
			INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, @immediate_manager, NULL, NULL, NULL, NULL, 0)
			SET @next_level_approver = ''
		END

		--- 4.4.1 Request approval of the VP of innovation
		IF @is_stagegate = 1
		BEGIN
			-- get role AD userid & name
			SET @role_id = 20  -- VP Innovation
			SELECT @next_level_approver = Users.userName
			,	@role_name = Roles.description
			FROM [CPX].[USERS].[UserRole] UserRole
				INNER JOIN [CPX].[USERS].[Users] Users
					ON UserRole.userId = Users.id
				INNER JOIN [CPX].[USERS].[Roles] Roles
					ON Roles.id = UserRole.roleId
			WHERE UserRole.roleId = @role_id

			IF @next_level_approver <> ''
			BEGIN
				-- increase SLA index and initialize SLA level
				SET @sla_index += 1
				SET @sla_level_index = 1	
				SET @sla_level = 10

				-- retrieve each approver's AD user email
				SELECT @approver_email = Users.Email
				,	@approver_first_name = Users.FirstName
				,	@approver_last_name = Users.LastName
				,	@approver_title = Users.Title
				FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
				WHERE Users.Active = 1
				AND Users.InActiveDirectory = 1 
				--AND Users.IsEmployeeAccount = 1
				AND @next_level_approver = Users.DomainName + '\' + Users.UserName

				-- create SLA approval record
				SET @immediate_manager = ''
				INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, @immediate_manager, NULL, NULL, NULL, NULL, 0)
				SET @next_level_approver = ''
			END
		END

		-- 4.4.2 Request approval of the VP of supply chain
		IF @afe_aliaxis_type_id = 1  -- CAP
		BEGIN
			-- get role AD userid & name
			SET @role_id = 23  -- VP Supply Chain
			SELECT @next_level_approver = Users.userName
			,	@role_name = Roles.description
			FROM [CPX].[USERS].[UserRole] UserRole
				INNER JOIN [CPX].[USERS].[Users] Users
					ON UserRole.userId = Users.id
				INNER JOIN [CPX].[USERS].[Roles] Roles
					ON Roles.id = UserRole.roleId
			WHERE UserRole.roleId = @role_id

			IF @next_level_approver <> ''
			BEGIN
				-- increase SLA index and initialize SLA level
				SET @sla_index += 1
				SET @sla_level_index = 1	
				SET @sla_level = 10

				-- retrieve each approver's AD user email
				SELECT @approver_email = Users.Email
				,	@approver_first_name = Users.FirstName
				,	@approver_last_name = Users.LastName
				,	@approver_title = Users.Title
				FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
				WHERE Users.Active = 1
				AND Users.InActiveDirectory = 1 
				--AND Users.IsEmployeeAccount = 1
				AND @next_level_approver = Users.DomainName + '\' + Users.UserName

				-- create SLA approval record
				SET @immediate_manager = ''
				INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, @immediate_manager, NULL, NULL, NULL, NULL, 0)
				SET @next_level_approver = ''
			END
		END

		-- 4.4.3 Request approval of the VP Sales and Marketing of the company (US or CA)
		IF @is_stagegate = 1 OR @afe_aliaxis_type_id = 1
		BEGIN
			IF @is_us_company = 1
			BEGIN
				SET @role_id = 21  -- VP Sales and Marketing US
			END
			ELSE
			BEGIN
				SET @role_id = 22  -- VP Sales and Marketing CA
			END

			-- get role AD userid & name
			SELECT @next_level_approver = Users.userName
			,	@role_name = Roles.description
			FROM [CPX].[USERS].[UserRole] UserRole
				INNER JOIN [CPX].[USERS].[Users] Users
					ON UserRole.userId = Users.id
				INNER JOIN [CPX].[USERS].[Roles] Roles
					ON Roles.id = UserRole.roleId
			WHERE UserRole.roleId = @role_id

			IF @next_level_approver <> ''
			BEGIN
				-- increase SLA index and initialize SLA level
				SET @sla_index += 1
				SET @sla_level_index = 1	
				SET @sla_level = 10

				-- retrieve each approver's AD user email
				SELECT @approver_email = Users.Email
				,	@approver_first_name = Users.FirstName
				,	@approver_last_name = Users.LastName
				,	@approver_title = Users.Title
				FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
				WHERE Users.Active = 1
				AND Users.InActiveDirectory = 1 
				--AND Users.IsEmployeeAccount = 1
				AND @next_level_approver = Users.DomainName + '\' + Users.UserName

				-- create SLA approval record
				SET @immediate_manager = ''
				INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, @immediate_manager, NULL, NULL, NULL, NULL, 0)
				SET @next_level_approver = ''
			END
		END
	END

	--**************************************************************
	--* AFE SLA Approval Workflow Process: STEP #11 - Executives 2 *
	--**************************************************************

	IF @afe_amount >= 100000
	BEGIN
		-- Request approval from the CFO

		-- get role AD userid & name
		SET @role_id = 26  -- CFO
		SELECT @next_level_approver = Users.userName
		,	@role_name = Roles.description
		FROM [CPX].[USERS].[UserRole] UserRole
			INNER JOIN [CPX].[USERS].[Users] Users
				ON UserRole.userId = Users.id
			INNER JOIN [CPX].[USERS].[Roles] Roles
				ON Roles.id = UserRole.roleId
		WHERE UserRole.roleId = @role_id

		IF @next_level_approver <> ''
		BEGIN
			-- increase SLA index and initialize SLA level
			SET @sla_index += 1
			SET @sla_level_index = 1	
			SET @sla_level = 10

			-- retrieve each approver's AD user email
			SELECT @approver_email = Users.Email
			,	@approver_first_name = Users.FirstName
			,	@approver_last_name = Users.LastName
			,	@approver_title = Users.Title
			FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
			WHERE Users.Active = 1
			AND Users.InActiveDirectory = 1 
			--AND Users.IsEmployeeAccount = 1
			AND @next_level_approver = Users.DomainName + '\' + Users.UserName

			-- create SLA approval record
			SET @immediate_manager = ''
			INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, @immediate_manager, NULL, NULL, NULL, NULL, 0)
			SET @next_level_approver = ''
		END

		-- Request approval from the COO by company
		IF @company_no IN ('05', '15')
		BEGIN
			SET @role_id = 29	-- COO HMK
		END
		ELSE
		BEGIN
			SET @role_id = 28	-- COO IPEX
		END

		-- get role AD userid & name
		SELECT @next_level_approver = Users.userName
		,	@role_name = Roles.description
		FROM [CPX].[USERS].[UserRole] UserRole
			INNER JOIN [CPX].[USERS].[Users] Users
				ON UserRole.userId = Users.id
			INNER JOIN [CPX].[USERS].[Roles] Roles
				ON Roles.id = UserRole.roleId
		WHERE UserRole.roleId = @role_id

		IF @next_level_approver <> ''
		BEGIN
			-- increase SLA index and initialize SLA level
			SET @sla_index += 1
			SET @sla_level_index = 1	
			SET @sla_level = 10

			-- retrieve each approver's AD user email
			SELECT @approver_email = Users.Email
			,	@approver_first_name = Users.FirstName
			,	@approver_last_name = Users.LastName
			,	@approver_title = Users.Title
			FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
			WHERE Users.Active = 1
			AND Users.InActiveDirectory = 1 
			--AND Users.IsEmployeeAccount = 1
			AND @next_level_approver = Users.DomainName + '\' + Users.UserName

			-- create SLA approval record
			SET @immediate_manager = ''
			INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, @immediate_manager, NULL, NULL, NULL, NULL, 0)
			SET @next_level_approver = ''
		END
	END

	-- Request approval from the CEO
	IF @afe_amount >= 200000
	BEGIN
		-- get role AD userid & name
		SET @role_id = 30  -- CEO
		SELECT @next_level_approver = Users.userName
		,	@role_name = Roles.description
		FROM [CPX].[USERS].[UserRole] UserRole
			INNER JOIN [CPX].[USERS].[Users] Users
				ON UserRole.userId = Users.id
			INNER JOIN [CPX].[USERS].[Roles] Roles
				ON Roles.id = UserRole.roleId
		WHERE UserRole.roleId = @role_id

		IF @next_level_approver <> ''
		BEGIN
			-- increase SLA index and initialize SLA level
			SET @sla_index += 1
			SET @sla_level_index = 1	
			SET @sla_level = 10

			-- retrieve each approver's AD user email
			SELECT @approver_email = Users.Email
			,	@approver_first_name = Users.FirstName
			,	@approver_last_name = Users.LastName
			,	@approver_title = Users.Title
			FROM SQL11.DataWarehouse.ActiveDirectory.Users AS Users
			WHERE Users.Active = 1
			AND Users.InActiveDirectory = 1 
			--AND Users.IsEmployeeAccount = 1
			AND @next_level_approver = Users.DomainName + '\' + Users.UserName

			-- create SLA approval record
			SET @immediate_manager = ''
			INSERT INTO @ApprovalWorkflow VALUES(@request_id, NULL, @sla_index, @sla_level_index, @sla_level, @next_level_approver, @approver_first_name, @approver_Last_name, @approver_title, @role_name, @approver_email, @overriden_email, @immediate_manager, NULL, NULL, NULL, NULL, 0)
			SET @next_level_approver = ''
		END
	END

	-- populate approval workflow table
	INSERT INTO [SLA].[dbo].[ApprovalWorkflow]
	SELECT  RequestId
	,	ReworkIndex = NULL
	,	SlaIndex
	,	SlaLevelIndex
	,	SlaLevel
	,	UserId
	,   FirstName
	,	LastName
	,	Title
	,	[Role]
	,	Email
	,	OverridenEmail
	,	ManagerUserId
	,	StatusCode
	,	StatusName
	,	ModifiedBy
	,	ModifiedOn
	,	IsModifedBySlaAdmin
	FROM (
			SELECT ID 
			,   RequestId
			,	ReworkIndex
			,	SlaIndex
			,	SlaLevelIndex
			,	SlaLevel
			,	UserId
			,   FirstName
			,	LastName
			,	Title
			,	[Role]
			,	Email
			,	OverridenEmail
			,	ManagerUserId
			,	StatusCode
			,	StatusName
			,	ModifiedBy
			,	ModifiedOn
			,	IsModifedBySlaAdmin
			,	ROW_NUMBER() OVER (PARTITION BY UserId ORDER BY ID) AS RowNumber
			 FROM @ApprovalWorkflow) AS a
	WHERE a.RowNumber = 1
	ORDER BY ID

	-- return result
	SELECT *
	FROM [SLA].[dbo].[ApprovalWorkflow] ApprovalWorkflow
	WHERE ApprovalWorkflow.RequestId = @request_id
	AND ApprovalWorkflow.StatusCode IS NULL
	AND ApprovalWorkflow.SlaIndex = 1
	AND ApprovalWorkflow.SlaLevel = 10
	ORDER BY ApprovalWorkflow.SlaLevel
END















GO


