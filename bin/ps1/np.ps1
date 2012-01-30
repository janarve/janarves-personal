#
# Small wrapper batch file for opening files with Notepad++.
#  jan-arve.saether@nokia.com
# 
# does not work if EDITOR contains parentheses
#@echo off
#
#SETLOCAL
#IF (%1) == (/?) (
    #goto usage
#)

param($Argument1)


$env:NPP="c:\Program Files (x86)\Notepad++\notepad++.exe"


& $env:NPP $Argument1
