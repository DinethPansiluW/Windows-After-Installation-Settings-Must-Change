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

:: Check current search icon state (0 = hidden, 1 = icon only, 2 = search box)
for /f "tokens=3" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode 2^>nul') do (
    set "searchValue=%%a"
)

if "!searchValue!"=="0x0" (
    set "searchStatus=DISABLED"
) else (
    set "searchStatus=ENABLED"
)

:menu
cls
echo %SKYBLUE%===============================================================%RESET%
echo %GREENU%         Taskbar Search Icon - Menu%RESET%
echo %SKYBLUE%===============================================================%RESET%
echo.
echo Current Status: %ORANGE%!searchStatus!%RESET%
echo.
echo %GREEN%1.%RESET% Show Search Icon
echo %RED%2.%RESET% Hide Search Icon
echo.
echo %SKYBLUE%===============================================================%RESET%
set /p choice=Choose an option (1 or 2): 

if "!choice!"=="1" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 1 /f >nul
    set "searchStatus=ENABLED"
    echo.
    echo %GREEN%Search icon ENABLED. Restart Explorer or sign out/in to apply changes.%RESET%
) else if "!choice!"=="2" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f >nul
    set "searchStatus=DISABLED"
    echo.
    echo %RED%Search icon DISABLED. Restart Explorer or sign out/in to apply changes.%RESET%
) else (
    echo.
    echo %RED%Invalid option. Try again.%RESET%
    pause
    goto menu
)

pause
goto menu
