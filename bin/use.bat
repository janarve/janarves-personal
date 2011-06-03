@echo off
REM
REM
REM

call :detect

IF (%1) == () (
    goto :usage
)


if (%1) EQU (asperl) (
    goto use_asperl
)
if (%1) EQU (bzr) (
    goto use_bzr
)
if (%1) EQU (cmake) (
    goto use_cmake
)
if (%1) EQU (git) (
    goto use_git
)
if (%1) EQU (hg) (
    goto use_hg
)
if (%1) EQU (gnuwin32) (
    goto use_gnuwin32
)

:use_asperl
SET PATH=%PATH%;%USE_ASPERL_DESC%
goto :quit

:use_bzr
SET PATH=%PATH%;%USE_BZR_DESC%
goto :EOF

:use_cmake
set PATH=%PATH%;c:\Program Files (x86)\CMake 2.8\bin
goto :EOF

:use_git
SET PATH=%PATH%;%USE_GIT_DESC%
goto :EOF

:use_gnuwin32
SET PATH=%USE_GNUWIN32_DESC%;%PATH%
goto :EOF

:use_hg
SET PATH=%PATH%;%USE_HG_DESC%
goto :EOF


REM *****************************************************************
REM
REM Detect function
REM
REM *****************************************************************
:detect

REM -- asperl ------------------------------------
if NOT EXIST "c:\perl\bin" (
    goto detect_skip_asperl
)
set USE_ASPERL_DESC=c:\perl\bin
:detect_skip_asperl


REM -- bzr ------------------------------------
if NOT EXIST "c:\PROGRA~2\Bazaar" (
    goto detect_skip_bzr
)
set USE_BZR_DESC=c:\PROGRA~2\Bazaar
:detect_skip_bzr


REM -- cmake ------------------------------------
if NOT EXIST "c:\Program Files (x86)\CMake 2.8\bin" (
    goto detect_cmake_skip
)
set USE_CMAKE_DESC=c:\Program Files (x86)\CMake 2.8\bin
:detect_cmake_skip


REM -- git ------------------------------------
IF "%GITPATH%" EQU "" (
    goto detect_git1
)
REM GITPATH is set:
if EXIST "%GITPATH%\bin\git.exe" (
    goto detect_found_git
)
:detect_git1
REM GITPATH is not set (or its incorrect)
set GITPATH=c:\Program Files (x86)\Git
if EXIST "%GITPATH%\bin\git.exe" (
    goto detect_found_git
)

goto detect_skip_git
:detect_found_git
set USE_GIT_DESC=%GITPATH%\bin
:detect_skip_git


REM -- hg ------------------------------------
if NOT EXIST "c:\Program Files (x86)\Mercurial" (
    goto detect_skip_hg
)
set USE_HG_DESC=c:\Program Files (x86)\Mercurial
:detect_skip_hg


REM -- GnuWin32 ------------------------------------
if NOT EXIST "c:\dev\GnuWin32\bin" (
    goto detect_skip_gnuwin32
)
set USE_GNUWIN32_DESC=c:\dev\GnuWin32\bin
:detect_skip_gnuwin32


goto :EOF



:usage
    echo Usage:
    echo   use ^<program^>, where ^<program^> must be one of the following:

    if NOT (%USE_ASPERL_DESC%) EQU () (
    echo     asperl      [%USE_ASPERL_DESC%]
    )

    if NOT (%USE_BZR_DESC%) EQU () (
    echo     bzr         [%USE_BZR_DESC%]
    )

    if "%USE_CMAKE_DESC%" EQU "" ( goto usage_cmake_skip)
    echo     cmake       [%USE_CMAKE_DESC%]
:usage_cmake_skip


    if "%USE_GIT_DESC%" EQU "" ( goto usage_git_skip)
    echo     git         [%USE_GIT_DESC%]
:usage_git_skip

    if "%USE_HG_DESC%" EQU "" ( goto usage_hg_skip)
    echo     hg          [%USE_HG_DESC%]
:usage_hg_skip

    if NOT (%USE_GNUWIN32_DESC%) EQU () (
    echo     gnuwin32    [%USE_GNUWIN32_DESC%]
    )

    goto :EOF
