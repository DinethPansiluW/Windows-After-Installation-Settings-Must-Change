@echo off
setlocal EnableDelayedExpansion

:: ANSI colors
set "GREEN=[1;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"

set "KEY=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer"
set "VAL=link"

:main
cls
call :show_status
echo.
echo %GREEN%1.%RESET% Disable "- Shortcut" suffix for new shortcuts
echo %GREEN%2.%RESET% Enable "- Shortcut" suffix for new shortcuts
echo %GREEN%3.%RESET% Exit
echo.
set /p choice=Select option [1-3]: 

if "%choice%"=="1" (
    call :disable
) else if "%choice%"=="2" (
    call :enable
) else if "%choice%"=="3" (
    exit /b
) else (
    echo %RED%Invalid choice.%RESET%
    pause
)
goto main

:show_status
set "status=Enabled"
set "data="
for /f "tokens=3,*" %%A in ('reg query "%KEY%" /v "%VAL%" 2^>nul') do (
    set "raw=%%A %%B"
    rem remove spaces
    set "data=!raw: =!"
)
if defined data (
    if /i "!data!"=="00000000" (
        set "status=Disabled"
    )
)
echo Current "- Shortcut" suffix status: %ORANGE%!status!%RESET%
exit /b

:disable
echo %ORANGE%Disabling "- Shortcut" suffix...%RESET%
reg add "%KEY%" /v "%VAL%" /t REG_BINARY /d "00000000" /f >nul 2>&1
echo Restarting Explorer...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo %GREEN%Done.%RESET%
pause
exit /b

:enable
echo %GREEN%Enabling "- Shortcut" suffix...%RESET%
reg delete "%KEY%" /v "%VAL%" /f >nul 2>&1
echo Restarting Explorer...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo %GREEN%Done.%RESET%
pause
exit /b
