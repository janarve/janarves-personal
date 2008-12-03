@echo off
REM 
REM Development setup for my home computer
REM 
SET HOME=c:\jans
SET NOTEPADPP=C:\PROGRA~1\NOTEPA~1\NOTEPA~1.exe
DOSKEY 7z=c:\PROGRA~1\7-ZIP\7z.exe $*

REM setup mingw and git
SET PATH=c:\jans\bin;%PATH%;C:\PROGRA~1\Git\bin

REM setup cmake
REM set PATH=%PATH%;C:\jans\bin\cmake-2.6.0-win32-x86\bin
