@echo off
setlocal enabledelayedexpansion

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    :: Create a temporary VBScript to relaunch this script with admin rights
    >"%temp%\getadmin.vbs" (
        echo Set UAC = CreateObject^("Shell.Application"^)
        echo UAC.ShellExecute "%~f0", "", "", "runas", 1
    )
    :: Run the VBScript silently and exit the current window
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit
)


REM — Ensure a consistent console size
mode con: cols=120 lines=50

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    :: Create a temporary VBScript to relaunch this script with admin rights
    >"%temp%\getadmin.vbs" (
        echo Set UAC = CreateObject^("Shell.Application"^)
        echo UAC.ShellExecute "%~f0", "", "", "runas", 1
    )
    :: Run the VBScript silently and exit the current window
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit
)

:: Admin check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo %GREEN%ERROR: Must run as Administrator!%RESET%
    pause
    exit /b 1
)

:: Set ANSI color escape codes
set "GREEN=[1;32m"
set "GREENU=[4;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[3;35m"
set "SKYBLUE=[96m"


:: Enable ANSI escape codes
reg query HKCU\Console /v VirtualTerminalLevel 2>nul | find "0x1" >nul || (
    reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
)

:: Get ESC
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

:: default to AC mode on load
if not defined mode set "mode=AC"

:: Elevate if needed
NET FILE 1>nul 2>nul || (
    powershell -Command "Start-Process cmd -ArgumentList '/c "%~f0"' -Verb RunAs"
    exit /b
)

:: GUIDs for power settings
set "GUID_HIBERNATE=9d7815a6-7ee4-497e-8888-515a05f02364"
set "GUID_SLEEP=29f6c1db-86da-48c5-9fdb-f2b67b1f44da"
set "GUID_DISPLAY=3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e"
set "SUB_DISPLAY=7516b95f-f776-4464-8c53-06167f40cc99"

:: Backup file paths
set "BACKUP_FILE=%~dp0backups\power_settings_backup.txt"
set "RECOMMEND_BACKUP_FILE=%~dp0backups\recommended_presets_backup.txt"

:: Initialize recommended presets
set "balanced_scr=5"
set "balanced_slp=15"
set "balanced_hib=60"
set "balanced_hd=5"
set "battery_scr=5"
set "battery_slp=10"
set "battery_hib=30"
set "battery_hd=5"


:: Load recommended presets from backup if exists
if exist "%RECOMMEND_BACKUP_FILE%" (
    for /f "tokens=1,2 delims==" %%A in ('findstr /b /i "balanced_scr" "%RECOMMEND_BACKUP_FILE%"') do set "balanced_scr=%%B"
    for /f "tokens=1,2 delims==" %%A in ('findstr /b /i "balanced_slp" "%RECOMMEND_BACKUP_FILE%"') do set "balanced_slp=%%B"
    for /f "tokens=1,2 delims==" %%A in ('findstr /b /i "balanced_hib" "%RECOMMEND_BACKUP_FILE%"') do set "balanced_hib=%%B"
    for /f "tokens=1,2 delims==" %%A in ('findstr /b /i "battery_scr" "%RECOMMEND_BACKUP_FILE%"') do set "battery_scr=%%B"
    for /f "tokens=1,2 delims==" %%A in ('findstr /b /i "battery_slp" "%RECOMMEND_BACKUP_FILE%"') do set "battery_slp=%%B"
    for /f "tokens=1,2 delims==" %%A in ('findstr /b /i "battery_hib" "%RECOMMEND_BACKUP_FILE%"') do set "battery_hib=%%B"
    for /f "tokens=1,2 delims==" %%A in ('findstr /b /i "balanced_hd" "%RECOMMEND_BACKUP_FILE%"') do set "balanced_hd=%%B"
    for /f "tokens=1,2 delims==" %%A in ('findstr /b /i "battery_hd" "%RECOMMEND_BACKUP_FILE%"') do set "battery_hd=%%B"

)


:: Check sleep state availability
set "sleepAvailable=0"
for /f "delims=" %%A in ('powercfg -query ^| findstr /i "Sleep after"') do (
    set "sleepAvailable=1"
)

:MAIN_LOOP
call :LOAD_SETTINGS
cls
:: Center header
set "width=80"
set /a "spaces=(width - 23) / 2"
set "spacer="
for /l %%i in (1,1,!spaces!) do set "spacer=!spacer! "

echo %SKYBLUE%!spacer!=========== SUPER POWER SETTINGS MANAGER ===========%RESET%

echo.
echo !spacer!                     %RED%Mode: %ORANGE%!mode!%RESET%
echo.
echo !spacer!          .%GREENU%AC%RESET%.          ^|           .%GREENU%BATTERY%RESET%.

::Screen OFF Times Display
echo !spacer!Screen OFF - %ORANGE%!ac_scr_display!%RESET%      ^|     Screen OFF - %ORANGE%!battery_scr_display!%RESET%

::Sleep Times Display
if "!sleepAvailable!"=="1" (
    echo !spacer!Sleep      - %ORANGE%!ac_slp_display!%RESET%     ^|     Sleep      - %ORANGE%!battery_slp_display!%RESET%
) else (
    echo !spacer!%RED%Plz Update Graphic Driver%RESET%
)
echo.

::Hibernate Times Display
if exist %SystemDrive%\hiberfil.sys ( 
    echo !spacer!Hibernate  - %ORANGE%!ac_hib_display!%RESET%     ^|     Hibernate  - %ORANGE%!battery_hib_display!%RESET%
) else (
    echo !spacer!Hibernate is %RED%Disabled %RESET%^(Choose Option 5 for %GREEN%Enable%RESET%^)
)

::Hard Disk OFF Times Display
echo !spacer!Hard Disk  - %ORANGE%!ac_hd_display!%RESET%      ^|     Hard Disk  - %ORANGE%!battery_hd_display!%RESET%

echo.
echo !spacer!%SKYBLUE%===================================================%RESET%

echo.
if /i "%mode%"=="AC" (
    echo 1. Recommended Settings ^(Screen %ORANGE%!balanced_scr!%RESET%m, Sleep %ORANGE%!balanced_slp!%RESET%m, Hibernate %ORANGE%!balanced_hib!%RESET%m, HD OFF %ORANGE%!balanced_hd!%RESET%m^)
) else (
    echo 1. Recommended Settings ^(Screen %ORANGE%!battery_scr!%RESET%m, Sleep %ORANGE%!battery_slp!%RESET%m, Hibernate %ORANGE%!battery_hib!%RESET%m, HD OFF %ORANGE%!battery_hd!%RESET%m^)
)

echo 2. Never ( Screen OFF, Sleep, Hibernate, Hard Disk OFF )
echo 3. Switch Mode ( %ORANGE%AC/Battery%RESET% )
echo.%SKYBLUE%
echo 4. Custom Settings All ( Screen OFF, Sleep )
echo 5. Custom Settings All ( Hibernate )
echo 6. Custom Settings All ( Hard Disk OFF ) 
echo. %GREEN%
echo 7. Backup Times
echo 8. Restore Settings from Backup
echo 9. Info Last Backup
echo.
echo %PINK%a. Power Plan Manager
echo b. Go to Hybrid Sleep Manager
echo c. Lid Close, Power Button ^& Sleep Button Press Manager
echo.
echo %RESET%100. Change Recommended Times ( Current Mode )


echo.
set /p "choice=%RED%Enter choice%RESET%: %ORANGE%"

:: Handle menu
if "%choice%"=="1" call :APPLY_RECOMMENDED

if "%choice%"=="2" (
    set "scr=0"
    set "slp=0"
    set "hib=0"
    set "hd=0"
    echo %SKYBLUE%All set to Never
    goto APPLY
)

if "%choice%"=="3" (if /i "%mode%"=="AC" (set "mode=BATTERY") else (set "mode=AC")) & goto MAIN_LOOP

if "%choice%"=="4" call "%~dp0src\PowerOptions.bat"
if "%choice%"=="5" call "%~dp0src\Hibernate.bat"
if "%choice%"=="6" call "%~dp0src\HardDiskOFFTimer.bat"

if "%choice%"=="7" (
    call :CONFIRM "Are you sure Backup current settings?" :BACKUP_TIMES
    goto MAIN_LOOP
)
if "%choice%"=="8" (
    call :CONFIRM "Are you sure Restore settings from backup?" :RESTORE_FROM_BACKUP
    goto MAIN_LOOP
)
if "%choice%"=="9" call :INFO_BACKUP & pause & goto MAIN_LOOP

if /i "%choice%"=="a" call "%~dp0src\PowerPlanManager.bat"
if /i "%choice%"=="b" call "%~dp0src\HybridSleep.bat"
if /i "%choice%"=="c" call "%~dp0src\LidClosePowerButtonManager.bat"

if "%choice%"=="100" (
    call :CONFIRM "Are you sure Change Recommended Times?" :CHANGE_PRESETS
    goto MAIN_LOOP
)

goto MAIN_LOOP

:APPLY_RECOMMENDED
if /i "%mode%"=="AC" (
    set "scr=!balanced_scr!" & set "slp=!balanced_slp!" & set "hib=!balanced_hib!" & set "hd=!balanced_hd!"
) else (
    set "scr=!battery_scr!" & set "slp=!battery_slp!" & set "hib=!battery_hib!" & set "hd=!battery_hd!"
)
echo %SKYBLUE%Applied Recommended Settings
goto APPLY

:APPLY
:: Apply power settings
if /i "%mode%"=="AC" (
    powercfg -change -monitor-timeout-ac %scr%
    powercfg -change -standby-timeout-ac %slp%
    powercfg -change -hibernate-timeout-ac %hib%
    powercfg -change -disk-timeout-ac %hd%
) else (
    powercfg -change -monitor-timeout-dc %scr%
    powercfg -change -standby-timeout-dc %slp%
    powercfg -change -hibernate-timeout-dc %hib%
    powercfg -change -disk-timeout-dc %hd%
)
timeout /t 2 >nul
goto MAIN_LOOP

:CHANGE_PRESETS
echo.
echo %GREEN%Change Recommended Times for %mode% Mode%RESET%
echo.
if /i "%mode%"=="AC" (
    echo AC Mode (Balanced)
    set /p "balanced_scr=New Screen timeout (current: %balanced_scr%m): "
    set /p "balanced_slp=New Sleep timeout (current: %balanced_slp%m): "
    set /p "balanced_hib=New Hibernate timeout (current: %balanced_hib%m): "
    set /p "balanced_hd=New Hard Disk timeout (current: %balanced_hd%m): "
) else (
    echo Battery Mode (Power Saver)
    set /p "battery_scr=New Screen timeout (current: %battery_scr%m): "
    set /p "battery_slp=New Sleep timeout (current: %battery_slp%m): "
    set /p "battery_hib=New Hibernate timeout (current: %battery_hib%m): "
    set /p "battery_hd=New Hard Disk timeout (current: %battery_hd%m): "
)
:: Save all presets to backup
(
    echo AC Screen OFF      = %balanced_scr%
    echo AC Sleep           = %balanced_slp%
    echo AC Hibernate       = %balanced_hib%
    echo AC HD OFF          = %balanced_hd%
    echo.
    echo Battery Screen OFF = %battery_scr%
    echo Battery Sleep      = %battery_slp%
    echo Battery Hibernate  = %battery_hib%
    echo Battery HD OFF     = %battery_hd%
) > "%RECOMMEND_BACKUP_FILE%"
echo Recommended times for %mode% updated and backed up!
timeout /t 2 >nul
exit /b

:CUSTOM_SETTINGS
echo.
echo %GREEN%Custom Settings%RESET%
set /p "scr=Enter Screen OFF in minutes: "
set /p "slp=Enter Sleep timeout in minutes: "
set /p "hib=Enter Hibernate timeout in minutes: "
exit /b

:LOAD_SETTINGS
:: Read and convert current AC/DC display timeout
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT %SUB_DISPLAY% %GUID_DISPLAY% ^| findstr /C:"Current AC Power Setting Index"') do set "DISP_AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT %SUB_DISPLAY% %GUID_DISPLAY% ^| findstr /C:"Current DC Power Setting Index"') do set "DISP_DC_SECS=%%A"
set /a DISP_AC_DEC=%DISP_AC_SECS%
set /a DISP_DC_DEC=%DISP_DC_SECS%
if "!DISP_AC_DEC!"=="0" (set "ac_scr_display=Never") else (set /a TMP=!DISP_AC_DEC!/60 & set "ac_scr_display=!TMP! min")
if "!DISP_DC_DEC!"=="0" (set "battery_scr_display=Never") else (set /a TMP=!DISP_DC_DEC!/60 & set "battery_scr_display=!TMP! min")

:: Read and convert current AC/DC sleep timeout
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_SLEEP% ^| findstr /C:"Current AC Power Setting Index"') do set "SLEEP_AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_SLEEP% ^| findstr /C:"Current DC Power Setting Index"') do set "SLEEP_DC_SECS=%%A"
set /a SLEEP_AC_DEC=%SLEEP_AC_SECS%
set /a SLEEP_DC_DEC=%SLEEP_DC_SECS%
if "!SLEEP_AC_DEC!"=="0" (set "ac_slp_display=Never") else (set /a TMP=!SLEEP_AC_DEC!/60 & set "ac_slp_display=!TMP! min")
if "!SLEEP_DC_DEC!"=="0" (set "battery_slp_display=Never") else (set /a TMP=!SLEEP_DC_DEC!/60 & set "battery_slp_display=!TMP! min")

:: Read and convert current AC/DC hibernate timeout
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_HIBERNATE% ^| findstr /C:"Current AC Power Setting Index"') do set "AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_HIBERNATE% ^| findstr /C:"Current DC Power Setting Index"') do set "DC_SECS=%%A"
set /a AC_DEC=%AC_SECS%
set /a DC_DEC=%DC_SECS%
if "!AC_DEC!"=="0" (set "ac_hib_display=Never") else (set /a TMP=!AC_DEC!/60 & set "ac_hib_display=!TMP! min")
if "!DC_DEC!"=="0" (set "battery_hib_display=Never") else (set /a TMP=!DC_DEC!/60 & set "battery_hib_display=!TMP! min")

:: Read and convert current AC/DC Hard Disk OFF timeout
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_DISK 6738e2c4-e8a5-4a42-b16a-e040e769756e ^| findstr /C:"Current AC Power Setting Index"') do set "HD_AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_DISK 6738e2c4-e8a5-4a42-b16a-e040e769756e ^| findstr /C:"Current DC Power Setting Index"') do set "HD_DC_SECS=%%A"
set /a HD_AC_DEC=%HD_AC_SECS%
set /a HD_DC_DEC=%HD_DC_SECS%
if "!HD_AC_DEC!"=="0" (set "ac_hd_display=Never") else (set /a TMP=!HD_AC_DEC!/60 & set "ac_hd_display=!TMP! min")
if "!HD_DC_DEC!"=="0" (set "battery_hd_display=Never") else (set /a TMP=!HD_DC_DEC!/60 & set "battery_hd_display=!TMP! min")



goto :eof

:BACKUP_TIMES
:: Backup current actual settings to BACKUP_FILE
echo Mode=AC > "%BACKUP_FILE%"
echo Screen=%ac_scr_display% >> "%BACKUP_FILE%"
echo Sleep=%ac_slp_display% >> "%BACKUP_FILE%"
echo Hibernate=%ac_hib_display% >> "%BACKUP_FILE%"
echo HardDisk=%ac_hd_display% >> "%BACKUP_FILE%"
echo. >> "%BACKUP_FILE%"
echo Mode=BATTERY >> "%BACKUP_FILE%"
echo Screen=%battery_scr_display% >> "%BACKUP_FILE%"
echo Sleep=%battery_slp_display% >> "%BACKUP_FILE%"
echo Hibernate=%battery_hib_display% >> "%BACKUP_FILE%"
echo HardDisk=%battery_hd_display% >> "%BACKUP_FILE%"
echo %GREEN%Current settings backed up to %BACKUP_FILE% %RESET%
timeout /t 2 >nul
exit /b


:RESTORE_FROM_BACKUP
REM --- Paths
set "BACKUP_FILE=%~dp0backups\power_settings_backup.txt"
set "TEMPENV=%temp%\restore_env.cmd"

REM --- Check backup exists
if not exist "%BACKUP_FILE%" (
    echo ERROR: No backup file at "%BACKUP_FILE%"
    timeout /t 2 >nul
    exit /b
)

REM --- Create temp env file
> "%TEMPENV%" echo @echo off
set cnt=0

REM --- Read and split into AC (first 4) and DC (next 4)
for /f "tokens=1,2 delims==" %%A in ('findstr /i /b "Screen= Sleep= Hibernate= HardDisk=" "%BACKUP_FILE%"') do (
    set /a cnt+=1
    set "raw=%%B"
    REM normalize Never -> 0, strip " min"
    if /i "!raw!"=="Never" (
        set "val=0"
    ) else (
        for /f "tokens=1 delims= " %%X in ("!raw!") do set "val=%%X"
    )
    REM decide AC vs DC
    if !cnt! leq 4 (
        echo set ac_%%A=!val!>> "%TEMPENV%"
    ) else (
        echo set dc_%%A=!val!>> "%TEMPENV%"
    )
)

REM --- Load variables
call "%TEMPENV%"
del "%TEMPENV%"
endlocal & (
    set "ac_scr=%ac_Screen%"
    set "ac_slp=%ac_Sleep%"
    set "ac_hib=%ac_Hibernate%"
    set "ac_hd=%ac_HardDisk%"
    set "dc_scr=%dc_Screen%"
    set "dc_slp=%dc_Sleep%"
    set "dc_hib=%dc_Hibernate%"
    set "dc_hd=%dc_HardDisk%"
)

REM --- Apply settings AC then DC
powercfg -change -monitor-timeout-ac %ac_scr%
powercfg -change -standby-timeout-ac %ac_slp%
powercfg -change -hibernate-timeout-ac %ac_hib%
powercfg -change -disk-timeout-ac %ac_hd%

powercfg -change -monitor-timeout-dc %dc_scr%
powercfg -change -standby-timeout-dc %dc_slp%
powercfg -change -hibernate-timeout-dc %dc_hib%
powercfg -change -disk-timeout-dc %dc_hd%

echo Restored all timeouts from text backup.
timeout /t 2 >nul
exit /b

:INFO_BACKUP
type "%BACKUP_FILE%" || echo %GREEN%No backup file found%RESET%
goto :eof

:CONFIRM
REM %1 = confirmation message
REM %2 = label to call if confirmed

setlocal enabledelayedexpansion
set "msg=%~1"
set /p "ans=%msg% (Y/N)? "
if /i "!ans!"=="Y" (
    endlocal & call %2
) else (
    endlocal
    echo Operation cancelled.
    timeout /t 2 >nul
)
exit /b
