@REM  standard command shell environment setup
@echo off

REM Computer-specific stuff
prompt $p$g
SET LS_OPTIONS=--more --color=auto --recent --streams
call %p4_tree%\personal\bin\%COMPUTERNAME%.bat

SET PATH=%p4_tree%\personal\bin;%p4_tree%\devtools\shell;%PATH%;%GITPATH%\bin
SET EDITOR=%NOTEPADPP%
set GIT_EDITOR=vim
DOSKEY ll=ls -l $*

