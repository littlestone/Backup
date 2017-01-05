USE [hydra_DataTransfer]
GO

/****** Object:  StoredProcedure [trs].[Insert_MatrixField]    Script Date: 03/03/2016 2:17:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		S.J.M.
-- Create date: 18 Decembre 2013
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [trs].[Insert_MatrixField]
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @RequestID INT
	DECLARE @BAPI VARCHAR(100)
	DECLARE @MleTrsID VARCHAR(100)
	DECLARE @i INT

	DECLARE @R TABLE
	(
		Request INT,
		SyncKey VARCHAR(3),
		rowID INT
	)


	INSERT INTO @R
		SELECT 
				RequestID
		,		SyncID
		,		ROW_NUMBER() OVER(ORDER BY RequestID)
		FROM	trs.Request
		WHERE
					ProcessReturnCode IN (0,3,4)
				AND NOT RequestID IN (Select RequestID From trs.MatrixField)

	SET @i = 1

	WHILE @i < 2 --(select max(rowID) from @R)
	BEGIN
			SELECT @RequestID = Request 
				FROM	@R
					WHERE	rowID = @i

			SELECT @BAPI = DialogFileID
				FROM	trs.Request
					WHERE	RequestID = @RequestID

			SELECT @MleTrsID = mleTrsID
				FROM	trs.DialogFile
					WHERE	DialogFileID = @BAPI

			--Select
			--		FieldPosition + 1 FieldID
			--,		FieldID
			--,		DataType
			--From cfg.SyncEntry
			--Where SyncID = (Select SyncKey From @R Where rowID = @i)

			Select
					RequestRowID
			,		RecordFieldID
			,		DataBefore
			,		DataAfter
			From
					dbo.RequestMatrix(@RequestID)

		

			--INSERT INTO trs.MatrixField(RequestID, DialogFileID, mleTrsID, MatrixRowID, MatrixFieldID, DataBefore, DataAfter, EntryFieldName, EntryDataType)
				SELECT
						@RequestID
				,		@BAPI
				,		@MleTrsID

				
			SET @i = @i + 1
	END

	--select * from @R
	--select @i
	--select * from [dbo].[RequestMatrix](15)

END

GO

