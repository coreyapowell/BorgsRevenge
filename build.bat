@echo off
REM specify a particular build in arg1 and go to that: build 2
IF "%~1" == "" (
REM if nothing is specified, set to 0. calling 0 will do all folders
    set /a ARG1=0
) ELSE (
REM just the one folder then 
    set /a ARG1=%1
)

REM backup directory and go to the root of projects
set returndir=%cd%
set compilever="project root folder"
set projectrootdosdir=\msys64\home\Corey\qjs\ng
set projectrootgnudir=/msys64/home/Corey/qjs/ng
cd %projectrootdosdir%
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED

:MINGW
IF %ARG1% GTR 1 GOTO CLANG64
set compilever="MSYS2 MINGW64"
set projectbuilddir=mingw
cd  %projectrootdosdir%\%projectbuilddir%
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED
echo @@ building %compilever%
cmd /c C:\msys64\msys2_shell.cmd -defterm -where "c:%projectrootgnudir%/%projectbuilddir%" -no-start -mingw64 -shell bash -c "cmake --build ."
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
echo @@ %compilever% built successfully.
@echo[
IF %ARG1% GTR 0 GOTO COMPLETE

:CLANG64
IF %ARG1% GTR 2 GOTO WSL
set compilever="MSYS2 CLANG64"
set projectbuilddir=clang64
cd  %projectrootdosdir%\%projectbuilddir%
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED
echo @@ building %compilever%
cmd /c C:\msys64\msys2_shell.cmd -defterm -where "c:%projectrootgnudir%/%projectbuilddir%" -no-start -clang64 -shell bash -c "cmake --build ."
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
echo @@ %compilever% built successfully.
@echo[
IF %ARG1% GTR 0 GOTO COMPLETE

:WSL
IF %ARG1% GTR 3 GOTO MSVC
set compilever="WSL Debian"
set projectbuilddir=wsl
cd  %projectrootdosdir%\%projectbuilddir%
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED
echo @@ building %compilever%
cmd /c wsl -e sh -c "cd /mnt/c%projectrootgnudir%/%projectbuilddir%; cmake --build ."
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
echo @@ %compilever% built successfully.
@echo[
IF %ARG1% GTR 0 GOTO COMPLETE

:MSVC
IF %ARG1% GTR 4 GOTO MSCLANG
set compilever="MSVC"
set projectbuilddir=msvc
cd  %projectrootdosdir%\%projectbuilddir%
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED
echo @@ building %compilever%
REM cmd /c msbuild quickjs.sln /p:Configuration=Release
cmd /c cmake --build .
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
echo @@ %compilever% built successfully.
@echo[
IF %ARG1% GTR 0 GOTO COMPLETE

:MSCLANG
IF %ARG1% GTR 5 GOTO COMPLETE
set compilever="Clang for MSVC"
set projectbuilddir=msclang
cd  %projectrootdosdir%\%projectbuilddir%
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED
echo @@ building %compilever%
REM cmd /c msbuild quickjs.sln /p:Configuration=Release
cmd /c cmake --build .
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
@echo @@ %compilever% built successfully.
@echo[
IF %ARG1% GTR 0 GOTO COMPLETE

:COMPLETE
@echo @@ All builds successful @@
GOTO END
cd %returndir%
:FOLDERFAILED
echo %compilever% : Failed to create build folder!
GOTO END
:FAILED
echo %compilever% : FAILED!
:END
cd %returndir%

@PAUSE
