﻿CREATE PROCEDURE [dbo].[sp_VCSC_C4G_MDT2]

 @StartDate AS datetime = null 
,@EndDate As datetime = null
,@robot As varchar = '%%'
,@ndays as int = 100 -- number of days history that will be calculated upon rebuild action.
,@Rebuild as bit = 1 -- setting this bit to 1 wil drop all related tables and do a full rebuild. !DANGEROUS!

AS
BEGIN


DECLARE @Timespan as int 
SET @Timespan = 0

---------------------------------------------------------------------------------------
--set first day of the week to monday (german std)
---------------------------------------------------------------------------------------
SET DATEFIRST 1
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
--Set start and en point for the calculation 
---------------------------------------------------------------------------------------
--full rebuild mode
if (@Rebuild = 1)
begin
	SET @StartDate = getdate()- @ndays 
	SET @EndDate = getdate()
end
--update mode 
if (@Rebuild = 0)
begin
  SET @StartDate = getdate()
  SET @EndDate = getdate()
end

--set start date to closest shift begin point
SET @StartDate =  gadata.dbo.[fn_volvoCurrentShiftBegin](@StartDate,CAST(@StartDate AS time))
--set End date to closest shift begin point
SET @EndDate =  gadata.dbo.[fn_volvoCurrentShiftBegin](@EndDate,CAST(@EndDate AS time))

------------------------------------------------------------------------------------------------------------------------------------------------
--Make a temp table that generates all the posible week day shifts from the end and startdate 
------------------------------------------------------------------------------------------------------------------------------------------------
Declare @Temp_L_WeekDayShift table(starttime datetime, shiftlength datetime,year int, week int, day int, shift int)

Declare @shiftlength datetime
Declare @Year int
Declare @week int 
Declare @day int 
Declare @shift int
Declare @Incdate datetime 

SET @Incdate = @StartDate
While @Incdate <= @enddate

Begin
 --calc current shiftlength
 Set @shiftlength = GADATA.dbo.fn_volvoshiftlength(@Incdate,CAST(@Incdate AS time)) 
 --insert current shift in temptable
 Set @Year = datepart(year,@Incdate)
 Set @week = DATEPART(week,@Incdate)
 Set @day = GADATA.dbo.fn_volvoday(@Incdate,CAST(@Incdate AS time))
 Set @Shift = GADATA.dbo.fn_volvoshift1(@Incdate,CAST(@Incdate AS time)) 
 insert into @Temp_L_WeekDayShift values (@Incdate, @shiftlength, @Year, @week, @day, @shift)
 --increment 1 shiftlength
 set @Incdate = @Incdate + @shiftlength	
 --shift counter 
 set @Timespan = @Timespan +1

--drop the temp object in a themp db 
if (OBJECT_ID('tempdb..#Temp_L_weekdayshift') is not null) drop table #Temp_L_weekdayshift
 SELECT * INTO #Temp_L_weekdayshift FROM @Temp_L_WeekDayShift
End



--SELECT *FROM @Temp_L_WeekDayShift
/*
Result
starttime				shiftlength			week  day  shift
2015-01-05 05:15:00.000	1900-01-01 08:15:00.000	2	1	1
2015-01-05 13:30:00.000	1900-01-01 08:00:00.000	2	1	2
2015-01-05 21:30:00.000	1900-01-01 07:45:00.000	2	1	3
2015-01-06 05:15:00.000	1900-01-01 08:15:00.000	2	2	1
2015-01-06 13:30:00.000	1900-01-01 08:00:00.000	2	2	2
2015-01-06 21:30:00.000	1900-01-01 07:45:00.000	2	2	3
2015-01-07 05:15:00.000	1900-01-01 08:15:00.000	2	3	1
2015-01-07 13:30:00.000	1900-01-01 08:00:00.000	2	3	2
2015-01-07 21:30:00.000	1900-01-01 07:45:00.000	2	3	3
2015-01-08 05:15:00.000	1900-01-01 08:15:00.000	2	4	1
*/
------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------
--Jah.... complicated to explain. 
------------------------------------------------------------------------------------------------------------------------------------------------
if (OBJECT_ID('tempdb..#Temp_uniqueSubgroups') is not null) drop table #Temp_uniqueSubgroups
BEGIN
SELECT DISTINCT 
c_logclass1.APPL,
c_logclass1.Subgroup
INTO #Temp_uniqueSubgroups
FROM c_logclass1
END


------------------------------------------------------------------------------------------------------------------------------------------------
--Crossjoin Temp_L_WeekDayShift with Robots objects and subgroups
--This is already a HEAVY join 3 sec for 12 shifts (35000 records)
------------------------------------------------------------------------------------------------------------------------------------------------
if (OBJECT_ID('tempdb..#Temp_L_WeekDayShift_RobotObjectSubgroup') is not null) drop table #Temp_L_WeekDayShift_RobotObjectSubgroup
BEGIN
SELECT 
starttime, 
shiftlength,
shift,
day,
week, 
Year,
#Temp_uniqueSubgroups.subgroup,
#Temp_uniqueSubgroups.appl,
c_controller.id as 'controllerID'
INTO #Temp_L_WeekDayShift_RobotObjectSubgroup
FROM #Temp_L_weekdayshift
CROSS JOIN #Temp_uniqueSubgroups
CROSS JOIN c_controller 
END

--SELECT * from #Temp_L_WeekDayShift_RobotObjectSubgroup 
/*
result
starttime	shiftlength	shift	day	week	subgroup	appl	controllerID
2015-02-11 13:30:00.000	1900-01-01 08:00:00.000	2	3	7	subgroup  	appl      	147
2015-02-11 13:30:00.000	1900-01-01 08:00:00.000	2	3	7	subgroup  	appl      	148
2015-02-11 13:30:00.000	1900-01-01 08:00:00.000	2	3	7	subgroup  	appl      	149
2015-02-11 13:30:00.000	1900-01-01 08:00:00.000	2	3	7	subgroup  	appl      	150
2015-02-11 13:30:00.000	1900-01-01 08:00:00.000	2	3	7	subgroup  	appl      	151
2015-02-11 13:30:00.000	1900-01-01 08:00:00.000	2	3	7	subgroup  	appl      	152
2015-02-11 13:30:00.000	1900-01-01 08:00:00.000	2	3	7	subgroup  	appl      	153
2015-02-11 13:30:00.000	1900-01-01 08:00:00.000	2	3	7	subgroup  	appl      	154
2015-02-11 13:30:00.000	1900-01-01 08:00:00.000	2	3	7	subgroup  	appl      	155
2015-02-11 13:30:00.000	1900-01-01 08:00:00.000	2	3	7	subgroup  	appl      	156
2015-02-11 13:30:00.000	1900-01-01 08:00:00.000	2	3	7	subgroup  	appl      	157
*/
------------------------------------------------------------------------------------------------------------------------------------------------
 
------------------------------------------------------------------------------------------------------------------------------------------------
--Join L_breakdown with logclass (just to get the right object and subgroup from a breakdown)
--also calc week day shift for later join + downtime in seconds
------------------------------------------------------------------------------------------------------------------------------------------------
if (OBJECT_ID('tempdb..#Temp_L_breakdownGroups') is not null) drop table #Temp_L_breakdownGroups
BEGIN
SELECT
controller_id,
EndOfBreakdown,
StartOfBreakdown,
error_number,
error_text,
idx,
DATEPART(YEAR,Endofbreakdown) as 'Year',
DATEPART(WEEK,EndOfBreakdown) AS 'Week',
GADATA.dbo.fn_volvoday(EndOfBreakdown,CAST(EndOfBreakdown AS time)) AS 'day',
GADATA.dbo.fn_volvoshift1(EndOfBreakdown,CAST(EndOfBreakdown AS time)) AS 'Shift',
c_logclass1.appl,
c_logclass1.Subgroup,
DowntimeM = DATEDIFF(MINUTE,StartOfBreakdown,EndOfBreakdown)
INTO #Temp_L_breakdownGroups
FROM L_breakdown

--try and get an error classification
LEFT JOIN GADATA.dbo.c_logclass1 as c_logclass1 ON 
(
(L_breakdown.error_number BETWEEN c_logclass1.error_codeStart AND c_logclass1.error_codeEnd)
OR
(L_breakdown.error_text LIKE RTRIM(c_logclass1.error_tekst))
)

WHERE EndOfBreakdown BETWEEN @StartDate AND @EndDate
END

--SELECT * from #Temp_L_breakdownGroups 
/*
result
controller_id	EndOfBreakdown	StartOfBreakdown	error_number	error_text	idx	Week	day	Shift	appl	Subgroup 
144	2015-02-11 05:55:09.243	2015-02-11 05:54:39.247	28808	Safety gate	2326365	7	3	1	Safety    	Gate/Hold 
*/
------------------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------------------
--Join L_breakdown with logclass (just to get the right object and subgroup from a breakdown)
------------------------------------------------------------------------------------------------------------------------------------------------
if (OBJECT_ID('tempdb..#Temp_L_breakdownTest') is not null) drop table #Temp_L_breakdownTest
BEGIN
SELECT
#Temp_L_WeekDayShift_RobotObjectSubgroup.starttime, 
#Temp_L_WeekDayShift_RobotObjectSubgroup.shiftlength,
#Temp_L_WeekDayShift_RobotObjectSubgroup.shift,
#Temp_L_WeekDayShift_RobotObjectSubgroup.day,
#Temp_L_WeekDayShift_RobotObjectSubgroup.week,
#Temp_L_WeekDayShift_RobotObjectSubgroup.Year, 
#Temp_L_WeekDayShift_RobotObjectSubgroup.subgroup,
#Temp_L_WeekDayShift_RobotObjectSubgroup.appl,
#Temp_L_WeekDayShift_RobotObjectSubgroup.controllerID,
ISNULL(#Temp_L_breakdownGroups.DowntimeM,0) as'downtimeM',
#Temp_L_breakdownGroups.DowntimeM as 'exists'
INTO #Temp_L_breakdownTest
FROM #Temp_L_WeekDayShift_RobotObjectSubgroup
LEFT JOIN #Temp_L_breakdownGroups on
(
(#Temp_L_WeekDayShift_RobotObjectSubgroup.shift = #Temp_L_breakdownGroups.shift)
AND
(#Temp_L_WeekDayShift_RobotObjectSubgroup.day = #Temp_L_breakdownGroups.day)
AND
(#Temp_L_WeekDayShift_RobotObjectSubgroup.week = #Temp_L_breakdownGroups.week)
AND
(#Temp_L_WeekDayShift_RobotObjectSubgroup.Year = #Temp_L_breakdownGroups.Year)
AND
(#Temp_L_WeekDayShift_RobotObjectSubgroup.subgroup = #Temp_L_breakdownGroups.subgroup)
AND
(#Temp_L_WeekDayShift_RobotObjectSubgroup.appl = #Temp_L_breakdownGroups.appl)
AND
(#Temp_L_WeekDayShift_RobotObjectSubgroup.controllerID = #Temp_L_breakdownGroups.controller_id)
)
END
------------------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------------------
--calc the mean and Grand totals for each for each subgroup
------------------------------------------------------------------------------------------------------------------------------------------------
if (OBJECT_ID('tempdb..#Temp_L_M_STDEV') is not null) drop table #Temp_L_M_STDEV
BEGIN
SELECT 
#Temp_L_breakdownTest.subgroup,
#Temp_L_breakdownTest.appl,
#Temp_L_breakdownTest.controllerID,
COUNT(#Temp_L_breakdownTest.[exists]) as 'GTotalnDB',
--COUNT(#Temp_L_breakdownTest.shift) as 'GTotalnShift', why does this not work good :( 
@Timespan as 'GTotalnShift',
[AVG] = ((COUNT(#Temp_L_breakdownTest.[exists])*1.0) / (@Timespan*1.0)),
SUM(#Temp_L_breakdownTest.[exists]) as 'GTotalDT'
into #Temp_L_M_STDEV 
from #Temp_L_breakdownTest
GROUP BY controllerID, appl, Subgroup
END

--SELECT * FROM #Temp_L_M_STDEV where controllerID = 144 AND subgroup LIKE '%meas%'
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
--make a c table with al the controllers application and subgroups that are beeing tested
------------------------------------------------------------------------------------------------------------------------------------------------
if (OBJECT_ID('C_Nextgen') is not null) drop table C_Nextgen
SELECT DISTINCT 
#Temp_L_M_STDEV.controllerID,
c_controller.controller_name,
#Temp_L_M_STDEV.APPL,
#Temp_L_M_STDEV.Subgroup
into C_Nextgen
FROM #Temp_L_M_STDEV
join c_controller on c_controller.id = #Temp_L_M_STDEV.controllerID
where #Temp_L_M_STDEV.GTotalnDB <> 0

------------------------------------------------------------------------------------------------------------------------------------------------
--calc the number of breakd downs per shift day week appl subgroup 
------------------------------------------------------------------------------------------------------------------------------------------------
if (OBJECT_ID('tempdb..#Temp_L_CountPerShift') is not null) drop table #Temp_L_CountPerShift
BEGIN
SELECT 
#Temp_L_breakdownTest.shift,
#Temp_L_breakdownTest.day,
#Temp_L_breakdownTest.week, 
#Temp_L_breakdownTest.Year, 
#Temp_L_breakdownTest.subgroup,
#Temp_L_breakdownTest.appl,
#Temp_L_breakdownTest.controllerID,
COUNT(#Temp_L_breakdownTest.[exists]) as 'cnBD',
ISNULL(SUM(#Temp_L_breakdownTest.[exists]),0) as 'tDT'
into #Temp_L_CountPerShift
from #Temp_L_breakdownTest
GROUP BY controllerID, appl, Subgroup, Year, week, day, shift
END
 

--SELECT * FROM #Temp_L_CountPerShift where controllerID = 144 AND subgroup LIKE '%meas%'
----------------------------------------------------------------------------------------------------------------------------------------------
--time for excel
if (OBJECT_ID('L_Nextgen') is not null) drop table L_Nextgen

SELECT 
#Temp_L_CountPerShift.[shift],
#Temp_L_CountPerShift.[day],
#Temp_L_CountPerShift.[week],
#Temp_L_CountPerShift.[Year],
#Temp_L_CountPerShift.[subgroup],
#Temp_L_CountPerShift.[appl],
--#Temp_L_CountPerShift.[controllerID],
c_controller.controller_name,
#Temp_L_CountPerShift.cnBD,
#Temp_L_CountPerShift.tDT,
#Temp_L_M_STDEV.GTotalDT,
#Temp_L_M_STDEV.GTotalnDB,
#Temp_L_M_STDEV.GTotalnShift,
#Temp_L_M_STDEV.AVG
INTO L_Nextgen
FROM #Temp_L_CountPerShift
LEFT JOIN c_controller on (c_controller.id = #Temp_L_CountPerShift.controllerID)
join #Temp_L_M_STDEV on 
(
(#Temp_L_CountPerShift.controllerID = #Temp_L_M_STDEV.controllerID)
AND
(#Temp_L_CountPerShift.APPL = #Temp_L_M_STDEV.appl)
AND
(#Temp_L_CountPerShift.Subgroup = #Temp_L_M_STDEV.Subgroup)
AND 
(#Temp_L_M_STDEV.GTotalDT is not null) --this excludes non existing object specs 
)
WHERE c_controller.controller_name LIKE @robot 
order by controller_name, APPL, Subgroup, [year] ,[week], [day], [shift]  desc 


SELECT * FROM L_Nextgen

END