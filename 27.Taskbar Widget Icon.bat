@echo off
setlocal EnableDelayedExpansion

:: Enable ANSI escape sequences
reg query HKCU\Console 2>nul || reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul

:: Set ANSI color escape codes
set "GREEN=[1;32m"
set "GREENU=[4;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[3;35m"
set "SKYBLUE=[96m"

:: Ensure admin rights
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

:: Check current widget icon state (1 = shown, 0 = hidden)
for /f "tokens=3" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa 2^>nul') do (
    set "widgetValue=%%a"
)

if "!widgetValue!"=="1" (
    set "widgetStatus=ENABLED"
) else (
    set "widgetStatus=DISABLED"
)

:menu
cls
echo %SKYBLUE%===============================================================%RESET%
echo %GREENU%         Taskbar Widgets Icon - Menu%RESET%
echo %SKYBLUE%===============================================================%RESET%
echo.
echo Current Status: %ORANGE%!widgetStatus!%RESET%
echo.
echo %GREEN%1.%RESET% Show Widgets Icon
echo %RED%2.%RESET% Hide Widgets Icon
echo.
echo %SKYBLUE%===============================================================%RESET%
set /p choice=Choose an option (1 or 2): 

if "!choice!"=="1" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 1 /f >nul
    set "widgetStatus=ENABLED"
    echo.
    echo %GREEN%Widgets icon ENABLED. You may need to restart Explorer or sign out/in.%RESET%
) else if "!choice!"=="2" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f >nul
    set "widgetStatus=DISABLED"
    echo.
    echo %RED%Widgets icon DISABLED. You may need to restart Explorer or sign out/in.%RESET%
) else (
    echo.
    echo %RED%Invalid option. Try again.%RESET%
    pause
    goto menu
)

pause
goto menu
