@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Analyze-WindowsPerformance.ps1"
set "RC=%ERRORLEVEL%"
echo.
echo Windows Performance Analyzer finished with exit code %RC%.
pause
exit /b %RC%
