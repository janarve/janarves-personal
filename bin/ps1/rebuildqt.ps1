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
Outputs the current compiler

.NOTES
Experimental

.LINK
http://sjarve@gmail.com

#>

param([string]$config, [switch]$pull, [switch]$nobuild)

$do_build = !$nobuild

$QTDIR = Get-QtBasePath
Push-Location $QTDIR

Set-Location ..
qtrepotools\bin\qt5_tool -c
if ($pull) {
    qtrepotools\bin\qt5_tool -p
}

if (!$config) {
    c
    if ($do_build) {
        jom
    }
} else {
    c "-$config"
    if ($do_build) {
        jom $config
    }
}
Pop-Location