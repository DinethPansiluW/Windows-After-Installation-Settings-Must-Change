@echo off
setlocal EnableDelayedExpansion

:: Enable ANSI escape sequences (Windows 10+)
reg query HKCU\Console 2>nul || reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul

:: Set ANSI color escape codes
set "GREEN=[1;32m"
set "GREENU=[4;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[3;35m"
set "SKYBLUE=[96m"

:: Simulated setting for Weather - assuming ENABLED by default
set "weatherStatus=ENABLED"

:menu
cls
echo %SKYBLUE%===============================================================%RESET%
echo %GREENU%         Weather Show - Menu%RESET%
echo %SKYBLUE%===============================================================%RESET%
echo.
echo Current Status: %ORANGE%!weatherStatus!%RESET%
echo.
echo %GREEN%1.%RESET% Enable
echo %RED%2.%RESET% Disable
echo.
echo %SKYBLUE%===============================================================%RESET%
set /p choice=Choose an option (1 or 2): 

if "!choice!"=="1" (
    set "weatherStatus=ENABLED"
    echo.
    echo %GREEN%Weather display ENABLED.%RESET%
) else if "!choice!"=="2" (
    set "weatherStatus=DISABLED"
    echo.
    echo %RED%Weather display DISABLED.%RESET%
) else (
    echo.
    echo %RED%Invalid option. Try again.%RESET%
    pause
    goto menu
)

pause
goto menu
