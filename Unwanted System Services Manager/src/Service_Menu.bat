@echo off
setlocal EnableDelayedExpansion

:: — load services definitions from external file —
call "services.bat"

:: first two arguments are service name and display name
if "%~1"=="" exit /b
set "service=%~1"
set "servicename=%~2"

:: — find matching description from loaded arrays —
set "desc="
for /L %%i in (1,1,!numServices!) do (
    if /I "!services[%%i]!"=="%service%" set "desc=!desc[%%i]!"
)
if not defined desc set "desc=No description available."

:MENU
cls
:: get current startup & state
for /f "tokens=3 delims=: " %%A in ('sc qc "%service%" ^| findstr /i "START_TYPE"') do set "startup=%%A"
if "%startup%"=="DEMAND_START" set "type=Manual"
if "%startup%"=="AUTO_START"   set "type=Automatic"
if "%startup%"=="DISABLED"     set "type=Disabled"
sc query "%service%" | findstr /i "RUNNING" >nul && set "state=Running" || set "state=Stopped"


echo.
echo ===== %servicename% Service Menu =====
echo Service: %service%
echo Description: %desc%
echo Startup Type: %type%
echo Status: %state%
echo =====================================
echo 1. Enable (Automatic)
echo 2. Disable
echo 3. Set to Manual
if not "%type%"=="Disabled" (
    if "%state%"=="Stopped" (
        echo 4. Start Service
    ) else if "%state%"=="Running" (
        echo 4. Stop Service
    )
)
echo 5. Return to Main Menu
echo.

set /p action=Choose (1-5): 
if "%action%"=="1" (
    sc config "%service%" start= auto
    net start "%service%"
    pause
    goto MENU
)
if "%action%"=="2" (
    sc config "%service%" start= disabled
    net stop "%service%"
    pause
    goto MENU
)
if "%action%"=="3" (
    sc config "%service%" start= demand
    echo Set to Manual.
    pause
    goto MENU
)
if "%action%"=="4" if not "%type%"=="Disabled" (
    if "%state%"=="Stopped" (
        net start "%service%"
    ) else if "%state%"=="Running" (
        net stop "%service%"
    )
    pause
    goto MENU
)
if "%action%"=="5" exit /b

echo Invalid choice.
pause
goto MENU
