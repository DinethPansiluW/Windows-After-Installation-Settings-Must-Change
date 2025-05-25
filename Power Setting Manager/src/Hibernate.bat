@echo off
setlocal enabledelayedexpansion

:: Set ANSI color escape codes
set "GREEN=[1;32m"
set "GREENU=[4;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[1;35m"
set "SKYBLUE=[96m"

:: Enable ANSI escape codes
reg query HKCU\Console /v VirtualTerminalLevel 2>nul | find "0x1" >nul || (
    reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
)

:: Get ESC
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

:: Elevate if needed
NET FILE 1>nul 2>nul || (
    powershell -Command "Start-Process cmd -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

:: GUID for "Hibernate after"
set "GUID_HIBERNATE=9d7815a6-7ee4-497e-8888-515a05f02364"

:main-loop
cls
echo %ESC%[1;36m========================================
echo      SYSTEM HIBERNATION CONTROL PANEL
echo ========================================%ESC%[0m

:: Hibernate status
set "HIBER_STATUS=Disabled" & set "HIBER_COLOR=31"
if exist %SystemDrive%\hiberfil.sys (
    set "HIBER_STATUS=Enabled" & set "HIBER_COLOR=32"
)

:: Read current AC and DC timeout in seconds
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_HIBERNATE% ^| findstr /C:"Current AC Power Setting Index"') do set "AC_SECS=%%A"
for /f "tokens=6" %%A in ('powercfg /query SCHEME_CURRENT SUB_SLEEP %GUID_HIBERNATE% ^| findstr /C:"Current DC Power Setting Index"') do set "DC_SECS=%%A"

:: Convert to minutes
set /a ACMIN=AC_SECS/60
set /a DCMIN=DC_SECS/60

:: Timeout status
set "TIMEOUT_STATUS=Disabled" & set "TIMEOUT_COLOR=31"
if defined AC_SECS if %AC_SECS% gtr 0 set "TIMEOUT_STATUS=Enabled" & set "TIMEOUT_COLOR=32"
if defined DC_SECS if %DC_SECS% gtr 0 set "TIMEOUT_STATUS=Enabled" & set "TIMEOUT_COLOR=32"

:: Display
echo %ESC%[1mCurrent Status:%ESC%[0m
echo Hibernate %ESC%[%HIBER_COLOR%m%HIBER_STATUS%%ESC%[0m
echo Timeouts  %ESC%[%TIMEOUT_COLOR%m%TIMEOUT_STATUS%%ESC%[0m
if "%TIMEOUT_STATUS%"=="Enabled" (
    if %ACMIN%==0 (
        echo AC Power  Never
    ) else (
        echo AC Power  %ACMIN% Minutes
    )
    if %DCMIN%==0 (
        echo Battery   Never
    ) else (
        echo Battery   %DCMIN% Minutes
    )
)
echo %ESC%[1;36m========================================%ESC%[0m
echo.

:: Menu with opposite-action labels
if "%HIBER_STATUS%"=="Enabled" (
    set "HIBER_ACTION=%RED%Disable %RESET%Hibernate"
) else (
    set "HIBER_ACTION=%GREEN%Enable %RESET%Hibernate"
)
if "%TIMEOUT_STATUS%"=="Enabled" (
    set "TIMEOUT_ACTION=%RED%Disable %RESET%Timeouts"
) else (
    set "TIMEOUT_ACTION=%GREEN%Enable %RESET%Timeouts"
)

echo 1. %HIBER_ACTION%
echo 2. %TIMEOUT_ACTION%
if "%TIMEOUT_STATUS%"=="Enabled" (
    echo 3. Configure AC Timeout
    echo 4. Configure Battery Timeout
)
echo.
echo 0. %ORANGE%Exit to Previous Menu
echo.

:: Use set /p instead of choice
if "%TIMEOUT_STATUS%"=="Enabled" (
    set /p "CHOICE=%RESET%Select option (1-4): %PINK%"
) else (
    set /p "CHOICE=%RESET%Select option (1-2): %PINK%"
)

:: Branching
if "%choice%"=="0" exit /b
if "%CHOICE%"=="1" goto OPTION_1
if "%CHOICE%"=="2" goto OPTION_2
if "%CHOICE%"=="3" goto OPTION_3
if "%CHOICE%"=="4" goto OPTION_4
goto main-loop

:OPTION_1
if "%HIBER_STATUS%"=="Enabled" (
    powercfg /hibernate off
) else (
    powercfg /hibernate on
)
timeout /t 1 >nul
goto main-loop

:OPTION_2
if "%TIMEOUT_STATUS%"=="Enabled" (
    powercfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP %GUID_HIBERNATE% 0
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP %GUID_HIBERNATE% 0
) else (
    powercfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP %GUID_HIBERNATE% 1800
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP %GUID_HIBERNATE% 900
)
powercfg /setactive SCHEME_CURRENT >nul
timeout /t 1 >nul
goto main-loop

:OPTION_3
cls
echo Current AC Hibernate Timeout: %ACMIN% minutes
set /p "INPUT=Enter new AC Hibernate Timeout (in minutes, 0 to disable): "
if "!INPUT!"=="" goto main-loop
echo !INPUT! | findstr /r "^ *[0-9][0-9]* *$" >nul || (
    echo %ESC%[31mInvalid input! Please enter a valid number.%ESC%[0m
    timeout /t 2 >nul
    goto OPTION_3
)
set "INPUT=!INPUT: =!"
powercfg /change hibernate-timeout-ac !INPUT!
powercfg /setactive SCHEME_CURRENT >nul
timeout /t 1 >nul
goto main-loop

:OPTION_4
cls
echo Current Battery Hibernate Timeout: %DCMIN% minutes
set /p "INPUT=Enter new Battery Hibernate Timeout (in minutes, 0 to disable): "
if "!INPUT!"=="" goto main-loop
echo !INPUT! | findstr /r "^ *[0-9][0-9]* *$" >nul || (
    echo %ESC%[31mInvalid input! Please enter a valid number.%ESC%[0m
    timeout /t 2 >nul
    goto OPTION_4
)
set "INPUT=!INPUT: =!"
powercfg /change hibernate-timeout-dc !INPUT!
powercfg /setactive SCHEME_CURRENT >nul
timeout /t 1 >nul
goto main-loop
