USE [hydra_DataTransfer]
GO

/****** Object:  StoredProcedure [dbo].[GetRequestMatrix]    Script Date: 03/03/2016 2:16:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		S.J.M.
-- Create date: 17 Decembre 2013
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[GetRequestMatrix] (@MleTrsID VARCHAR(100)
 )
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DECLARE @Json VARCHAR(max)
	DECLARE @JT AS trs.JSONHierarchy

	SELECT @Json = JsonDataString
		FROM trs.Request
			WHERE	DialogFileID = (Select DialogFileID From  trs.DialogFile Where mleTrsID = @MleTrsID)
	
	--SELECT @Json = JsonDataString
	--	FROM trs.Request
	--		WHERE RequestID = 223

	INSERT INTO @JT
		SELECT * FROM trs.parseJSON(@Json)

	--select * from @JT

	DECLARE @dB INT
	DECLARE @dA INT

	SELECT @dB = [Object_ID] FROM @JT WHERE [NAME] = 'dataBefore'
	SELECT @dA = [Object_ID] FROM @JT WHERE [NAME] = 'dataAfter'

	-- select @dB,  @dA
	DECLARE @Join TABLE

	(
		dataBefore INT,
		dataAfter INT
	)

	DECLARE @InsertOrDeleteCase INT
	SET @InsertOrDeleteCase = (select count(1) from @JT Where parent_ID in (select dataBefore from @Join)) * (select count(1) from @JT Where parent_ID in (select dataAfter from @Join))

	INSERT INTO @Join
		SELECT
				dataBefore
		,		dataAfter
		FROM
			(
				select [Object_ID] dataBefore, ROW_NUMBER() OVER (ORDER BY [Object_ID]) mID from @JT
				where parent_ID = @dB
			) dBefore
					INNER JOIN
			(
				select [Object_ID] dataAfter, ROW_NUMBER() OVER (ORDER BY [Object_ID]) mID from @JT
				where parent_ID = @dA
			) dAfter
						ON dBefore.mID = dAfter.mID


	--Select *, ROW_NUMBER() OVER(ORDER BY databefore) RequestRowID from @Join

	--Select *
	--			, ROW_NUMBER() OVER(PARTITION BY parent_id ORDER BY element_id) dataBeforeRowID
	--			From @JT Where parent_ID In (select dataBefore from @Join)

	--Select * 
	--			, ROW_NUMBER() OVER(PARTITION BY parent_id ORDER BY element_id) dataAfterRowID
	--			From @JT Where parent_ID In (select dataAfter from @Join)


	SELECT
			B.RequestRowID
	,		ROW_NUMBER() OVER(PARTITION BY B.RequestRowID ORDER BY ISNULL(B.element_id,A.element_id))	RecordFieldID
	,		ISNULL(B.StringValue,'') DataBefore
	,		ISNULL(A.StringValue,'') DataAfter
	FROM
			(
			Select
			*
			From
					(
						Select *, ROW_NUMBER() OVER(ORDER BY databefore) RequestRowID from @Join
					)	MainT

					LEFT JOIN

					(
						Select *
						, ROW_NUMBER() OVER(PARTITION BY parent_id ORDER BY element_id) dataBeforeRowID
						From @JT Where parent_ID In (select dataBefore from @Join)
					) DB
						ON MainT.dataBefore = DB.parent_ID
		
			) B
				INNER JOIN
			(
			Select
			*
			From
					(
						Select *, ROW_NUMBER() OVER(ORDER BY databefore) RequestRowID from @Join
					)	MainT

					LEFT JOIN

					(
						Select * 
						, ROW_NUMBER() OVER(PARTITION BY parent_id ORDER BY element_id) dataAfterRowID
						From @JT Where parent_ID In (select dataAfter from @Join)		
					) DA
						ON MainT.dataAfter = DA.parent_ID
				) A

					ON		B.RequestRowID = A.RequestRowID
						AND 
						(
							(
								((B.element_id IS NULL) OR (A.element_id IS NULL)) AND (1 = 1)
							)
							OR
							(
								((NOT B.element_id IS NULL) OR (NOT A.element_id IS NULL)) AND (B.dataBeforeRowID = A.dataAfterRowID)
							)
						)
END

GO

