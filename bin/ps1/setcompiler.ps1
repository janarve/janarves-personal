<#
.SYNOPSIS
A tool to switch between default compiler on windows.

.DESCRIPTION
You can switch to another compiler version (e.g. msvc2008)
You can also switch between x86 and amd64 architecture, (using the current compiler version).
Available compilers and architectures:
 | Compiler Spec | Architectures |
 +==============+================+
 | mingw46       | x86           |
 | msvc2008      | x86 | amd64   |
 | msvc2010expr  | x86 | amd64   |
 
.\setcompiler x86 mingw46

mingw46

.EXAMPLE
.\setcompiler.ps1 amd64
Changes current compiler target architecture to amd64. Compiler version is left unchanged.

.EXAMPLE
.\setcompiler.ps1 -compiler msvc2010expr
Changes current compiler version to MS Visual Express 2010.
Compiler target architecture is left unchanged if it exist for that compiler version.

.EXAMPLE
.\setcompiler.ps1
Outputs the current compiler

.NOTES
Experimental

.LINK
http://jans.tihlde.org

#>
param([string]$architecture = $null, [string]$compiler = $null, [switch]$help)

function currentCompilerString()
{
    $error.Clear()
    cl 2>$null
    $error.Reverse()
    $error | % { $_.TargetObject }
}

function smartResolvePath($path)
{
    $splitted = $path -split "\\\.\.\\"
    if ($splitted.count -eq 2) {
        $first = Resolve-Path $splitted[0]
        $last = $splitted[1]
        return (Resolve-Path "$first\..\$last").Path
    }
    return (Resolve-Path $path).Path
}

function addUnique([ref]$arr, $item)
{
    if (! ($arr.Value -contains $item)) {
        $arr.Value = $arr.Value + $item
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

    #--------------------------------------
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
            addUnique ($newIncludes) (smartResolvePath $var[0])
            addUnique ($newLibs) (smartResolvePath $var[1])
            if ($var[2] -is [array]) {
                foreach ($p in $var[2]) {
                    addUnique ($newPaths) (smartResolvePath $p)
                }
            } else {
                addUnique ($newPaths) (smartResolvePath $var[2])
            }
        }
    }
}


function setCompiler($arch, $comp){
    if ($arch -and !($arch -eq "x86" -or $arch -eq "amd64")) {
        Write-Output "Invalid architecture ""$arch"". Can only  be x86 or amd64."
        return
    }
    if (!$comp) {
        if (!$arch) {
            Write-Host "Current compiler:"
            currentCompilerString
            return
        }
        if (Test-Path "HKCU:\Software\JASOFT\SetCompiler") {
            if ($arch) {
                $comp = (Get-ItemProperty -path "HKCU:\Software\JASOFT\SetCompiler")."LastUsedCompiler"
            }
        }
        if (!$comp) {
            # First time - require a compiler
            Write-Host "You need to specify a compiler version"
            Write-Host "I don't know the current compiler, asking cl:"
            Write-Host
            currentCompilerString
            return
        }
    } else {
        if (!(Test-Path "HKCU:\Software\JASOFT\SetCompiler")) {
            # Create the registry keys
            $obj = New-Item -path "HKCU:\Software\JASOFT"
            $obj = New-Item -path "HKCU:\Software\JASOFT\SetCompiler"
        }
        $obj = Set-ItemProperty -path "HKCU:\Software\JASOFT\SetCompiler" -name "LastUsedCompiler" -value $comp
    }
    $NewIncludes  = @()
    $newPaths = @()
    $NewLibs = @()

    $keyBase="Software"
    $compilerFound = $false
    $mingw = $false

    ### msvc2010expr
    $archPart = "amd64"

    ### Aliases
    if ($comp -eq "2008") {
        $comp = "msvc2008"
    } elseif ($comp -eq "2010") {
        $comp = "msvc2010"
    }

    switch ($comp) {
        "mingw44" {
            if (Test-Path "t:\bin\MinGW-gcc440\mingw\bin") {
                $compilerFound = $true
                $env:Path="t:\bin\MinGW-gcc440\mingw\bin;$env:Path"
            }
            $mingw = $true
        }
        "mingw46" {
            if (Test-Path "c:\mingw\bin\mingw32-gcc-4.6*.exe") {
                $compilerFound = $true
                $env:Path="c:\mingw\bin;$env:Path"
            }
            $mingw = $true
        }
        "mingw47" {
            if (Test-Path "t:\bin\mingw-builds\bin\i686-w64-mingw32-g++.exe") {
                $compilerFound = $true
                $env:Path="t:\bin\mingw-builds\bin;$env:Path"
            }
            $mingw = $true
        }
        "msvc2010" {
            $registryPath = "HKLM:\$keyBase\Microsoft\VisualStudio\SxS\VC7"
            $compilerFound = Test-Path $registryPath
            if ($compilerFound) {
                $VCINSTALLDIR = (Get-ItemProperty $registryPath)."10.0"

                ### Get WinSDK
                $WinSDKRegKeyPath = "HKLM:\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v7.1"
                if (Test-Path $WinSDKRegKeyPath) {
                    $WindowsSDKDir = (Get-ItemProperty $WinSDKRegKeyPath)."InstallationFolder"
                } else {
                    Write-Host "Could not locate windows SDK directory"
                    Exit-PSSession
                }
                ### SDK stuff
                $OSLibraries = "$($WindowsSDKDir)Lib"
                $OSIncludes = "$($WindowsSDKDir)INCLUDE;$($WindowsSDKDir)INCLUDE\gl"

                ### Gather information for $env:LIB
                $VCLibraries = "$($VCINSTALLDIR)Lib"
                if ($arch -eq "amd64") {
                    $NewLibs += "$VCLibraries\amd64"
                    $NewLibs += "$OSLibraries\X64"
                } else {
                    $NewLibs += $VCLibraries
                    $NewLibs += $OSLibraries
                }

                ### Gather information for $env:INCLUDE
                $VCIncludes = "$($VCINSTALLDIR)Include"
                $NewIncludes += $VCIncludes
                $NewIncludes += $OSIncludes

                ### ATLMFC
                if (Test-Path "$($VCINSTALLDIR)ATLMFC") {
                    $NewIncludes += "$($VCINSTALLDIR)ATLMFC\INCLUDE"
                    $NewLibs += "$($VCINSTALLDIR)ATLMFC\LIB"
                }

                ### VSTools
                $VSINSTALLDIR = "${env:ProgramFiles(x86)}" + "\Microsoft Visual Studio 10.0\"
                $VSTools = ""
                if (Test-Path $VSINSTALLDIR) {
                    $VSTools=";${VSINSTALLDIR}Common7\IDE;${VSINSTALLDIR}Common7\Tools"
                }

                ### Gather information for $env:PATH
                #VCTools
                $VCTools = "$($VCINSTALLDIR)bin"
                if ($arch -eq "amd64") {
                    if (Test-Path "$VCTools\amd64\cl.exe") {
                        $VCTools = "$VCTools\amd64"
                    }
                }
                $VCTools+= ";$VCTools\VCPackages"

                #SDKTools
                if ($arch -eq "x86") {
                    $SdkTools += "$($WindowsSdkDir)Bin\NETFX 4.0 Tools"
                } elseif ($arch -eq "amd64") {
                    $SdkTools += "$($WindowsSdkDir)Bin\NETFX 4.0 Tools\x64;$($WindowsSdkDir)Bin\x64"
                }
                $SdkTools += ";$($WindowsSdkDir)Bin"

                $newPaths += $VSTools
                $newPaths += $VCTools
                $newPaths += $SDKTools

                $env:MSSdk = $WindowsSDKDir

                Write-Host "Setting compiler to msvc2010 ($arch)"
            }
        }
        "msvc2008" {
            #$registryPath = "HKLM:\$keyBase\Microsoft\VisualStudio\9.0\Setup\VC\"
            #$compilerFound = Test-Path $registryPath
            #if ($compilerFound) {
            #   $VCINSTALLDIR = Get-ItemProperty $registryPath -name "ProductDir"
            #}

            $compilerFound = $true
            if ($arch -eq "x86") {
                $NewLibs += "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\ATLMFC\LIB"
                $NewLibs += "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\LIB"
                $NewLibs += "C:\Program Files\Microsoft SDKs\Windows\v7.0\lib"

                $NewIncludes +=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\ATLMFC\INCLUDE"

                $NewPaths += "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\BIN"
                $NewPaths += "C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\Tools"
                $NewPaths += "C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\Tools\bin"
                $NewPaths += "C:\Windows\Microsoft.NET\Framework"
                $NewPaths += "C:\Windows\Microsoft.NET\Framework\Microsoft .NET Framework 3.5 (Pre-Release Version)"
                $NewPaths += "C:\Windows\Microsoft.NET\Framework\v2.0.50727"

            }
            if ($arch -eq "amd64") {
                $NewLibs += "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\Lib\amd64"
                $NewLibs += ";C:\Program Files\Microsoft SDKs\Windows\v7.0\Lib\X64"

                $NewPaths += "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\Bin\amd64"
                $NewPaths += ";C:\Program Files\Microsoft SDKs\Windows\v7.0\Bin\x64"
            }


            $NewIncludes += "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\INCLUDE"
            $NewIncludes += "C:\Program Files\Microsoft SDKs\Windows\v7.0\Include"
            $NewIncludes += "C:\Program Files\Microsoft SDKs\Windows\v7.0\Include\gl"

            $NewPaths += "C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE"
            $NewPaths += "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\vcpackages"
            $NewPaths += "C:\Windows\Microsoft.NET\Framework64\v3.5;"
            $NewPaths += "C:\Windows\Microsoft.NET\Framework\v3.5"
            $NewPaths += "C:\Windows\Microsoft.NET\Framework64\v2.0.50727"
            $NewPaths += "C:\Windows\Microsoft.NET\Framework\v2.0.50727"
            $NewPaths += "C:\Program Files\Microsoft SDKs\Windows\v7.0\Setup"
            $NewPaths += "C:\Program Files\Microsoft SDKs\Windows\v7.0\Bin"

            $env:MSSdk="C:\Program Files\Microsoft SDKs\Windows\v7.0"
        }
    }

    if (!$compilerFound) {
        Write-Host "No such compiler installed on this system"
        Exit-PSSession
    }

    detectInstalledLibraries $arch ([ref]$NewIncludes) ([ref]$NewLibs) ([ref]$NewPaths)

    #
    # We've finally gathered all include, lib and path paths.
    # Join the arrays, and update the proper environment variables
    #
    $NewINCLUDE = $newIncludes -Join ";"
    $NewLIB = $newLibs -Join ";"
    $NewPATH = $newPaths -Join ";"

    if ($arch -eq "x86" -or $arch -eq "amd64") {
        updateEnvironmentPathValue "INCLUDE" "SETCOMPILER_INCLUDE" $NewINCLUDE
        updateEnvironmentPathValue "LIB" "SETCOMPILER_LIB" $NewLIB
        updateEnvironmentPathValue "PATH" "SETCOMPILER_PATH" $NewPATH
    }

    if ($env:CL -notmatch '[/-MP]') {
        $env:CL += "/MP"
    }

    $Host.UI.RawUI.WindowTitle = "[PS] $comp-$arch"
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

# Main function
function main(){
    if ($help){
        Get-Help setCompiler.ps1
    } else {
        setCompiler $architecture $compiler
    }
}
# Calling main function
main
