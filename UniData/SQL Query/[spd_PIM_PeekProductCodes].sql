USE [PIM]
GO

/****** Object:  StoredProcedure [dbo].[spd_PeekProductCode]    Script Date: 2016-11-23 4:56:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


































-- =============================================
-- Author:		Junjie Tang
-- Create date: 2016-07-29
-- Description:	Product Codes Reservation Service for Infoflo (Peek)
-- =============================================
ALTER PROCEDURE [dbo].[spd_PeekProductCode]
	-- Add the parameters for the stored procedure here
	@ProductCode VARCHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [StatusCode]
	FROM [PIM].[dbo].[ProductCodesReservation]
	WHERE [ProductCode] = @ProductCode

END


































GO


