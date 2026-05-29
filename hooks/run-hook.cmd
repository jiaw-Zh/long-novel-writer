@echo off
:: run-hook.cmd — Polyglot hook runner (Windows batch / Unix bash)
:: Usage: run-hook.cmd <hook-name>

set "HOOK_NAME=%~1"
if "%HOOK_NAME%"=="" (
    echo Usage: run-hook.cmd ^<hook-name^>
    exit /b 1
)

:: Detect if running in bash (via Git Bash, WSL, etc.)
if defined BASH_VERSION (
    bash "%~dp0%HOOK_NAME%"
    exit /b %errorlevel%
)

:: Try to find bash in common locations
where bash >nul 2>&1
if %errorlevel%==0 (
    bash "%~dp0%HOOK_NAME%"
    exit /b %errorlevel%
)

:: Fallback: try Git Bash
if exist "C:\Program Files\Git\bin\bash.exe" (
    "C:\Program Files\Git\bin\bash.exe" "%~dp0%HOOK_NAME%"
    exit /b %errorlevel%
)

echo ERROR: bash not found. Install Git for Windows or WSL.
exit /b 1
