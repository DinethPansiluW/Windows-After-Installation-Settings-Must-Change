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
echo %GREEN%Background Apps Control Panel%RESET%
echo =============================== 
echo.
echo %GREEN%1.%RESET% Enable Background Apps
echo %GREEN%2.%RESET% Disable Background Apps
echo %GREEN%3.%RESET% Exit
echo.
set /p choice=Select option [1-3]: 

if "%choice%"=="1" call :enable_bg_apps
if "%choice%"=="2" call :disable_bg_apps
if "%choice%"=="3" exit
echo %RED%Invalid choice. Try again.%RESET%
pause
goto main_menu

:show_status
set "bg_apps_status=Enabled"

:: Check registry setting for background apps (0=enabled, 2=disabled)
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=3" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled 2^>nul') do (
        if %%a equ 0x2 (set "bg_apps_status=Disabled")
    )
) else (
    :: If key/value doesn't exist, assume enabled by default
    set "bg_apps_status=Enabled"
)

echo %SKYBLUE%Current Background Apps Status:%RESET%
echo - Status: %ORANGE%!bg_apps_status!%RESET%
echo.

exit /b

:disable_bg_apps
echo %RED%Disabling Background Apps...%RESET%
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 2 /f
echo %RED%Background Apps Disabled.%RESET%
pause
goto main_menu

:enable_bg_apps
echo %GREEN%Enabling Background Apps...%RESET%
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /f >nul 2>&1
echo %GREEN%Background Apps Enabled.%RESET%
pause
goto main_menu
