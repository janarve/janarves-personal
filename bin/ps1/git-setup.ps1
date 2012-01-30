function GitConfigSet($var, $value)
{
	git config --global --unset-all $var
	git config --global --add $var $value
	return
}


Push-Location .
$drive = Get-Location | Split-Path -Qualifier
$drive = $drive + "\"

while (!(Test-Path .git)) {
	Set-Location ..
	$loc = Get-Location
	if ("$loc" -eq "$drive") {
		break
	}
}
$loc = Get-Location

if ("$loc" -eq "$drive") {
	Write-Host "not a git repo!"
	return
}
Write-Host "Found git repository at $loc"

if (!(Test-Path "$curr\.git\hooks\post-commit")) {
	Write-Host "Configuring git post-commit hook (not implemented)"
}

Write-Host "Configuring global .gitconfig"

if ("$env:COMPUTERNAME" -eq "PILSEN") {
	GitConfigSet("url.qtsoftware:.insteadOf", "git@scm.dev.troll.no:")
}
git config --global mailmap.file t:\dev\devtools\aliases\mailmap
git config --global alias.loginternal "log --pretty=tformat:'commit %H%nAuthor: %an <%ae>%n (int): %aN <%aE>%nDate: %%ad%%n%%n%%s%%n%%n%%b'"

GitConfigSet("core.autocrlf", "true");
GitConfigSet("alias.br", "branch");
GitConfigSet("alias.st", "status");
GitConfigSet("alias.co", "checkout");
GitConfigSet("alias.ce", "config --global -e");

# Show resulting configuration
git config --global --list

Pop-Location