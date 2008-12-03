@REM  standard command shell environment setup
@echo off

REM Computer-specific stuff
call %p4_tree%\personal\bin\%COMPUTERNAME%.bat

SET PATH=%p4_tree%\personal\bin;%p4_tree%\devtools\shell;%PATH%
SET EDITOR=%NOTEPADPP%
set GIT_EDITOR=vim
DOSKEY npp=%NOTEPADPP% $*
DOSKEY ll=ls -l $*

