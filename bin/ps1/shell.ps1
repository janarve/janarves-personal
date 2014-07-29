
function detectTools()
{
    # Look for registered tools in registry, 
    # returns the latest version if there are several versions
    function LastVersionFromRegistry($regPath, $keyName = $null) {
        if (Test-Path $regPath) {
            $o = (Get-ItemProperty -path $regPath)
            if ($o.GetType() -eq [Object[]]) {
                $count = $o.Count
                $o = $o[$count - 1]
            }
            if ($keyName -ne $null) {
                $r = ($o."$keyName")
                return $r
                
            } else {
                return ($o.'(Default)')
            }
        }
        return $null
    }
    ### Detect Active State Perl
    Write-Host -nonewline "[ActivePerl] "   #11 characters
    if (Test-Path "C:\Perl64\bin") {
        $env:Path = "C:\Perl64\bin;" + $env:PATH
        Write-Host " C:\Perl64"
    } elseif (Test-Path "C:\Perl\bin") {
        $env:Path = "C:\Perl\bin;" + $env:PATH
        Write-Host " C:\Perl"
    } else {
        Write-Host " Not found"
    }

    ### Detect python
    Write-Host -nonewline "[Python]     "   #11 characters
    if (Test-Path "C:\Python27") {
        $env:Path = "C:\Python27;C:\Python27\Scripts;" + $env:Path
        Write-Host " C:\Python27"
    } elseif (Test-Path "C:\Python26") {
        $env:Path = "C:\Python26;" + $env:Path
        Write-Host " C:\Python26"
    } else {
        Write-Host " Not found"
    }

    ### Detect Ruby (needed for webkit)
    # Not sure if Wow6432Node is the same regardless of arch
    Write-Host -nonewline "[Ruby]       "   #11 characters
    $rubyPath = LastVersionFromRegistry "HKLM:\SOFTWARE\Wow6432Node\RubyInstaller\MRI\*" "InstallLocation"
    if ($rubyPath) {
        $env:Path += ";$rubyPath\bin"
        Write-Host " $rubyPath"
    } else {
        Write-Host " Not found"    
    }

    ### Detect cmake
    Write-Host -nonewline "[CMake]      "   #11 characters
    # Not sure if Wow6432Node is the same regardless of arch
    $cmakePath = LastVersionFromRegistry "HKLM:\SOFTWARE\Wow6432Node\Kitware\CMake *"
    if ($cmakePath) {
        $env:Path += ";$cmakePath\bin"
        Write-Host " $cmakePath"
    } else {
        Write-Host " Not found"    
    }
    
}

function e($path)
{
    if (! $path) {
        $path = "."
    }
    explorer $path
}

#. utils.ps1
detectTools

$env:Path+=";Q:\dev\personal\bin\ps1;Q:\bin"
$env:Path+=";C:\Program Files (x86)\Git\bin"
### Move to setqt.ps?
# unreliable, works only within the meta repo and its submodules
# $env:Path += ";Q:\dev\qt-5\qtrepotools\bin"

$env:ARTISTIC_STYLE_OPTIONS="$env:USERPROFILE\astylerc"
$env:QT_MESSAGE_PATTERN="%{file}(%{line}):%{message}"
$env:GIT_TEMPLATE_DIR="Q:\dev\devtools\git\template"

# eeew... Get rid of symbian toolchain (might confuse mingw)
$env:Path = $env:Path.replace("C:\Program Files (x86)\Common Files\Symbian\tools;", "")

####################################################################
# Load posh-git example profile
Push-Location 'Q:\dev\posh-git'

# Load posh-git module from current directory
Import-Module .\posh-git

# If module is installed in a default location ($env:PSModulePath),
# use this instead (see about_Modules for more information):
# Import-Module posh-git

$global:GitPromptSettings.EnableFileStatus = $false
$global:GitTabSettings.AllCommands = $true

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

$env:GIT_PUSH="spell"
#Start-SshAgent -Quiet

#. 'Q:\dev\posh-git\profile.example.ps1'

. 'qttabexp.ps1'

Set-Compiler msvc2013expr
setqt .

$env:CL += " /MP"
