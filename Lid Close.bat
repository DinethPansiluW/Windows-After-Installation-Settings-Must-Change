@echo off
setlocal enabledelayedexpansion

REM Define mapping of action codes to descriptions
set "action_0=Do nothing"
set "action_1=Sleep"
set "action_2=Hibernate"
set "action_3=Shutdown"

REM Retrieve current power scheme GUID using language-independent method
set "scheme="
for /f "tokens=*" %%a in ('powercfg /list ^| findstr /c:"*"') do set "line=%%a"
for /f "tokens=2 delims=:(" %%b in ("%line%") do set "scheme=%%b"
set "scheme=!scheme: =!"
set "scheme=!scheme:~0,36!"
if not defined scheme (
    echo Failed to get active power scheme.
    pause
    exit /b 1
)

REM Define subgroup and setting GUIDs (Lid close actions)
set "subgroup=4f971e89-eebd-4455-a8de-9e59040e7347"
set "setting=5ca83367-6e45-459f-a27b-476b1d01c936"

REM Retrieve current lid-close actions
set "ac_index="
set "dc_index="
for /f "tokens=4" %%a in ('powercfg /query %scheme% %subgroup% %setting% ^| find "0x"') do (
    if not defined ac_index (
        set "ac_index=%%a"
    ) else if not defined dc_index (
        set "dc_index=%%a"
    )
)

REM Process indices
set "ac_index=!ac_index:~2!"
set "dc_index=!dc_index:~2!"
set /a ac_index_dec=0x!ac_index! 2>nul
set /a dc_index_dec=0x!dc_index! 2>nul

REM Validate indices
if !ac_index_dec! gtr 3 set ac_index_dec=0
if !dc_index_dec! gtr 3 set dc_index_dec=0

REM Map indices to action descriptions
set "ac_action=!action_%ac_index_dec%!"
set "dc_action=!action_%dc_index_dec%!"

REM Display current lid-close actions
echo Current lid-close actions:
echo   On Battery  : !dc_action!
echo   Plugged in  : !ac_action!
echo.

REM Input validation loop
:input
set "new_dc="
set "new_ac="
set /p "new_dc=New action on battery [0-3]: "
echo !new_dc! | findstr /r "^[0-3]$" >nul || (
    echo Invalid input. Please enter 0-3.
    goto input
)
set /p "new_ac=New action on AC [0-3]: "
echo !new_ac! | findstr /r "^[0-3]$" >nul || (
    echo Invalid input. Please enter 0-3.
    goto input
)

REM Apply new settings
powercfg /setdcvalueindex %scheme% %subgroup% %setting% %new_dc% >nul
powercfg /setacvalueindex %scheme% %subgroup% %setting% %new_ac% >nul
powercfg /setactive %scheme% >nul

REM Verify changes
set "ac_index="
set "dc_index="
for /f "tokens=4" %%a in ('powercfg /query %scheme% %subgroup% %setting% ^| find "0x"') do (
    if not defined ac_index (
        set "ac_index=%%a"
    ) else if not defined dc_index (
        set "dc_index=%%a"
    )
)

set "ac_index=!ac_index:~2!"
set "dc_index=!dc_index:~2!"
set /a ac_index_dec=0x!ac_index! 2>nul
set /a dc_index_dec=0x!dc_index! 2>nul

if !ac_index_dec! gtr 3 set ac_index_dec=0
if !dc_index_dec! gtr 3 set dc_index_dec=0

set "ac_action=!action_%ac_index_dec%!"
set "dc_action=!action_%dc_index_dec%!"

echo Updated lid-close actions:
echo   On Battery  : !dc_action!
echo   Plugged in  : !ac_action!
echo.
pause