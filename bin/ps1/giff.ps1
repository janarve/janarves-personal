<#
.SYNOPSIS
Visual diff tool for git (and not for git)

.DESCRIPTION
If zero or one argument is given it works as a wrapper for git difftool.
Depends on correct configured git difftool

If two arguments are given it assumes both arguments are files,
and it will present a visual diff of the two files.
Depends on WinMerge.

.EXAMPLE
.\giff.ps1
Shows the local changes.

.EXAMPLE
.\giff.ps1 <sha1>
Shows the diff between <sha1>~1 and <sha1>.

.EXAMPLE
.\giff.ps1 main.cpp main.cpp.orig
Shows a visual diff between the two files.
#>

param([string]$commitOrPath, [string]$otherPath)

if ($commitOrPath -and $otherPath) {
	$winMergePath = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\WinMergeU.exe")."(default)"
	if (Test-Path $winMergePath) {
		if ((Test-Path $commitOrPath) -and (Test-Path $otherPath)) {
			Start-Process $winMergePath -ArgumentList "$commitOrPath $otherPath"
		}
    } else {
		Write-Host "Cannot find winMerge at $winMergePath"
	}
    Exit-PSSession
}

if ($commitOrPath) {
    if (Test-Path $commitOrPath) {
        & git difftool -y $commitOrPath
    } else {
        & git difftool -y $commitOrPath~1 $commitOrPath
    }
    Exit-PSSession
} else {
    & git difftool -y
}
