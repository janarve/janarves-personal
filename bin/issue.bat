@echo off
IF EXIST t:\tasks\QTBUG-%1 (
    cd t:\tasks\QTBUG-%1
    goto :EOF
)

IF EXIST t:\tasks\QT-%1 (
    cd t:\tasks\QT-%1
    goto :EOF
)

IF EXIST t:\tasks\%1 (
    cd t:\tasks\%1
    goto :EOF
)

IF EXIST t:\tasks\%1* (
    cd t:\tasks\%1*
    goto :EOF
)

IF EXIST t:\tasks\*%1 (
    cd t:\tasks\*%1
    goto :EOF
)

echo Could not find any issue matching "%1".