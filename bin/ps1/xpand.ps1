param([string]$command, [string]$archive)
if (!$command -or !$archive) {
    Write-Host "Syntax: xpand <command> <file name>"
    Exit-PSSession
}
function whereIs($needle){
    $splitPath = $Env:path.split(';')
    $found = $false
    foreach($p in $splitPath){
        $fullPath = [System.IO.Path]::Combine($p, $needle)
        $found = Test-Path $fullPath
        if ($found) {
            return $fullPath
        }
    }

    return $null
}
$expandTools = @{"7z.exe"    = @("HKCU:\Software\7-Zip", "Path");
                 "tar.exe"   = @();
                 "unzip.exe" = @()}


$global:expandExtensions = @{".7z"      = @( @("7z.exe",    "x"));
                             ".xz"      = @( @("7z.exe",    "x"));
                             ".tar.gz"  = @( @("tar.exe",   "zxf", "zlf"));
                             ".tar"     = @( @("7z.exe",    "x", "l"),
                                             @("tar.exe",   "xf", "tf"));
                             ".tar.bz2" = @( @("7z.exe",    "x", "l"),
                                             @("tar.exe",   "jxf", "jlf"));
                             ".zip"     = @(
                                             @("7z.exe",    "x"),
                                             @("unzip.exe", $null)
                                    )
                    }

foreach ($key in $expandExtensions.keys) {
    if ($archive.endsWith("$key")) {
        $candidatePrograms = $expandExtensions[$key]
        foreach($cmdList in $candidatePrograms) {
            $cmd = $cmdList[0]

            if ($command -eq "x") {
                $opt = $cmdList[1]
            }


            if ($command -eq "l" -and ($cmdList.Length -gt 2)) {
                $opt = $cmdList[2]
            }

            "opt: $opt"
            $arr = $expandTools[$cmd]
            "arr: '$arr'"
            if ($arr.count -eq 2) {
                # If array has 2 entries, it has:
                # 0. registry path
                # 1. keyname
                $regKey = $arr[0]
                if (Test-Path $regKey) {
                    $keyName = $arr[1]
                    $fullPath = (Get-ItemProperty $arr[0])."$keyName"
                    $progName = $cmd
                    $fullPath += "$progName"
                    Write-Host $fullPath
                    if (Test-Path $fullPath) {
                        Write-Host "$fullPath $opt $archive"
                        & $fullPath $opt $archive
                        return
                    }
                }
            } elseif ($arr.count -eq 0) {
                # Look in $env:Path
                $fullPath = whereIs($cmd)
                if ($fullPath) {
                    if ($opt) {
                        $args = "$opt $archive"
                    } else {
                        $args = "$archive"
                    }
                    Write-Host "$fullPath $args"
                    & $fullPath "$args"
                    return
                }
            }
        }
    }
}

