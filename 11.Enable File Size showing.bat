@echo off
:: Enable Virtual Terminal Processing for ANSI colors
for /f "tokens=2 delims=:" %%i in ('"prompt $H & for %%b in (1) do rem"') do set "BS=%%i"
echo %BS%[?25l
reg query HKCU\Console | find "VirtualTerminalLevel" >nul || (
    reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul
)

:: Set ANSI color escape codes
set "GREEN=[1;32m"
set "GREENU=[4;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[3;35m"
set "SKYBLUE=[96m"

cls


echo.
echo %ORANGE%================================================%RESET%
echo %SKYBLUE%        File Size Showing Status - Menu       %RESET%
echo %ORANGE%================================================%RESET%
echo.

:: Read current registry value
set current=
for /f "tokens=3" %%a in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCompColor 2^>nul') do set current=%%a

:: Display current status with color
if "%current%"=="0x1" (
    echo Current Status: %GREEN%ENABLED%RESET%
) else (
    echo Current Status: %RED%DISABLED%RESET%
)

echo.
echo %PINK%1.%RESET% Enable
echo %PINK%2.%RESET% Disable
echo.
echo %ORANGE%================================================%RESET%
echo.
set /p choice=Choose an option (1 or 2): 

:: Apply user's choice
if "%choice%"=="1" (
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCompColor /t REG_DWORD /d 1 /f >nul
    echo %GREEN%Enabled successfully.%RESET%
) else if "%choice%"=="2" (
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCompColor /t REG_DWORD /d 0 /f >nul
    echo %RED%Disabled successfully.%RESET%
) else (
    echo %RED%Invalid choice. Exiting.%RESET%
    exit /b
)

:: Restart Explorer
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
exit
