param([string]$subdir)

if (!$env:QTDIR) {
    Write-Host "QTDIR not set. Run setqt <version>"
    return
} elseif (!$subdir) {
    Push-Location $env:QTDIR
} else {
    foreach ($s in @(".", "..", "src", "examples")) {
        $dest = "$env:QTDIR\$s\$subdir"
        if (Test-Path $dest) {
            Push-Location $dest
            return
        }
    }
    Write-Host "$subdir not found in QTDIR, .., src or examples"
    return
}
