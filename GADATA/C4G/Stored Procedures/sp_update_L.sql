﻿CREATE PROCEDURE [C4G].[sp_update_L]

AS
--USE GADATA
---------------------------------------------------------------------------------------
--set first day of the week to monday (german std)
---------------------------------------------------------------------------------------
SET DATEFIRST 1
---------------------------------------------------------------------------------------
BEGIN
--****************************************************************************************************************--
---------------------------------------------------------------------------------------------------------------------
--In this part we will compare the error text data from rt_alarm with the L_<logtext> tables.
--This is the first part in normalizing the db. (store each text / error type once
print '--*****************************************************************************--'
Print '--Running C4G.sp_update_L'
print '--*****************************************************************************--'
---------------------------------------------------------------------------------------------------------------------
--****************************************************************************************************************--
---------------------------------------------------------------------------------------
Print'--Update L_error with all NEW Unique text, error number and error serv'
---------------------------------------------------------------------------------------
INSERT INTO GADATA.C4G.L_error
SELECT  distinct  
 R.[error_number]
,R.[error_severity]
,ISNULL(R.error_text,c_logtekst.error_text) as 'error_text'
,NULL as 'Appl_id'
,NULL as 'Subgroup_id'
From GADATA.dbo.rt_alarm as R 
--this join is temporary... just to get the 'historical data'  
left join GADATA.dbo.c_logtekst  on R.error_id = c_logtekst.id

Left join GADATA.C4G.L_error as L on
(R.[error_number] = L.[error_number])
AND
(R.[error_severity] = L.[error_severity])
AND
(
(R.error_text = L.error_text)

--temporary
OR
(c_logtekst.error_text = L.error_text)
)
where (L.id IS NULL)
---------------------------------------------------------------------------------------


--****************************************************************************************************************--

--****************************************************************************************************************--
---------------------------------------------------------------------------------------------------------------------
--In this part we will compare the rt_alarm with h_alarm.
--we must check for duplicate errors between rt_alarm and h_alarm.
--alarm text and remedy we will not crosscompare to save time 
---------------------------------------------------------------------------------------------------------------------
--****************************************************************************************************************--

---------------------------------------------------------------------------------------
Print'--step to normalize the rt_alarm dataset. gets the normalized id. and put it in a temp table'
---------------------------------------------------------------------------------------
INSERT INTO GADATA.C4G.h_alarm
SELECT 
 R.controller_id
,R._timestamp
,R.error_timestamp as 'c_timestamp'
,R.error_is_alarm as 'error_is_alarm'
,L_error.id as 'error_id'
,NULL as 'is_realtime'
FROM GADATA.dbo.rt_alarm as R 

--this join is temporary... just to get the 'historical data'  
left join GADATA.dbo.c_logtekst  on R.error_id = c_logtekst.id

--join error_id
join gadata.C4G.L_error on 
(
(L_error.[error_number] = R.[error_number])
AND
(L_error.[error_severity] = R.[error_severity])
AND
(L_error.error_text = ISNULL(R.error_text,c_logtekst.error_text)) --voorlopig
)

--this will filter out unique results
LEFT join GADATA.C4G.h_alarm AS H on 
(
(R.controller_id  = H.controller_id)
AND
(R.error_id  = H.error_id)
)
where (H.id IS NULL)

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--Print'--delete in rt_alarm is exist in h_alarm (Watch => constraints on wi_timestamp / controller_id / error_id)'
---------------------------------------------------------------------------------------
--DELETE FROM gadata.abb.rt_alarm_IRC5 where gadata.abb.rt_alarm_IRC5.id <= (select max(id) from #ABB_AE_normalized)
---------------------------------------------------------------------------------------

--****************************************************************************************************************--

END