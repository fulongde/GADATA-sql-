﻿


CREATE FUNCTION [C3G].[fn_ShortSysstate] 
	(
		@Sysstate int
	) 
RETURNS varchar(30) 
AS 
BEGIN 
	declare @SysstateString varchar(50) 
	SET @SysstateString = ''

	
--Connection ---------------------------------------------------------
--=0 connection lost to robot
IF (@sysstate = 0)
BEGIN
  SET @SysstateString =  'Disconnected '
  return @SysstateString 
END

--=1 Controller side not running
IF (@sysstate  = 1)
BEGIN
  SET @SysstateString =  'Controller Watchdog '
  return @SysstateString 
END


---------------------------------------------------------

-- bit 15 AUTO-local
IF (@sysstate & 16384 = 16384)
BEGIN
 SET @SysstateString =  @SysstateString +'T2 |'
END

--bit 16 PROG -- for some reason does not work...
--IF (@sysstate & 262144 = 262144)
-- dan maar niet locaal en niet remote voor T
IF (not (@sysstate & 16384 = 16384) AND not  (@sysstate & 8192 = 8192))
BEGIN
 SET @SysstateString =  @SysstateString +'T1 |'
END
---------------------------------------------------------
/*


*/
--optional state ---------------------------------------------------------


--bit 4 safety gate or Estop
IF (@sysstate & 8 = 8)
BEGIN
  SET @SysstateString = @SysstateString + 'Safety Gate OR E-stop (SS)'
   return @SysstateString 
END

--bit 6 maint from plc
IF (@sysstate & 32 = 32)
BEGIN
  SET @SysstateString = @SysstateString + 'Maint mode has been selected '
  return @SysstateString 
END

--not bit 7 Application fault
IF NOT (@sysstate & 64 = 64)
BEGIN
  SET @SysstateString = @SysstateString + 'Appl '
END


--bit 27 System alarm
IF (@sysstate & 67108864 = 67108864)
BEGIN
  SET @SysstateString = @SysstateString + 'Alarm '
END

-- bit 30 HOLD
IF (@sysstate & 536870912 = 536870912)
BEGIN
  SET @SysstateString = @SysstateString + 'Hold '
END

-- bit 31 DriveOff
IF (@sysstate & 1073741824 = 1073741824)
BEGIN
  SET @SysstateString = @SysstateString + 'DriveOff (SS) '
END
---------------------------------------------------------

return @SysstateString 
end