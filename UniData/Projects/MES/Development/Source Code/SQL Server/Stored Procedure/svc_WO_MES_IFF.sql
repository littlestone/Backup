USE [hydra_DataTransfer]
GO

/****** Object:  StoredProcedure [dbo].[svc_WO_MES_IFF]    Script Date: 03/03/2016 2:17:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		S.J.M.
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[svc_WO_MES_IFF]
@lastRunDateTime DATETIME OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FromDate	DATETIME
		, @ToDate		DATETIME

	SELECT	@FromDate = ISNULL(MAX(LastRunDateTime), DATEADD(DAY, 0, DATEDIFF(DAY, 0, GETDATE())))
		, @ToDate = GETDATE()
	FROM	ServiceExecLog
	WHERE	ServiceCode = 'svc_WO_MES_IFF'

	--PRINT('StartDate = ' + CONVERT(VARCHAR(30), @FromDate) + ' 
	--EndDate = ' + CONVERT(VARCHAR(30), @ToDate))

	SELECT
			B.auftrag_nr													OperationNumber
	,		B.aunr															OrderNumber
	,		B.artikel														ProductCode
	,		B.soll_menge_pri												TargetQuantity
	,		ISNULL(B.masch_nr,'')											PlannedMachineCode
	,		ISNULL(B.mgruppe,'')											MachineGroupCode

	,		ISNULL(CONVERT(varchar,B.erranf_dat,101),'')					PlannedStartDate
	,		ISNULL(CONVERT(varchar,B.errend_dat,101),'')					PlannedEndDate
	,		ISNULL(CONVERT(varchar, DATEADD(s,B.erranf_zeit, 0), 108),'')	PlannedStartTime
	,		ISNULL(CONVERT(varchar, DATEADD(s, B.errend_zeit, 0), 108),'')	PlannedEndTime
	,		ISNULL(B.res_wnr,'')											MoldCode
	,		S.eingeplant													ShedulingType
	FROM
			hydra1.hydadm.auftrags_bestand	B
						INNER JOIN hydra1.hydadm.auftrag_status S
								ON B.auftrag_nr = S.auftrag_nr
	WHERE
				B.a_typ = 'AG'
			--AND	B.bearb_date  = '2013-04-05'
			AND DATEADD(SECOND, B.bearb_time, CONVERT(DATETIME, B.bearb_date, 102)) BETWEEN @FromDate AND @ToDate
			OR	B.auftrag_nr IN (SELECT DISTINCT LEFT(sap_sdata,13) 
									FROM	hydra1.hydadm.hysap_out_data
										WHERE	sap_segnam = 'HY72ADRCK_SCHEDULE'
											--AND ds_workdate = '2013-04-05'
											AND		DATEADD(SECOND, ds_worktime, CONVERT(DATETIME, ds_workdate, 102)) BETWEEN @FromDate AND @ToDate)

	SET @lastRunDateTime = GETDATE()

END

	--,		CONVERT(varchar,ISNULL(B.erranf_dat,B.term_anf_dat),101)					PlannedStartDate
	--,		CONVERT(varchar,ISNULL(B.errend_dat,B.term_end_dat),101)					PlannedEndDate
	--,		CONVERT(varchar, DATEADD(s, ISNULL(B.erranf_zeit,B.term_anf_zeit), 0), 108)	PlannedStartTime
	--,		CONVERT(varchar, DATEADD(s, ISNULL(B.errend_zeit,B.term_end_zeit), 0), 108)	PlannedEndTime


GO

