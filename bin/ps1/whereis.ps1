$firstArg = $args[0]

$validExecutableExtentions = @("exe", "com", "ps1", "bat")
# Set the Qt environment; QTDIR QTDEPOT and PATH
function whereIs($needle){
	$splitPath = $Env:path.split(';')
    $found = 0
    foreach($p in $splitPath){
        $fullPath = [System.IO.Path]::Combine($p, $needle)
        $found = Test-Path $fullPath
        if (!$found) {
            $baseFullPath = $fullPath
            foreach($ext in $validExecutableExtentions) {
                $fullPath = $baseFullPath + "." + $ext
                $found = Test-Path $fullPath
                if ($found) {
                    break
                }
            }
        }
        if ($found) {
            break
        }
    }
    if ($found) {
        Write-Host $fullPath
    } else {
        Write-Host $needle does not exist in env:PATH
    }
}

# Help function
function getHelp(){
	Write-Host "whereis searches through env:PATH to find the absolute location of the <filename>"
    Write-Host
    Write-Host "Usage:  whereis <filename>"
    
}

# Main function
function main($arguments)
{
	if($arguments.length -eq 0 -or $arguments[0] -match "-help"){
		. getHelp
		exit
	} else {
        . whereIs($arguments[0])
		exit
	}
}
# Calling main function
. main $args