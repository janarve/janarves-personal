@echo off
IF "_%PROCESSOR_ARCHITECTURE%_" EQU "_AMD64_" (
    xxd-64.exe %*
) else (
    xxd-32.exe %*
)