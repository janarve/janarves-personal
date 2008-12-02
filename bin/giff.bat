@echo off
REM assumes taht git_external_diff.cmd is in the same path as giff.bat
SETLOCAL
SET GIT_EXTERNAL_DIFF=git_external_diff.cmd
git diff --exit-code %*
