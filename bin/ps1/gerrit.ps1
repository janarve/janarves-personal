<#
.SYNOPSIS
A tool to fetch patches from gerrit server a patch from gerrit into the current branch. 

.DESCRIPTION
It requires 3 arguments: 
The first argument is the operation mode.
This is mandatory, and can either be cp (cherry-pick) or co (checkout).

The second argument should be a url "https:// prefixed"
The third argument is the refspec

In order to be able to take what the "copy to clipboard" copies
as a command line argument, any argument containing "git" or "pull"
will be discarded :D

Therefore, the following command line:
gerrit cp git pull https://codereview.qt-project.org/p/qt/qtbase refs/changes/97/37197/3
is the same as:
gerrit cp https://codereview.qt-project.org/p/qt/qtbase refs/changes/97/37197/3


.EXAMPLE
gerrit cp https://codereview.qt-project.org/p/qt/qtbase refs/changes/97/37197/3

cherry-pick


.EXAMPLE
gerrit cp git pull https://codereview.qt-project.org/p/qt/qtbase refs/changes/97/37197/3

The same as the above example


.EXAMPLE
gerrit co https://codereview.qt-project.org/p/qt/qtbase refs/changes/97/37197/3

checkout. It will checkout into the branch "changes/37197"



#>

$i = 0

$operation = $null
foreach ($arg in $Args) {
    if ($i -eq 0) {
        if (!$operation) {
            $operation = $arg
        }
    } elseif ($i -eq 1) {
        $remote = $arg
    } elseif ($i -eq 2) {
        $refspec = $arg
    }
    if ($arg -ne "git" -and $arg -ne "pull") {
        $i++
    }
}

switch ($operation)
{
    "cp" {
        $refParts = $refspec -split "/"
        #git pull https://smd@codereview.qt-project.org/p/qt/qtdeclarative refs/changes/70/26370/1
        if ($refParts.count -eq 5) {
            $branch = $refParts[3..4] -join "/"
            Write-Host "git fetch $remote $refspec"
            git fetch $remote $refspec
            Write-Host "git cherry-pick FETCH_HEAD"
            git cherry-pick FETCH_HEAD
        }
    }
    "co" {
        $refParts = $refspec -split "/"
        #git pull https://smd@codereview.qt-project.org/p/qt/qtdeclarative refs/changes/70/26370/1
        if ($refParts.count -eq 5) {
            $branch = $refParts[3..4] -join "/"
            Write-Host "git fetch $remote $refspec"
            git fetch $remote $refspec
            Write-Host "git checkout -b change/$branch FETCH_HEAD"
            git checkout -b change/$branch FETCH_HEAD
        }
    }
}