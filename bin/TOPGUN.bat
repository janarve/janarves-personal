@echo off
REM 
REM Development setup for my home computer
REM 
SET HOME=c:\jans
SET NOTEPADPP=C:\PROGRA~1\NOTEPA~1\NOTEPA~1.exe
DOSKEY 7z=c:\PROGRA~1\7-ZIP\7z.exe $*

REM setup mingw and git, make sure that ActivePerl is before the msys bin directory (it also contains perl.exe)
SET GITPATH=c:\PROGRA~1\Git
SET PATH=T:\bin;c:\jans\bin;%PATH%
REM setup cmake
REM set PATH=%PATH%;C:\jans\bin\cmake-2.6.0-win32-x86\bin
