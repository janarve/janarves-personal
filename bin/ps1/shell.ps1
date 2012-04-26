function detectTools()
{
    ### Detect Active State Perl
    if (Test-Path "c:\Perl64\bin") {
        $env:Path = "c:\Perl64\bin;" + $env:PATH
    }elseif (Test-Path "c:\Perl\bin") {
        $env:Path = "c:\Perl\bin;" + $env:PATH
    } else {
        Write-Host "ActivePerl not found"
    }

    ### Detect python
    if (Test-Path "c:\Python26") {
        $env:Path = "c:\Python26;" + $env:Path
    } else {
        Write-Host "Python not found"
    }
}

function detectInstalledLibraries() {
    $includeCandidates = @(
        "t:\3rdparty\openssl64\include",
        "t:\3rdparty\expat\Source\lib"
    )

    $libCandidates = @(
        "t:\dev\devtools\database\lib\msvc",
        "t:\3rdparty\openssl64\lib",
        "t:\3rdparty\expat\bin"
    )

    foreach ($sqldriver in @("tds", "db2", "fbird", "oci", "mysql", "psql")) {
        $includeCandidates += "t:\dev\devtools\database\include\$sqldriver"
    }

    foreach ($inclPath in $includeCandidates) {
        if (Test-Path $inclPath) {
            if ($env:Include) {
                $env:Include+=";"
            }
            $env:Include+= "$inclPath"
        }
    }

    foreach ($libPath in $libCandidates) {
        if (Test-Path $libPath) {
            if ($env:Lib) {
                $env:Lib+=";"
            }
            $env:Lib+= "$libPath"
        }
    }
}

function e()
{
	explorer .
}

detectTools
detectInstalledLibraries

$env:Path+=";t:\dev\personal\bin\ps1;t:\bin"
$env:Path+=";c:\Program Files (x86)\Git\bin"

### Move to setqt.ps?
$env:Path += ";t:\dev\qt-5\qtrepotools\bin"


$env:ARTISTIC_STYLE_OPTIONS="$USERPROFILE\astylerc"
$env:QT_MESSAGE_PATTERN="%{file}(%{line}):%{message}"

if ($env:COMPUTERNAME -eq "AIRWOLF") {
    setcompiler x86 msvc2008
} else {
    setcompiler amd64 msvc2010
}

# eeew... Get rid of symbian toolchain (might confuse mingw)
$env:Path = $env:Path.replace("C:\Program Files (x86)\Common Files\Symbian\tools;", "")

# Load posh-git example profile
. 'T:\dev\posh-git\profile.example.ps1'
