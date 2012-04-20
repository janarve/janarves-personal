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


$env:Path+=";t:\dev\personal\bin\ps1;t:\bin"
$env:Path+=";c:\Program Files (x86)\Git\bin"

$env:ARTISTIC_STYLE_OPTIONS="$USERPROFILE\astylerc"
$env:QT_MESSAGE_PATTERN="%{file}(%{line}):%{message}"