@echo off
setlocal EnableDelayedExpansion

:: Enable ANSI escape sequences
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

:: Set color codes
set "GREEN=[1;32m"
set "GREENU=[4;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "SKYBLUE=[96m"

:: Elevate if not admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    >"%temp%\getadmin.vbs" (
        echo Set UAC = CreateObject^("Shell.Application"^)
        echo UAC.ShellExecute "%~f0", "", "", "runas", 1
    )
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit
)

:: Detect current setting
for /f "tokens=3" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode 2^>nul') do (
    set "weatherValue=%%a"
)

if "!weatherValue!"=="0x2" (
    set "weatherStatus=DISABLED"
) else (
    set "weatherStatus=ENABLED"
)

:menu
cls
echo %SKYBLUE%==============================================================%RESET%
echo %GREENU%                    WEATHER ICON - MENU                      %RESET%
echo %SKYBLUE%==============================================================%RESET%
echo.
echo Current Status: %ORANGE%!weatherStatus!%RESET%
echo.
echo %RED%1.%RESET% Disable Weather Icon
echo %GREEN%2.%RESET% Enable Weather Icon
echo.
echo %SKYBLUE%==============================================================%RESET%
set /p choice=Choose an option (1 or 2): 

if "!choice!"=="1" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode /t REG_DWORD /d 2 /f >nul
    set "weatherStatus=DISABLED"
    echo.
    echo %RED%Need to Restart to apply changes...%RESET%
    pause
    goto menu
) else if "!choice!"=="2" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode /t REG_DWORD /d 0 /f >nul
    set "weatherStatus=ENABLED"
    echo.
    echo %GREEN%Need to Restart to apply changes...%RESET%
    pause
    goto menu
) else (
    echo.
    echo %RED%Invalid option. Try again.%RESET%
    pause
    goto menu
)
