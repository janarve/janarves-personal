@echo off
@REM  standard command shell environment setup

REM Computer-specific stuff
prompt $p$g
SET LS_OPTIONS=--more --color=auto --recent --streams

echo Applying computer-specific settings...
call t:\dev\personal\bin\%COMPUTERNAME%.bat %1
SET PATH=t:\dev\qt-stable\bin;t:\dev\personal\bin;t:\dev\devtools\shell;%PATH%
SET EDITOR=%NOTEPADPP%
REM set GIT_EDITOR=t:\dev\personal\bin\npp.bat
REM set GIT_EDITOR=t:/dev/personal/bin/npp.bat
set GIT_TEMPLATE_DIR=t:\dev\devtools\git\template

IF NOT EXIST "%P4_TREE%" (
    set P4_TREE=t:\dev
)
DOSKEY ll=ls -l $*

set PASTEBIN=pastebin.com

REM for cpaster
set CODEPASTER_HOST=codepaster.europe.nokia.com

call use asperl
call use git

echo Detecting 3rd party libraries...
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
    goto expat_skip
)
set Include=t:\3rdparty\expat\Source\lib;%Include%
set Lib=t:\3rdparty\expat\bin;%Lib%
set PATH=t:\3rdparty\expat\bin;%PATH%
:expat_skip


REM *****************************************************************
REM
REM "detect" open ssl
REM
REM *****************************************************************
if NOT EXIST "t:\3rdparty\openssl64" (
    goto openssl_skip
)
set Include=t:\3rdparty\openssl64\include;%Include%
set Lib=t:\3rdparty\openssl64\lib;%Lib%
set PATH=t:\3rdparty\openssl64\bin;%PATH%
:openssl_skip

