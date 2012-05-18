setqt 5-x86

if (Test-Path Function:\TabExpansion) {

    $qtteBackup = 'qcd_DefaultTabExpansion'
    if (!(Test-Path Function:\$qtteBackup)) {
        Rename-Item Function:\TabExpansion $qtteBackup
    }
    Write-Host "installed qcd tab expansion"    
    
    function TabExpansion($line, $lastWord) {
        
        if ($env:QTDIR) {
            $lastBlock = [regex]::Split($line, '[|;]')[-1].TrimStart()
            
            switch -regex ($lastBlock) {
                # Execute qcd tab completion 
                "qcd .*" {
                    $arg = $lastWord
                    $lastSlash = $arg.lastIndexOf('\')
                    $lastSlash = $lastSlash + 1
                    $base = $arg.substring(0, $lastSlash)
                    foreach ($s in @("src", "examples", ".", "..")) {   # Order must be the same as in qcd
                        Get-ChildItem "$env:QTDIR\$s\$lastWord*" | ForEach-Object { $base + $_.Name }
                    }
                }
                # Fall back on existing tab expansion
                default { & $qtteBackup $line $lastWord }
            }
        } else {
            & $qtteBackup $line $lastWord
        }
    }
}