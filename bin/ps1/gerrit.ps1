<#
.SYNOPSIS
A tool to ease usage of gerrit from powershell.

.DESCRIPTION
Can for instance do cherry-pick, checkout and push.

In order to be able to take what the "copy to clipboard" copies
as a command line argument, any argument containing "git" or "pull"
will be discarded when invoked with the "cp" or "co" commands.

Therefore, the following command line:
gerrit cp git pull https://codereview.qt-project.org/p/qt/qtbase refs/changes/97/37197/3
is the same as:
gerrit cp https://codereview.qt-project.org/p/qt/qtbase refs/changes/97/37197/3

However, "git push pull" is allowed (if you want to push to a branch called pull)

.PARAMETER command
What action to perform. Can be on of these:
  cp <remote> <refspec>     fetches from gerrit and cherry picks into current branch
  co <remote> <refspec>     fetches from gerrit and checkouts into a separate branch
  push <branch>             pushed local commit(s) to gerrit
<remote> argument is a gerrit URL "https://" prefixed
<refspec> argument is a gerrit refspec (e.g. refs/changes/97/37197/3)
<branch> is the branch to push to

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
param([string]$command)

function parseUrlAndRefSpectFromGitPull($gitPullArgs, [ref] $remote, [ref] $refspec)
{
#gitPullArgs: git pull https://smd@codereview.qt-project.org/p/qt/qtdeclarative refs/changes/70/26370/1
    $i = 0
    foreach ($arg in $gitPullArgs) {
        switch ($i) {
            0 { $remote.Value = $arg }
            1 { 
                # simple validate
                $refParts = $arg -split "/"
                if ($refParts.count -eq 5) {
                    $refspec.Value = $arg                    
                }
            }
        }
        if ($arg -ne "git" -and $arg -ne "pull") {
            $i++
        }            
    }    
}

switch ($command)
{
    "cp" {
        $remote = $null
        $refspec = $null
        parseUrlAndRefSpectFromGitPull $Args ([ref]$remote) ([ref]$refspec)
        if ($remote -and $refspec) {
            $cmd = "git fetch $remote $refspec"
            Write-Host $cmd
            Invoke-Expression $cmd

            $cmd = "git cherry-pick FETCH_HEAD"
            Write-Host $cmd
            Invoke-Expression $cmd
        }
    }
    "co" {
        $remote = $null
        $refspec = $null
        parseUrlAndRefSpectFromGitPull $Args ([ref]$remote) ([ref]$refspec)
        $refParts = $refspec -split "/"
        if ($refParts.count -eq 5) {
            $branch = $refParts[3..4] -join "/"
            $cmd = "git fetch $remote $refspec"
            Write-Host $cmd
            Invoke-Expression $cmd

            $cmd = "git checkout -b change/$branch FETCH_HEAD"
            Write-Host $cmd
            Invoke-Expression $cmd
        }
    }
    "push" {
        if ($Args.count -eq 0) {
            Write-Host "Syntax: gerrit push <branch>"
            Exit-PSSession
        } else {
            $branch = $Args[0]
            $cmd = "git push gerrit HEAD:refs/for/$branch"
            Write-Host $cmd
            Invoke-Expression $cmd
        }
    }
}