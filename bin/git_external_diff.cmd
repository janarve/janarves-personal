@echo off
REM diff is called by git with 7 parameters:
REM path old-file old-hex old-mode new-file new-hex new-mode


SET WINMERGE=C:\Progra~2\WinMerge\WinMergeU.exe
IF EXIST "%WINMERGE%" (
    goto showdiff
)

SET WINMERGE=T:\bin\WinMerge-2.8.0-exe\WinMergeU.exe
IF EXIST "%WINMERGE%" (
    goto showdiff
)

echo "WinMerge not found"
goto :EOF

:showdiff
%WINMERGE% /e /x /u /wl /dl "Old File" %2 %5

