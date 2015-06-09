﻿CREATE PROCEDURE [dbo].[sp_VCSC_C4G_B4beta]

   @StartDate as DATETIME = null,
   @EndDate as DATETIME = null,
   @RobotFilterWild as varchar(10) = '%',
   @RobotFilterMaskStart as varchar(10) = '%',
   @RobotFilterMaskEnd as varchar(10) = '99999R99%',
   @LocationFilterWild as varchar(20) = '%',

   @OrderbyRobot as bit = null,
  
   @GetC4GAction as bit = 1,
   @GetC4Gerror as bit = 1,
   @GetC4GEvents as bit = 1,
   @GetC4GDowntimes as bit = 1,
   @GetC4GDownTBegin as bit = 1,
   @GetC4GCollisions as bit = 1,
   @GetC3GError as bit = 1,

   @ExcludeGateStops as bit = 0,
   @MinLogserv as int = 0
AS
BEGIN
---------------------------------------------------------------------------------------
--set first day of the week to monday (german std)
---------------------------------------------------------------------------------------
SET DATEFIRST 1
---------------------------------------------------------------------------------------
--update the L_breakdown table 
---------------------------------------------------------------------------------------
--EXEC dbo.sp_VCSC_C4G_Update_L_breakdown_A1 
---------------------------------------------------------------------------------------
--to index sys event table based on time and robotid 
---------------------------------------------------------------------------------------
if (OBJECT_ID('tempdb..#SysEventIdx') is not null) drop table #SysEventIdx
	SELECT *,
		 ROW_NUMBER() OVER (PARTITION BY x.controller_id ORDER BY x._timestamp DESC) AS rnDESC
		 INTO #SysEventIdx FROM 
	(
			--data from rt_sys_event table. 
			SELECT 
				rt_sys_event.id,
				rt_sys_event.controller_id,
				rt_sys_event._timestamp,
				rt_sys_event.sys_state,
				robotState = dbo.fn_robstate(rt_sys_event.sys_state) --calculates a robot state a running robot has 2 a non running one 0 
			FROM  GADATA.dbo.rt_sys_event  AS rt_sys_event
			WHERE rt_sys_event._timestamp  BETWEEN ISNULL(@StartDate,GETDATE()-1) AND ISNULL(@EndDate,GETDATE())
			AND @GetC4GEvents = 1
	
			--data from L_operation (to catch robots goning offline)
			UNION
			SELECT 
				l_operation.id,
				l_operation.controller_id,
				l_operation._timestamp,
				sys_state = 262144, 
				robotState = 0
			FROM GADATA.dbo.l_operation AS l_operation
			WHERE (l_operation._timestamp  BETWEEN ISNULL(@StartDate,GETDATE()-1) AND ISNULL(@EndDate,GETDATE())) AND (l_operation.code = 4) --connection lost 
			AND @GetC4GEvents = 1
	) AS x 
	
---------------------------------------------------------------------------------------
--to calculate time in state for each event. (passed events)
---------------------------------------------------------------------------------------
if (OBJECT_ID('tempdb..#SysEventPast') is not null) drop table #SysEventPast
       SELECT 
         #SysEventIdx.id,
         #SysEventIdx.controller_id,
         #SysEventIdx._timestamp,
         #SysEventIdx.sys_state,
         #SysEventIdx.rnDESC,
         TimeInState = SyseventOffs._timestamp - #SysEventIdx._timestamp,  
         #SysEventIdx.robotState
       INTO #SysEventPast
       FROM #SysEventIdx
       
    JOIN    #SysEventIdx AS SyseventOffs 
    ON (#SysEventIdx.rnDESC = SyseventOffs.rnDESC + 1)  
              AND 
              (#SysEventIdx.controller_id = SyseventOffs.controller_id) 
              AND 
              (#SysEventIdx.rnDESC <> 1)
	WHERE @GetC4GEvents = 1
---------------------------------------------------------------------------------------
--SysEventIdx with rownumbers 1 to calc TimeInState (active event)
---------------------------------------------------------------------------------------
if (OBJECT_ID('tempdb..#SysEventLive') is not null) drop table #SysEventLive
       (
       SELECT 
         #SysEventIdx.id,
         #SysEventIdx.controller_id,
         #SysEventIdx._timestamp,
         #SysEventIdx.sys_state,
         #SysEventIdx.rnDESC,
         TimeInState = (GETDATE()-#SysEventIdx._timestamp),
         #SysEventIdx.robotState
       INTO #SysEventLive
       FROM #SysEventIdx
   WHERE (#SysEventIdx.rnDESC = 1)
   	     AND @GetC4GEvents = 1
       )
---------------------------------------------------------------------------------------
--SysEventPast UNION with the SysEventLive table. (ongoing and past events)
---------------------------------------------------------------------------------------
if (OBJECT_ID('tempdb..#SysEventTime') is not null) drop table #SysEventTime
       (
       select * into #SysEventTime from (
		   SELECT * FROM #SysEventPast
		   UNION 
		   SELECT * FROM #SysEventLive
       ) as x
       )

---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
--Runs an update of the 'actionlog' timeoffset table  (builds a instance of #C4GActionLogtimediff)
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
--create temp table in daterange to 'guess' the best timeoffset for action log 
---------------------------------------------------------------------------------------
if (OBJECT_ID('tempdb..#C4GActionLogtimedifftemp') is not null) drop table #C4GActionLogtimedifftemp
SELECT 
 --c_controller.controller_name
 --,rt_alarm._timestamp as 'realtime'
 --,rt_alarm.error_timestamp as 'controllertime'
  rt_alarm.controller_id
 ,timeoffset = (rt_alarm._timestamp - rt_alarm.error_timestamp)
 ,ROW_NUMBER() OVER (PARTITION BY rt_alarm.controller_id ORDER BY rt_alarm._timestamp DESC) AS rnDESC
INTO #C4GActionLogtimedifftemp
FROM GADATA.dbo.c_controller
JOIN GADATA.dbo.rt_alarm on c_controller.id = rt_alarm.controller_id

WHERE 
--reference pool
(rt_alarm._timestamp  BETWEEN ISNULL(@StartDate,GETDATE()-1) AND ISNULL(@EndDate,GETDATE()))
--error must be a realtime alarm.
AND
(rt_alarm.error_is_alarm = 1)

if (OBJECT_ID('tempdb..#C4GActionLogtimediff') is not null) drop table #C4GActionLogtimediff
SELECT #C4GActionLogtimedifftemp.controller_id, #C4GActionLogtimedifftemp.timeoffset  
INTO #C4GActionLogtimediff 
FROM #C4GActionLogtimedifftemp
WHERE rnDESC = 1 

---------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
--Output qry 
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--Qry Sys events 
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

SELECT  
              c_controller.location AS 'Location',
			  c_controller.controller_name AS 'Robotname',
              'C4G' AS 'Type',
			  'EVENT' AS 'Errortype',
			  convert(char(19),SysEventTime._timestamp,120) AS 'Timestamp',
              NULL AS 'Logcode',
              NULL AS 'Severity',
              'Time: ' + convert(Char(8),SysEventTime.timeinstate,108) + '  Code: ' + CAST(SyseventTime.Sys_state AS varchar) + '  SysState: ' + (dbo.fn_decodeSysstate(SysEventTime.Sys_state)) AS 'Logtekst', --+ '  Code: ' + (CAST(SyseventTime.Sys_state) AS String) 
              NULL AS 'Downtime',
              DATEPART(YEAR, SysEventTime._timestamp) AS 'Year',
			  DATEPART(WEEK,SysEventTime._timestamp) AS 'Week',
			  GADATA.dbo.fn_volvoday(SysEventTime._timestamp,CAST(SysEventTime._timestamp AS time)) AS 'Day',
			  --DATEPART(WEEKDAY,SysEventTime._timestamp)AS 'Day',
			  GADATA.dbo.fn_volvoshift1(SysEventTime._timestamp,CAST(SysEventTime._timestamp AS time)) AS 'Shift',
			  NULL  AS 'Object',
			  NULL AS 'Subgroup',
			  
			  --debug collums
              --SysEventTime.sys_state,
              --CAST(SysEventTime.rnDESC AS int) AS 'rnDESC',
              CAST(SysEventTime.id AS int) AS 'idx'
              --NULL AS 'SSidx'
			  

FROM    #SysEventTime AS SysEventTime 
--join the controller name
JOIN    c_controller ON (SysEventTime.controller_id = c_controller.id) 
--robot name filter 
WHERE 
(c_controller.controller_name BETWEEN    @RobotFilterMaskStart AND @RobotFilterMaskEnd)
AND  
(c_controller.controller_name LIKE @RobotFilterWild)
--Location Filter
AND
(ISNULL(c_controller.location,'') LIKE @LocationFilterWild )


---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--Qry collisions
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
UNION

SELECT  
              c_controller.location AS 'Location',
			  c_controller.controller_name AS 'Robotname',
              'C4G' AS 'Type',
			  'COLLISION' AS 'Errortype',
			  convert(char(19),rt_value._timestamp,120) AS 'Timestamp',
              NULL AS 'Logcode',
              NULL AS 'Severity',
              rt_value.value AS 'Logtekst',
              NULL AS 'Downtime',
              DATEPART(YEAR, rt_value._timestamp) AS 'Year',
			  DATEPART(WEEK,rt_value._timestamp) AS 'Week',
			  GADATA.dbo.fn_volvoday(rt_value._timestamp,CAST(rt_value._timestamp AS time)) AS 'Day',
			  GADATA.dbo.fn_volvoshift1(rt_value._timestamp,CAST(rt_value._timestamp AS time)) AS 'Shift',
			  NULL  AS 'Object',
			  NULL AS 'Subgroup',
              CAST(rt_value.id AS int) AS 'idx'
		
FROM    rt_value  
--join the controller name
JOIN    c_controller ON (rt_value.controller_id = c_controller.id) 
--robot name filter 
WHERE
--only get the collision specific data 
(rt_value.variable_id = 11)
AND
--datetime filter
(rt_value._timestamp  BETWEEN ISNULL(@StartDate,GETDATE()-1) AND ISNULL(@EndDate,GETDATE())) 
AND 
(c_controller.controller_name BETWEEN    @RobotFilterMaskStart AND @RobotFilterMaskEnd)
AND  
(c_controller.controller_name LIKE @RobotFilterWild)
--Location Filter
AND
(ISNULL(c_controller.location,'') LIKE @LocationFilterWild )
AND
(@GetC4GCollisions = 1)

---------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--C4G Qry Breakdowns (einde van storings met storings tijd)
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
UNION
SELECT  
              c_controller.location AS 'Location',
			  c_controller.controller_name AS 'Robotname',
              'C4G' AS 'Type',
			  'BREAKDOWN',
              convert(char(19),L_breakdown.EndOfBreakdown,120) AS 'Timestamp',
              L_breakdown.error_number AS 'Logcode',
              NULL AS 'Severity',
              ISNULL(L_breakdown.error_text,'-----------Breakdown Tag-----------') AS 'Logtekst',
			  DOWNTIME = DATEDIFF(MINUTE,L_breakdown.StartOfBreakdown,L_breakdown.EndOfBreakdown),
              DATEPART(YEAR, L_breakdown.StartOfBreakdown) AS 'Year',
			  DATEPART(WEEK,L_breakdown.StartOfBreakdown) AS 'Week',
			  GADATA.dbo.fn_volvoday(L_breakdown.StartOfBreakdown,CAST(L_breakdown.StartOfBreakdown AS time)) AS 'day',
			 -- DATEPART(WEEKDAY,L_breakdown.StartOfBreakdown)AS 'day',
			  GADATA.dbo.fn_volvoshift1(L_breakdown.StartOfBreakdown,CAST(L_breakdown.StartOfBreakdown AS time)) AS 'Shift',
			  c_logclass1.appl AS 'Object',
			  c_logclass1.subgroup AS 'Subgroup',
			  
			  --debug collums
              --SysBreakDwn.sys_state,
              --CAST(SysBreakDwn.rnDESC AS int) AS 'rnDESC',
              L_breakdown.idx
              --CAST(SysBreakDwn.SysBreakDwnIndx AS int) AS 'SSidx'
			  
            
FROM GADATA.dbo.L_breakdown
--join the controller name
JOIN    c_controller ON (L_breakdown.controller_id = c_controller.id) 
--try and get an error classification
LEFT JOIN GADATA.dbo.c_logclass1 as c_logclass1 ON 
(
(L_breakdown.error_number BETWEEN c_logclass1.error_codeStart AND c_logclass1.error_codeEnd)
OR
(L_breakdown.error_text LIKE c_logclass1.error_tekst)
)

WHERE 
--Datetime filter
 L_breakdown.StartOfBreakdown  BETWEEN ISNULL(@StartDate,GETDATE()-1) AND ISNULL(@EndDate,GETDATE())
AND
--robot name filter 
((c_controller.controller_name BETWEEN    @RobotFilterMaskStart AND @RobotFilterMaskEnd))
AND
(c_controller.controller_name LIKE @RobotFilterWild)
--Location Filter
AND
(ISNULL(c_controller.location,'') LIKE @LocationFilterWild )
AND
--Exclude Gatestops 
((@ExcludeGateStops = 1 AND (ISNULL(c_logclass1.subgroup,'') NOT LIKE '%Gate/Hold%')) OR @ExcludeGateStops =0)
AND
--enable bit
(@GetC4GDowntimes = 1)

---------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--C4G Qry Breakdowns (begin van een storing)
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
UNION
SELECT  
              c_controller.location AS 'Location',
			  c_controller.controller_name AS 'Robotname',
              'C4G' AS 'Type',
			  'BEGIN',
              convert(char(19),L_breakdown.StartOfBreakdown,120) AS 'Timestamp',
              L_breakdown.error_number AS 'Logcode',
              NULL AS 'Severity',
              ISNULL(L_breakdown.error_text,'-----------Breakdown Tag-----------') AS 'Logtekst',
			  NULL as 'DOWNTIME', --DOWNTIME = DATEDIFF(MINUTE,L_breakdown.StartOfBreakdown,L_breakdown.EndOfBreakdown),
              DATEPART(YEAR, L_breakdown.StartOfBreakdown) AS 'Year',
			  DATEPART(WEEK,L_breakdown.StartOfBreakdown) AS 'Week',
			  --DATEPART(WEEKDAY,L_breakdown.StartOfBreakdown)AS 'day',
			  GADATA.dbo.fn_volvoday(L_breakdown.StartOfBreakdown,CAST(L_breakdown.StartOfBreakdown AS time)) AS 'day',
			  GADATA.dbo.fn_volvoshift1(L_breakdown.StartOfBreakdown,CAST(L_breakdown.StartOfBreakdown AS time)) AS 'Shift',
			  c_logclass1.appl AS 'Object',
			  c_logclass1.subgroup AS 'Subgroup',
			  --debug collums
              --SysBreakDwn.sys_state,
              --CAST(SysBreakDwn.rnDESC AS int) AS 'rnDESC',
              L_breakdown.idx
              --CAST(SysBreakDwn.SysBreakDwnIndx AS int) AS 'SSidx'
			  
            
FROM GADATA.dbo.L_breakdown
--join the controller name
JOIN    c_controller ON (L_breakdown.controller_id = c_controller.id) 
--try and get an error classification
LEFT JOIN GADATA.dbo.c_logclass1 as c_logclass1 ON 
(
(L_breakdown.error_number BETWEEN c_logclass1.error_codeStart AND c_logclass1.error_codeEnd)
OR
(L_breakdown.error_text LIKE c_logclass1.error_tekst)
)

WHERE 
--Datetime filter
 L_breakdown.StartOfBreakdown  BETWEEN ISNULL(@StartDate,GETDATE()-1) AND ISNULL(@EndDate,GETDATE())
AND
--robot name filter 
((c_controller.controller_name BETWEEN    @RobotFilterMaskStart AND @RobotFilterMaskEnd))
AND
(c_controller.controller_name LIKE @RobotFilterWild)
--Location Filter
AND
(ISNULL(c_controller.location,'') LIKE @LocationFilterWild )
AND
--Exclude Gatestops 
((@ExcludeGateStops = 1 AND (ISNULL(c_logclass1.subgroup,'') NOT LIKE '%Gate/Hold%')) OR @ExcludeGateStops =0)
AND
--enable bit
(@GetC4GDownTBegin = 1)

---------------------------------------------------------------------------------------




---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--C4G Alarm information (error log)
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
UNION
SELECT 
              c_controller.location AS 'Location',
			  c_controller.controller_name AS 'Robotname',
              'C4G' AS 'Type',
			  'ERROR' AS 'Errortype',
              convert(char(19),(rt_alarm._timestamp + '1900-01-01 00:00:05.00'),120) AS 'timestamp',--  because the err event is always a little bit quicker than the Sys event
              ISNULL(c_logtekst.error_number, rt_alarm.error_number) AS 'Logcode',
			  ISNULL(c_logtekst.error_severity, rt_alarm.error_severity) AS 'Severity',
			  ISNULL(c_logtekst.error_text,rt_alarm.error_text) AS 'Logtekst',
			  NULL AS 'Downtime',
			  DATEPART(YEAR, rt_alarm._timestamp) AS 'Year',
			  DATEPART(WEEK,rt_alarm._timestamp) AS 'Week',
			  GADATA.dbo.fn_volvoday(rt_alarm._timestamp,CAST(rt_alarm._timestamp AS time)) AS 'day',
			  --DATEPART(WEEKDAY,rt_alarm._timestamp) AS 'Day',
			  GADATA.dbo.fn_volvoshift1(rt_alarm._timestamp,CAST(rt_alarm._timestamp AS time)) AS 'Shift',
			  c_logclass1.appl AS 'Object',
			  c_logclass1.subgroup AS 'Subgroup',
              --debug collums
              --NULL, --SysEventTime.sys_state,
              --NULL AS 'rnDESC',
              CAST(rt_alarm.id AS int) AS 'idx'
              --NULL AS 'SSidx'
			  
FROM    GADATA.dbo.rt_alarm rt_alarm
--join the controller name
JOIN    c_controller ON (rt_alarm.controller_id = c_controller.id)
--join logtekst table
LEFT JOIN c_logtekst ON (c_logtekst.id = rt_alarm.error_id)

--try and get an error classification
LEFT JOIN GADATA.dbo.c_logclass1 as c_logclass1 ON 
(
(isnull(c_logtekst.error_number, rt_alarm.error_number) BETWEEN c_logclass1.error_codeStart AND c_logclass1.error_codeEnd)
OR
(isnull(c_logtekst.error_text, rt_alarm.error_text) LIKE c_logclass1.error_tekst)
) 

WHERE 
--datetime filter
rt_alarm._timestamp  BETWEEN ISNULL(@StartDate,GETDATE()-1) AND ISNULL(@EndDate,GETDATE())
AND
--robot name filter 
 (c_controller.controller_name BETWEEN    @RobotFilterMaskStart AND @RobotFilterMaskEnd )
 AND  
 (c_controller.controller_name LIKE @RobotFilterWild)
 --Location Filter
 AND
(ISNULL(c_controller.location,'') LIKE @LocationFilterWild )
 AND
 --Exclude Gatestops 
(
(@ExcludeGateStops = 1 AND (ISNULL(c_logclass1.subgroup,'') NOT LIKE '%Gate/Hold%')) 
OR 
@ExcludeGateStops =0
)
 --minimum log serverity
 AND
 (rt_alarm.error_severity  > (@MinLogserv-1))
 --Enable bit 
 AND
 (@GetC4Gerror = 1)
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--C4G ACTION information (action log)
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
UNION
SELECT 
              c_controller.location AS 'Location',
			  c_controller.controller_name AS 'Robotname',
              'C4G' AS 'Type',
			  'ACTION' AS 'Errortype',
              --convert(char(19),rt_alarm.error_timestamp,120) AS 'timestamp',
			  convert(char(19),((rt_alarm.error_timestamp - '1900-01-01 01:00:00.00') + #C4GActionLogtimediff.timeoffset),120) AS 'timestamp', -- timeoffset houd geen rekening met daylight saving time daarom -1 h 
              ISNULL(c_logtekst.error_number, rt_alarm.error_number) AS 'Logcode',
			  ISNULL(c_logtekst.error_severity, rt_alarm.error_severity) AS 'Severity',
			  ISNULL(c_logtekst.error_text,rt_alarm.error_text) AS 'Logtekst',
			  NULL AS 'Downtime',
			  DATEPART(YEAR, rt_alarm.error_timestamp) AS 'Year',
			  DATEPART(WEEK,rt_alarm.error_timestamp) AS 'Week',
			  --DATEPART(WEEKDAY,rt_alarm.error_timestamp) AS 'Day',
			  GADATA.dbo.fn_volvoday(rt_alarm.error_timestamp,CAST(rt_alarm.error_timestamp AS time)) AS 'day',
			  GADATA.dbo.fn_volvoshift1(rt_alarm.error_timestamp,CAST(rt_alarm.error_timestamp AS time)) AS 'Shift',
			  c_logclass1.appl AS 'Object',
			  c_logclass1.subgroup AS 'Subgroup',
              --debug collums
              --NULL, --SysEventTime.sys_state,
              --NULL AS 'rnDESC',
              CAST(rt_alarm.id AS int) AS 'idx'
              --NULL AS 'SSidx'
			  
FROM    GADATA.dbo.rt_alarm rt_alarm
--join the controller name
JOIN    c_controller ON (rt_alarm.controller_id = c_controller.id) 
--join logtekst table
LEFT JOIN c_logtekst ON (c_logtekst.id = rt_alarm.error_id)

--join a temp table of timeoffset 
LEFT JOIN #C4GActionLogtimediff on (#C4GActionLogtimediff.controller_id = rt_alarm.controller_id)

--try and get an error classification
LEFT JOIN GADATA.dbo.c_logclass1 as c_logclass1 ON 
(
(isnull(c_logtekst.error_number, rt_alarm.error_number) BETWEEN c_logclass1.error_codeStart AND c_logclass1.error_codeEnd)
OR
(isnull(c_logtekst.error_text, rt_alarm.error_text) LIKE c_logclass1.error_tekst)
) 

WHERE
--limit to action logs
rt_alarm.error_is_alarm = 0
AND 
--datetime filter
rt_alarm.error_timestamp  BETWEEN ISNULL(@StartDate,GETDATE()-1) AND ISNULL(@EndDate,GETDATE())
AND
--robot name filter 
(c_controller.controller_name BETWEEN    @RobotFilterMaskStart AND @RobotFilterMaskEnd )
AND  
(c_controller.controller_name LIKE @RobotFilterWild)
--Location Filter
AND
(ISNULL(c_controller.location,'') LIKE @LocationFilterWild )
AND 
@GetC4GAction = 1
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--C3G Alarm information (error log)
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
UNION
SELECT 
              Robot.location AS 'Location',
			  Robot.RobotName AS 'Robotname',
              'C3G' AS 'Type',
			  'ERROR' AS 'Errortype',
              rt_alarm.error_timestamp AS 'timestamp',
              rt_alarm.error_number AS 'Logcode',
              rt_alarm.error_severity AS 'Severity',
              isnull(rt_alarm.error_text,RobotLogText.LogText) AS 'Logtekst',
              NULL AS 'Downtime',
			  DATEPART(YEAR, rt_alarm.error_timestamp) AS 'Year',
			  DATEPART(WEEK,rt_alarm.error_timestamp) AS 'Week',
			  --DATEPART(WEEKDAY,RobotLog.DateTime) AS 'Day',
			  GADATA.dbo.fn_volvoday(rt_alarm.error_timestamp,CAST(rt_alarm.error_timestamp AS time)) AS 'day',
			  GADATA.dbo.fn_volvoshift1(rt_alarm.error_timestamp,CAST(rt_alarm.error_timestamp AS time)) AS 'Shift',
			  c_logclass1.appl AS 'Object',
			  c_logclass1.subgroup AS 'Subgroup',
              --debug collums
              --NULL, --SysEventTime.sys_state,
              --NULL AS 'rnDESC',
              CAST(rt_alarm.id AS int) AS 'idx'
              --NULL AS 'SSidx'
			  
FROM    GADATA.RobotGA.rt_alarm
--join the controller name
JOIN    GADATA.RobotGA.Robot ON (rt_alarm.controller_id = Robot.id)
--joint the logtekst
LEFT JOIN GADATA.RobotGA.RobotLogText ON (rt_alarm.error_text_id = RobotLogText.id)

--try and get an error classification
LEFT JOIN GADATA.dbo.c_logclass1 as c_logclass1 ON 
(
(rt_alarm.error_number BETWEEN c_logclass1.error_codeStart AND c_logclass1.error_codeEnd)
OR
(RobotLogText.LogText LIKE c_logclass1.error_tekst)
) 


WHERE
--only C3G robots
Robotga.robot.Type = 1

AND 
--date time filter
rt_alarm.error_timestamp  BETWEEN ISNULL(@StartDate,GETDATE()-1) AND ISNULL(@EndDate,GETDATE())
AND
--robot name filter 
(Robot.RobotName BETWEEN    @RobotFilterMaskStart AND @RobotFilterMaskEnd )
AND  
(Robot.RobotName LIKE @RobotFilterWild)
--Location Filter
AND
(ISNULL(Robot.location,'') LIKE @LocationFilterWild ) 
AND
 --Exclude Gatestops 
(
(@ExcludeGateStops = 1 AND (ISNULL(c_logclass1.subgroup,'') NOT LIKE '%Gate/Hold%')) 
OR 
@ExcludeGateStops =0
)
--minimum log serverity
AND
(rt_alarm.error_severity  > (@MinLogserv-1))
--enable bit
AND
@GetC3GError = 1
---------------------------------------------------------------------------------------
ORDER BY   Timestamp DESC --robotname,
--*/

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--Activity log (logs the execution of the Query to a table)
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
DECLARE @rowcountmen as int 
SET @rowcountmen = @@rowcount
DECLARE @RequestString as varchar(255)
SET @RequestString =
   CONCAT(
   '[sp_VCSC_C4G_B4beta]',
   ' @StartDate = " '						, @StartDate
     ,' "  ,@EndDate = " '					, @EndDate
     ,' "  ,@RobotFilterWild = " '			, @RobotFilterWild
     ,' "  ,@RobotFilterMaskStart = " '		, @RobotFilterMaskStart
     ,' "  ,@RobotFilterMaskEnd = " '		, @RobotFilterMaskEnd
     ,' "  ,@LocationFilterWild = " '		, @LocationFilterWild 
     ,' "  ,@OrderbyRobot = " '				, @OrderbyRobot 
     ,' "  ,@GetC4GAction = " '				, @GetC4GAction   
     ,' "  ,@GetC4Gerror = " '				, @GetC4Gerror 
     ,' "  ,@GetC4GEvents = " '				, @GetC4GEvents 
     ,' "  ,@GetC4GDowntimes = " '			, @GetC4GDowntimes  
     ,' "  ,@GetC4GDownTBegin = " '			, @GetC4GDownTBegin  
     ,' "  ,@GetC3GError = " '				, @GetC3GError 
     ,' "  ,@ExcludeGateStops = " '			, @ExcludeGateStops  
     ,' "  ,@MinLogserv = " '				, @MinLogserv ,' "'
	)
EXEC GADATA.dbo.sp_Activitylog @rowcount = @rowcountmen, @Request = @RequestString

END