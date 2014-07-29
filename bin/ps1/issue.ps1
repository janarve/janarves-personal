param([string]$issueNumberOrSubdir)

function GetGitCurrentBranch()
{
    git rev-parse --abbrev-ref HEAD
}

$issueDirs = @("$env:QTREPOS\issues", "q:\tasks")
$qtdir = Get-QtBasePath

if (!$qtdir) {
    Write-Host "Could not detect location of Qt, neither through QTDIR or SETQT_PATH. Run setqt <version>"
    return
}


$guessedFromCurrentBranch = $false
if (!$issueNumberOrSubdir) {
    $currentBranchName = GetGitCurrentBranch
    $issueNumberOrSubDir = $currentBranchName
}
if ($issueNumberOrSubdir) {
    foreach ($s in $issueDirs) {
        $dest = "$s\*$issueNumberOrSubdir"
        if (Test-Path $dest) {
            Push-Location $dest
            return
        }
    }
    if ($guessedFromCurrentBranch) {
        Write-Host "No argument given, trying to deduct issue from current branch name ($issueNumberOrSubDir)"
    }
    Write-Host "$issueNumberOrSubdir not found in $issueDirs"
    return
}
