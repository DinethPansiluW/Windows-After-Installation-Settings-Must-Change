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

:: Check current startup sound status (1 = enabled, 0 = disabled)
for /f "tokens=3" %%a in ('reg query "HKCU\AppEvents\Schemes\Apps\.Default\WindowsLogon\.Current" 2^>nul') do (
    set "soundPath=%%a"
)

for /f "tokens=3" %%a in ('reg query "HKCU\AppEvents\Schemes\Apps\.Default\WindowsLogon\.Current" /ve 2^>nul') do (
    if "%%a"=="" (
        set "startupSoundStatus=DISABLED"
    ) else (
        set "startupSoundStatus=ENABLED"
    )
)

:menu
cls
echo %SKYBLUE%===============================================================%RESET%
echo %GREENU%       Windows Startup Sound - Menu%RESET%
echo %SKYBLUE%===============================================================%RESET%
echo.
echo Current Status: %ORANGE%!startupSoundStatus!%RESET%
echo.
echo %RED%1.%RESET% Disable Startup Sound
echo %GREEN%2.%RESET% Enable Startup Sound
echo.
echo %SKYBLUE%===============================================================%RESET%
set /p choice=Choose an option (1 or 2): 

if "!choice!"=="2" (
    reg add "HKCU\AppEvents\Schemes\Apps\.Default\WindowsLogon\.Current" /ve /d "C:\Windows\Media\Windows Logon.wav" /f >nul
    set "startupSoundStatus=ENABLED"
    echo.
    echo %GREEN%Startup sound ENABLED.%RESET%
) else if "!choice!"=="1" (
    reg delete "HKCU\AppEvents\Schemes\Apps\.Default\WindowsLogon\.Current" /ve /f >nul
    set "startupSoundStatus=DISABLED"
    echo.
    echo %RED%Startup sound DISABLED.%RESET%
) else (
    echo.
    echo %RED%Invalid option. Try again.%RESET%
    pause
    goto menu
)

pause
goto menu
