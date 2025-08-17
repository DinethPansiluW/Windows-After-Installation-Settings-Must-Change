@echo off
:: Ensure console supports ANSI escape codes
for /f "tokens=2 delims==" %%i in ('"wmic os get Caption /value | findstr ="') do set "osName=%%i"
reg query HKCU\Console 2>nul || reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul

:: Set ANSI color escape codes
set "GREEN=[1;32m"
set "GREENU=[4;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[3;35m"
set "SKYBLUE=[96m"

:: Ensure consistent console size
mode con: cols=120 lines=30

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

:: Get current Scroll Lock startup status
for /f "tokens=3" %%a in ('reg query "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" /v InitialKeyboardIndicators 2^>nul') do (
    set "scrollValue=%%a"
)

if "%scrollValue%"=="4" (
    set "scrollStatus=ENABLED"
) else (
    set "scrollStatus=DISABLED"
)

:menu
cls
echo %SKYBLUE%===============================================================%RESET%
echo %GREENU%         Scroll Lock on Startup - Menu%RESET%
echo %SKYBLUE%===============================================================%RESET%
echo.
echo Current Status: %ORANGE%%scrollStatus%%RESET%
echo.
echo %GREEN%1.%RESET% Enable
echo %RED%2.%RESET% Disable
echo.
echo %SKYBLUE%===============================================================%RESET%
set /p choice=Choose an option (1 or 2): 

if "%choice%"=="1" (
    reg add "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" /v InitialKeyboardIndicators /t REG_SZ /d 4 /f >nul
    set "scrollStatus=ENABLED"
    echo.
    echo %GREEN%Scroll Lock on startup ENABLED.%RESET%
) else if "%choice%"=="2" (
    reg add "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" /v InitialKeyboardIndicators /t REG_SZ /d 0 /f >nul
    set "scrollStatus=DISABLED"
    echo.
    echo %RED%Scroll Lock on startup DISABLED.%RESET%
) else (
    echo.
    echo %RED%Invalid option. Try again.%RESET%
    pause
    goto menu
)

pause
goto menu
