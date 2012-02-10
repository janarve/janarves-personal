$firstArg = $args[0]

# Set the Qt environment; QTDIR QTDEPOT and PATH
function setCompiler($cpu){
    
    if ($env:SETCOMPILER_ORIGINALPATH) {
        if ($cpu -eq "x86" -or $cpu -eq "amd64") {
            $env:PATH=$env:SETCOMPILER_ORIGINALPATH
            $env:Include=$env:SETCOMPILER_ORIGINALINCLUDE
            $env:Lib=$env:SETCOMPILER_ORIGINALLIB
        }
    } else {
        $env:SETCOMPILER_ORIGINALPATH=$env:PATH
        $env:SETCOMPILER_ORIGINALINCLUDE=$env:Include
        $env:SETCOMPILER_ORIGINALLIB=$env:Lib
    }

    if ($cpu -eq "x86") {
        $env:Lib+="C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\ATLMFC\LIB"
        $env:Lib+=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\LIB"
        $env:Lib+=";C:\Program Files\Microsoft SDKs\Windows\v7.0\lib"
    
        $env:Include="C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\ATLMFC\INCLUDE;"    
        
        $env:PATH+=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\BIN"
        $env:PATH+=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\Tools"
        $env:PATH+=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\Tools\bin"
        $env:PATH+=";C:\Windows\Microsoft.NET\Framework\"
        $env:PATH+=";C:\Windows\Microsoft.NET\Framework\Microsoft .NET Framework 3.5 (Pre-Release Version)"
        $env:PATH+=";C:\Windows\Microsoft.NET\Framework\v2.0.50727"    
        
    }
    if ($cpu -eq "amd64") {
        $env:Lib+=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\Lib\amd64"
        $env:Lib+=";C:\Program Files\Microsoft SDKs\Windows\v7.0\Lib\X64"
        $env:Lib+=";t:\3rdparty\openssl64\lib"
    
        $env:PATH+=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\Bin\amd64"
        $env:PATH+=";C:\Program Files\Microsoft SDKs\Windows\v7.0\Bin\x64"

    }

    ### common stuff ###
    $env:Lib+=";t:\3rdparty\expat\bin"
    $env:Lib+=";t:\dev\devtools\database\lib\msvc"
    
    $env:Include+="C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\INCLUDE"
    $env:Include+=";C:\Program Files\Microsoft SDKs\Windows\v7.0\Include"
    $env:Include+=";C:\Program Files\Microsoft SDKs\Windows\v7.0\Include\gl" 

    $env:Include+=";t:\dev\devtools\database\include\tds;t:\dev\devtools\database\include\db2;t:\dev\devtools\database\include\fbird"
    $env:Include+=";t:\dev\devtools\database\include\oci;t:\dev\devtools\database\include\mysql;t:\dev\devtools\database\include\psql"
    $env:Include+=";t:\3rdparty\openssl64\include"
    $env:Include+=";t:\3rdparty\expat\Source\lib"
    
    $env:PATH+=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE"
    $env:PATH+=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\vcpackages"
    $env:PATH+=";C:\Windows\Microsoft.NET\Framework64\v3.5;"
    $env:PATH+=";C:\Windows\Microsoft.NET\Framework\v3.5"
    $env:PATH+=";C:\Windows\Microsoft.NET\Framework64\v2.0.50727"
    $env:PATH+=";C:\Windows\Microsoft.NET\Framework\v2.0.50727"
    $env:PATH+=";C:\Program Files\Microsoft SDKs\Windows\v7.0\Setup"
    $env:PATH+=";C:\Program Files\Microsoft SDKs\Windows\v7.0\Bin"    
    
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