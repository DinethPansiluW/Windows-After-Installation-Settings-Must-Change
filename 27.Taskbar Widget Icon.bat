@echo off
setlocal EnableDelayedExpansion

:: ANSI color codes
set "GREEN=[1;32m"
set "RED=[31m"
set "RESET=[0m"

:: --- Read current widget state ---
set "widgetValue=0"
for /f "usebackq tokens=2,* skip=2" %%A in (`reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa 2^>nul`) do (
    set "widgetValue=%%B"
)

:: Convert hex to decimal if needed
if /i "!widgetValue:~0,2!"=="0x" (
    set /a widgetValueDec=!widgetValue!
) else (
    set /a widgetValueDec=!widgetValue!
)

if "!widgetValueDec!"=="1" (
    set "widgetStatus=ENABLED"
) else (
    set "widgetStatus=DISABLED"
)

:menu
cls
echo %GREEN%===============================================================%RESET%
echo %GREEN%         Taskbar Widgets Icon - Menu%RESET%
echo %GREEN%===============================================================%RESET%
echo.
echo Current Status: !widgetStatus!
echo.
echo %GREEN%1.%RESET% Hide Widgets Icon
echo %GREEN%2.%RESET% Show Widgets Icon
echo %RED%3.%RESET% Exit
echo.
set /p choice=Choose an option (1, 2, or 3): 

if "!choice!"=="1" (
    call :SetWidgetState 0
    goto menu
) else if "!choice!"=="2" (
    call :SetWidgetState 1
    goto menu
) else if "!choice!"=="3" (
    exit /b
) else (
    echo.
    echo %RED%Invalid option. Try again.%RESET%
    pause
    goto menu
)

goto :eof

:SetWidgetState
setlocal
set "state=%1"

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d %state% /f >nul 2>&1
if errorlevel 1 (
    echo %RED%Failed to write registry key. Close apps or reboot and try again.%RESET%
    pause
    endlocal & exit /b 1
)

echo Restarting Explorer to apply changes...
taskkill /f /im explorer.exe >nul
timeout /t 2 >nul
start explorer.exe

if "%state%"=="1" (
    echo %GREEN%Widgets icon ENABLED.%RESET%
) else (
    echo %RED%Widgets icon DISABLED.%RESET%
)

pause
endlocal
exit /b
