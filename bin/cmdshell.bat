@echo off
@REM  standard command shell environment setup

REM Computer-specific stuff
prompt $p$g
SET LS_OPTIONS=--more --color=auto --recent --streams
call t:\dev\personal\bin\%COMPUTERNAME%.bat

SET PATH=t:\dev\qt-stable\bin;t:\dev\personal\bin;t:\dev\devtools\shell;%PATH%;%GITPATH%\bin
SET EDITOR=%NOTEPADPP%
set GIT_EDITOR=t:\dev\personal\bin\npp.bat
set P4_TREE=t:\dev
DOSKEY ll=ls -l $*

set PASTEBIN=pastebin.com

REM for cpaster
set CODEPASTER_HOST=codepaster.europe.nokia.com


REM *****************************************************************
REM
REM Detect d-bus compiled from source
REM
REM *****************************************************************
goto dbus_skip
if NOT EXIST "C:\Program Files (x86)\dbus\include" (
    goto dbus1
)
set PATH=%PATH%;C:\Program Files (x86)\dbus\bin
set Include=c:\Progra~2\dbus\include
set Lib=%Lib%;C:\Program Files (x86)\dbus\lib
goto dbus_found
:dbus1

if NOT EXIST "C:\Program Files\dbus\include" (
    goto dbus2
)
set PATH=%PATH%;C:\Program Files\dbus\bin
set Include=%Include%;C:\Program Files\dbus\include
set Lib=%Lib%;C:\Program Files\dbus\lib
goto dbus_found
:dbus2
:dbus_found

:dbus_skip


REM *****************************************************************
REM
REM "detect" expat
REM 
REM *****************************************************************
if NOT EXIST "t:\3rdparty\expat" (
    goto expat
)
set Include=t:\3rdparty\expat\Source\lib;%Include%
set Lib=t:\3rdparty\expat\bin;%Lib%
set PATH=t:\3rdparty\expat\bin;%PATH%
:expat


REM *****************************************************************
REM
REM "detect" open ssl
REM 
REM *****************************************************************
set Include=t:\3rdparty\openssl64\include;%Include%
set Lib=t:\3rdparty\openssl64\lib;%Lib%
set PATH=t:\3rdparty\openssl64\bin;%PATH%


REM cmake
set PATH=%PATH%;c:\Program Files (x86)\CMake 2.8\bin

