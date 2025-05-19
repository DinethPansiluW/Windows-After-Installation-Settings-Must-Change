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
echo %GREEN%Delivery Optimization Control Panel%RESET%
echo ===============================
echo.
echo %GREEN%1.%RESET% Enable Delivery Optimization
echo %GREEN%2.%RESET% Disable Delivery Optimization
echo %GREEN%3.%RESET% Exit
echo.
set /p choice=Select option [1-3]: 

if "%choice%"=="1" call :enable_dosvc
if "%choice%"=="2" call :disable_dosvc
if "%choice%"=="3" exit
echo %RED%Invalid choice. Try again.%RESET%
pause
goto main_menu

:show_status
set "do_status=Enabled"
set "svc_status=Running"

:: Check registry setting
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode 2^>nul') do (
        if %%a equ 0x0 (set "do_status=Disabled")
    )
)

:: Check service status
sc query DoSvc | find "STOPPED" >nul && set "svc_status=Stopped"
sc query DoSvc | find "DISABLED" >nul && set "svc_status=Disabled"

echo %SKYBLUE%Current Delivery Optimization Status:%RESET%
echo - Policy: %ORANGE%!do_status!%RESET%
echo - Service: %ORANGE%!svc_status!%RESET%
echo.

exit /b

:disable_dosvc
echo %RED%Disabling Delivery Optimization...%RESET%
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 0 /f
net stop DoSvc >nul 2>&1
sc config DoSvc start= disabled >nul
echo %RED%Delivery Optimization Disabled.%RESET%
pause
goto main_menu

:enable_dosvc
echo %GREEN%Enabling Delivery Optimization...%RESET%
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /f >nul 2>&1
sc config DoSvc start= auto >nul
net start DoSvc >nul 2>&1
echo %GREEN%Delivery Optimization Enabled.%RESET%
pause
goto main_menu
