@echo off
@REM workaround for notepad++, since it has problems opening several relative files
IF "_%PROCESSOR_ARCHITECTURE%_" EQU "_AMD64_" (
    @start C:\Progra~2\notepad++\notepad++.exe %~f1 %~f2 %~f3 %~f4 %~f5 %~f6
) else (
    @start /B c:\PROGRA~1\NOTEPA~1\NOTEPA~1.exe %~f1 %~f2 %~f3 %~f4 %~f5 %~f6 %~f7
)
