$firstArg = $args[0]

# Set the Qt environment; QTDIR QTDEPOT and PATH
function setPath($loc){
	$splitPath = $Env:path.split(';')
    if ($env:QTDIR) {
        $tempEnv;
        foreach($line in $splitPath){
            if (!($line -eq "$env:QTDIR\bin")){
                if ($tempEnv) {
                    $tempEnv += ";"
                }
                $tempEnv+=$line
            }
		} 
        $env:Path = $tempEnv
    }
    
	if(!$Env:QTDEPOT)
	{ 
		$qtDep = Read-host "Please enter the complete path to your Qt depot(e.g. D:\depot\qt)"
		$Env:QTDEPOT = $qtDep
		$storeQtdep = Read-host "Do you want to set the location of your Qt depot as a permanent setting?(y/n)"
		if($storeQtdep -match "y")
		{
			echo "Qt depot location stored as permanent environment variable. To remove, run .\qtp.ps1 -clean"
			[Environment]::SetEnvironmentVariable("QTDEPOT", "$qtDep", "User")
		}
		elseif($storeQtdep -match "n")
		{
			echo "Qt depot location temporarily stored and will be available in this session only."
		}
		else
		{
			echo "Invalid parameter - Qt depot location temporarily stored and will be available in this session only. Run qtp -clean and qtp qtdir once more to reset it. "
		}
	}
    
    if ($loc -eq ".") {
        $loc = Get-Location
    }
    
    if (Test-Path $loc) {
        $Env:QTDIR = $loc
    } elseif (Test-Path ($Env:QTDEPOT + "\qt-" + $loc)) {
        $Env:QTDIR = $Env:QTDEPOT + "\qt-" + $loc
    }
    
	$Env:Path = $Env:QTDIR + "\bin;" + $Env:Path	
}

# Help function
function getHelp(){
	echo "      To run this tool type: .\setqt.ps1 [option]"
	echo "                                                               "
	echo "      Options: [-clean] [-help] [<qtdir>]                      "
	echo "                                                               "
	echo "          -clean  Clean will iterate through the Windows       "
	echo "                  path and clean any path containing the       "
	echo "                  word Qt.                                     "
	echo "          <qtdir> Type the path to your Qt directory to       "
	echo "                  set the QtDir. If QTDIR is set the script    "
	echo "                  will abort and a clean must be done.         "
	echo "                  e.g. .\qtp.ps1 4.5Desktop                    "
	echo "                                                               "
}

# Main function
function main(){
	if($firstArg -match "-help"){
		. getHelp
		exit
	} elseif(!$firstArg){
		if($Env:QTDIR){
            echo "$Env:QTDIR"
		} else{
            echo "QTDIR is not set"
		}
	} else {
        . setPath($firstArg)
		echo "Qt version is set to $Env:QTDIR"
		exit
	}
}
# Calling main function
. main