@echo off
REM
REM 
REM 

pushd .

REM *******************************************************
REM **
REM ** Detect root of the git repo we're inside
REM **
REM *******************************************************
:loop
if exist .git goto :found_git_repo
cd ..
FOR /F "tokens=1,2 delims=:" %%A IN ('echo %CD%') DO IF NOT "%%B" EQU "\" ( goto :loop )
if NOT exist .git goto :error_not_a_git_repo

:found_git_repo
echo Found git repository at '%CD%'




REM *******************************************************
REM **
REM ** Install .git\hooks\post-commit
REM **
REM *******************************************************
if EXIST .git\hooks\post-commit (
    goto :post_commit_installed
)

echo Configuring git post-commit hook
mklink .git\hooks\post-commit t:\dev\devtools\shell\git_post_commit_hook

:post_commit_installed




REM *******************************************************
REM **
REM ** Install .git\hooks\commit-msg
REM **
REM *******************************************************
if EXIST .git\hooks\commit-msg (
    goto :skip_commit_msg_install
)
REM ### Check if we are a Qt 5 repo
if NOT EXIST sync.profile (
    goto :skip_commit_msg_install
)
echo Configuring gerrit commit msg
scp -p smd@codereview.qt-project.org:hooks/commit-msg .git\hooks

:skip_commit_msg_install

goto :done

:error_not_a_git_repo
echo not a git repo!

:done
popd


REM 
REM
REM
echo "please add add gerrit remote:"
echo "  git remote add gerrit codereview.qt-project.org:qt/<qtbase|qt5|...>"



REM *******************************************************
REM **
REM ** Set up aliases
REM **
REM *******************************************************
echo Configuring aliases
REM qtsoftware:.insteadOf
if "%COMPUTERNAME%" EQU "PILSEN" (
    call :git_config_set "url.git@scm.dev.troll.no::.insteadOf",qtsoftware:
) else (
    call :git_config_set "url.git@scm.dev.nokia.troll.no:.insteadOf",qtsoftware:
)
call :git_config_set core.autocrlf,true
call :git_config_set user.email,jan-arve.saether@nokia.com
call :git_config_set user.name,"Jan-Arve Saether"

call :git_config_set alias.br,branch
call :git_config_set alias.st,status
call :git_config_set alias.co,checkout

git config --global mailmap.file t:\dev\devtools\aliases\mailmap
git config --global alias.loginternal "log --pretty=tformat:'commit %%H%%nAuthor: %%an <%%ae>%%n (int): %%aN <%%aE>%%nDate: %%ad%%n%%n%%s%%n%%n%%b'"


REM show resulting file
git config --global --list
goto :EOF

:git_config_set
    call git config --global --unset-all %1
    call git config --global --add %1 %2
    goto :EOF
