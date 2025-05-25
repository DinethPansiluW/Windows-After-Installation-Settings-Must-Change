@echo off
setlocal EnableDelayedExpansion

rem =====================================================
rem  HARD DISK TIMEOUT CONTROL PANEL (Live Status Fix)
rem =====================================================

:: Define color codes
:: Set ANSI color escape codes
set "GREEN=[1;32m"
set "GREENU=[4;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[1;35m"
set "SKYBLUE=[96m

:show_panel
cls
echo %PINK%========================================%RESET%
echo %GREEN%     HARD DISK TIMEOUT CONTROL PANEL%RESET%
echo %PINK%========================================%RESET%

rem 1) Get active power plan GUID
for /f "tokens=4" %%G in ('powercfg /getactivescheme') do set "scheme=%%G"

rem 2) Query DC (On battery) idle timeout
for /f "tokens=2 delims=:" %%S in ('powercfg /query !scheme! 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e ^| findstr /c:"Current DC Power Setting Index"') do (
  set "dc_hex=%%S"
  for /f "tokens=* delims= " %%h in ("!dc_hex!") do set "dc_hex=%%h"
  set /a dc_seconds=!dc_hex!
)

rem 3) Query AC (Plugged in) idle timeout
for /f "tokens=2 delims=:" %%S in ('powercfg /query !scheme! 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e ^| findstr /c:"Current AC Power Setting Index"') do (
  set "ac_hex=%%S"
  for /f "tokens=* delims= " %%h in ("!ac_hex!") do set "ac_hex=%%h"
  set /a ac_seconds=!ac_hex!
)

rem 4) Convert to minutes
set /a dc_minutes = dc_seconds / 60
set /a ac_minutes = ac_seconds / 60

rem 5) Show results with 0 = Never in RED
if !ac_minutes! EQU 0 (
  echo %ORANGE%Plugged in%RESET%  - %RED%Never%RESET%
) else (
  echo %ORANGE%Plugged in%RESET%  - !ac_minutes! minutes
)

if !dc_minutes! EQU 0 (
  echo %ORANGE%On battery%RESET%  - %RED%Never%RESET%
) else (
  echo %ORANGE%On battery%RESET%  - !dc_minutes! minutes
)

echo %PINK%========================================%RESET%
echo.
echo %GREEN%1.%RESET% Set AC Timeout
echo %GREEN%2.%RESET% Set Battery Timeout
echo %GREEN%3.%RESET% Set All to Never %SKYBLUE%(Recommend for SSD users and PCs)%RESET%
echo.
echo %GREEN%0.%ORANGE% Exit to Previous Menu %RESET%
echo.
set /p choice="Select option (0-3): %PINK%"

if "%choice%"=="0" (
    exit /b
) else if "%choice%"=="1" (
    set "mode=AC"
    goto set_timeout
) else if "%choice%"=="2" (
    set "mode=DC"
    goto set_timeout
) else if "%choice%"=="3" (
    goto set_all_never
) else (
    echo.
    echo %RED%Invalid choice "%choice%". Please enter 0, 1, 2, or 3.%RESET%
    pause
    goto show_panel
)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:set_all_never
echo.
echo %ORANGE%Setting both AC and DC disk timeout to Never...%RESET%
powercfg /setacvalueindex SCHEME_CURRENT SUB_DISK DISKIDLE 0
powercfg /setdcvalueindex SCHEME_CURRENT SUB_DISK DISKIDLE 0
powercfg /setactive SCHEME_CURRENT
echo.
echo %GREEN%Both AC and DC disk timeouts set to Never.%RESET%
echo.
pause
goto show_panel

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:set_timeout
echo.
set /p newMin="Enter new timeout in minutes (0 for Never): "

rem Validate numeric input (only digits allowed)
for /f "delims=0123456789" %%X in ("!newMin!") do (
  echo.
  echo %RED%Invalid number: %%X%RESET%
  pause
  goto show_panel
)

set /a newSec=newMin*60

echo.
echo %ORANGE%Applying to %mode%...%RESET%
if /I "%mode%"=="AC" (
  powercfg /setacvalueindex SCHEME_CURRENT SUB_DISK DISKIDLE !newSec!
) else (
  powercfg /setdcvalueindex SCHEME_CURRENT SUB_DISK DISKIDLE !newSec!
)

powercfg /setactive SCHEME_CURRENT

echo.
echo %GREEN%%mode% disk timeout set to !newMin! minute(s).%RESET%
echo.
pause
goto show_panel
