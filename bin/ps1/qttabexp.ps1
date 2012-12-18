setqt 5-x86-stable

if (Test-Path Function:\TabExpansion) {

    $qtteBackup = 'qcd_DefaultTabExpansion'
    if (!(Test-Path Function:\$qtteBackup)) {
        Rename-Item Function:\TabExpansion $qtteBackup
    }
    Write-Host "installed qcd tab expansion"

    function TabExpansion($line, $lastWord) {
        $qtdir = Get-QtBasePath
        if ($qtdir) {
            $lastBlock = [regex]::Split($line, '[|;]')[-1].TrimStart()

            switch -regex ($lastBlock) {
                # Execute qcd tab completion
                "qcd .*" {
                    $arg = $lastWord
                    $lastSlash = $arg.lastIndexOf('\')
                    $lastSlash = $lastSlash + 1
                    $base = $arg.substring(0, $lastSlash)
                    foreach ($s in @("src", "examples", ".", "..")) {   # Order must be the same as in qcd
                        Get-ChildItem "$qtdir\$s\$lastWord*" | ForEach-Object { $base + $_.Name }
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



function detectInstalledLibraries($arch, [ref]$newIncludes, [ref]$newLibs, [ref]$newPaths)
{
    # "include", "lib", "PATH"
    $detectionVariables = @{
        "x86" = @(
            @("${env:DXSDK_DIR}Include", "${env:DXSDK_DIR}Lib\x86", "${env:DXSDK_DIR}Utilities\Bin\x86"),
            @("T:\3rdparty\icu*\icu\lib\..\include", "T:\3rdparty\icu*\icu\lib", "T:\3rdparty\icu*\icu\bin"),
            #@("t:\3rdparty\openssl-1.0.0a\include", "t:\3rdparty\openssl-1.0.0a\out_win32", "t:\3rdparty\openssl-1.0.0a\out_win32"),
            @("t:\3rdparty\expat\Source\lib", "t:\3rdparty\expat\bin", "t:\3rdparty\expat\bin"),
            @("t:\dev\devtools\database\include\db2", "t:\dev\devtools\database\lib\msvc", "t:\dev\devtools\database\bin"),
            @("t:\dev\devtools\database\include\fbird", "t:\dev\devtools\database\lib\msvc", "t:\dev\devtools\database\bin"),
            @("t:\dev\devtools\database\include\mysql", "t:\dev\devtools\database\lib\msvc", "t:\dev\devtools\database\bin"),
            @("t:\dev\devtools\database\include\oci", "t:\dev\devtools\database\lib\msvc", "t:\dev\devtools\database\bin"),
            @("t:\dev\devtools\database\include\psql", "t:\dev\devtools\database\lib\msvc", "t:\dev\devtools\database\bin"),
            @("t:\dev\devtools\database\include\tds", "t:\dev\devtools\database\lib\msvc", "t:\dev\devtools\database\bin")
        );
        "amd64" = @(
            @("${env:DXSDK_DIR}Include", "${env:DXSDK_DIR}Lib\x64", @("${env:DXSDK_DIR}Utilities\Bin\x86",
                                                                      "${env:DXSDK_DIR}Utilities\Bin\x64")),
            @("T:\3rdparty\icu*\icu\lib64\..\include", "T:\3rdparty\icu*\icu\lib64", "T:\3rdparty\icu*\icu\bin64"),
            @("t:\3rdparty\openssl64\include", "t:\3rdparty\openssl64\lib", "t:\3rdparty\openssl64\bin")
        )
    }

    # expat
    $regPath = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\expat_is1"
    $expatPath = $null
    if (Test-Path $regPath) {
        $expatPath = (Get-ItemProperty $regPath)."InstallLocation"
    } else {
        $programFiles = (Get-Item 'env:ProgramFiles(x86)').Value
        if (!$programFiles) {
            $programFiles = (Get-Item 'env:ProgramFiles').Value
        }
        if ($programFiles) {
            $expatPath = "$programFiles\Expat 2.1.0"
        }
    }
    if ($expatPath -and (Test-Path $expatPath)) {
        $expatPath = $expatPath.TrimEnd('\')
        $detectionVariables["x86"] += ,@("$expatPath\Source\lib", "$expatPath\bin", "$expatPath\Bin")
#        $detectionVariables["amd64"] += ,@("$expatPath\Source\lib", "$expatPath\bin", "$expatPath\Bin")
    }


    #--------------------------------------
    $addUnique = {  param($arr, $item);
        if (! ($arr.Value -contains $item)) {
            $arr.Value = $arr.Value + $item
        }
    }

    $smartResolvePath = { param($path);
        $splitted = $path -split "\\\.\.\\"
        if ($splitted.count -eq 2) {
            $first = Resolve-Path $splitted[0]
            $last = $splitted[1]
            return (Resolve-Path "$first\..\$last").Path
        }
        return (Resolve-Path $path).Path
    }

    foreach($detectionVars in $detectionVariables[$arch]) {
        $var = $detectionVars
        $pathIsValid = $false
        if ($var[2] -is [array]) {
            foreach ($p in $var[2]) {
                $pathIsValid = Test-Path $p
                if (!$pathIsValid) {
                    break
                }
            }
        } elseif ($var[2] -is [string]) {
            $pathIsValid = Test-Path $var[2]
        }
        if ((Test-Path $var[0]) -and (Test-Path $var[1]) -and $pathIsValid) {
            & $addUnique ($newIncludes) (& $smartResolvePath $var[0])
            & $addUnique ($newLibs) (& $smartResolvePath $var[1])
            if ($var[2] -is [array]) {
                foreach ($p in $var[2]) {
                    & $addUnique ($newPaths) (& $smartResolvePath $p)
                }
            } else {
                & $addUnique ($newPaths) (& $smartResolvePath $var[2])
            }
        }
    }
}

function Get-Batchfile($file, $SetCmdArgs, [ref]$environmentHash) {
    # we need to chdir to the path, because cmd cannot take an path argument
    # that contain spaces (e.g. c:\Program Files\)
    $tempFilePre = [IO.Path]::GetTempFileName()
    $tempFilePost = [IO.Path]::GetTempFileName()
    $path = [System.IO.Path]::GetDirectoryName($file)
    $fileName = [System.IO.Path]::GetFileName($file)
    pushd $path

    $command = "set > $tempFilePre && .\$fileName $SetCmdArgs 2>&1 && set > $tempFilePost"
    cmd /c "$command" > $null
## Go through the environment variables in the temp file.
## For each of them, set the variable in our local environment.

    $preHash = @{}
    Get-Content $tempFilePre | Foreach-Object {
        if ($_ -match "^(.*?)=(.*)$") {
            $n = $matches[1]
            $preHash[$n] = $matches[2]
        }
    }

    $postHash = @{}
    Get-Content $tempFilePost | Foreach-Object {
        if ($_ -match "^(.*?)=(.*)$") {
            $n = $matches[1]
            $postHash[$n] = $matches[2]
        }
    }

    foreach ($key in $postHash.keys) {
        $val = $postHash[$key]
        $oldVal = $preHash[$key]
        $newVal = $null
        if (!$oldVal) {
            $newVal = $val
        } elseif ($oldVal -ne $val) {
            if ($val.contains($oldVal)) {
                $newVal = $val.replace($oldVal,"")
            } else {
                $newVal = $val
            }
        }
        if ($newVal) {
            $environmentHash.Value[$key] = $newVal
        }
    }

    popd
    Remove-Item $tempFilePre
    Remove-Item $tempFilePost
}

# Used to restore the environment variables back to its original content
$globalEnvironmentHash = @{}

function SetCmd($version = "7.1", $arch = "x86")
{
    $environmentHash = @{}

    $key = "HKLM:\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v$version\WinSDKTools"
    if ((Test-Path $key) -or ($version -eq "none")) {
        # Restore back to original content
        foreach ($envName in $globalEnvironmentHash.keys) {
            $oldVal = $globalEnvironmentHash[$envName]
            $currentVal = (Get-Item -path "env:$envName").Value
            $originalVal = $currentVal.replace($oldVal, "")
            Set-Item -path "env:$envName" -value "$originalVal"
        }
        $globalEnvironmentHash.clear()

        if ($version -ne "none") {
            $VsKey = get-ItemProperty $key
            $VsInstallPath = [System.IO.Path]::GetDirectoryName($VsKey.InstallationFolder)
            $VsToolsDir = $VsInstallPath
            $BatchFile = [System.IO.Path]::Combine($VsToolsDir, "SetEnv.Cmd")
            Get-Batchfile "$BatchFile" "/$arch" ([ref]$globalEnvironmentHash)
            [System.Console]::Title = "Visual Studio " + $version + " Windows Powershell"

            $NewIncludes = $globalEnvironmentHash["INCLUDE"].TrimEnd(";") -split ";"
            $NewLibs = $globalEnvironmentHash["LIB"].TrimEnd(";") -split ";"
            $NewPaths = $globalEnvironmentHash["PATH"].TrimEnd(";") -split ";"

            detectInstalledLibraries $arch ([ref]$NewIncludes) ([ref]$NewLibs) ([ref]$NewPaths)

            $globalEnvironmentHash["INCLUDE"] = $NewIncludes -join ";"
            $globalEnvironmentHash["LIB"] = $NewLibs -join ";"
            $globalEnvironmentHash["PATH"] = $NewPaths -join ";"

        }


#    $globalEnvironmentHash.Remove("ORIGINALPATH")
        if ($version -ne "none") {
            # update
            foreach ($key in $globalEnvironmentHash.keys) {
                $newVal = $globalEnvironmentHash[$key]
                if (Test-Path "env:$key") {
                    $currentVal = (Get-Item -path "env:$key").Value
                    #Write-Host "current: $key = $currentVal"
                    #Write-Host "new:     $key = $newVal"
                    if (!$newVal.startsWith(";")) {
                        #prepend
                        $currentVal = "$newVal;$currentVal"
                    } else {
                        #append
                        $currentVal += "$newVal"
                    }
                } else {
                    $currentVal = $newVal
                }
                Set-Item -path "env:$key" $currentVal
            }
        }
        return $true
    } else {
        return $false
    }
}

function Set-Compiler($compilerSpec = "msvc2010", $arch = "x86")
{
    $foundCompiler = $false
    switch ($compilerSpec) {
        "none" {
            $foundCompiler = SetCmd "none"
        }
        "msvc2010" {
            $foundCompiler = SetCmd "7.1" $arch
        }
       "mingw46" {
            if (Test-Path "c:\mingw\bin\mingw32-gcc-4.6*.exe") {
                $compilerFound = $true
                $env:Path="c:\mingw\bin;$env:Path"
            }
        }

        default {
            $foundCompiler = $false
        }
    }
    if ($foundCompiler) {
        if ($version -eq "none") {
            Write-Host "Unregistering compiler"
        } else {
            Write-Host "MS SDK set to $compilerSpec ($arch)"
        }
    } else {
        Write-Host "MS SDK $compilerSpec ($arch) was not found"
    }
}

function Get-QtBasePath() {
    if ($env:SETQT_PATH) {
        (Resolve-Path "$env:SETQT_PATH\..").Path
    } else {
#    (& qmake -query QT_INSTALL_PREFIX) -replace "/", "\"
        return $null
    }
}

function Generate-Pro-File()
{
    & qmake -project
}

Set-Alias qp "Generate-Pro-File"
