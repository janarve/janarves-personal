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

.\qtrepotools\bin\qt5_tool -c --Branch stable
if ($pull) {
    .\qtrepotools\bin\qt5_tool -p --Branch stable
}
$start = Get-Date
.\qtrepotools\bin\qt5_tool -b --Branch stable
(Get-Date) - $start
Pop-Location