function detectInstalledLibraries($arch, [ref]$newIncludes, [ref]$newLibs, [ref]$newPaths)
{
    # "include", "lib", "PATH"
    $detectionVariables = @{
        "x86" = @(
            @("${env:DXSDK_DIR}Include", "${env:DXSDK_DIR}Lib\x86", "${env:DXSDK_DIR}Utilities\Bin\x86"),
            @("Q:\3rdparty\icu*\icu\lib\..\include", "Q:\3rdparty\icu*\icu\lib", "Q:\3rdparty\icu*\icu\bin"),
            @("${env:THIRDPARTYPATH}\openssl-1.0.1e\include", "${env:THIRDPARTYPATH}\openssl-1.0.1e\lib", "${env:THIRDPARTYPATH}\openssl-1.0.1e\bin"),
            @("${env:THIRDPARTYPATH}\openssl-1.0.1i\include", "${env:THIRDPARTYPATH}\openssl-1.0.1i\lib", "${env:THIRDPARTYPATH}\openssl-1.0.1i\bin"),
            @("Q:\3rdparty\expat\Source\lib", "Q:\3rdparty\expat\bin", "Q:\3rdparty\expat\bin"),
            @("Q:\dev\devtools\database\include\db2", "Q:\dev\devtools\database\lib\msvc", "Q:\dev\devtools\database\bin"),
            @("Q:\dev\devtools\database\include\fbird", "Q:\dev\devtools\database\lib\msvc", "Q:\dev\devtools\database\bin"),
            @("Q:\dev\devtools\database\include\mysql", "Q:\dev\devtools\database\lib\msvc", "Q:\dev\devtools\database\bin"),
            @("Q:\dev\devtools\database\include\oci", "Q:\dev\devtools\database\lib\msvc", "Q:\dev\devtools\database\bin"),
            @("Q:\dev\devtools\database\include\psql", "Q:\dev\devtools\database\lib\msvc", "Q:\dev\devtools\database\bin"),
            @("Q:\dev\devtools\database\include\tds", "Q:\dev\devtools\database\lib\msvc", "Q:\dev\devtools\database\bin")
        );
        "amd64" = @(
            @("${env:DXSDK_DIR}Include", "${env:DXSDK_DIR}Lib\x64", @("${env:DXSDK_DIR}Utilities\Bin\x86",
                                                                      "${env:DXSDK_DIR}Utilities\Bin\x64")),
            @("Q:\3rdparty\icu*\icu\lib64\..\include", "Q:\3rdparty\icu*\icu\lib64", "Q:\3rdparty\icu*\icu\bin64"),
            # @("Q:\3rdparty\openssl64\include", "Q:\3rdparty\openssl64\lib", "Q:\3rdparty\openssl64\bin"),
            @("${env:THIRDPARTYPATH}\openssl-1.0.1e\include", "${env:THIRDPARTYPATH}\openssl-1.0.1e\lib", "${env:THIRDPARTYPATH}\openssl-1.0.1e\bin"),
            @("${env:THIRDPARTYPATH}\openssl-1.0.1i\include", "${env:THIRDPARTYPATH}\openssl-1.0.1i\lib", "${env:THIRDPARTYPATH}\openssl-1.0.1i\bin")
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

function getEnvironmentCategory([string]$category)
{
	if ($global:environmentModifications -eq $null) {
		$global:environmentModifications = @{}
	}
	if ($global:environmentModifications[$category] -eq $null) {
		$global:environmentModifications[$category] = @{}
	}
	return $global:environmentModifications[$category]
}

function setEnvironment([string]$category, [string]$name, [string]$value)
{
	$envir = getEnvironmentCategory($category)
	$envir[$name] = $value
}

function appendEnvironment([string]$category, [string]$name, [string]$value, [string]$separator = ";")
{
	$envir = getEnvironmentCategory($category)
	$val = $envir[$name]
	if ($val -ne $null) {
		if ($val.lastIndexOf($separator) -ne -1) {
			$val += $separator
		}
	}
	$val += $value
	$envir[$name] = $val	
}

function appendEnvironmentMap([string]$category, $keyvalues, [string]$separator = ";")
{
	$envir = getEnvironmentCategory($category)
	$newVal = $envir[$name] + $separator + $value
	$envir[$name] = $newVal	
}

function applyEnvironment([string]$category, [string]$separator = ";")
{
	$envir = getEnvironmentCategory($category)
	foreach ($envName in $envir.keys) {
		$valueToAdd = $envir[$envName]
		$currentVal = $null
		if (Test-Path "env:$envName") {
			$currentVal = (Get-Item -path "env:$envName").Value
		}
		if ($currentVal -eq $null) {
			Set-Item -path "env:$envName" -value "$valueToAdd"
		} else {
			Set-Item -path "env:$envName" -value "$currentVal$separator$valueToAdd"
		}
	}
}
function restoreEnvironment([string]$category)
{
	$envir = getEnvironmentCategory($category)
	
	foreach ($envName in $envir.keys) {
		$addedVal = $envir[$envName]
		$currentVal = (Get-Item -path "env:$envName").Value
		$restoredVal = $currentVal.replace($addedVal, "")
		Set-Item -path "env:$envName" -value "$restoredVal"
	}
	$envir.clear()
}

function SetCmd($version = "7.1", $arch = "x86")
{
	if ($version -eq "none") {
        # Restore back to original content
        foreach ($envName in $globalEnvironmentHash.keys) {
            $oldVal = $globalEnvironmentHash[$envName]
            $currentVal = (Get-Item -path "env:$envName").Value
            $originalVal = $currentVal.replace($oldVal, "")
            Set-Item -path "env:$envName" -value "$originalVal"
        }
        $globalEnvironmentHash.clear()	
		return
	}
    $environmentHash = @{}
    $BatchFile = $null
    $SetEnv_arch = $null
    if ($version -eq "2013expr") {
        $BatchFile = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat"
# "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\VsDevCmd.bat"
        if ($arch -eq "amd64") {
            $SetEnv_arch = "x86_amd64"
        } else {
            $SetEnv_arch = "x86"
        }        
    } else {
        $key = "HKLM:\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v$version\WinSDKTools"
        if (Test-Path $key) {
			$VsKey = get-ItemProperty $key
			$VsInstallPath = [System.IO.Path]::GetDirectoryName($VsKey.InstallationFolder)
			$VsToolsDir = $VsInstallPath
			$BatchFile = [System.IO.Path]::Combine($VsToolsDir, "SetEnv.Cmd")
			if ($arch -eq "amd64") {
				$SetEnv_arch = "/x64"
			} else {
				$SetEnv_arch = "/x86"
			}        
        }
    }
	
    if ($BatchFile) {
        # Restore back to original content
        foreach ($envName in $globalEnvironmentHash.keys) {
            $oldVal = $globalEnvironmentHash[$envName]
            $currentVal = (Get-Item -path "env:$envName").Value
            $originalVal = $currentVal.replace($oldVal, "")
            Set-Item -path "env:$envName" -value "$originalVal"
        }
        $globalEnvironmentHash.clear()

        Get-Batchfile "$BatchFile" "$SetEnv_arch" ([ref]$globalEnvironmentHash)
        [System.Console]::Title = "Visual Studio " + $version + " Windows Powershell"

        $NewIncludes = $globalEnvironmentHash["INCLUDE"].TrimEnd(";") -split ";"
        $NewLibs = $globalEnvironmentHash["LIB"].TrimEnd(";") -split ";"
        $NewPaths = $globalEnvironmentHash["PATH"].TrimEnd(";") -split ";"

        detectInstalledLibraries $arch ([ref]$NewIncludes) ([ref]$NewLibs) ([ref]$NewPaths)

        $globalEnvironmentHash["INCLUDE"] = $NewIncludes -join ";"
        $globalEnvironmentHash["LIB"] = $NewLibs -join ";"
        $globalEnvironmentHash["PATH"] = $NewPaths -join ";"

#    $globalEnvironmentHash.Remove("ORIGINALPATH")
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
        return $true
    } else {
        return $false
    }
}

function SetCmdEx($version = "7.1", $arch = "x86")
{
	if ($version -eq "none") {
        # Restore back to original content
        restoreEnvironment "compiler"
		return
	}
    $BatchFile = $null
    $SetEnv_arch = $null
    if ($version -eq "2013") {      # Works for both VS 2013 Professional and VS 2013 Express
        $BatchFile = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat"
# "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\VsDevCmd.bat"
        if ($arch -eq "amd64") {
            $SetEnv_arch = "x86_amd64"
        } else {
            $SetEnv_arch = "x86"
        }        
    } else {
        $key = "HKLM:\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v$version\WinSDKTools"
        if (Test-Path $key) {
			$VsKey = get-ItemProperty $key
			$VsInstallPath = [System.IO.Path]::GetDirectoryName($VsKey.InstallationFolder)
			$VsToolsDir = $VsInstallPath
			$BatchFile = [System.IO.Path]::Combine($VsToolsDir, "SetEnv.Cmd")
			if ($arch -eq "amd64") {
				$SetEnv_arch = "/x64"
			} else {
				$SetEnv_arch = "/x86"
			}        
        }
    }
	
    if ($BatchFile) {
        # Restore back to original content
		restoreEnvironment "compiler"
		$envir = getEnvironmentCategory "compiler"
        Get-Batchfile "$BatchFile" "$SetEnv_arch" ([ref]$envir)
        [System.Console]::Title = "Visual Studio " + $version + " Windows Powershell"

        $NewIncludes = $envir["INCLUDE"].TrimEnd(";") -split ";"
        $NewLibs = $envir["LIB"].TrimEnd(";") -split ";"
        $NewPaths = $envir["PATH"].TrimEnd(";") -split ";"

        detectInstalledLibraries $arch ([ref]$NewIncludes) ([ref]$NewLibs) ([ref]$NewPaths)

        $envir["INCLUDE"] = $NewIncludes -join ";"
        $envir["LIB"] = $NewLibs -join ";"
        $envir["PATH"] = $NewPaths -join ";"

#    $globalEnvironmentHash.Remove("ORIGINALPATH")
		# update
		applyEnvironment "compiler"
        return $true
    } else {
        return $false
    }
}

function removeFromEnvironmentPath($value)
{
    $lowValue = $value.toLower()
    $pathString = $env:Path
    $pathLowered = $pathString.toLower()

    $idx = $pathLowered.indexOf($lowValue)
    if ($idx -ne -1) {
        if ($idx -gt 0) {
            $idx--
        }
        $pathString = $pathString.remove($idx, $value.Length + 1)
    }
    $env:Path = $pathString
}

function Set-Compiler([string]$compilerSpec = "msvc2010", [string]$arch = "x86") {
<#
.SYNOPSIS
A tool to switch between different compilers.
List of supported compilers specs:
    msvc2008     (msc15)
    msvc2010     (msc16)
    msvc2013expr (msc18)
    mingw46
    mingw-builds-x64
    mingw-builds-x32
    none

.EXAMPLE
Set-Compiler msvc2010 x86
Will switch to the 32 bit version of the MS

.LINK
sjarve@gmail.com
#>
    $foundCompiler = $false
    if ($arch -eq "x64") {
        $arch = "amd64"
    }
    if ($compilerSpec -eq "mingw") {
        $compilerSpec = "mingw-builds-x32"
    } elseif ($compilerSpec -eq "msc15") {
        $compilerSpec = "msvc2008"
    } elseif ($compilerSpec -eq "msc16") {
        $compilerSpec = "msvc2010"
    } elseif ($compilerSpec -eq "msc18") {
        $compilerSpec = "msvc2013"
    }
    if ($arch -eq "x86") {
        $env:THIRDPARTYPATH="Q:\3rdparty\x86"
    } elseif ($arch -eq "amd64") {
        $env:THIRDPARTYPATH="Q:\3rdparty\x64"
    } elseif ($compilerSpec -eq "none") {
        $env:THIRDPARTYPATH=$null
    }

    switch ($compilerSpec) {
        "none" {
            $foundCompiler = SetCmdEx "none"
        }
        "msvc2013" {
            $foundCompiler = SetCmdEx "2013" $arch
        }
        "msvc2010" {
            $foundCompiler = SetCmdEx "7.1" $arch
        }
        "msvc2008" {
            $foundCompiler = SetCmdEx "7.0" $arch
        }
        "mingw46" {
            $candidatePath = "c:\mingw\bin"
            if (Test-Path $candidatePath) {
				$foundCompiler = SetCmd "none"
                $foundCompiler = $true
                $env:Path="$candidatePath;$env:Path"
                $globalEnvironmentHash["Path"] = $candidatePath
                $shPath = Resolve-Path ((Get-Command sh.exe).Definition + "\..")
                $env:PATH = $env:PATH.replace("$shPath;", "")      #doing it twice in case its the first or last item in the Path
                $env:PATH = $env:PATH.replace(";$shPath", "")      #doing it twice in case its the first or last item in the Path
            }
        }
        "mingw48" {
            $candidatePath = "q:\bin\mingw-builds-x32-4.8.1\bin"
            if (Test-Path $candidatePath) {
				$foundCompiler = SetCmd "none"
                restoreEnvironment("compiler")
                $foundCompiler = $true
				appendEnvironment "compiler" "Path" $candidatePath
				# might be needed
                #$shPath = Resolve-Path ((Get-Command sh.exe).Definition + "\..")
                #$env:PATH = $env:PATH.replace("$shPath;", "")      #doing it twice in case its the first or last item in the Path
                #$env:PATH = $env:PATH.replace(";$shPath", "")      #doing it twice in case its the first or last item in the Path
				applyEnvironment "compiler"
            }
        }
		
        "mingw-builds-x64" {
            $candidatePath = "Q:\bin\mingw-builds-4.7.2\bin"
            if (Test-Path $candidatePath) {
                $foundCompiler = SetCmd "none"
                $foundCompiler = $true
                $env:Path="$candidatePath;$env:Path"
                $globalEnvironmentHash["Path"] = $candidatePath
                $shPath = Resolve-Path ((Get-Command sh.exe).Definition + "\..")
                $env:PATH = $env:PATH.replace("$shPath;", "")      #doing it twice in case its the first or last item in the Path
                $env:PATH = $env:PATH.replace(";$shPath", "")      #doing it twice in case its the first or last item in the Path
            }
        }
        "mingw-builds-x32" {
            $candidatePath = "Q:\bin\mingw-builds-x32-4.7.2\bin"
            if (Test-Path $candidatePath) {
                $foundCompiler = SetCmd "none"
                $foundCompiler = $true
                $env:Path="$candidatePath;$env:Path"
                $globalEnvironmentHash["Path"] = $candidatePath
                $shPath = Resolve-Path ((Get-Command sh.exe).Definition + "\..")
                $env:PATH = $env:PATH.replace("$shPath;", "")      #doing it twice in case its the first or last item in the Path
                $env:PATH = $env:PATH.replace(";$shPath", "")      #doing it twice in case its the first or last item in the Path
            }
        }

        default {
            $foundCompiler = $false
        }
    }
    if ($foundCompiler) {
        if ($version -eq "none") {
            Write-Host "Unregistering compiler"
            updateWindowTitle "none"
        } else {
            Write-Host "SDK set to $compilerSpec ($arch)"
            updateWindowTitle $compilerSpec
        }
    } else {
        Write-Host "SDK $compilerSpec ($arch) was not found"
    }
}

function updateWindowTitle([string]$cs = $null, [string]$qts = $null)
{
    if ($Host.UI.RawUI.WindowTitle -match "PS:([^\s]+)? (\d+)?-([^\s]+)?") {
        if ($cs -eq $null -or $cs -eq "") {
            $cs = $matches[1]
        }
        if ($qts -eq $null -or $qts -eq "") {
            $qtVersion = $matches[2]
            $qtBranch = $matches[3]
        }
    }
    if ($qts -match "qt-(\d+)-([dsr])") {
        $qtVersion = $matches[1]
        $qtBranch = $matches[2]
    }
    $Host.UI.RawUI.WindowTitle = "PS:$cs $qtVersion-$qtBranch"
}

function resolveQtPath($loc)
{
   if (Test-Path $loc) {
        # Try relative and absolute
        $loc = Resolve-Path $loc
        if (Test-Path ("$loc\qtbase\bin")) {
            $loc = "$loc\qtbase"
        }
        return $loc
    }
    return $null
}

### Appends $newValue to the environment variable specified by $envName
### Stores what was appended to $envNameAppendedPortion in order to know
### how to restore it back to its original form.
function updateEnvironmentPathValue($envName, $envNameAppendedPortion, $newValue)
{
    $result = $null

    $oldVar = $null
    if (Test-Path -path env:$envNameAppendedPortion) {
        $oldVar = (Get-Item -path env:$envNameAppendedPortion).Value
    }

    $nameVar = $null
    if (Test-Path -path env:$envName) {
        $nameVar = (Get-Item -path env:$envName).Value
    }

    if ($oldVar) {
        $result = $nameVar.replace($oldVar, $newValue)
    } else {
        if ($newValue) {
            if ($nameVar) {
                $result = $nameVar + ";"
            }
            $result += $newValue
        }
    }
    if ($result) {
        Set-Item -path env:$envName -value "$result"
        Set-Item -path env:$envNameAppendedPortion -value "$newValue"
    }
}




function Set-QtPath() {
<#
.SYNOPSIS
A tool to switch between different installed Qt versions

.DESCRIPTION
The tool will look for Qt on the system using various heuristics. The path can
be either an absolute or relative path. If it is relative it is either relative
to the current working directory or to the path specified by the QTREPOS
environment variable.
Paths matching these criterias must either have a <qtdir>\bin folder (for Qt 4
series) or a <qtdir>\qtbase\bin folder.

It tries to find the desired Qt version by 3 different strategies,
in the following order:
1. If an absolute path is given and it exist, the path will be used.
2. If an relative path is given and it exist, the corresponding absolute
   path of the relative path will be used.
3. If QTREPOS is set it will check if there exists a directory located
   under $QTREPOS named qt-$qtdir. If that exist, it will set QTDIR
   to $QTREPOS\qt-$qtdir. (Recommended usage)

.EXAMPLE
Set-QtPath c:\projects\qt-5\qtbase
Will switch to the Qt version installed at c:\projects\qt-5\qtbase, if it exists.

.EXAMPLE
Set-QtPath qt-48
If current directory is c:\projects, will set QTDIR to c:\projects\qt-48, if it exists.

.EXAMPLE
Set-QtPath none
Will unset QTDIR environment variable and remove $env:QTDIR\bin from the PATH environment variable.

.EXAMPLE
Set-QtPath .
Will set QTDIR to the current directory.

.EXAMPLE
Set-QtPath 5\qtbase
If QTREPOS is set to c:\dev, it will switch to the Qt version installed
at c:\dev\qt-5\qtbase

.EXAMPLE
Set-QtPath 5
If QTREPOS is set to c:\dev, it will switch to the Qt version installed
at c:\dev\qt-5\qtbase

.EXAMPLE
Set-QtPath 47
If QTREPOS is set to c:\dev, it will switch to the Qt version installed
at c:\dev\qt-47

.LINK
http://jans.tihlde.org
#>
param([string]$qtdir = $null, [switch]$clean)

    if ($clean){
        Write-Host "Cleaning up QTREPOS environment variable"
        [Environment]::SetEnvironmentVariable("QTREPOS", "", "User")
        $Env:QTREPOS = ""
    } elseif ($qtdir) {
        if ($qtdir -ne "none") {
            $newQTDIR = resolveQtPath($qtdir)
            if (!$newQTDIR) {
                if (!$Env:QTREPOS) {
                    $qtRepos = Read-host "Please enter the complete path to your Qt development area (Q:\dev)"
                    if (!$qtRepos) {
                        $qtRepos = "Q:\dev"
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
                $newQTDIR = resolveQtPath($Env:QTREPOS + "\qt-" + $qtdir)
            }
        }
        if ($newQTDIR -or $qtdir -eq "none") {
            # If successful, first remove old QTDIR\bin from PATH, then unset $env:QTDIR
            if ($env:SETQT_PATH) {
                $pattern = $env:SETQT_PATH
                $env:PATH = $env:PATH.replace(";$pattern", "")      #doing it twice in case its the first or last item in the Path
                $env:PATH = $env:PATH.replace("$pattern;", "")

                if ($setQTDIR) {
                    $env:QTDIR = $null
                }
                $env:SETQT_PATH = $null
            }

            if ($newQTDIR) {
                if ($setQTDIR) {
                    $Env:QTDIR = $newQTDIR
                }
                $gnuWinPath = ""
                if (Test-Path "$newQTDIR\..\gnuwin32\bin") {
                    $gnuWinPath = ";" + (Resolve-Path "$newQTDIR\..\gnuwin32\bin")
                }
                updateEnvironmentPathValue "PATH" "SETQT_PATH" "$newQTDIR\bin$gnuWinPath"
                Write-Host "Qt version is set to $newQTDIR"
            } else {
                # ($qtdir -eq "none")
                Write-Host "Qt version is unset."
            }
        } else {
            Write-Host "Could not find the given Qt version"
        }
    } else {
        if ($Env:QTDIR){
            Write-Host "$Env:QTDIR"
        } else {
            $qtdir = Get-QtBasePath
            if ($qtdir) {
                Write-Host $qtdir
            } else {
                Write-Host "QTDIR is not set"
            }
        }
    }

    $qtdir = Get-QtBasePath
    updateWindowTitle -qts $qtdir
}

function findInPath([string]$command)
{
    try {
        $res = Get-Command -CommandType Application -Name $command -ErrorAction "Stop"
        if ($res.GetType() -eq [Object[]]) {
            $res = res[0]
        }
        $res = $res.Definition
        $qtdir = Resolve-Path "$res\..\.."
        return $qtdir.Path
    } catch {
        return $null
    }
    return $null
}

function Get-QtBasePath() {
    # Try by looking in PATH environment
    $res = findInPath("syncqt.pl")      # From Qt ~5.1
    if ($res -eq $null) {
        $res = findInPath("syncqt.bat")
    }
    if ($res -eq $null) {
        $paths = $env:PATH -replace ";;", ";" -split ";"
        foreach ($p in $paths) {
            $candidate = "$p\..\.."
            if (Test-Path $candidate) {
                $candidate = Resolve-Path "$p\..\.."
                if (Test-Path "$candidate\init-repository") {
                    $candidate = "$candidate\qtbase"
                    if (Test-Path $candidate) {
                        $res = $candidate
                        break
                    }
                }
            }
        }
    }
    return $res
}

function Generate-Pro-File()
{
    & qmake -project
}

function Set-QtLocation() {
<#
.SYNOPSIS
Changes working directory to a folder within the current Qt version.

.DESCRIPTION
This tool is used together with Set-QtPath, and it will change the current
working directory to the last Qt version that Set-QtPath changed to.
If an argument is supplied, it will look in subfolders of the current Qt
version.

.EXAMPLE
Suppose the following precondition:
Set-QtPath c:\projects\qt-5\qtbase
cd c:\temp
Set-QtLocation
will change current working directory back to c:\projects\qt-5\qtbase

#>
param([string]$subdir)

    $qtdir = Get-QtBasePath

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
}

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
            $command = ($lastBlock -split " ")[0]
            # unwrap aliases
            $realCommand = (Get-Alias $command).Definition
            if (!$realCommand) {
                $realCommand = $command
            }
            switch ($realCommand) {
                # Execute qcd tab completion
                "Set-QtLocation" {
                    $arg = $lastWord
                    $lastSlash = $arg.lastIndexOf('\')
                    $lastSlash = $lastSlash + 1
                    $base = $arg.substring(0, $lastSlash)
                    foreach ($s in @("src", "examples", ".", "..")) {   # Order must be the same as in qcd
                        Get-ChildItem "$qtdir\$s\$lastWord*" | ForEach-Object { $base + $_.Name }
                    }
                }
                "Set-QtPath" {
                    $arg = $lastWord
                    $qtRepos = $env:QTREPOS
                    if ($qtRepos) {
                        Get-ChildItem "$qtRepos/qt-$arg*" | ForEach-Object { $_.Name -replace "qt-"}
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

Set-Alias qp "Generate-Pro-File"
Set-Alias setqt "Set-QtPath"
Set-Alias qcd "Set-QtLocation"


