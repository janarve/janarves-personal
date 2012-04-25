(Get-Host).UI.RawUI.BackgroundColor="black"
(Get-Host).UI.RawUI.ForegroundColor="Blue"
cls

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
    setcompiler amd64 msvc2008
    $env:CL = "/MP"
}


function e()
{
	explorer .
}

QT

# eeew... Get rid of symbian toolchain (might confuse mingw)
$env:Path = $env:Path.replace("C:\Program Files (x86)\Common Files\Symbian\tools;", "")

. 'T:\dev\personal\bin\ps1\shell.ps1'

# Load posh-git example profile
. 'T:\dev\posh-git\profile.example.ps1'
