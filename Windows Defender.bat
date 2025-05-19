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
echo %GREEN%Windows Defender Control Panel%RESET%
echo ===============================
echo.
echo %GREEN%1.%RESET% Enable Windows Defender
echo %GREEN%2.%RESET% Disable Windows Defender
echo %GREEN%3.%RESET% Exit
echo.
set /p choice=Select option [1-3]: 

if "%choice%"=="1" call :enable_defender
if "%choice%"=="2" call :disable_defender
if "%choice%"=="3" exit
echo %RED%Invalid choice. Try again.%RESET%
pause
goto main_menu

:show_status
set "defender_status=Enabled"

:: Check if Defender service is running
sc query WinDefend | findstr /i "RUNNING" >nul
if errorlevel 1 (
    set "defender_status=Stopped"
)

:: Check if Real-Time Protection is disabled in registry
for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring 2^>nul') do (
    if %%a neq 0x0 set "defender_status=Disabled"
)

echo %SKYBLUE%Current Windows Defender Status:%RESET%
echo - Service Status: %ORANGE%!defender_status!%RESET%
echo.

exit /b

:disable_defender
echo %RED%Disabling Windows Defender Real-Time Protection and Service...%RESET%
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f >nul 2>&1
sc stop WinDefend >nul 2>&1
sc config WinDefend start= disabled >nul 2>&1
echo %RED%Windows Defender Disabled.%RESET%
pause
goto main_menu

:enable_defender
echo %GREEN%Enabling Windows Defender Real-Time Protection and Service...%RESET%
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 0 /f >nul 2>&1
sc config WinDefend start= auto >nul 2>&1
sc start WinDefend >nul 2>&1
echo %GREEN%Windows Defender Enabled.%RESET%
pause
goto main_menu
