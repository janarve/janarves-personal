@echo off
REM
if "%1" EQU "" (
    echo Usage:
    echo    gitboss ^<file^>
    goto :EOF
)
SETLOCAL
SET SORT="c:\Program Files\Git\bin\sort.exe"
REM git log -40 %1 | grep '^Author:' | %SORT% +1 | uniq -c  | %SORT% -r +0
git blame %1 | cut -b11-31 | %SORT% +0 | uniq -c | %SORT% -r +0

