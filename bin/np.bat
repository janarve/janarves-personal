@REM
@REM Small wrapper batch file for opening files with Notepad++.
@REM  jan-arve.saether@nokia.com
@REM 
@REM does not work if EDITOR contains parentheses
@echo off

SETLOCAL
IF "_%1_" == "_/?_" (
    goto usage
)

set NPP=C:\PROGRA~1\NOTEPA~1\NOTEPA~1.exe

IF "%EDITOR%" == "" goto no_editor
    set NPP=%EDITOR%
:no_editor
    
IF exist "%NPP%" goto found_editor
    echo Could not find %NPP%, please set the EDITOR environment variable
    goto :EOF
:found_editor

REM SET VV=%1
REM -- Split the input argument into drive, path, and linenumber, using colon as delimiters
for /f "tokens=1,2,3 delims=:" %%a in ("%1") do set FILENAME=%%a&set LINEINFILE=%%b&set LINEINFILE2=%%c

REM We split the filename on colon, so we must handle these three cases:
REM 1. c:\a.txt
REM 2. c:\a.txt:122
REM 3. a.txt:122

IF "_%LINEINFILE2%_" EQU "__" goto no_case2
REM     this case: "c:\a.txt:122"
    set FILENAME=%FILENAME%:%LINEINFILE%
    set LINEINFILE=%LINEINFILE2%
    goto skip
)
:no_case2

IF "%1" == "" (
    goto skip
)
SET TMP_ARG=%1
IF "%TMP_ARG:~1,1%" NEQ ":" goto skip
REM     this case: "c:\a.txt"
set FILENAME=%1
set LINEINFILE=
set LINEINFILE2=
:skip
echo %NPP%
IF not "_%LINEINFILE%_" EQU "__" goto linenumber_else
    start /b %NPP% %*
    goto linenumber_endif
:linenumber_else
    start /b %NPP% -n%LINEINFILE% %FILENAME%
:linenumber_endif
goto :EOF

:usage
echo Usage: np ^<filename^> [:^<linenumber^>]
echo     Opens a file in Notepad++. If the argument has a filename:line syntax it will open the file at that specific line.
