@echo off

echo Webview directory: %src_dir%
echo Build directory: %build_dir%

echo Looking for vswhere.exe...
set "vswhere=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%vswhere%" set "vswhere=%ProgramFiles%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%vswhere%" (
	echo ERROR: Failed to find vswhere.exe
	exit 1
)
echo Found %vswhere%

echo Looking for VC...
for /f "usebackq tokens=*" %%i in (`"%vswhere%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
  set vc_dir=%%i
)
if not exist "%vc_dir%\Common7\Tools\vsdevcmd.bat" (
	echo ERROR: Failed to find VC tools x86/x64
	exit 1
)
echo Found %vc_dir%

call "%vc_dir%\Common7\Tools\vsdevcmd.bat" -arch=x64 -host_arch=x64

echo Compiling Neutralinojs...

if EXIST bin\neutralino.exe (
    del /f bin\neutralino.exe
)

cl /std:c++17 ^
/I ../core-shared ^
/I src/platform/webview2 ^
/EHsc ^
../core-shared/main.cpp ^
../core-shared/settings.cpp ^
../core-shared/resources.cpp ^
../core-shared/router.cpp ^
../core-shared/auth/authbasic.cpp ^
../core-shared/ping/ping.cpp ^
../core-shared/helpers.cpp ^
../core-shared/permission.cpp ^
../core-shared/server/neuserver.cpp ^
../core-shared/lib/easylogging/easylogging++.cc ^
../core-shared/lib/boxer/boxer_win.cpp ^
src/platform/windows.cpp ^
src/api/computer/computer.cpp ^
src/api/filesystem/filesystem.cpp ^
src/api/os/os.cpp ^
src/api/storage/storage.cpp ^
src/api/debug/debug.cpp ^
src/api/app/app.cpp ^
src/api/window/window.cpp ^
/DELPP_NO_DEFAULT_LOG_FILE ^
/link dll/WebView2Loader.dll.lib "/OUT:bin\neutralino.exe"

if EXIST bin\neutralino.exe (
    echo Neutralino binary is compiled in to bin/netralino.exe
)

if NOT EXIST bin\neutralino.exe (
    echo ERR : Neutralino binary is not compiled
)
