function GitConfigSet($var, $value)
{
    $oldValue = `git config --global --get $var`
    if ($value -ne $oldValue) {
        git config --global --add $var $value
    }
	return
}

function Get-LocalOrParentPath($path) {
    $checkIn = Get-Item .
    while ($checkIn -ne $NULL) {
        $pathToTest = [System.IO.Path]::Combine($checkIn.fullname, $path)
        if (Test-Path $pathToTest) {
            return $checkIn.fullname;
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

if (!(Test-Path "$loc\.git\hooks\post-commit")) {
	Write-Host "Configuring git post-commit hook (not implemented)"
}

$copyCommitMsg = $false
if ((Test-Path "$loc\.git\hooks\commit-msg")) {
    $commitMsgSize = (Get-ItemProperty .git\hooks\commit-msgd).Length
    if ($commitMsgSize -lt 200) {
        $copyCommitMsg = $true
    }
} else {
    $copyCommitMsg = $true
}

if ($copyCommitMsg) {
	Write-Host "Configuring git commit-msg hook"
    Push-Location "$loc\.git\hooks\"
    scp -p smd@codereview.qt-project.org:hooks/commit-msg .
    Pop-Location
}

Write-Host "Configuring global .gitconfig"

if ("$env:COMPUTERNAME" -eq "PILSEN") {
	GitConfigSet "url.qtsoftware:.insteadOf" "git@scm.dev.troll.no:"
}

GitConfigSet "mailmap.file" "t:\dev\devtools\aliases\mailmap"
GitConfigSet "alias.loginternal" "log --pretty=tformat:'commit %H%nAuthor: %an <%ae>%n (int): %aN <%aE>%nDate: %%ad%%n%%n%%s%%n%%n%%b'"
GitConfigSet "core.autocrlf" "true"
GitConfigSet "alias.br" "branch"
GitConfigSet "alias.st" "status"
GitConfigSet "alias.co" "checkout"
GitConfigSet "alias.ce" "config --global -e"
GitConfigSet "alias.pushgerrit" "push gerrit HEAD:refs/for/master"

# Show resulting configuration
git config --global --list

