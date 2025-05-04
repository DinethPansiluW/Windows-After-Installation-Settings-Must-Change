@echo off
setlocal enabledelayedexpansion

:: Enable ANSI escape codes
reg query HKCU\Console /v VirtualTerminalLevel 2>nul | find "0x1" >nul || (
    reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
)

for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

:: Elevate to admin
NET FILE 1>nul 2>nul || (
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

:: Power setting GUIDs
set "GUID_DISK=0012ee47-9041-4b5d-9b77-535fba8b1442"
set "GUID_DISK_TIMEOUT=6738e2c4-e8a5-4a42-b16a-e040e769756e"

:main
cls
echo %ESC%[1;36m========================================
echo      HARD DISK TIMEOUT CONTROL PANEL
echo ========================================%ESC%[0m

:: Read current timeouts (seconds) - FIXED PARSING
for /f "tokens=2 delims=()" %%A in (
    'powercfg /query SCHEME_CURRENT %GUID_DISK% %GUID_DISK_TIMEOUT% ^| findstr /c:"Current AC Power Setting Index"'
) do set "AC_SECS=%%A"
for /f "tokens=2 delims=()" %%A in (
    'powercfg /query SCHEME_CURRENT %GUID_DISK% %GUID_DISK_TIMEOUT% ^| findstr /c:"Current DC Power Setting Index"'
) do set "DC_SECS=%%A"

set /a AC_MIN=AC_SECS/60 2>nul || set AC_MIN=0
set /a DC_MIN=DC_SECS/60 2>nul || set DC_MIN=0

echo %ESC%[1mCurrent Timeouts:%ESC%[0m
if %AC_MIN% EQU 0 (
    echo [AC Power]  Never
) else (
    echo [AC Power]  %AC_MIN% Minutes
)
if %DC_MIN% EQU 0 (
    echo [Battery]   Never
) else (
    echo [Battery]   %DC_MIN% Minutes
)
echo %ESC%[1;36m========================================%ESC%[0m
echo.
echo 1. Set AC Timeout
echo 2. Set Battery Timeout
echo.

choice /c 12 /n /m "Select option (1-2): "
set "CHOICE=%ERRORLEVEL%"

if "%CHOICE%"=="1" goto SET_AC
if "%CHOICE%"=="2" goto SET_DC
goto main

:SET_AC
cls
echo Current AC Timeout: %AC_MIN% minutes
set "MIN="
set /p "MIN=Enter new timeout (in minutes, 0 for Never): "
if not defined MIN goto main
echo %MIN% | findstr /r "^[0-9]*$" >nul || (
    echo %ESC%[31mInvalid input. Use numbers only.%ESC%[0m
    timeout /t 2 >nul
    goto SET_AC
)
set /a "SECONDS=MIN*60"
powercfg /setacvalueindex SCHEME_CURRENT %GUID_DISK% %GUID_DISK_TIMEOUT% %SECONDS% >nul
powercfg /setactive SCHEME_CURRENT >nul
goto main

:SET_DC
cls
echo Current Battery Timeout: %DC_MIN% minutes
set "MIN="
set /p "MIN=Enter new timeout (in minutes, 0 for Never): "
if not defined MIN goto main
echo %MIN% | findstr /r "^[0-9]*$" >nul || (
    echo %ESC%[31mInvalid input. Use numbers only.%ESC%[0m
    timeout /t 2 >nul
    goto SET_DC
)
set /a "SECONDS=MIN*60"
powercfg /setdcvalueindex SCHEME_CURRENT %GUID_DISK% %GUID_DISK_TIMEOUT% %SECONDS% >nul
powercfg /setactive SCHEME_CURRENT >nul
goto main