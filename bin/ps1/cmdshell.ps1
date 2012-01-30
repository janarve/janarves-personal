

# call t:\dev\personal\bin\%COMPUTERNAME%.bat %1

$env:Path+=";c:\Program Files (x86)\Git\Bin"


$env:Path+=";t:\dev\qt-stable\bin;t:\dev\personal\bin\ps1;t:\dev\devtools\shell"
$env:EDITOR=$env:NOTEPADPP

$env:GIT_EDITOR="t:/dev/personal/bin/npp.bat"
$env:GIT_TEMPLATE_DIR="t:\dev\devtools\git\template"

$env:P4_TREE="t:\dev"

Function LongListing {
    Get-ChildItem
}
sal ll LongListing

$env:PASTEBIN="pastebin.com"

$env:CODEPASTER_HOST="codepaster.europe.nokia.com"

SetCL 7.0
"C:\Program Files\Microsoft SDKs\Windows\v7.0\Bin\SetEnv.cmd"
# call use asperl
# call use git

