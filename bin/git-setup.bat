@echo off
REM
REM 
REM 

pushd .

:loop
if exist .git goto :found_git_repo
cd ..
FOR /F "tokens=1,2 delims=:" %%A IN ('echo %CD%') DO IF NOT "%%B" EQU "\" ( goto :loop )
if NOT exist .git goto :error_not_a_git_repo

:found_git_repo
echo Found git repository at '%CD%'
if EXIST %CD%.\.git\hooks\post-commit (
    goto :done
)
echo Configuring git post-commit hook
mklink %CD%\.git\hooks\post-commit t:\dev\devtools\shell\git_post_commit_hook
goto :done

:error_not_a_git_repo
echo not a git repo!
goto :done

:done
popd




echo Configuring aliases
REM qtsoftware:.insteadOf
if "%COMPUTERNAME%" EQU "PILSEN" (
    call :git_config_set "url.qtsoftware:.insteadOf",git@scm.dev.troll.no:
) else (
    REM ###???call :git_config_set "url.qtsoftware:.insteadOf",git@scm.dev.troll.no:
    echo ###fix me
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
