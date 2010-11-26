REM 
REM 

call t:\dev\personal\bin\cmdshell.bat
call setqt main
call qcd
call git pull
call jom
if NOT "%ERRORLEVEL%" EQU "0" (
	call git clean -dfx
	call configure -nokia-developer
	call jom
)
