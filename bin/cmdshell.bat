@echo off
@REM  standard command shell environment setup

REM Computer-specific stuff
IF EXIST "%P4_TREE%" (
	goto :EOF
)
prompt $p$g
SET LS_OPTIONS=--more --color=auto --recent --streams

call t:\dev\personal\bin\%COMPUTERNAME%.bat %1
SET PATH=t:\dev\qt-stable\bin;t:\dev\personal\bin;t:\dev\devtools\shell;%PATH%;%GITPATH%\bin
SET EDITOR=%NOTEPADPP%
REM set GIT_EDITOR=t:\dev\personal\bin\npp.bat
set GIT_EDITOR=t:/dev/personal/bin/npp.bat
set GIT_TEMPLATE_DIR=t:\dev\devtools\git\template

set P4_TREE=t:\dev
DOSKEY ll=ls -l $*

set PASTEBIN=pastebin.com

REM for cpaster
set CODEPASTER_HOST=codepaster.europe.nokia.com

set CHOICE_OPT_Y=/C YN /T 0 /D Y
set CHOICE_OPT_N=/C YN /T 0 /D N

REM call use git

REM *****************************************************************
REM
REM "detect" Git
REM
REM *****************************************************************
if NOT EXIST "%GITPATH%\bin" (
    goto git_skip
)
choice %CHOICE_OPT_Y% /M Git
if ERRORLEVEL 2 goto git_skip
SET PATH=%PATH%;%GITPATH%\bin
:git_skip


REM *****************************************************************
REM
REM "detect" GnuWin32
REM
REM *****************************************************************
if NOT EXIST "c:\dev\GnuWin32\bin" (
    goto gnuwin32_skip
)
choice %CHOICE_OPT_Y% /M GnuWin32
if ERRORLEVEL 2 goto gnuwin32_skip
SET PATH=c:\dev\GnuWin32\bin;%PATH%
:gnuwin32_skip



REM *****************************************************************
REM
REM "detect" ActiveState Perl
REM
REM *****************************************************************
if NOT EXIST "c:\perl\bin" (
    goto asperl_skip
)
choice %CHOICE_OPT_Y% /M "ActiveState Perl"
if ERRORLEVEL 2 goto asperl_skip
SET PATH=c:\perl\bin;%PATH%
:asperl_skip



REM *****************************************************************
REM
REM "detect" python
REM
REM *****************************************************************
if NOT EXIST "c:\python26" (
    goto python_skip
)
choice %CHOICE_OPT_N% /M Python
if ERRORLEVEL 2 goto python_skip
SET PATH=c:\python26;%PATH%
:python_skip


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

