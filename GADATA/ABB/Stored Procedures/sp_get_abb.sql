﻿CREATE PROCEDURE [ABB].[sp_get_abb]

   @StartDate as DATETIME = null,
   @EndDate as DATETIME = null,
   @RobotFilterWild as varchar(10) = '%',
   @RobotFilterMaskStart as varchar(10) = '%',
   @RobotFilterMaskEnd as varchar(10) = '99999R99%',
   @LocationFilterWild as varchar(20) = '%',
   @OrderbyRobot as bit = null
AS
BEGIN
---------------------------------------------------------------------------------------
--set first day of the week to monday (german std)
---------------------------------------------------------------------------------------
SET DATEFIRST 1
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
print '--*****************************************************************************--'
print '--[ABB].[sp_get_abb]--'
print '--*****************************************************************************--'
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
SELECT top 10
              NULL AS 'Location',
			  c.controller_name AS 'Robotname',
              'ABB' AS 'Type',
			  'ERROR' AS 'Errortype',
              H._timestamp AS 'timestamp',
              error.error_number AS 'Logcode',
              error.error_severity AS 'Severity',
              'ERR:  ' + Cast( error.error_text as varchar(10)) + '   | Cause: ' + CAST(isnull(cause.cause_text,' NA') as varchar(10)) AS 'Logtekst',
              H.wi_timestamp AS 'wi_timestamp', -- 'Downtime', --voorlopig windows time meegegeven 
			  DATEPART(YEAR, H._timestamp) AS 'Year',
			  DATEPART(WEEK,H._timestamp) AS 'Week',
			  GADATA.dbo.fn_volvoday(H._timestamp,CAST(H._timestamp AS time)) AS 'day',  --need to remake this function 
			  GADATA.dbo.fn_volvoshift1(H._timestamp,CAST(H._timestamp AS time)) AS 'Shift',
			  NULL AS 'Object',
			  NULL AS 'Subgroup',
              CAST(H.id AS int) AS 'idx'
			  
FROM GADATA.abb.h_alarm as H

--join the controller name
LEFT JOIN gadata.abb.c_controller as C ON (c.id = H.controller_id)
--join the alarm text
LEFT JOIN GADATA.ABB.L_error as error on (error.id = H.error_id)
--join the cause text 
LEFT JOIN GADATA.ABB.L_cause as cause on (cause.id = H.error_id)
/*
WHERE
--date time filter
H._timestamp BETWEEN ISNULL(@StartDate,GETDATE()-1) AND ISNULL(@EndDate,GETDATE())
AND
--robot name filter 
(c.controller_name BETWEEN @RobotFilterMaskStart AND @RobotFilterMaskEnd )
AND  
(c.controller_name LIKE @RobotFilterWild)
*/
ORDER BY   Timestamp DESC
END