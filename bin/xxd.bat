@echo off

SET BASE=%~dp0
IF (%PROCESSOR_ARCHITECTURE%) EQU (AMD64) (
    %BASE%xxd-64.exe %*
) else (
    %BASE%xxd-32.exe %*
)