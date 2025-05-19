@echo off
setlocal

:: Check current status of hidden files setting
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden | find "0x1" >nul
if %errorlevel%==0 (
    set STATUS=shown
) else (
    set STATUS=hidden
)

:MENU
cls
echo Hidden Files - %STATUS%
echo.
echo 1. Show Hidden Files
echo 2. Hide Hidden Files
echo 3. Exit
echo.
set /p choice=Enter your choice: 

if "%choice%"=="1" goto SHOW
if "%choice%"=="2" goto HIDE
if "%choice%"=="3" exit
goto MENU

:SHOW
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f >nul
set STATUS=shown
goto MENU

:HIDE
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 2 /f >nul
set STATUS=hidden
goto MENU
