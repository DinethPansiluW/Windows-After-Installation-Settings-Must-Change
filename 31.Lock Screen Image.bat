@echo off
setlocal EnableDelayedExpansion

:: Enable ANSI escape sequences in Windows Console (Windows 10+)
reg query "HKCU\Console" /v VirtualTerminalLevel >nul 2>&1
if errorlevel 1 (
    reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul
)

:: ANSI color codes variables
set "ESC="
set "GREEN=%ESC%[1;32m"
set "RED=%ESC%[1;31m"
set "YELLOW=%ESC%[1;33m"
set "CYAN=%ESC%[1;36m"
set "RESET=%ESC%[0m"

:: Ensure running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo %YELLOW%Requesting Administrator privileges...%RESET%
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:menu
cls
echo %CYAN%===============================================================%RESET%
echo %GREEN%          Lock Screen Image Toggle Menu%RESET%
echo %CYAN%===============================================================%RESET%
echo.

:: Ensure the Personalization key exists
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" >nul 2>&1
if errorlevel 1 (
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /f >nul
)

:: Read current setting
set "val=0"
for /f "tokens=3" %%a in ('
    reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreen 2^>nul ^| find "NoLockScreen"
') do (
    set "val=%%a"
)

if "!val!"=="0x1" (
    set "status=%RED%DISABLED%RESET% (Direct to password prompt)"
) else (
    set "status=%GREEN%ENABLED%RESET% (With lock screen image)"
)

echo Current Lock Screen Image Status: !status!
echo.
echo %GREEN%1.%RESET% Disable Lock Screen Image (skip picture, go direct to password)
echo %GREEN%2.%RESET% Enable  Lock Screen Image (show picture before password)
echo %RED%3.%RESET% Exit
echo.
set /p choice=Choose an option (1-3): 

if "!choice!"=="1" (
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreen /t REG_DWORD /d 1 /f >nul 2>&1
    echo.
    echo %RED%Lock Screen Image DISABLED.%RESET%  (restart PC for changes)
    pause
    goto menu
) else if "!choice!"=="2" (
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v NoLockScreen /t REG_DWORD /d 0 /f >nul 2>&1
    echo.
    echo %GREEN%Lock Screen Image ENABLED.%RESET%  (restart PC for changes)
    pause
    goto menu
) else if "!choice!"=="3" (
    exit /b
) else (
    echo.
    echo %RED%Invalid choice. Please try again.%RESET%
    timeout /t 2 >nul
    goto menu
)
