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

:: Set ANSI color escape codes
set "GREEN=[1;32m"
set "GREENU=[4;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[3;35m"
set "SKYBLUE=[96m"

:: Administrator check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo %ORANGE%Requesting administrator privileges...%RESET%
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
    exit /b
)

:main_menu
cls
echo %SKYBLUE%Windows Update Control Panel%RESET%
echo ==========================
echo.
call :show_status
echo.
echo %GREEN%1.%RESET% Disable Automatic Updates (keep manual checks)
echo %GREEN%2.%RESET% Enable Automatic Updates
echo %GREEN%3.%RESET% Completely Disable Windows Update
echo %GREEN%4.%RESET% Fully Enable Windows Update
echo %GREEN%5.%RESET% Exit
echo.
set /p choice=Select option [1-5]: 

if "%choice%"=="1" call :disable_auto_updates
if "%choice%"=="2" call :enable_auto_updates
if "%choice%"=="3" call :disable_windows_update
if "%choice%"=="4" call :enable_windows_update
if "%choice%"=="5" exit
echo %RED%Invalid selection! Please try again.%RESET%
pause
goto main_menu

:disable_auto_updates
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 4 /f
sc config wuauserv start= auto >nul
sc config UsoSvc start= auto >nul
net start wuauserv >nul 2>&1
net start UsoSvc >nul 2>&1
echo %PINK%Disabling automatic updates (manual checks remain available)...%RESET%
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 2 /f
echo %ORANGE%Status: Automatic updates disabled (manual checks still work)%RESET%
pause
goto main_menu

:enable_auto_updates
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 4 /f
sc config wuauserv start= auto >nul
sc config UsoSvc start= auto >nul
net start wuauserv >nul 2>&1
net start UsoSvc >nul 2>&1
echo %PINK%Enabling automatic updates...%RESET%
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 4 /f
echo %GREEN%Status: Automatic updates enabled%RESET%
pause
goto main_menu

:disable_windows_update
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 4 /f
sc config wuauserv start= auto >nul
sc config UsoSvc start= auto >nul
net start wuauserv >nul 2>&1
net start UsoSvc >nul 2>&1
echo %PINK%Completely disabling Windows Update services...%RESET%
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /f >nul 2>&1
net stop wuauserv >nul 2>&1
net stop UsoSvc >nul 2>&1
sc config wuauserv start= disabled >nul
sc config UsoSvc start= disabled >nul
echo %RED%Status: Windows Update completely disabled%RESET%
pause
goto main_menu

:enable_windows_update
echo %PINK%Fully enabling Windows Update...%RESET%
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 4 /f
sc config wuauserv start= auto >nul
sc config UsoSvc start= auto >nul
net start wuauserv >nul 2>&1
net start UsoSvc >nul 2>&1
echo %GREEN%Status: Windows Update fully enabled%RESET%
pause
goto main_menu

:show_status
set "auto_status=Not Configured"
set "service_status=Running"
set "policy_mode=Default"

reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate 2^>nul') do (
        if %%a equ 0x1 (set "auto_status=Disabled") else (set "auto_status=Enabled")
    )
)

sc query wuauserv | find "STOPPED" >nul && set "service_status=Stopped"
sc query wuauserv | find "DISABLED" >nul && set "service_status=Disabled"

reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions 2^>nul') do (
        if %%a equ 0x2 (set "policy_mode=Notify to download")
        if %%a equ 0x3 (set "policy_mode=Auto download, notify install")
        if %%a equ 0x4 (set "policy_mode=Auto download and install")
    )
)

echo %SKYBLUE%Current Status:%RESET%
echo - Automatic Updates: %ORANGE%!auto_status!%RESET%
echo - Windows Update Service: %ORANGE%!service_status!%RESET%
echo - Update Policy: %ORANGE%!policy_mode!%RESET%
exit /b
