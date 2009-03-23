@REM 
@echo off
IF "%1" EQU "" (
    goto usage
)
IF "%1" EQU "/?" (
    goto usage
)

SETLOCAL
SET SORTCMD=%GITPATH%\bin\sort.exe
git blame %1 | sed -e "s/.*(\\([^)][^)]*\\) [0-9][0-9][0-9][0-9]-.*/\1/g" | %SORTCMD% +0 | uniq -c | %SORTCMD% +0 -r
goto :EOF

:usage
echo Usage: gitboss ^<filename^>
echo     Shows how many lines a user have changed in the current version of the ^<filename^>.
