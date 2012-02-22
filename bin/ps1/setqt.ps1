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
.\setqt.ps1 .
Will set QTDIR to the current directory.

.EXAMPLE
.\setqt.ps1 5\qtbase
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

function setPath($loc){
    # Remove old QTDIR\bin from PATH
    if ($env:QTDIR) {
        $pattern = ";$env:QTDIR\bin"
        $env:PATH = $env:PATH.replace($pattern, "")
    }
    $newQTDIR = $null
    if (Test-Path $loc) {
        # Try relative and absolute
        $loc = Resolve-Path $loc
        $newQTDIR = $loc
    } else {
        if (!$Env:QTREPOS) {
            $qtRepos = Read-host "Please enter the complete path to your Qt depot (T:\dev)"
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

        if (Test-Path ($Env:QTREPOS + "\qt-" + $loc)) {
            $loc = Resolve-Path ($Env:QTREPOS + "\qt-" + $loc)
            $newQTDIR = $loc
        }
    }
    if ($newQTDIR) {
        $Env:QTDIR = $newQTDIR
        $Env:Path = "$newQTDIR\bin;" + $Env:Path
        Write-Host "Qt version is set to $newQTDIR"
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
        } else {
            Write-Host "QTDIR is not set"
        }
    }
}
# Calling main function
. main