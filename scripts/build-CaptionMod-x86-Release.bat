@echo off
setlocal
set "Configuration=Release"
call "%~dp0build-CaptionMod-x86.bat" %*
exit /b %errorlevel%
