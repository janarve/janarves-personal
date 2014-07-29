

# call t:\dev\personal\bin\%COMPUTERNAME%.bat %1

$env:Path+=";c:\Program Files (x86)\Git\Bin"


$env:Path+=";Q:\dev\qt-stable\bin;Q:\dev\personal\bin\ps1;Q:\dev\devtools\shell"
$env:EDITOR=$env:NOTEPADPP

$env:GIT_EDITOR="q:/dev/personal/bin/npp.bat"
$env:GIT_TEMPLATE_DIR="q:\dev\devtools\git\template"
$env:P4_TREE="q:\dev"

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

