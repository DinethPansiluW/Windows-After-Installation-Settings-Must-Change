@echo off
setlocal enabledelayedexpansion

:: Define ESC character for ANSI escape codes
for /f "delims=" %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

:: Set ANSI color escape codes
set "GREEN=[1;32m"
set "GREENU=[4;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[3;35m"
set "SKYBLUE=[96m"
set "YELLOW=[1;33m"
set "CYAN=[36m"

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
echo %GREENU%Delivery Optimization Control Panel%RESET%
echo %CYAN%===============================================%RESET%
echo %YELLOW%When Enabled:%RESET%
echo Advantages: %PINK%Speeds up updates and reduces internet bandwidth usage.%RESET%
echo Disadvantages: %PINK%Can use local network and internet resources, potentially affecting performance.%RESET%
echo.
echo %GREEN%1.%RESET% Enable Delivery Optimization
echo %GREEN%2.%RESET% Disable Delivery Optimization
echo %GREEN%3.%RESET% Exit
echo.
set /p choice=%CYAN%Select option [1-3]: %RESET%

if "%choice%"=="1" call :enable_dosvc & goto main_menu
if "%choice%"=="2" call :disable_dosvc & goto main_menu
if "%choice%"=="3" exit

echo %RED%Invalid choice. Try again.%RESET%
pause
goto main_menu

:show_status
set "do_status=%GREEN%Enabled%RESET%"
set "svc_status=%GREEN%Running%RESET%"

:: Check registry setting
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode 2^>nul') do (
        if %%a equ 0x0 set "do_status=%RED%Disabled%RESET%"
    )
)

:: Check service status
sc query DoSvc | find "STOPPED" >nul && set "svc_status=%RED%Stopped%RESET%"
sc query DoSvc | find "DISABLED" >nul && set "svc_status=%RED%Disabled%RESET%"

echo %SKYBLUE%Current Delivery Optimization Status:%RESET%
echo - Policy: %ORANGE%!do_status!%RESET%
echo - Service: %ORANGE%!svc_status!%RESET%
echo.

exit /b

:disable_dosvc
echo %RED%Disabling Delivery Optimization...%RESET%
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 0 /f >nul 2>&1

net stop DoSvc /y >nul 2>&1
timeout /t 3 /nobreak >nul

sc config DoSvc start= disabled >nul 2>&1

:: Confirm service is stopped
sc query DoSvc | findstr /i "STATE.*STOPPED" >nul
if errorlevel 1 (
    echo %RED%Failed to stop the Delivery Optimization service.%RESET%
) else (
    echo %RED%Delivery Optimization Disabled.%RESET%
)
pause
exit /b

:enable_dosvc
echo %GREEN%Enabling Delivery Optimization...%RESET%
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /f >nul 2>&1
sc config DoSvc start= auto >nul 2>&1
net start DoSvc >nul 2>&1
echo %GREEN%Delivery Optimization Enabled.%RESET%
pause
exit /b
