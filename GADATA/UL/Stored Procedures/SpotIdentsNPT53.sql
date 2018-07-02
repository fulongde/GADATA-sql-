﻿-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [UL].[SpotIdentsNPT53]

AS
BEGIN try

	SET NOCOUNT ON;

--Insert Weldmeasurement for UL data to see buildBody's and if there is production----
--insert spotident
INSERT INTO [UL].[IdentsNPT53] (timestamp,spotid)

  SELECT DISTINCT tbl.datetime, dbo.Spot.ID
FROM     OPENQUERY([10.249.240.14\BOS_SQLSERV_2005], '
SELECT datetime, spotname
                  FROM      dbo.extweldmeasureprotddw_v
                  ') AS tbl INNER JOIN
                  dbo.Inspectionplan ON tbl.spotname = dbo.Inspectionplan.SpotIdent INNER JOIN
                  dbo.Spot ON tbl.spotname = dbo.Spot.Number LEFT OUTER JOIN
                  [UL].[IdentsNPT53] ON tbl.datetime = [UL].[IdentsNPT53].timestamp
WHERE  ([UL].[IdentsNPT53].timestamp IS NULL)
 --insert spotBefore
 INSERT INTO [UL].[IdentsNPT53] (timestamp,spotid)

SELECT DISTINCT tbl.datetime, dbo.Spot.ID
FROM     OPENQUERY([10.249.240.14\BOS_SQLSERV_2005], '
SELECT datetime, spotname
                  FROM      dbo.extweldmeasureprotddw_v
                  ') AS tbl INNER JOIN
                  dbo.Inspectionplan ON tbl.spotname = dbo.Inspectionplan.SpotBefore INNER JOIN
                  dbo.Spot ON tbl.spotname = dbo.Spot.Number LEFT OUTER JOIN
                  [UL].[IdentsNPT53] ON tbl.datetime = [UL].[IdentsNPT53].timestamp
WHERE  ([UL].[IdentsNPT53].timestamp IS NULL)
 -- insert spotAfter
 INSERT INTO [UL].[IdentsNPT53] (timestamp,spotid)

SELECT DISTINCT tbl.datetime, dbo.Spot.ID
FROM     OPENQUERY([10.249.240.14\BOS_SQLSERV_2005], '
SELECT datetime, spotname
                  FROM      dbo.extweldmeasureprotddw_v
                  ') AS tbl INNER JOIN
                  dbo.Inspectionplan ON tbl.spotname = dbo.Inspectionplan.Spotafter INNER JOIN
                  dbo.Spot ON tbl.spotname = dbo.Spot.Number LEFT OUTER JOIN
                  [UL].[IdentsNPT53] ON tbl.datetime = [UL].[IdentsNPT53].timestamp
WHERE  ([UL].[IdentsNPT53].timestamp IS NULL)

end try

begin catch
INSERT INTO [UL].[ErrorHandling]([procedure]
      ,[ErrorNumber]
      ,[ErrorSeverity]
      ,[ErrorState]
      ,[ErrorLine]
      ,[ErrorMessage]
	  ,[timestamp])

  SELECT 
    '[UL].[spotidentNPT53]_fault_catch'
    ,ERROR_NUMBER() AS ErrorNumber  
    ,ERROR_SEVERITY() AS ErrorSeverity  
    ,ERROR_STATE() AS ErrorState  
    ,ERROR_LINE() AS ErrorLine  
    ,ERROR_MESSAGE() AS ErrorMessage
	,GETDATE();  
end catch