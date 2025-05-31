@echo off
REM "cmakebuild" creates 5 folders and a build environment in each
REM specified with no paramters or "cmakebuild 0" runs all cmake configurations
REM specify a number: "cmakebuild 1" will just create MSVC folder and run cmake
REM specify 2nd param 1 to force overwrite: "cmakebuild 2 1" deleetes and builds clang64
REM to just force rebuild all folders specify "cmakebuild 0 1"

REM specify a particular build in arg1 and go to that
IF "%~1" == "" (
REM if nothing is specified, set to 0. calling 0 will do all folders
    set /a ARG1=0
) ELSE (
REM just the one folder then 
    set /a ARG1=%1
)

REM specify arg2 as 1 if you want to remove the old directory
IF "%~2" == "" (
    set /a ARG2=0
) ELSE (
    set /a ARG2=%2
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
set projectbuilddir="mingw"
IF %ARG2%==1 rmdir /S /Q %projectrootdosdir%\%projectbuilddir%
mkdir %projectrootdosdir%\%projectbuilddir%
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED

echo @@ running cmake for %compilever%
cmd /c C:\msys64\msys2_shell.cmd -defterm -where "c:%projectrootgnudir%/%projectbuilddir%" -no-start -mingw64 -shell bash -c "cmake -B . -S .."
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
echo @@ %compilever% built successfully.
@echo[
IF %ARG1% GTR 0 GOTO COMPLETE

:CLANG64
IF %ARG1% GTR 2 GOTO WSL
set compilever="MSYS2 CLANG64"
set projectbuilddir="clang64"
IF %ARG2%==1 rmdir /S /Q %projectrootdosdir%\%projectbuilddir%
mkdir %projectrootdosdir%\%projectbuilddir%
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED

echo @@ building %compilever%
cmd /c C:\msys64\msys2_shell.cmd -defterm -where "c:%projectrootgnudir%/%projectbuilddir%" -no-start -clang64 -shell bash -c "cmake -B . -S .."
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
echo @@ %compilever% built successfully.
@echo[
IF %ARG1% GTR 0 GOTO COMPLETE    

:WSL
IF %ARG1% GTR 3 GOTO MSVC
set compilever="WSL Debian"
set projectbuilddir="wsl"
IF %ARG2%==1 rmdir /S /Q %projectrootdosdir%\%projectbuilddir%
mkdir %projectrootdosdir%\%projectbuilddir%
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED

echo @@ building %compilever%
cmd /c wsl -e sh -c "cd /mnt/c/%projectrootgnudir%/%projectbuilddir%; cmake -B . -S .."
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
echo @@ %compilever% built successfully.
@echo[
IF %ARG1% GTR 0 GOTO COMPLETE

:MSVC
IF %ARG1% GTR 4 GOTO MSCLANG
set compilever="MSVC"
set projectbuilddir="msvc"
IF %ARG2%==1 rmdir /S /Q %projectrootdosdir%\%projectbuilddir%
mkdir %projectrootdosdir%\%projectbuilddir%
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED
cd  %projectrootdosdir%\%projectbuilddir%
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED

echo @@ building %compilever%
cmake -G "Visual Studio 17 2022" -S ..\ -B .
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
echo @@ %compilever% built successfully.
cd ../
@echo[
IF %ARG1% GTR 0 GOTO COMPLETE

:MSCLANG
IF %ARG1% GTR 5 GOTO COMPLETE
set compilever="Clang for MSVC"
set projectbuilddir="msclang"
IF %ARG2%==1 rmdir /S /Q %projectrootdosdir%\%projectbuilddir%
mkdir %projectrootdosdir%\%projectbuilddir%
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED
cd  %projectrootdosdir%\%projectbuilddir%
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED

echo @@ building %compilever%
REM this is removed because I started getting errors: build with: cmake --build .
REM cmake -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -D CMAKE_BUILD_TYPE=Release -S ../ -B .
REM without -G Ninja this version will use the MSVC build environment
cmake -S .. -B . -G "Visual Studio 17 2022" -T="ClangCL" -D_CMAKE_TOOLCHAIN_PREFIX="ClangCL" -DCMAKE_C_COMPILER:FILEPATH="C:\Program Files\LLVM\bin\clang.exe" -DCMAKE_CXX_COMPILER:FILEPATH="C:\Program Files\LLVM\bin\clang++.exe"
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
@echo @@ %compilever% built successfully.
cd ../
@echo[
IF %ARG1% GTR 0 GOTO COMPLETE

:COMPLETE
@echo @@ All Cmake configurations successful @@
@echo[
GOTO END

:FOLDERFAILED
echo %compilever% : Failed to create build folder!
GOTO END
:FAILED
echo %compilever% : FAILED!
:END
cd %returndir%
