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


:: ANSI Colors
set "GREEN=[1;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "SKY=[96m"

:: Require admin
net session >nul 2>&1
if errorlevel 1 (
    echo %ORANGE%Requesting administrator privileges...%RESET%
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
    exit /b
)

:: Entry point
:menu
cls
call :status
echo.
echo %GREEN%Core Isolation (Memory Integrity) Control%RESET%
echo ============================================
echo.
echo %GREEN%1.%RESET% Enable Core Isolation
echo %GREEN%2.%RESET% Disable Core Isolation
echo %GREEN%3.%RESET% Exit
echo.
set /p choice=Select an option [1-3]: 

if "%choice%"=="1" call :enable
if "%choice%"=="2" call :disable
if "%choice%"=="3" exit
goto menu

:status
set "state=Unknown"
for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled 2^>nul') do (
    if %%a==0x1 set "state=Enabled"
    if %%a==0x0 set "state=Disabled"
)
echo %SKY%Current Core Isolation (VBS) Status:%RESET%
echo - Memory Integrity: %ORANGE%!state!%RESET%
exit /b

:enable
echo %GREEN%Enabling Core Isolation (Memory Integrity)...%RESET%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 1 /f >nul
echo %GREEN%Core Isolation Enabled. Please restart your PC to apply changes.%RESET%
pause
goto menu

:disable
echo %RED%Disabling Core Isolation (Memory Integrity)...%RESET%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f >nul
echo %RED%Core Isolation Disabled. Please restart your PC to apply changes.%RESET%
pause
goto menu
