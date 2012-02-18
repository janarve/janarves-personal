function GitConfigSet($var, $value)
{
    $oldValue = `git config --global --get $var`
    if ($value -ne $oldValue) {
        if ($oldValue) {
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
            return $pathToTest;
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

#if (!(Test-Path "$loc\hooks\post-commit")) {
    Write-Host "Creating git post-commit hook"
    $qtRepoToolsLoc = Get-LocalOrParentPath("qtrepotools")
    if (!$qtRepoToolsLoc) {
        Write-Host "Could not find qtrepotools\git-hooks\git_post_commit_hook"
    } else {
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
    }
#}

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

Write-Host "Configuring global .gitconfig"

if ("$env:COMPUTERNAME" -eq "PILSEN") {
	GitConfigSet "url.qtsoftware:.insteadOf" "git@scm.dev.troll.no:"
}

GitConfigSet "mailmap.file" "t:\dev\devtools\aliases\mailmap"
GitConfigSet "alias.loginternal" "log --pretty=tformat:'commit %H%nAuthor: %an <%ae>%n (int): %aN <%aE>%nDate: %ad%n%n%s%n%n%b'"
GitConfigSet "core.autocrlf" "true"
GitConfigSet "alias.br" "branch"
GitConfigSet "alias.st" "status"
GitConfigSet "alias.co" "checkout"
GitConfigSet "alias.ce" "config --global -e"
GitConfigSet "alias.pushgerrit" "push gerrit HEAD:refs/for/master"

# Show resulting configuration
git config --global --list

