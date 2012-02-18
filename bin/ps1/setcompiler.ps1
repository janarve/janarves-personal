<#
.SYNOPSIS
A tool to switch between default compiler on windows.

.DESCRIPTION
You can switch to another compiler version (e.g. msvc2008)
You can also switch between x86 and amd64 architecture, (using the current compiler version).

.EXAMPLE
.\setcompiler.ps1 amd64
Changes current compiler target architecture to amd64. Compiler version is left unchanged.

.EXAMPLE
.\setcompiler.ps1 -compiler msvc2010expr
Changes current compiler version to MS Visual Express 2010.
Compiler target architecture is left unchanged if it exist for that compiler version.

.NOTES
Experimental

.LINK
http://jans.tihlde.org

#>
param([string]$architecture = "x86", [string]$compiler = $null, [switch]$help)

function setCompiler($arch, $comp){
    if (!$comp) {
        if (Test-Path "HKCU:\Software\JASOFT\SetCompiler") {
            $comp = (Get-ItemProperty -path "HKCU:\Software\JASOFT\SetCompiler")."LastUsedCompiler"
        } else {
            # First time - require a compiler
            Write-Host "You need to specify a compiler version"
            Write-Host "I don't know the current compiler, asking cl:"
            Write-Host
            cl
            Exit-PSSession
        }
    } else {
        if (!(Test-Path "HKCU:\Software\JASOFT\SetCompiler")) {
            # Create the registry keys
            $obj = New-Item -path "HKCU:\Software\JASOFT"
            $obj = New-Item -path "HKCU:\Software\JASOFT\SetCompiler"
            $obj = New-ItemProperty -path "HKCU:\Software\JASOFT\SetCompiler" -name "LastUsedCompiler" -value $comp
        }
    }
    $NewIncludes  = @()
    $newPaths = @()
    $NewLibs = @()

    $keyBase="Software"
    $compilerFound = $false

    ### msvc2010expr
    $archPart = "amd64"
    switch ($comp) {
        "msvc2010expr" {
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
                    $NewLibs += "$VCLibraries\amd64;$OSLibraries\X64"
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

                #VSTools - ignore for now
                #SET "VSTools=%VSINSTALLDIR%Common7\IDE;%VSINSTALLDIR%Common7\Tools;"

                ### Gather information for $env:PATH
                #VCTools
                $VCTools = "$($VCINSTALLDIR)bin"
                switch ($arch) {
                    "amd64" {
                        if (Test-Path "$VCTools\amd64\cl.exe") {
                            $VCTools = "$VCTools\amd64"
                        }
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

                $newPaths += $VCTools
                $newPaths += $SDKTools

                $NewPATH = $newPaths -Join ";"
                $NewINCLUDE = $newIncludes -Join ";"
                $NewLIB = $newLibs -Join ";"
                $env:MSSdk = $WindowsSDKDir

                Write-Host "Setting compiler to msvc2010 express ($arch)"
                }
            }
        "msvc2008" {
            #$registryPath = "HKLM:\$keyBase\Microsoft\VisualStudio\9.0\Setup\VC\"
            #$compilerFound = Test-Path $registryPath
            #if ($compilerFound) {
            #	$VCINSTALLDIR = Get-ItemProperty $registryPath -name "ProductDir"
            #}

            if ($arch -eq "x86") {
                $NewLIB  = "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\ATLMFC\LIB"
                $NewLIB +=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\LIB"
                $NewLIB +=";C:\Program Files\Microsoft SDKs\Windows\v7.0\lib"

                $NewINCLUDE+=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\ATLMFC\INCLUDE"

                $NewPATH  = "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\BIN"
                $NewPATH +=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\Tools"
                $NewPATH +=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\Tools\bin"
                $NewPATH +=";C:\Windows\Microsoft.NET\Framework"
                $NewPATH +=";C:\Windows\Microsoft.NET\Framework\Microsoft .NET Framework 3.5 (Pre-Release Version)"
                $NewPATH +=";C:\Windows\Microsoft.NET\Framework\v2.0.50727"

            }
            if ($arch -eq "amd64") {
                $NewLIB  = "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\Lib\amd64"
                $NewLIB += ";C:\Program Files\Microsoft SDKs\Windows\v7.0\Lib\X64"
                $NewLIB += ";t:\3rdparty\openssl64\lib"

                $NewPATH  = "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\Bin\amd64"
                $NewPATH += ";C:\Program Files\Microsoft SDKs\Windows\v7.0\Bin\x64"

            }


            ### common stuff ###
            $NewLIB+=";t:\3rdparty\expat\bin"
            $NewLIB+=";t:\dev\devtools\database\lib\msvc"

            $NewINCLUDE+=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\INCLUDE"
            $NewINCLUDE+=";C:\Program Files\Microsoft SDKs\Windows\v7.0\Include"
            $NewINCLUDE+=";C:\Program Files\Microsoft SDKs\Windows\v7.0\Include\gl"

            $NewINCLUDE+=";t:\dev\devtools\database\include\tds;t:\dev\devtools\database\include\db2;t:\dev\devtools\database\include\fbird"
            $NewINCLUDE+=";t:\dev\devtools\database\include\oci;t:\dev\devtools\database\include\mysql;t:\dev\devtools\database\include\psql"
            $NewINCLUDE+=";t:\3rdparty\openssl64\include"
            $NewINCLUDE+=";t:\3rdparty\expat\Source\lib"

            $NewPATH+=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE"
            $NewPATH+=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\vcpackages"
            $NewPATH+=";C:\Windows\Microsoft.NET\Framework64\v3.5;"
            $NewPATH+=";C:\Windows\Microsoft.NET\Framework\v3.5"
            $NewPATH+=";C:\Windows\Microsoft.NET\Framework64\v2.0.50727"
            $NewPATH+=";C:\Windows\Microsoft.NET\Framework\v2.0.50727"
            $NewPATH+=";C:\Program Files\Microsoft SDKs\Windows\v7.0\Setup"
            $NewPATH+=";C:\Program Files\Microsoft SDKs\Windows\v7.0\Bin"

            $env:MSSdk="C:\Program Files\Microsoft SDKs\Windows\v7.0"
        }
    }

    if (!$compilerFound) {
        Write-Host "No such compiler installed on this system"
        Exit-PSSession
    }

    if ($arch -eq "x86" -or $arch -eq "amd64") {
        if ($env:SETCOMPILER_LIB) {
            $env:LIB = $env:LIB.replace($env:SETCOMPILER_LIB, $NewLIB)
        } else {
            if ($env:LIB) {
                $env:LIB += ";"
            }
            $env:LIB += ";" + $NewLIB
        }
        $env:SETCOMPILER_LIB = $NewLIB

        if ($env:SETCOMPILER_INCLUDE) {
            $env:INCLUDE = $env:INCLUDE.replace($env:SETCOMPILER_INCLUDE, $NewINCLUDE)
        } else {
            if ($env:INCLUDE) {
                $env:INCLUDE += ";"
            }
            $env:INCLUDE += $NewINCLUDE
        }
        $env:SETCOMPILER_INCLUDE = $NewINCLUDE

        if ($env:SETCOMPILER_PATH) {
            $env:PATH = $env:PATH.replace($env:SETCOMPILER_PATH, $NewPATH)
        } else {
            $env:PATH += ";" + $NewPATH
        }

        $env:SETCOMPILER_PATH = $NewPATH
    }

    $env:CL = "/MP"

}

# Main function
function main(){
    if ($help){
        Get-Help setCompiler.ps1
        exit
    } else {
        setCompiler $architecture $compiler
        exit
    }
}
# Calling main function
main
