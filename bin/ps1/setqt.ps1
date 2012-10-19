<#
.SYNOPSIS
A tool to switch between different installed Qt versions

.DESCRIPTION
The tool will set the QTDIR environment variable, and append %QTDIR%\bin
to the PATH environment variable.
It tries to find the desired Qt version by 3 different strategies,
in the following order:
1. If an absolute path is given and it exist, the path will be used.
2. If an relative path is given and it exist, the corresponding absolute
   path of the relative path will be used.
3. If QTREPOS is set it will check if there exists a directory located
   under $QTREPOS named qt-$qtdir. If that exist, it will set QTDIR
   to $QTREPOS\qt-$qtdir.

.EXAMPLE
.\setqt.ps1 c:\projects\qt-5\qtbase
Will switch to the Qt version installed at c:\projects\qt-5\qtbase, if it exists.

.EXAMPLE
.\setqt.ps1 qt-48
If current directory is c:\projects, will set QTDIR to c:\projects\qt-48, if it exists.

.EXAMPLE
.\setqt.ps1 none
Will unset QTDIR environment variable and remove $env:QTDIR\bin from the PATH environment variable.

.EXAMPLE
.\setqt.ps1 .
Will set QTDIR to the current directory.

.EXAMPLE
.\setqt.ps1 5\qtbase
If QTREPOS is set to c:\dev, it will switch to the Qt version installed
at c:\dev\qt-5\qtbase

.EXAMPLE
.\setqt.ps1 5
If QTREPOS is set to c:\dev, it will switch to the Qt version installed
at c:\dev\qt-5\qtbase

.EXAMPLE
.\setqt.ps1 47
If QTREPOS is set to c:\dev, it will switch to the Qt version installed
at c:\dev\qt-47

.LINK
http://jans.tihlde.org
#>
param([string]$qtdir, [switch]$clean)

$setQTDIR = $false

function resolveQtPath($loc)
{
   if (Test-Path $loc) {
        # Try relative and absolute
        $loc = Resolve-Path $loc
        if (Test-Path ("$loc\qtbase\bin")) {
            $loc = "$loc\qtbase"
        }
        return $loc
    }
    return $null
}

### Appends $newValue to the environment variable specified by $envName
### Stores what was appended to $envNameAppendedPortion in order to know
### how to restore it back to its original form.
function updateEnvironmentPathValue($envName, $envNameAppendedPortion, $newValue)
{
    $result = $null

    $oldVar = $null
    if (Test-Path -path env:$envNameAppendedPortion) {
        $oldVar = (Get-Item -path env:$envNameAppendedPortion).Value
    }

    $nameVar = $null
    if (Test-Path -path env:$envName) {
        $nameVar = (Get-Item -path env:$envName).Value
    }

    if ($oldVar) {
        $result = $nameVar.replace($oldVar, $newValue)
    } else {
        if ($newValue) {
            if ($nameVar) {
                $result = $nameVar + ";"
            }
            $result += $newValue
        }
    }
    if ($result) {
        Set-Item -path env:$envName -value "$result"
        Set-Item -path env:$envNameAppendedPortion -value "$newValue"
    }
}

function setPath($loc){
    if (!($loc -eq "none")) {
        $newQTDIR = resolveQtPath($loc)
        if (!$newQTDIR) {
            if (!$Env:QTREPOS) {
                $qtRepos = Read-host "Please enter the complete path to your Qt development area (T:\dev)"
                if (!$qtRepos) {
                    $qtRepos = "T:\dev"
                }
                $Env:QTREPOS = $qtRepos
                $storeQtdep = Read-host "Do you want to set the location of your Qt depot as a permanent setting?(y/n)"
                if ($storeQtdep -eq "y") {
                    Write-Host "Qt depot location stored as permanent environment variable. To remove, run .\setqt.ps1 -clean"
                    [Environment]::SetEnvironmentVariable("QTREPOS", "$qtRepos", "User")
                } else {
                    if (!($storeQtdep -eq "n")) {
                        Write-Host "Invalid input"
                    }
                    Write-Host "Qt depot location temporarily stored and will be available in this session only."
                }
            }
            $newQTDIR = resolveQtPath($Env:QTREPOS + "\qt-" + $loc)
        }
    }
    if ($newQTDIR -or $loc -eq "none") {
        # If successful, first remove old QTDIR\bin from PATH, then unset $env:QTDIR
        if ($env:SETQT_PATH) {
            $pattern = $env:SETQT_PATH
            $env:PATH = $env:PATH.replace(";$pattern", "")      #doing it twice in case its the first or last item in the Path
            $env:PATH = $env:PATH.replace("$pattern;", "")

            if ($setQTDIR) {
                $env:QTDIR = $null
            }
            $env:SETQT_PATH = $null
        }

        if ($newQTDIR) {
            if ($setQTDIR) {
                $Env:QTDIR = $newQTDIR
            }
            updateEnvironmentPathValue "PATH" "SETQT_PATH" "$newQTDIR\bin"
            Write-Host "Qt version is set to $newQTDIR"
        } else {
            # ($loc -eq "none")
            Write-Host "Qt version is unset."
        }
    } else {
        Write-Host "Could not find the given Qt version"
    }
}

# Main function
function main(){
    if ($clean){
        Write-Host "Cleaning up QTREPOS environment variable"
        [Environment]::SetEnvironmentVariable("QTREPOS", "", "User")
        $Env:QTREPOS = ""
    } elseif ($qtdir) {
        setPath $qtdir
    } else {
        if ($Env:QTDIR){
            Write-Host "$Env:QTDIR"
        } elseif ($Env:SETQT_PATH) {
            Write-Host ($Env:SETQT_PATH -replace "\\bin", "")
        } else {
            Write-Host "QTDIR is not set"
        }
    }
}
# Calling main function
. main
