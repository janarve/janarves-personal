@echo off
REM diff is called by git with 7 parameters:
REM path old-file old-hex old-mode new-file new-hex new-mode
c:/Progra~2/WinMerge/WinMergeU.exe /e /x /u /wl /dl "Old File" %2 %5
