$firstArg = $args[0]

# Set the Qt environment; QTDIR and PATH
function setPath($loc){
    # Remove old QTDIR\bin from PATH
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
    
    if (Test-Path $loc) {
        $loc = Resolve-Path $loc
        $Env:QTDIR = $loc
    } elseif (Test-Path ($Env:QTDEPOT + "\qt-" + $loc)) {
        $loc = Resolve-Path ($Env:QTDEPOT + "\qt-" + $loc)
        $Env:QTDIR = $loc
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