@echo off
REM diff is called by git with 7 parameters:
REM path old-file old-hex old-mode new-file new-hex new-mode
IF "_%PROCESSOR_ARCHITECTURE%_" EQU "_AMD64_" (
    C:\Progra~2\WinMerge\WinMergeU.exe /e /x /u /wl /dl "Old File" %2 %5
) else (
    T:\bin\WinMerge-2.8.0-exe\WinMergeU.exe /e /x /u /wl /dl "Old File" %2 %5
)
