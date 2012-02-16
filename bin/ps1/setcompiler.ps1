$firstArg = $args[0]

# Set the Qt environment; QTDIR QTDEPOT and PATH
function setCompiler($cpu){
    $NewINCLUDE  = "t:\3rdparty\openssl64\include"
    $NewINCLUDE += ";t:\3rdparty\expat\Source\lib"
    
    if ($cpu -eq "x86") {
        $NewLIB  = "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\ATLMFC\LIB"
        $NewLIB +=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\LIB"
        $NewLIB +=";C:\Program Files\Microsoft SDKs\Windows\v7.0\lib"
    
        $NewINCLUDE+=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\ATLMFC\INCLUDE"

        $NewPATH  = "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\BIN"
        $NewPATH +=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\BIN"
        $NewPATH +=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\Tools"
        $NewPATH +=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\Tools\bin"
        $NewPATH +=";C:\Windows\Microsoft.NET\Framework"
        $NewPATH +=";C:\Windows\Microsoft.NET\Framework\Microsoft .NET Framework 3.5 (Pre-Release Version)"
        $NewPATH +=";C:\Windows\Microsoft.NET\Framework\v2.0.50727"
        
    }
    if ($cpu -eq "amd64") {
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

    if ($cpu -eq "x86" -or $cpu -eq "amd64") {
        if ($env:SETCOMPILER_LIB) {
            $env:LIB = $env:LIB.replace($env:SETCOMPILER_LIB, $NewLIB)
        } else {
            $env:LIB += ";" + $NewLIB
        }
        $env:SETCOMPILER_LIB = $NewLIB

        if ($env:SETCOMPILER_INCLUDE) {
            $env:INCLUDE = $env:INCLUDE.replace($env:SETCOMPILER_INCLUDE, $NewINCLUDE)
        } else {
            $env:INCLUDE += ";" + $NewINCLUDE
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
    $env:MSSdk="C:\Program Files\Microsoft SDKs\Windows\v7.0"
    
}

# Help function
function getHelp(){
	Write-Host "      To run this tool type: .\setcompiler.ps1 <cpu-target>"
	Write-Host "                                                               "
	Write-Host "      cpu-target: x86 | amd64                                  "
	Write-Host "                                                               "
}

# Main function
function main(){
	if($firstArg -match "-help"){
		. getHelp
		exit
	} elseif(!$firstArg){
        Write-Host "I don't know the current compiler, asking cl:"
        Write-Host
		cl
	} else {
        . setCompiler($firstArg)
		exit
	}
}
# Calling main function
. main