@REM jasaethe@trolltech.com
@REM 
@echo off
set E_SWITCHES=/e,
if __E%1E__ == __EE__ (
    @explorer %E_SWITCHES% .
    goto end
)

if exist %1 (
    explorer %E_SWITCHES% %1
)
:end

