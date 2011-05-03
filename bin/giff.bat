@echo off
REM assumes taht git_external_diff.cmd is in the same path as giff.bat
SETLOCAL
IF EXIST "%1" (
    IF EXIST "%2" (
        C:\Progra~2\WinMerge\WinMergeU.exe %1 %2
        goto :EOF
    )
)
SET GIT_EXTERNAL_DIFF=git_external_diff.cmd
git diff --exit-code %*
