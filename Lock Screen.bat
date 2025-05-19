@echo off
setlocal enabledelayedexpansion

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    :: Create a temporary VBScript to relaunch this script with admin rights
    >"%temp%\getadmin.vbs" (
        echo Set UAC = CreateObject^("Shell.Application"^)
        echo UAC.ShellExecute "%~f0", "", "", "runas", 1
    )
    :: Run the VBScript silently and exit the current window
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit
)


:: Set ANSI color escape codes (for supported terminals)
set "GREEN=[1;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "SKYBLUE=[96m"

:: Ensure administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo %ORANGE%Requesting administrator privileges...%RESET%
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
    exit /b
)

:main_menu
cls
call :show_status
echo.
echo %GREEN%Lock Screen Control Panel%RESET%
echo ===========================
echo.
echo %GREEN%1.%RESET% Enable Lock Screen
echo %GREEN%2.%RESET% Disable Lock Screen
echo %GREEN%3.%RESET% Exit
echo.
set /p choice=Select option [1-3]: 

if "%choice%"=="1" call :enable_lock_screen
if "%choice%"=="2" call :disable_lock_screen
if "%choice%"=="3" exit
echo %RED%Invalid choice. Try again.%RESET%
pause
goto main_menu

:show_status
set "lock_status=Enabled"

:: Check registry for lock screen disable setting (0=enabled, 1=disabled)
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreen >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreen 2^>nul') do (
        if %%a equ 0x1 (set "lock_status=Disabled")
    )
)

echo %SKYBLUE%Current Lock Screen Status:%RESET%
echo - Status: %ORANGE%!lock_status!%RESET%
echo.

exit /b

:disable_lock_screen
echo %RED%Disabling Lock Screen...%RESET%
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreen /t REG_DWORD /d 1 /f
echo %RED%Lock Screen Disabled.%RESET%
pause
goto main_menu

:enable_lock_screen
echo %GREEN%Enabling Lock Screen...%RESET%
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreen /f >nul 2>&1
echo %GREEN%Lock Screen Enabled.%RESET%
pause
goto main_menu
