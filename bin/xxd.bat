@echo off
IF (%PROCESSOR_ARCHITECTURE%) EQU (AMD64) (
    xxd-64.exe %*
) else (
    xxd-32.exe %*
)