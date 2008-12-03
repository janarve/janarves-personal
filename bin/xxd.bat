@echo off
IF "_%PROCESSOR_ARCHITEW6432%_" EQU "_AMD64_" (
    xxd-64.exe %*
) else (
    xxd-32.exe %*
)