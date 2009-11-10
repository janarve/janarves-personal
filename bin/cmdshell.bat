@REM  standard command shell environment setup
@echo off

REM Computer-specific stuff
prompt $p$g
SET LS_OPTIONS=--more --color=auto --recent --streams
call t:\dev\personal\bin\%COMPUTERNAME%.bat

SET PATH=t:\dev\personal\bin;t:\dev\devtools\shell;%PATH%;%GITPATH%\bin
SET EDITOR=%NOTEPADPP%
set GIT_EDITOR=vim
DOSKEY ll=ls -l $*

