REM 
REM 
IF NOT "%1" EQU "" (
	call setqt %1
	call qcd
)

call git pull
call jom
if NOT "%ERRORLEVEL%" EQU "0" (
	choice /C YN /T 10 /D Y /M "Perform clean build"
	IF "%ERRORLEVEL%" EQU 1 (
		rem call git clean -dfx
		rem call configure -nokia-developer
		rem call jom
	)
)
