@echo off
set returndir=%cd%
REM echo %CWD%
REM cd \msys64\home\Corey\qjs\ng\mingw

set compilever="MSYS2 MINGW64"
echo @@ building %compilever%
cmd /c C:\msys64\msys2_shell.cmd -defterm -where "c:/msys64/home/Corey/qjs/ng/mingw" -no-start -mingw64 -shell bash -c "echo @@ making mingw version & cmake --build ."
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
echo @@ %compilever% built successfully.
@echo[

set compilever="MSYS2 CLANG64"
echo @@ building %compilever%
cmd /c C:\msys64\msys2_shell.cmd -defterm -where "c:/msys64/home/Corey/qjs/ng/clang64" -no-start -clang64 -shell bash -c "cmake --build ."
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
echo @@ %compilever% built successfully.
@echo[

set compilever="WSL Debian"
echo @@ building %compilever%
cmd /c wsl -e sh -c "cd /mnt/c/msys64/home/Corey/qjs/ng/deb; make"
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
echo @@ %compilever% built successfully.
@echo [

set compilever="MSVC"
echo @@ building %compilever%
cmd /c msbuild c:\msys64\home\Corey\qjs\ng\ms\quickjs.sln /p:Configuration=Release
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
echo @@ %compilever% built successfully.
@echo[

set compilever="Clang for MSVC"
echo @@ building %compilever%
cd c:\msys64\home\Corey\qjs\ng\msclangr
cmd /c ninja
IF %ERRORLEVEL% NEQ 0 GOTO FAILED
@echo @@ %compilever% built successfully.
@echo[

@echo @@ All compiles completed successfully @@
GOTO END
cd %returndir%
:FAILED
echo %compilever% : compile FAILED!
:END
cd %returndir%
