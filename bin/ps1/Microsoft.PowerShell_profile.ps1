
function Get-Batchfile ($file) {
	# we need to chdir to the path, because cmd cannot take an path argument
	# that contain spaces (e.g. c:\Program Files\)
	$tempFile = [IO.Path]::GetTempFileName()
	$path = [System.IO.Path]::GetDirectoryName($file);
	$fileName = [System.IO.Path]::GetFileName($file)
	pushd $path
	
	Write-Host "Get-Batchfile $tempFile $path $fileName"
	cmd /c " $fileName && set > `"$tempFile`" "
## Go through the environment variables in the temp file.
## For each of them, set the variable in our local environment.
	remove-item -path env:*
	Get-Content $tempFile | Foreach-Object {
		if($_ -match "^(.*?)=(.*)$") {
			$n = $matches[1]
			if ($n -eq "prompt") {
				# Ignore: Setting the prompt environment variable has no
				#         connection to the PowerShell prompt
			} elseif ($n -eq "title") {
				$host.ui.rawui.windowtitle = $matches[2];
				set-item -path "env:$n" -value $matches[2];
			} else {
				set-item -path "env:$n" -value $matches[2];
			}
		}
	}
	popd
	Remove-Item $tempFile	
}

function SetCL($version = "7.1")
{
	$key = "HKLM:\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v$version\WinSDKTools"
    if (Test-Path $key) {
        $VsKey = get-ItemProperty $key
        $VsInstallPath = [System.IO.Path]::GetDirectoryName($VsKey.InstallationFolder)
        $VsToolsDir = $VsInstallPath
        $BatchFile = [System.IO.Path]::Combine($VsToolsDir, "SetEnv.Cmd")
        Get-Batchfile "$BatchFile"
        [System.Console]::Title = "Visual Studio " + $version + " Windows Powershell"
    } else {
        Write-Host "MS SDK Version $version was not found"
    }
}

function QT()
{
    $env:PATH +=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\Bin\amd64"
    $env:PATH +=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\vcpackages"
    $env:PATH +=";C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE"
    $env:PATH +=";C:\Program Files\Microsoft SDKs\Windows\v7.0\Bin\x64;C:\Program Files\Microsoft SDKs\Windows\v7.0\Bin"
    $env:PATH +=";C:\Windows\Microsoft.NET\Framework64\v3.5;"
    $env:PATH +=";C:\Windows\Microsoft.NET\Framework\v3.5"
    $env:PATH +=";C:\Windows\Microsoft.NET\Framework64\v2.0.50727"
    $env:PATH +=";C:\Windows\Microsoft.NET\Framework\v2.0.50727"
    $env:PATH +=";C:\Program Files\Microsoft SDKs\Windows\v7.0\Setup"
    $env:PATH +=";t:\dev\qt-stable\bin"

    $env:CL = "/MP"
    
    $env:MSSdk="C:\Program Files\Microsoft SDKs\Windows\v7.0"
    
    $env:Include="C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\Include;C:\Program Files\Microsoft SDKs\Windows\v7.0\Include" 
    $env:Include+=";C:\Program Files\Microsoft SDKs\Windows\v7.0\Include\gl" 
    $env:Include+=";t:\dev\devtools\database\include\tds;t:\dev\devtools\database\include\db2;t:\dev\devtools\database\include\fbird"
    $env:Include+=";t:\dev\devtools\database\include\oci;t:\dev\devtools\database\include\mysql;t:\dev\devtools\database\include\psql"
    $env:Include+=";t:\3rdparty\openssl64\include"
    $env:Include+=";t:\3rdparty\expat\Source\lib"
    
    $env:Lib="t:\dev\devtools\database\lib\msvc;C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\Lib\amd64"
    $env:Lib+=";C:\Program Files\Microsoft SDKs\Windows\v7.0\Lib\X64"
    $env:Lib+=";t:\3rdparty\openssl64\lib"
    $env:Lib+=";t:\3rdparty\expat\bin"
    
}


function e()
{
	explorer .
    
}


Set-Alias np 'C:\Program Files (x86)\Notepad++\notepad++.exe'

(Get-Host).UI.RawUI.BackgroundColor="black"
#(Get-Host).UI.RawUI.ForegroundColor="DarkYellow"
(Get-Host).UI.RawUI.ForegroundColor="Blue"
Clear-Host

QT
$env:Path = $env:Path.Replace("t:\dev\personal\bin;", "")
$env:Path += ";c:\Perl\bin"
$env:Path += ";c:\Program Files (x86)\Git\bin"
$env:Path+=';t:\dev\personal\bin\ps1\'

# Load posh-git example profile
. 'T:\dev\posh-git\profile.example.ps1'
