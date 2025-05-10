@echo off
setlocal EnableDelayedExpansion

rem =====================================================
rem  HARD DISK TIMEOUT CONTROL PANEL (Live Status Fix)
rem =====================================================

:: Define color codes
set "GREEN=[32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[1;35m"

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

rem 5) Show results
echo %ORANGE%Plugged in%RESET%  - !ac_minutes! minute
echo %ORANGE%On battery%RESET%  - !dc_minutes! minute

echo %PINK%========================================%RESET%
echo.
echo %GREEN%1.%RESET% Set AC Timeout
echo %GREEN%2.%RESET% Set Battery Timeout
echo.
set /p choice="Select option (1-2): "

if "%choice%"=="1" (
    set "mode=AC"
    goto set_timeout
) else if "%choice%"=="2" (
    set "mode=DC"
    goto set_timeout
) else (
    echo.
    echo %RED%Invalid choice "%choice%". Please enter 1 or 2.%RESET%
    pause
    goto show_panel
)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:get_timeout  modeVar  outVar
  set "%~2="
  if /I "%~1"=="AC" (
    for /f "tokens=* delims=" %%L in ('powercfg /getacvalueindex SCHEME_CURRENT SUB_DISK DISKIDLE') do set "line=%%L"
  ) else (
    for /f "tokens=* delims=" %%L in ('powercfg /getdcvalueindex SCHEME_CURRENT SUB_DISK DISKIDLE') do set "line=%%L"
  )
  for /f "tokens=* delims=" %%D in ("!line!") do (
    for /f "delims=0123456789" %%X in ("%%D") do (
      set "temp=%%D"
      setlocal DisableDelayedExpansion
      for /f "tokens=* delims=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ: .=" %%N in ("!temp!") do endlocal & set "%~2=%%N"
    )
  )
  goto :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:format_display  secondsVar  displayVar
  setlocal EnableDelayedExpansion
  set "s=!%~1!"
  if "!s!"=="" set "s=0"
  set /a m = s / 60
  if !m! equ 0 (
    endlocal & set "%~2=Never"
  ) else (
    endlocal & set "%~2=!m! min"
  )
  goto :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:set_timeout
echo.
set /p newMin="Enter new timeout in minutes (0 for Never): "

rem Validate numeric input
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
