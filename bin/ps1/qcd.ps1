param([string]$subdir)

$qtdir = $null
if ($env:QTDIR) {
    $qtdir = $env:QTDIR
} elseif ($env:SETQT_PATH) {
    $qtdir = $env:SETQT_PATH -replace "\\bin", ""
}

if (!$qtdir) {
    Write-Host "Could not detect location of Qt, neither through QTDIR or SETQT_PATH. Run setqt <version>"
    return
}

if (!$subdir) {
    Push-Location $qtdir
} else {
    foreach ($s in @("src", "examples", ".", "..")) {
        $dest = "$qtdir\$s\$subdir"
        if (Test-Path $dest) {
            Push-Location $dest
            return
        }
    }
    Write-Host "$subdir not found in QTDIR, .., src or examples"
    return
}
