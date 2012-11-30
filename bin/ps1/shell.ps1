
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

$env:Path+=";t:\dev\personal\bin\ps1;t:\bin"
$env:Path+=";c:\Program Files (x86)\Git\bin"
### Move to setqt.ps?
# unreliable, works only within the meta repo and its submodules
# $env:Path += ";t:\dev\qt-5\qtrepotools\bin"

$env:ARTISTIC_STYLE_OPTIONS="$USERPROFILE\astylerc"
$env:QT_MESSAGE_PATTERN="%{file}(%{line}):%{message}"
$env:GIT_TEMPLATE_DIR="t:\dev\devtools\git\template"

if ($env:COMPUTERNAME -eq "AIRWOLF") {
    setcompiler x86 msvc2010
} else {
    setcompiler x86 msvc2010
}
$env:CL = "/MP"

# eeew... Get rid of symbian toolchain (might confuse mingw)
$env:Path = $env:Path.replace("C:\Program Files (x86)\Common Files\Symbian\tools;", "")

# Load posh-git example profile
. 'profile.posh-git.ps1'

. 'qttabexp.ps1'
