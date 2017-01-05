USE [hydra_DataTransfer]
GO

/****** Object:  StoredProcedure [dbo].[RequestReport]    Script Date: 03/03/2016 2:17:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[RequestReport](@RequestID INT)
AS
BEGIN

	SET NOCOUNT ON;

	Select * From trs.Request Where RequestID = @RequestID

	Select * From trs.DialogFile Where DialogFileID = (Select DialogFileID From trs.Request Where RequestID = @RequestID)

	Select * From trs.mleInTrs Where mleTrsID = (Select mleTrsID From trs.DialogFile Where DialogFileID = (Select DialogFileID From trs.Request Where RequestID = @RequestID))

	Select * From trs.mleInSeg Where mleTrsID = (Select mleTrsID From trs.DialogFile Where DialogFileID = (Select DialogFileID From trs.Request Where RequestID = @RequestID))

END

GO

