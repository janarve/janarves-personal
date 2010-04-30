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

