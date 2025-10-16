@echo off
echo Building Visual Studio 2022 project files...

cd build

echo Running Premake5...
premake5.exe vs2022

if %errorlevel% neq 0 (
    echo Error running Premake5!
    pause
    exit /b %errorlevel%
)

echo Project files generated successfully!
pause