param($arg1)

if ($env:QTDIR -eq "" ) {
    echo "QTDIR not set. Run setqt <version>"
} elseif (!$arg1) {
    Push-Location $env:QTDIR
} else {
    "$arg1 not found in QTDIR, src, examples or tools"
}


#for %%i in (. src examples tools) do (
#  if exist %qtdir%\%%i\%1 (
#    pushd %qtdir%\%%i\%1
#    goto end
#  )
#)

#echo %1 not found in QTDIR, src, examples or tools
