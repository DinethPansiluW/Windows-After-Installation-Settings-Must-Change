@echo off

:: Check for admin rights
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

:: Set ANSI color escape codes using literal ESC (ASCII 27) character
set "GREEN=[1;32m"
set "RED=[31m"
set "YELLOW=[1;33m"
set "CYAN=[36m"
set "RESET=[0m"
set "BLUE=[96m"

:: Check current shortcut arrow status
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 >nul 2>&1
if %errorlevel%==0 (
    echo Current Status: Shortcut Arrows are %BLUE%HIDDEN%RESET%
) else (
    echo Current Status: Shortcut Arrows are %GREEN%SHOWING%RESET%
)

echo.
echo Select an option:
echo [1] %GREEN%Show%RESET% Shortcut Arrow
echo [2] %BLUE%Hide%RESET% Shortcut Arrow
echo.
set /p choice=Enter your choice (1 or 2): 

if "%choice%"=="1" (
    REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /f >nul 2>&1
    taskkill /f /im explorer.exe >nul
    start explorer.exe
    echo Shortcut arrows are now VISIBLE.
) else if "%choice%"=="2" (
    REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /t REG_SZ /d "" /f >nul
    taskkill /f /im explorer.exe >nul
    start explorer.exe
    echo Shortcut arrows are now HIDDEN. (You may need to refresh or reboot.)
) else (
    echo Invalid choice.
)

pause