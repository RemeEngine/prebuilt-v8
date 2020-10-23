@echo on
setlocal EnableDelayedExpansion

set DEPOT_TOOLS_WIN_TOOLCHAIN=0
set PATH=%PATH%;%CD%\depot_tools

set platform=%1
set version=%2
set version=%version:v=%

set spec=
for /f "delims=" %%x in (spec.cfg) do set spec=!spec!%%x

set build_args=
for /f "delims=" %%x in (build_args.cfg) do set build_args=!build_args! %%x

echo platform: %platform%
echo version: %version%
@REM echo %spec%
@REM echo %build_args%

if not %platform%==Windows (
    echo Invalid platform %platform%
    exit 1
) else (
    set platform=win64
)

@REM Acquire V8 source
if not exist v8 (
    fetch v8
)

@REM Prepare build directory
del /f /s /q build 1>nul
rmdir /s /q build
md build

@REM Prepare solution
gclient sync -R -D --revision %version% --spec "%spec%"

@REM Generate build config
cd v8
gn gen ..\build --args="%build_args%"
cd ..

@REM Build V8
cd v8
ninja -v -C ..\build v8_monolith
cd ..

@REM Create package
del /f /s /q package 1>nul
rmdir /s /q package
md package
copy build\obj\libv8_monolith.* package\libv8.*
xcopy v8\include package\include /E /I
tar czf build/v8-v%version%-%platform%.tar.gz -C package .

@REM Output package metadata for GitHub actions
echo ::set-output name=package::v8-v%version%-%platform%
echo ::set-output name=package_path::build/v8-v%version%-%platform%.tar.gz
