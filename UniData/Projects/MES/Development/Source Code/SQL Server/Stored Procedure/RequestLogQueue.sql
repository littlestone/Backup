USE [hydra_DataTransfer]
GO

/****** Object:  StoredProcedure [trs].[RequestLogQueue]    Script Date: 03/03/2016 2:17:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		S.J.M.
-- Create date: 26 Nov. 2013
-- Description:	Log a request coming from Web Service
-- =============================================
ALTER PROCEDURE [trs].[RequestLogQueue]
@pUserId VARCHAR(100) = 'DEBUG'
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		-- Check if there is Record to Process
		IF (SELECT COUNT(1) FROM trs.RequestLog WHERE RequestLogError = 0) > 0
		BEGIN
			BEGIN TRANSACTION			-- Transaction to keep together same data states in 4 tables
				
				-- Fake statements to lock the 4 table
				update TOP (1) trs.Request		set RequestID = RequestID		where RequestID = RequestID
				update TOP (1) trs.DialogFile	set DialogFileID = DialogFileID where DialogFileID = DialogFileID
				update TOP (1) trs.mleInTrs		set mleTrsID = mleTrsID			where mleTrsID = mleTrsID
				update TOP (1) trs.mleInSeg		set mleTrsID = mleTrsID			where mleTrsID = mleTrsID
												
				-- Processing is by BAPI ---> @BAPI				
				--DECLARE @Request INT
				DECLARE @BAPI	VARCHAR(100)
				DECLARE @i INT	-- to iterate in the case where there is multiple Request in one BAPI
				
				-- Table to Store one or more Records to Process
				DECLARE @T TABLE
				(
					RequestLogID		INT,
					RequestLogDate		DATETIME,
					JsonFileName		VARCHAR(100),
					BapiFileName		VARCHAR(100),
					BapiFileLineCount	INT,
					JsonDataSting		VARCHAR(MAX),
					TreeNodeList		VARCHAR(MAX),
					RequestStatusCode	INT,
					RequestLogError		INT,
					LogRequestKey		INT
				)
			
				-- First Bapi that need to be Processes
				SELECT @BAPI = BapiFileName
					FROM trs.RequestLog
						WHERE RequestLogDate = (Select MIN(RequestLogDate) From trs.RequestLog Where RequestLogError = 0)
				
				-- Get All the Web Service Info for that BAPI
				INSERT INTO @T
					SELECT
							*
					,		ROW_NUMBER() OVER(ORDER BY RequestLogID)
					FROM
							trs.RequestLog
					WHERE
							BapiFileName = @BAPI


				-- ========================================================================================================================
				-- REQUEST GRANULARITY
				-- ------------------------------------------------------------------------------------------------------------------------
				SET @i = 1
				
				-- For Each Request GET :  Request Status, SyncID, UserID, Request Date AND DialogFileID
				-- Also, Insert each request in trs.Request table
				WHILE @i <= (SELECT COUNT(1) FROM @T)
				BEGIN

						
						DECLARE @TreeNodeList VARCHAR(1000)
						DECLARE @RequestStatus VARCHAR(3)
						DECLARE @SyncKey VARCHAR(5)

						SELECT	@TreeNodeList = TreeNodeList FROM @T WHERE LogRequestKey = @i

						-- Request Status and Sync Key are calculated from TreeNode list
						-- if There is empty TreeNode list --> BLL did not run --> something was wrong in the input json file
						SET @RequestStatus = CASE @TreeNodeList
												WHEN '' THEN 'ERR'
												ELSE 'OK' END

						SET @SyncKey = CASE @RequestStatus
											WHEN 'ERR' THEN ''
											WHEN 'OK' THEN SUBSTRING(@TreeNodeList,CHARINDEX('->',@TreeNodeList,1)+2,CHARINDEX('->',@TreeNodeList, CHARINDEX('->',@TreeNodeList,1)+1)-4) END
						 
						
						-- To Get the User from the json String: Position from config entry table is needed,
						DECLARE @UserID VARCHAR(30)						
						DECLARE @JT AS trs.JSONHierarchy
						DECLARE @JsonString VARCHAR(MAX)

						SELECT @JsonString = JsonDataSting FROM @T WHERE LogRequestKey = @i	
						-- select * from @JT

						/*
						COMMENTED TO AVOID CALLING PARSE JSON
						WHICH WAS CONSUMING TOO MUCH TIME
						INSERT INTO @JT
							SELECT * FROM trs.parseJSON(@JsonString)
																					
						IF NOT @SyncKey = 'T'
						BEGIN

							DECLARE @UserPosition INT
							SELECT @UserPosition = FieldPosition FROM cfg.SyncEntry WHERE SyncID = @SyncKey AND FieldID = 'UserID'

								-- Recursice CTE
								;
								WITH JsonTree
								AS(
									SELECT MP.element_id, MP.parent_ID, MP.Object_ID, MP.NAME, MP.StringValue, MP.ValueType, 1 scLevel
									FROM	@JT	MP
									WHERE	MP.parent_ID IS NULL

									UNION ALL

									SELECT MP.element_id, MP.parent_ID, MP.Object_ID, MP.NAME, MP.StringValue, MP.ValueType, SC.scLevel + 1
									FROM	@JT	MP
												INNER JOIN	JsonTree SC
													ON MP.parent_ID = SC.Object_ID
									WHERE	NOT MP.parent_ID IS NULL
									)

									--  Get the User Name from the raw jason data
									SELECT	@UserID = StringValue
											FROM
												(Select 
															*
													,		ROW_NUMBER() OVER(ORDER BY scLevel, element_id) dRank
													From
															JsonTree
													Where
															scLevel = 4 ) T
											WHERE
													dRank = @UserPosition + 1

								SET @UserID = ISNULL(@UserID,'')

						END
						ELSE
							BEGIN
								SELECT @UserID = StringValue FROM @JT WHERE element_id = 3
							END
						*/
						SELECT @UserID = @pUserId;

						-- Get Input File Date Stamp & Status
						DECLARE @JsonFileName VARCHAR(100)
						DECLARE @JsonFileDateString VARCHAR(30)
						DECLARE @JsonFileDate	DATETIME

						SELECT	@JsonFileName = JsonFileName FROM @T WHERE LogRequestKey = @i
						SET @JsonFileDateString = SUBSTRING(@JsonFileName,CHARINDEX('_',@JsonFileName) + 1, CHARINDEX('.',@JsonFileName) - CHARINDEX('_',@JsonFileName) - 1)
						SET @JsonFileDate = (SELECT SUBSTRING(@JsonFileDateString,0,5) + '-' + SUBSTRING(@JsonFileDateString,5,2)  + '-' + SUBSTRING(@JsonFileDateString,7,2) +  ' ' +
													SUBSTRING(@JsonFileDateString,9,2) + ':' + SUBSTRING(@JsonFileDateString,11,2) + ':' + SUBSTRING(@JsonFileDateString,13,2) + '.'  + RIGHT(@JsonFileDateString,3))

						-- CALCULATE DialogFileID :
						-- If Input Status is Error do not declare a DialogFileID (no link to DialogFile table)
						DECLARE @DialogFileID VARCHAR(100)
						SET @DialogFileID = CASE @RequestStatus
												WHEN 'ERR' THEN ''
												WHEN 'OK' THEN LEFT(@BAPI,CHARINDEX('.', @BAPI) - 1) END

							-- select @DialogFileID, @TreeNodeList, @RequestStatus, @SyncKey, @UserPosition, @JsonString, @UserID, @JsonFileName, @JsonFileDateString, @JsonFileDate
				-- ------------------------------------------------------------------------------------------------------------------------

							-- 1 - FIRST INSERT : REQUEST TABLE
						INSERT INTO trs.Request(RequestID, RequestInsertDate, RequestDate, JsonFileName, BapiFileName, DialogFileID, JsonDataString, TreeNodeList, RequestStatus, SyncID ,RequestUserID, ProcessReturnCode)
								SELECT
										RequestLogID
								,		RequestLogDate
								,		@JsonFileDate
								,		JsonFileName
								,		BapiFileName
								,		@DialogFileID
								,		JsonDataSting
								,		@TreeNodeList
								,		@RequestStatus
								,		@SyncKey
								,		@UserID
								,		RequestStatusCode
								FROM
										@T
								WHERE
										LogRequestKey = @i

				-- ------------------------------------------------------------------------------------------------------------------------

								-- select * from @T where LogRequestKey = @i

						SET @i = @i + 1
				END		-- End of WHILE loop in Request Granularity
				-- ========================================================================================================================




				-- ========================================================================================================================
				-- DIALOG FILE GRANULARITY
				-- ------------------------------------------------------------------------------------------------------------------------
				IF NOT @DialogFileID = ''
				BEGIN
					-- For One BAPI only GET : DialogFileDate, DialogFileStatus, RequestCount, DialogCount and MLE Transaction ID (if available)
					DECLARE @BapiFileDateString VARCHAR(30)	-- this is the date time stamp with milliseconds that is found inside of the BAPI file name
					DECLARE @BapiFileDate DATETIME			-- this is the DATE TIME stamp with milliseconds
					DECLARE @BapiFileDateMLE DATETIME		-- this is the same DATE ITME stamp WITHOUT milliseconds, this is used is the query that get the matching MLE Transaction ID
					DECLARE @BapiFileStatus VARCHAR(3)		-- the status is parsed from the extension of the file
					DECLARE @MleTrsID VARCHAR(100)			-- is the actual MLE Inbound transaction Number, if there is an Error in the Webservice processing then MLETrsID should be empty string
					DECLARE @BAPIlineCount INT				-- Number of Dialog in a File as provided from the Web Service
					DECLARE @TimeOutTime DATETIME			-- Variable to do a time out

					SET @BapiFileDateString = SUBSTRING(@BAPI,CHARINDEX('_',@BAPI) + 1, CHARINDEX('.',@BAPI) - CHARINDEX('_',@BAPI) - 1)
					SET @BapiFileDate = (SELECT SUBSTRING(@BapiFileDateString,0,5) + '-' + SUBSTRING(@BapiFileDateString,5,2)  + '-' + SUBSTRING(@BapiFileDateString,7,2) +  ' ' +
												SUBSTRING(@BapiFileDateString,9,2) + ':' + SUBSTRING(@BapiFileDateString,11,2) + ':' + SUBSTRING(@BapiFileDateString,13,2) + '.'  + RIGHT(@BapiFileDateString,3))
					SET @BapiFileDateMLE =  CAST((CONVERT(VARCHAR(8), @BapiFileDate, 112)  + ' ' + CONVERT(varchar, @BapiFileDate, 108)) AS DATETIME)
					SET @BapiFileStatus = CASE SUBSTRING(@BAPI,CHARINDEX('.', @BAPI) + 1, LEN(@BAPI) - CHARINDEX('.', @BAPI) + 1)
											WHEN 'DAT' THEN 'OK'
											WHEN 'ERR' THEN 'ERR'
											END
					SELECT DISTINCT @BAPIlineCount =  BapiFileLineCount FROM @T

					IF @BapiFileStatus = 'ERR' SET @MleTrsID = ''

					IF @BapiFileStatus = 'OK'
					BEGIN

						DECLARE @MaxMleTrsID VARCHAR(100)	-- Last MleTrsID
												
						--;
						--WITH CTE	-- Sort MLE Keys
						--AS
							--(Select 
							--		ROW_NUMBER() OVER(ORDER BY TrsSaveDate, mleTrsID) rID
							--,		mleTrsID
							--From	trs.mleInTrs)
							

						
						--SELECT @MaxMleTrsID = mleTrsID collate SQL_Latin1_General_CP1_CS_AS FROM CTE WHERE rID = (Select Max(rID) From CTE)
																	
						-- GET the MLE Trs
						SET @MleTrsID = NULL
						SET @TimeOutTime = DATEADD(s,3,GETDATE())
						
						DECLARE @intCounter INT = 0
						-- COUNTER SET TO 10 SECONDS
						-- IF THERE'S NO DATA WITHIN 10 SECONDS, IT WILL DEFAULT TO EMPTY (NULL)

						WHILE (@MleTrsID IS NULL AND @intCounter <= 100)
							BEGIN
									SELECT TOP 1 @MleTrsID =  ta_id
									FROM
												hydra1.hydadm.v_hysap_inbound_ctrl
									WHERE
													DATEADD(SECOND, ta_savtime, CONVERT(DATETIME, ta_savdate, 102)) >= @BapiFileDateMLE
												--AND	ta_id <>  ISNULL(@MaxMleTrsID,'')
												AND verweis > ISNULL((select max(TrsKEY) from trs.mleInTrs),0)
												--AND ta_lines = @BAPIlineCount
									ORDER BY
												DATEADD(SECOND, ta_savtime, CONVERT(DATETIME, ta_savdate, 102)) ASC
 
									WAITFOR DELAY '00:00:00.1';
									SET @intCounter = @intCounter + 1;
									--IF DATEDIFF(s,@TimeOutTime,GETDATE()) > 0
									--	BREAK
																	
							END

					END	-- END of Getting the Mle No

					
				--	select @DialogFileID, @BapiFileDateString, @BapiFileDate, @BapiFileDateMLE, @BapiFileStatus, @MaxMleTrsID, @BAPIlineCount

				-- ------------------------------------------------------------------------------------------------------------------------

				-- 2 - 2nd INSERT : DIALOG TABLE only if not @DialogFileID is empty
					INSERT INTO trs.DialogFile (DialogFileID, DialogFileDate, DialogFileName, DialogFileStatus, RequestCount, DialogCount, mleTrsID)
						SELECT	
								@DialogFileID
						,		@BapiFileDate
						,		@BAPI
						,		@BapiFileStatus
						,		@i - 1
						,		@BAPIlineCount
						,		@MleTrsID

				-- ------------------------------------------------------------------------------------------------------------------------
					
				-- SUB REGION of DIALOG GRANULARITY
				-- .....................................................................................................
				-- Data From MES relative to a MleTrsID
				-- .....................................................................................................
							
					IF ((NOT @MleTrsID IS NULL) AND (@MleTrsID <> ''))
					BEGIN
						-- ------------------------------------------------------------------------------------------------------------------------		
						-- 3 - 3rd INSERT : MLE TRS table only if not MLE Transaction exist
						INSERT INTO trs.mleInTrs(mleTrsID, TrsStatus, TrsSegCount, TrsSegDone, TrsSegUnknown, TrsSegError, TrsSaveDate, TrsProcessDate, mleDocNo, mleFileType, dataFileName, errorFileName, TrsKEY)										
							SELECT 
										I.ta_id
							,			CASE I.ta_status
											WHEN '099' THEN 'OK'
											WHEN '097' THEN 'Error'	END
							,			I.ta_lines
							,			I.ta_ldone
							,			I.ta_lunknown
							,			I.ta_lerror
							,			DATEADD(SECOND, I.ta_savtime, CONVERT(DATETIME, I.ta_savdate, 102))
							,			DATEADD(SECOND, I.ta_worktime, CONVERT(DATETIME, I.ta_workdate, 102))
							,			I.sap_docnum
							,			I.sap_mestyp
							,			ISNULL(P.d_datei_name,'')
							,			ISNULL(P.f_datei_name,'')
							,			I.verweis
							FROM
										hydra1.hydadm.v_hysap_inbound_ctrl I
														LEFT JOIN	hydra1.hydadm.v_hysap_protokoll P
																ON		I.ta_id = P.ta_id
																	AND P.anwendung = 'mle72imp'
							WHERE
										I.ta_id = @MleTrsID
						-- ------------------------------------------------------------------------------------------------------------------------										

						-- ------------------------------------------------------------------------------------------------------------------------
						-- 4 - 4th INSERT : MLE TRS Segment table only if not MLE Transaction exist
						INSERT INTO trs.mleInSeg(mleTrsID, SegPosition, SegStatus, SegSaveDate, SegProcessDate, SegName, SegData, segKEY)
							SELECT 
										ta_id
							,			ROW_NUMBER() OVER(ORDER BY verweis)
							,			CASE ds_status
											WHEN '099' THEN 'OK'
											WHEN '079' THEN 'Error'	END
							,			DATEADD(SECOND, ds_savtime, CONVERT(DATETIME, ds_savdate, 102))
							,			DATEADD(SECOND, ds_worktime, CONVERT(DATETIME, ds_workdate, 102))
							,			sap_segnam
							,			sap_sdata
							,			verweis

							FROM
										hydra1.hydadm.v_hysap_inbound_data
							WHERE
										ta_id = @MleTrsID
						-- ------------------------------------------------------------------------------------------------------------------------
									
					END	-- End of sub region Dialog Granularity --> only correspond when MLE Trs ID EXIST!
							
				END	-- End of region that is responsible of 3 insert trs.DialogFile, trs.MleInTrs, trs.MleInSeg

				--DELETE FROM trs.RequestLog WHERE RequestLogID IN (Select RequestLogID From @T)
				UPDATE trs.RequestLog SET RequestLogError = 1 WHERE RequestLogID IN (Select RequestLogID From @T)

			COMMIT TRANSACTION
		END	-- Check if there is Record to process
	END TRY

	BEGIN CATCH
				ROLLBACK TRANSACTION

				-- Reporting the Error inside of trs.RequestError Table
				-- ------------------------------------------------------------------------------------------------------------------------
				INSERT INTO trs.RequestError(DialogFileID,ErrorDate, ErrorNumber, ErrorSeverity, ErrorState, ErrorProcedure, ErrorLine, ErrorMessage)
					SELECT
							@DialogFileID
					,		GETDATE()
					,		ERROR_NUMBER() AS ErrorNumber
					,		ERROR_SEVERITY() AS ErrorSeverity
					,		ERROR_STATE() AS ErrorState
					,		ERROR_PROCEDURE() AS ErrorProcedure
					,		ERROR_LINE() AS ErrorLine
					,		ERROR_MESSAGE() AS ErrorMessage
				-- ------------------------------------------------------------------------------------------------------------------------
				UPDATE trs.RequestLog SET RequestLogError = 2 WHERE RequestLogID IN (Select RequestLogID From @T)

	END CATCH

END

GO

