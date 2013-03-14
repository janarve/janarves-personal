function GitConfigSet($var, $value)
{
    $oldValue = $(git config --global --get $var)
    if ($value -ne $oldValue) {
        if ($oldValue -ne $null) {
            git config --global --unset-all $var
        }
        git config --global --add $var $value
    }
}

### Borrowed from git-posh project
function Get-LocalOrParentPath($path) {
    $checkIn = Get-Item .
    while ($checkIn -ne $NULL) {
        $pathToTest = [System.IO.Path]::Combine($checkIn.fullname, $path)
        if (Test-Path $pathToTest) {
            return $pathToTest
        } else {
            $checkIn = $checkIn.parent
        }
    }
    return $null
}

$loc = Get-LocalOrParentPath ".git"

if (!$loc) {
	Write-Host "not a git repo!"
	return
}
Write-Host "Found git repository at $loc"


while ((Read-Host "Insert post-commit hook? (Y/n)") -ne "n") {  # just one time, allows us to break out
    Write-Host "Creating git post-commit hook"
    $qtRepoToolsLoc = Get-LocalOrParentPath("qtrepotools")
    if (!$qtRepoToolsLoc) {
        Write-Host "Could not find qtrepotools\git-hooks\git_post_commit_hook"
        $qtRepoToolsLoc = Read-Host "Please give location to qtrepotools"
        if (!(Test-Path "$qtRepoToolsLoc\.git")) {
            Write-Host "Could not install ($qtRepoToolsLoc is not a valid Git repo)"
            break
        }
    }
    
    # mingw-ize the path to the hook so that bash can find it
    $drive = $qtRepoToolsLoc[0]
    $hooksDir = "/$drive/" + $qtRepoToolsLoc.substring(3) + "/git-hooks"
    $hooksDir = $hooksDir.replace("\", "/")
    $hooksDir = $hooksDir.replace("\", "/")
    $content =
@"
#!/bin/sh
export PATH=`$PATH:$hooksDir
exec $hooksDir/git_post_commit_hook
"@
        Set-Content "$loc\hooks\post-commit" $content
        Write-Host "$loc\hooks\post-commit"
    break
}

if ((Read-Host "Install commit-msg hook (for gerrit)? (Y/n)") -ne "n") {
    $copyCommitMsg = $false
    if ((Test-Path "$loc\hooks\commit-msg")) {
        $commitMsgSize = (Get-ItemProperty "$loc\hooks\commit-msg").Length
        if ($commitMsgSize -lt 200) {
            $copyCommitMsg = $true
        }
    } else {
        $copyCommitMsg = $true
    }

    if ($copyCommitMsg) {
        Write-Host "Copying git commit-msg hook"
        Push-Location "$loc\hooks\"
        scp -p smd@codereview.qt-project.org:hooks/commit-msg .
        Pop-Location
    }
}

if ((Read-Host "Configure global .gitconfig? (y/N)") -eq "y") {
    Write-Host "Configuring global .gitconfig"

    if ("$env:COMPUTERNAME" -eq "PILSEN") {
        GitConfigSet "url.qtsoftware:.insteadOf" "git@scm.dev.troll.no:"
    }

    GitConfigSet "mailmap.file" "t:\dev\devtools\aliases\mailmap"
    GitConfigSet "alias.loginternal" "log --pretty=tformat:'commit %H%nAuthor: %an <%ae>%n (int): %aN <%aE>%nDate: %ad%n%n%s%n%n%b'"
    GitConfigSet "core.autocrlf" "true"
    GitConfigSet "alias.br" "branch"
    GitConfigSet "alias.ce" "config --global -e"
    GitConfigSet "alias.co" "checkout"
    GitConfigSet "alias.cp" "cherry-pick"
    GitConfigSet "alias.di" "diff"
    GitConfigSet "alias.pr" "pull --rebase"
    GitConfigSet "alias.st" "status"
    GitConfigSet "alias.pushgerrits" "push gerrit HEAD:refs/for/stable"
    GitConfigSet "alias.pushgerritd" "push gerrit HEAD:refs/for/dev"
    GitConfigSet "alias.pushgerrit48" "push gerrit HEAD:refs/for/4.8"
    GitConfigSet "alias.currentbranch" "rev-parse --abbrev-ref HEAD"

    # Show resulting configuration
    git config --global --list

}
