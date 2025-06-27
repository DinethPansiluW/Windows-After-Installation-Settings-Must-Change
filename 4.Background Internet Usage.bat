@echo off
setlocal enabledelayedexpansion

:: Define ESC character for ANSI codes (ASCII 27)
for /F "delims=" %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"

:: Set ANSI color escape codes (for supported terminals)
set "GREEN=[1;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "SKYBLUE=[96m"

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
echo %GREEN%Background Internet Usage Control Panel%RESET%
echo ========================================
echo.
echo %GREEN%1.%RESET% Disable Background Internet Usage
echo %GREEN%2.%RESET% Enable Background Internet Usage
echo %GREEN%3.%RESET% Exit
echo.
set /p choice=Select option [1-3]: 

if "%choice%"=="2" call :enable_bg_internet
if "%choice%"=="1" call :disable_bg_internet
if "%choice%"=="3" exit
echo %RED%Invalid choice. Try again.%RESET%
pause
goto main_menu

:show_status
set "bg_internet_status=Enabled"

:: Check registry setting for background internet usage (0=enabled, 1=disabled)
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=3" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled 2^>nul') do (
        if %%a equ 0x1 (
            set "bg_internet_status=Disabled"
        ) else (
            set "bg_internet_status=Enabled"
        )
    )
) else (
    set "bg_internet_status=Enabled"
)

echo %SKYBLUE%Current Background Internet Usage Status:%RESET%
echo - Status: %ORANGE%!bg_internet_status!%RESET%
echo.

exit /b

:disable_bg_internet
echo %RED%Disabling Background Internet Usage...%RESET%
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f
echo %RED%Background Internet Usage Disabled.%RESET%
pause
goto main_menu

:enable_bg_internet
echo %GREEN%Enabling Background Internet Usage...%RESET%
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /f >nul 2>&1
echo %GREEN%Background Internet Usage Enabled.%RESET%
pause
goto main_menu
