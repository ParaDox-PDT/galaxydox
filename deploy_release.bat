@echo off
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tool\deploy_release.ps1"
exit /b %ERRORLEVEL%
