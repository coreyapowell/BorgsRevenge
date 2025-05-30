@echo off
REM specified with no paramters or "cmakebuild 0" runs all cmake configurations
REM specify a number: "cmakebuild 1" will just create MSVC folder and run cmake
REM specify 2nd param 1 to force overwrite: "cmakebuild 2 1" deleetes and builds clang64
REM to just force rebuild all folders specify "cmakebuild 0 1"

REM specify a particular build in arg1
IF "%~1" == "" (
    set /a ARG1=0
) ELSE (
    set /a ARG1=%1
)
set returndir=%cd%

REM specify arg2 as 1 if you want to remove the old folder
IF "%~2" == "" (
    set /a ARG2=0
) ELSE (
    set /a ARG2=%2
)

set compilever="starting folder"
cd \msys64\home\Corey\qjs\ng
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED

IF %ARG1% GTR 1 GOTO CLANG64
set compilever="MSYS2 MINGW64"
IF %ARG2%==1 rmdir /S /Q mingw
mkdir mingw
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED

echo @@ running cmake for %compilever%
cmd /c C:\msys64\msys2_shell.cmd -defterm -where "c:/msys64/home/Corey/qjs/ng/mingw" -no-start -mingw64 -shell bash -c "cmake -B . -S .."
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
echo @@ %compilever% built successfully.
@echo[
IF %ARG1% GTR 0 GOTO COMPLETE

:CLANG64
IF %ARG1% GTR 2 GOTO WSL
set compilever="MSYS2 CLANG64"
IF %ARG2%==1 rmdir /S /Q clang64
mkdir clang64
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED

echo @@ building %compilever%
cmd /c C:\msys64\msys2_shell.cmd -defterm -where "c:/msys64/home/Corey/qjs/ng/clang64" -no-start -clang64 -shell bash -c "cmake -B . -S .."
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
echo @@ %compilever% built successfully.
@echo[
IF %ARG1% GTR 0 GOTO COMPLETE    

:WSL
IF %ARG1% GTR 3 GOTO MSVC
set compilever="WSL Debian"
IF %ARG2%==1 rmdir /S /Q wsl
mkdir wsl
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED

echo @@ building %compilever%
cmd /c wsl -e sh -c "cd /mnt/c/msys64/home/Corey/qjs/ng/wsl; cmake -B . -S .."
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
echo @@ %compilever% built successfully.
@echo [
IF %ARG1% GTR 0 GOTO COMPLETE

:MSVC
IF %ARG1% GTR 4 GOTO MSCLANG
set compilever="MSVC"
IF %ARG2%==1 rmdir /S /Q msvc
mkdir msvc
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED
cd msvc
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
IF %ARG2%==1 rmdir /S /Q msclang
mkdir msclang
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED
cd msclang
IF %ERRORLEVEL% NEQ 0 GOTO FOLDERFAILED

echo @@ building %compilever%
cd c:\msys64\home\Corey\qjs\ng\msclang
REM this is removed because I started getting errors: build with: cmake --build .
REM cmake -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -D CMAKE_BUILD_TYPE=Release -S ../ -B .
REM without -G Ninja this version will use the MSVC build environment
cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -D CMAKE_BUILD_TYPE=Release -S .. -B .
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
@echo @@ %compilever% built successfully.
cd ../
@echo[
IF %ARG1% GTR 0 GOTO COMPLETE

:COMPLETE
@echo @@ All Cmake configurations successful @@
GOTO END
cd %returndir%
:FOLDERFAILED
echo %compilever% : Failed to create build folder!
GOTO END
:FAILED
echo %compilever% : FAILED!
:END
cd %returndir%



