@echo off
setlocal EnableDelayedExpansion

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

:: Set default UI color
color 1F
mode con: cols=65 lines=30
title File Extension Visibility Manager

:: Read current setting
for /f "tokens=3" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt 2^>nul') do (
    set "current=%%a"
)

:: Determine current status
if "!current!"=="0x0" (
    set "status_text=Extensions are currently: SHOWN"
    set "status_color=0A"
) else (
    set "status_text=Extensions are currently: HIDDEN"
    set "status_color=0C"
)

:: Display Header
call :drawHeader
call :coloredEcho !status_color! "!status_text!"
echo.
echo    ---------------------------------------------
echo    1. Show File Extensions
echo    2. Hide File Extensions
echo    ---------------------------------------------
echo.

:choice
set /p choice=    Enter your choice [1-2]: 

if "%choice%"=="2" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 1 /f >nul
    color 4F
    echo.
    echo    Setting changed: Extensions will now be HIDDEN
) else if "%choice%"=="1" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f >nul
    color 2F
    echo.
    echo    Setting changed: Extensions will now be SHOWN
) else (
    color 6F
    echo.
    echo    Invalid choice. Please enter 1 or 2.
    timeout /t 2 >nul
    goto choice
)

:: Restart Explorer
echo.
color 3F
echo    Restarting File Explorer to apply changes...
timeout /t 2 /nobreak >nul
taskkill /f /im explorer.exe >nul
start explorer.exe

:: Completion
color 1F
echo.
echo    Operation completed successfully!
echo.
pause
endlocal
exit /b

:: === Draw Header ===
:drawHeader
color 5F
echo.
echo    =========================================================
echo                     FILE EXTENSION MANAGER                  
echo    =========================================================
color 1F
exit /b

:: === Colored Echo ===
:coloredEcho
:: %1 = color code, %2 = message
color %1
echo    %~2
color 1F
exit /b
