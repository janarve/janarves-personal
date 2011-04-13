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
mklink %CD%\.git\hooks\post-commit t:\dev\devtools\shell\git_post_commit_hook
goto :done

:error_not_a_git_repo
echo not a git repo!
goto :done

:done
popd