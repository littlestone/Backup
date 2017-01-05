USE [hydra_DataTransfer]
GO

/****** Object:  StoredProcedure [trs].[GetMleTrsStatus]    Script Date: 03/03/2016 2:17:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		S.J.M.
-- Create date: 5 decembre 213
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [trs].[GetMleTrsStatus]
AS
BEGIN
	SET NOCOUNT ON;


	IF (SELECT COUNT(1) FROM trs.mleInTrs WHERE TrsStatus IS NULL) > 0
		BEGIN
			-- select * from trs.mleInTrs


			-- UPDATING The Segment Table for Status and MLE Processing DATE TIME
			---------------------------------------------------------------------------------------------------------------------------
			UPDATE trs.mleInSeg
				SET
					SegStatus = CASE m.ds_status
									WHEN '099' THEN 'OK'
									WHEN '079' THEN 'Error'	END,
					SegProcessDate = DATEADD(SECOND, ds_worktime, CONVERT(DATETIME, ds_workdate, 102))
			FROM
					trs.mleInSeg S
						INNER JOIN	hydra1.hydadm.v_hysap_inbound_data m
							ON S.SegKEY = m.verweis
			WHERE
					SegStatus IS NULL

			-- UPADTING MLE Transaction Table
			---------------------------------------------------------------------------------------------------------------------------
			UPDATE	trs.mleInTrs
				SET
					errorFileName = P.f_datei_name,
					dataFileName = P.d_datei_name,
					TrsProcessDate = DATEADD(SECOND, I.ta_worktime, CONVERT(DATETIME, I.ta_workdate, 102)),
					TrsSegError = I.ta_lerror,
					TrsSegUnknown = I.ta_lunknown,
					TrsSegDone = I.ta_ldone,
					TrsSegCount = I.ta_lines,
					TrsStatus = CASE I.ta_status
									WHEN '099' THEN 'OK'
									WHEN '097' THEN 'Error'	END
			FROM
					trs.mleInTrs T
						INNER JOIN hydra1.hydadm.v_hysap_inbound_ctrl I
							ON		T.TrsKEY = I.verweis
						LEFT JOIN	hydra1.hydadm.v_hysap_protokoll P
							ON		I.ta_id = P.ta_id
								AND P.anwendung = 'mle72imp'
			WHERE
					TrsStatus IS NULL			

		END
END

GO

