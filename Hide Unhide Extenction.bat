@echo off
setlocal EnableDelayedExpansion

:: Set color scheme
color 0F
mode con: cols=60 lines=25
title File Extension Visibility Manager

:: Read current setting
for /f "tokens=3" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt 2^>nul') do (
    set "current=%%a"
)

:: Convert numeric value to text
if "!current!"=="0" (
    set "status_text=Currently: SHOWN (Disabled)"
    set "status_color=0A"
) else (
    set "status_text=Currently: HIDDEN (Enabled)"
    set "status_color=0C"
)

:: Display UI
cls
echo.
echo    ================================
echo     FILE EXTENSION VISIBILITY MANAGER
echo    ================================
echo.
echo    !status_text!
echo    --------------------------------
echo.
echo    1. Hide File Extensions
echo    2. Show File Extensions
echo.
echo    ================================
echo.

:choice
set /p choice=    Enter your choice [1-2]: 

if "%choice%"=="1" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 1 /f >nul
    color 0C
    echo    Setting changed: Extensions will be HIDDEN
) else if "%choice%"=="2" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f >nul
    color 0A
    echo    Setting changed: Extensions will be SHOWN
) else (
    echo    Invalid choice. Please enter 1 or 2.
    goto choice
)

:: Restart Explorer to apply changes
echo.
echo    Restarting File Explorer to apply changes...
echo.
timeout /t 2 /nobreak >nul
taskkill /f /im explorer.exe >nul
start explorer.exe

:: Final message
echo    Operation completed successfully!
echo.
pause
endlocal