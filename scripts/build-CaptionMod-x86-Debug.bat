@echo off
setlocal
set "Configuration=Debug"
call "%~dp0build-CaptionMod-x86.bat" %*
exit /b %errorlevel%
