﻿
CREATE PROCEDURE [NGAC].[sp_CalcTipWearBeforeChange]
  @daysBack as int = 40 --must be this high because some tips are on the robot a LONG time
AS
BEGIN
---------------------------------------------------------------------------------------------------------------------
print '--*****************************************************************************--'
Print '--Running [NGAC].[sp_CalcTipWearBeforeChange]'
print '--*****************************************************************************--'
---------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
print'preselect data'
---------------------------------------------------------------------------------------
if (OBJECT_ID('tempdb..#TipWearBeforeChange') is not null) drop table #TipWearBeforeChange
SELECT 
 x.controller_name
,x.controller_id
,x.tipDressID
,x.Tool_Nr
,x.TipchangeTimestamp
,x.FixedWearBeforeChange
,x.MoveWearBeforeChange
,x.WearBeforeChange
,(x.MaxWeldsbetweenDresses * x.DressBeforeChange) as  'WeldsBeforeChange'
,x.DressBeforeChange 
,x.DeltaNom
,x.DeltaNomBeforeChange
,ROUND((X.FixedWearBeforeChange  / X.Max_Wear_Fixed)*100,0)as '%FixedWearBeforeChange' --fixed dataType cast !!
,ROUND((X.MoveWearBeforeChange  / X.Max_Wear_Move)*100,0) as '%MoveWearBeforeChange' --fixed dataType cast !!
,(x.MaxWeldsbetweenDresses * x.DressBeforeChange) * (((100-ROUND((X.FixedWearBeforeChange  / X.Max_Wear_Fixed)*100,0))/100)+1) as 'ESTnSpotsFixedWearBefore100'
,(x.MaxWeldsbetweenDresses * x.DressBeforeChange) * (((100-ROUND((X.MoveWearBeforeChange  / X.Max_Wear_Move)*100,0))/100)+1)  as 'ESTnSpotsMoveWearBefore100'
,DATEDIFF(hour,x.PreviousTipchange,X.TipchangeTimestamp) as 'TipAge(h)'

into #TipWearBeforeChange

FROM (
--sub select the number of welds for that tiplife************************************************************************************--
SELECT 
*
--estemate number of welds for this tiplife.
--SDEBEUL 18w16d1 before this we did SUM but this is wrong because we only log on big dressen.
--now we take MAX welds between dresses and multiply later with the number of dresses.
,(
SELECT TOP 1 ISNULL(MAX(rt.Weld_Counter),0) 
FROM GADATA.NGAC.rt_TipDressLogFile as rt 
WHERE rt.rt_csv_file_id = Z.rt_csv_file_id
AND isnull(rt.[Tool_Nr],1)  = Z.Tool_Nr
AND rt.[Date Time] BETWEEN Z.PreviousTipchange AND Z.TipchangeTimestamp
) as 'MaxWeldsbetweenDresses'
FROM(
--join previous tipchange to get that timestamp************************************************************************************--
SELECT 
*
,lead(Y.TipchangeTimestamp) OVER (PARTITION BY y.controller_name, y.Tool_nr  ORDER BY y.TipchangeTimestamp desc) as 'PreviousTipchange' 
--*********************************************************************************************************************************--
FROM (
--get date from a single tip interval**********************************************************************************************--
SELECT
 c.controller_name
,c.id as 'controller_id'
,rt.id as 'tipDressID'
,rt.rt_csv_file_id
,rt.[Date Time] as 'TipchangeTimestamp'
,isnull(rt.[Tool_Nr],1)  as 'Tool_Nr'
,rt.Dress_Num 
,rt.Weld_Counter
,rt.Max_Wear_Fixed
,rt.Max_Wear_Move
,rt.Dress_Reason
,rt.ErrorType
,[NGAC].[DistanceBetweenPoints]([GunTCP_X],[GunTCP_Y],[GunTCP_Z],[NomTCP_X],[NomTCP_Y],[NomTCP_Z]) as 'DeltaNom'
,lead([NGAC].[DistanceBetweenPoints]([GunTCP_X],[GunTCP_Y],[GunTCP_Z],[NomTCP_X],[NomTCP_Y],[NomTCP_Z])) OVER (PARTITION BY c.controller_name, rt.Tool_nr  ORDER BY rt.[Date Time] desc) as 'DeltaNomBeforeChange'
,lead(rt.Wear_Fixed) OVER (PARTITION BY c.controller_name, rt.Tool_nr  ORDER BY rt.[Date Time] desc) as 'FixedWearBeforeChange'
,lead(rt.Wear_Move) OVER (PARTITION BY c.controller_name, rt.Tool_nr  ORDER BY rt.[Date Time] desc) as 'MoveWearBeforeChange'
,lead(rt.Current_TipWear) OVER (PARTITION BY c.controller_name, rt.Tool_nr  ORDER BY rt.[Date Time] desc) as 'WearBeforeChange'
,lead(rt.Dress_num) OVER (PARTITION BY c.controller_name, rt.Tool_nr  ORDER BY rt.[Date Time] desc) as 'DressBeforeChange'
from GADATA.NGAC.rt_TipDressLogFile as rt 
left join GADATA.NGAC.rt_csv_file as rt_csv on rt.rt_csv_file_id = rt_csv.id
left join GADATA.NGAC.c_controller as c on c.id = rt_csv.c_controller_id
--SDEBEUL bugfix 18w04d3
/*
When we have a fault like weld colaps or something like that a record gets inserted with no read wear values.
controller_name	id	rt_csv_file_id	Date Time	Tool_Nr	Dress_Num	Weld_Counter	Dress_Reason	Weld_Result	Length_Fixed_Result	Length_Move_Result	Max_Wear_Fixed	Wear_Fixed	DiffFrLastWear_Fixed	Max_Wear_Move	Wear_Move	DiffFrLastWear_Move	MaxDiffFrLastMeas	Current_TipWear	TipWearRatio	Dress_Time1	Dress_Pressure1	Dress_Time2	Dress_Pressure2	CleanDress_Time	CleanDress_Pressure	Time_DressCycleTime	ErrorType	ExtraInfo	GunTCP_X	GunTCP_Y	GunTCP_Z	GunRefTCP_X	GunRefTCP_Y	GunRefTCP_Z	NomTCP_X	NomTCP_Y	NomTCP_Z	Tool_NrHs	ChkDrWear_Fixed_Result	ChkDrWear_Move_Result	FxSens_SetupVal	FxSens_StartVal	FxSens_PrevVal	FxSens_PrevWare	FxSens_DiffValue	FxSens_MaxSensZComp	FxSens_WarmSensZComp	FxSens_FlPinPrevVal	FxSens_FlPinSetupVal	FxSens_FlPinPhysActVal	FxSens_FlPinPhysSetupVal	Internal_Arg	DeltaRef	DeltaNom
357040R11	115642	4957	2018-01-23 02:14:44.000	1	3	0	InitDress	OK	OK	OK	6	0,64	-5,05	6	0,64	-5,14	NULL	1,28	NULL	3	1176,47	2	1176,47	NULL	NULL	56,6	NULL	NULL	1287,701	1682,299	427,062	1287,7	1682,3	427,703	1287,7	1682,3	427,84	6	NEW	NEW	11,435	11,591	12,232	0,641	0,137	10	9	11,353	11,335	425,36	425,36	4110	0,64	0,78
This must be excluded. Can be detected by Dress_reason = "" o
*/
WHERE len(rt.Dress_Reason) > 1

--limit date range for Query performance
AND rt._timestamp between GETDATE()-@daysBack and GETDATE()
) AS Y
WHERE 

--robot mounted guns
(
	Y.Dress_Num = 0 
AND Y.Dress_Reason = 'FullDress'
--SDEBEUL bugfix 18w20d4
/*
Also possible to have fault when dress_reson is filled in.
controller_name	LocationTree	id	rt_csv_file_id	Date Time	Tool_Nr	Dress_Num	Weld_Counter	Dress_Reason	Weld_Result	Length_Fixed_Result	Length_Move_Result	Max_Wear_Fixed	Wear_Fixed	DiffFrLastWear_Fixed	Max_Wear_Move	Wear_Move	DiffFrLastWear_Move	MaxDiffFrLastMeas	Current_TipWear	TipWearRatio	Dress_Time1	Dress_Pressure1	Dress_Time2	Dress_Pressure2	CleanDress_Time	CleanDress_Pressure	Time_DressCycleTime	ErrorType	ExtraInfo	GunTCP_X	GunTCP_Y	GunTCP_Z	GunRefTCP_X	GunRefTCP_Y	GunRefTCP_Z	NomTCP_X	NomTCP_Y	NomTCP_Z	Tool_NrHs	ChkDrWear_Fixed_Result	ChkDrWear_Move_Result	FxSens_SetupVal	FxSens_StartVal	FxSens_PrevVal	FxSens_PrevWare	FxSens_DiffValue	FxSens_MaxSensZComp	FxSens_WarmSensZComp	FxSens_FlPinPrevVal	FxSens_FlPinSetupVal	FxSens_FlPinPhysActVal	FxSens_FlPinPhysSetupVal	Internal_Arg	DeltaRef	DeltaNom	_timestamp
336040R03	VCG -> A -> A GA1.0 -> A LIJN 336 -> A STN336040 -> 336040R03	766849	4032	2018-05-23 23:18:33.000	1	1	15	FullDress	NOK	NOK	OK	6	-2,04	-2,04	6	-2,55	-2,55	1	-4,59	44,5	3	1176,5	1,5	1176,5	0,5	100	15,2	OverMill		-881,07	814,13	251,72	-881,07	814,13	251,72	-881,58	813,42	251,04	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	0	1,11	2018-05-23 23:18:32.737
336040R03	VCG -> A -> A GA1.0 -> A LIJN 336 -> A STN336040 -> 336040R03	766688	4032	2018-05-23 22:41:13.000	1	0	0	FullDress	OK	OK	OK	6	0	0	6	0	0	1	0,02	44,5	3	1176,5	1,5	1176,5	0,5	100	47,9			-881,07	814,13	251,72	-881,07	814,13	251,72	-881,58	813,42	251,04	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	NULL	0	1,11	2018-05-23 22:41:17.310
In this case there was en error in ErrorType (these records must be excluded)
--bugfix 18W23 when you apply this to statguns nothing is returnd.
*/
AND len(Y.ErrorType) < 1
)
OR --stat guns
(
Y.Dress_Num in (0,1,2,3) --normaly guns are set to 3 dresses in init-dress but some are change to 2 this clause will handle all 
AND 
Y.Dress_Reason = 'InitDress'
)
AND Y.DressBeforeChange is not null 
--*********************************************************************************************************************************--
) AS Z
) AS X

--select * from #TipWearBeforeChange


---------------------------------------------------------------------------------------
print'insert new data'
---------------------------------------------------------------------------------------
--DROP TABLE gadata.ngac.h_TipWearBeforeChange
INSERT INTO gadata.ngac.h_TipWearBeforeChange
SELECT 
	   temp.[controller_name]
      ,temp.[controller_id]
      ,temp.[tipDressID]
      ,temp.[Tool_Nr]
      ,temp.[TipchangeTimestamp]
      ,temp.[FixedWearBeforeChange]
      ,temp.[MoveWearBeforeChange]
      ,temp.[WearBeforeChange]
      ,temp.[WeldsBeforeChange]
      ,temp.[DressBeforeChange]
      ,temp.[%FixedWearBeforeChange]
      ,temp.[%MoveWearBeforeChange]
      ,temp.[ESTnSpotsFixedWearBefore100]
      ,temp.[ESTnSpotsMoveWearBefore100]
      ,temp.[TipAge(h)]
	  ,temp.DeltaNom
	  ,temp.DeltaNomBeforeChange
--INTO gadata.ngac.h_TipWearBeforeChange
FROM #TipWearBeforeChange as temp

Left join gadata.ngac.h_TipWearBeforeChange as h on
h.tipDressID = temp.tipDressID
where 
h.tipDressID IS NULL



END