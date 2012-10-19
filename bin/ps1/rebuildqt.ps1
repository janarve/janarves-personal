param([switch]$pull)

$QTDIR = Get-QtBasePath
Push-Location $QTDIR

Set-Location ..
qtrepotools\bin\qt5_tool -c
if ($pull) {
    qtrepotools\bin\qt5_tool -p
}
c

jom
Pop-Location