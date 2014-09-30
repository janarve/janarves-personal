<#
.SYNOPSIS
A tool to rebuild the current Qt version

.DESCRIPTION
This script will do the following procedure:
1. git clean -dfx across all repos
2. update all repositories with git pull (optional)
3. run configure
4. build with jom

.EXAMPLE
.\rebuildqt.ps1

.NOTES
Experimental

.LINK
http://sjarve@gmail.com

#>

param([switch]$pull)

$QTDIR = Get-QtBasePath
Push-Location $QTDIR

Set-Location ..

.\qtrepotools\bin\qt5_tool -c
if ($pull) {
    .\qtrepotools\bin\qt5_tool -p
}
$start = Get-Date
.\qtrepotools\bin\qt5_tool -b
(Get-Date) - $start
Pop-Location