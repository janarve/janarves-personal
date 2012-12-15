
function detectTools()
{
    ### Detect Active State Perl
    if (Test-Path "c:\Perl64\bin") {
        $env:Path = "c:\Perl64\bin;" + $env:PATH
    } elseif (Test-Path "c:\Perl\bin") {
        $env:Path = "c:\Perl\bin;" + $env:PATH
    } else {
        Write-Host "ActivePerl not found"
    }

    ### Detect python
    if (Test-Path "c:\Python26") {
        $env:Path = "c:\Python26;" + $env:Path
    } elseif (Test-Path "c:\Python27") {
        $env:Path = "c:\Python27;c:\Python27\Scripts;" + $env:Path
    } else {
        Write-Host "Python not found"
    }
}

function e($path)
{
    if (! $path) {
        $path = "."
    }
	explorer $path
}

detectTools

$env:Path+=";t:\dev\personal\bin\ps1;t:\bin"
$env:Path+=";c:\Program Files (x86)\Git\bin"
### Move to setqt.ps?
# unreliable, works only within the meta repo and its submodules
# $env:Path += ";t:\dev\qt-5\qtrepotools\bin"

$env:ARTISTIC_STYLE_OPTIONS="$USERPROFILE\astylerc"
$env:QT_MESSAGE_PATTERN="%{file}(%{line}):%{message}"
$env:GIT_TEMPLATE_DIR="t:\dev\devtools\git\template"

setcompiler x86 msvc2010

$env:CL = "/MP"

# eeew... Get rid of symbian toolchain (might confuse mingw)
$env:Path = $env:Path.replace("C:\Program Files (x86)\Common Files\Symbian\tools;", "")

####################################################################
# Load posh-git example profile
Push-Location 'T:\dev\posh-git'

# Load posh-git module from current directory
Import-Module .\posh-git

# If module is installed in a default location ($env:PSModulePath),
# use this instead (see about_Modules for more information):
# Import-Module posh-git

$global:GitPromptSettings.EnableFileStatus = $false
# Set up a simple prompt, adding the git prompt parts inside git repos
function prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    Write-Host($pwd) -nonewline

    Write-VcsStatus

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

Enable-GitColors

Pop-Location

#Start-SshAgent -Quiet

#. 'T:\dev\posh-git\profile.example.ps1'

. 'qttabexp.ps1'
