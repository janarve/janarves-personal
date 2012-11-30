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
call use python

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
echo [D-Bus]    C:\Program Files (x86)\dbus\bin
goto dbus_found
:dbus1

if NOT EXIST "C:\Program Files\dbus\include" (
    goto dbus2
)
set PATH=%PATH%;C:\Program Files\dbus\bin
set Include=%Include%;C:\Program Files\dbus\include
set Lib=%Lib%;C:\Program Files\dbus\lib
echo [D-Bus]    C:\Program Files\dbus\bin
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
echo [Expat]    t:\3rdparty\expat
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
echo [OpenSSL]  t:\3rdparty\openssl64
:openssl_skip


REM *****************************************************************
REM
REM "detect" cmake
REM
REM *****************************************************************

FOR /F "tokens=* delims=" %%A IN ('reg query "HKLM\SOFTWARE\Wow6432Node\Kitware\CMake 2.8.0" /ve ^| findstr "(Default)"') do (
    set CMAKE_PATH=%%A\bin\
)
REM extract the last path stuff (and remove last backspace), 18 + strlen("(Default)") = 27
set CMAKE_PATH=%CMAKE_PATH:~27,-1%

if NOT EXIST "%CMAKE_PATH%\cmake.exe" (
    goto cmake_skip
)
set PATH=%PATH%;%CMAKE_PATH%
echo [CMake]    %CMAKE_PATH%
:cmake_skip



REM *****************************************************************
REM
REM "detect" ruby
REM
REM *****************************************************************

FOR /F "tokens=* delims=" %%A IN ('reg query "HKLM\SOFTWARE\Wow6432Node\RubyInstaller\MRI\1.9.3" /v InstallLocation ^| findstr "REG_SZ"') do (
    set RUBY_PATH=%%A\bin\
)
REM RUBY_PATH contains "    InstallLocation    REG_SZ    C:\Ruby193\bin\"
REM extract the last path stuff (and remove last backspace)
set RUBY_PATH=%RUBY_PATH:~33,-1%
if NOT EXIST "%RUBY_PATH%\ruby.exe" (
    goto ruby_skip
)
set PATH=%PATH%;%RUBY_PATH%
echo [Ruby]     %RUBY_PATH%
:ruby_skip


REM *****************************************************************
REM
REM "detect" ICU
REM
REM *****************************************************************
set ICU_PATH=t:\3rdparty\icu4c-49_1_2-Win32-msvc10\icu
if NOT EXIST "%ICU_PATH%" (
    goto icu_skip
)
SET INCLUDE=%INCLUDE%;%ICU_PATH%\include
SET LIB=%LIB%;%ICU_PATH%\lib
SET PATH=%PATH%;%ICU_PATH%\bin
echo [ICU]      %ICU_PATH%
:icu_skip