@echo off
setlocal EnableDelayedExpansion

:: Set full screen
mode con: cols=700 lines=60

title Windows Unwanted Services Manager

:: define backup folder
set "scriptDir=%~dp0"
set "backupDir=%scriptDir%backup"
if not exist "%backupDir%" mkdir "%backupDir%"

:: load service definitions from external files
call "%~dp0src\services.bat"
call "%~dp0src\Service_Menu.bat"

:: check if numServices is defined
if not defined numServices (
    echo Error: numServices is not defined.
    echo Ensure that services.bat is loaded before creating backup.
    pause
    exit /b
)

:: on first launch, create 1stTimeBackup.txt if missing (include startup type and live state)
if not exist "%backupDir%\1stTimeBackup.txt" (
    > "%backupDir%\1stTimeBackup.txt" (
        echo REM Initial backup created on %DATE% %TIME%
        for /L %%i in (1,1,%numServices%) do (
            set "svc=!services[%%i]!"
            for /f "tokens=3 delims=: " %%A in ('sc qc "!svc!" ^| findstr /i "START_TYPE"') do set "stype=%%A"
            sc query "!svc!" | findstr /i "RUNNING" >nul && set "state=Running" || set "state=Stopped"
            echo !svc! !stype! !state!
        )
    )
)

:: --- define total width for name + dashes ---
set padLen=30
set dashes=------------------------------

:MAIN_MENU
cls
color 0A
echo.
echo =============== MAIN MENU ===============
for /L %%i in (1,1,%numServices%) do (
    set "svc=!services[%%i]!"
    set "nm=!names[%%i]!"
    set "type="
    set "state="
    for /f "tokens=3 delims=: " %%A in ('sc qc "!svc!" ^| findstr /i "START_TYPE"') do set "type=%%A"
    if "!type!"=="DEMAND_START" set "type=Manual"
    if "!type!"=="AUTO_START"   set "type=Automatic"
    if "!type!"=="DISABLED"     set "type=Disabled"

    if /i "!svc!"=="src\HyperV.bat" (
        for /f "tokens=2 delims=:" %%A in ('dism /online /get-featureinfo /featurename:Microsoft-Hyper-V-All ^| findstr /i "State"') do set state=%%A
        set "state=!state: =!"
        if /i "!state!"=="Enabled" (set "state=Enabled") else (set "state=Disabled")
    ) else (
        sc query "!svc!" | findstr /i "RUNNING" >nul && set "state=Running" || set "state=Stopped"
    )

    set "entry=%%i. !nm!!dashes!"
    set "entry=!entry:~0,%padLen%!"
    echo !entry! [ !type! ^| !state! ]
)
echo.
echo - Backup Live Status                ( b  )
echo - Restore from Backup               ( r  )
echo - Restore to Script 1st Launch      ( r1 )
echo.
echo - Enable All Services               ( ea )
echo - Disable All Services              ( da )
echo - Manual ^| Running All              ( mr )
echo - Manual ^| Stopped All              ( ms )
echo - Run All                           ( ra )
echo - Stop All                          ( sa )
echo.
echo - Exit                              ( e  )
echo ========================================
set /p choice=Select : 

if /i "%choice%"=="e" exit /b

if /i "%choice%"=="b" (
    call :ConfirmBackup
    pause
    goto MAIN_MENU
)
if /i "%choice%"=="r" (
    call :RestoreBackup "ServiceBackup.txt"
    pause
    goto MAIN_MENU
)
if /i "%choice%"=="r1" (
    call :RestoreBackup "1stTimeBackup.txt"
    pause
    goto MAIN_MENU
)

for %%A in (ea da mr ms ra sa) do if /i "%choice%"=="%%A" (
    call :ConfirmProceed "%%A"
    call :ConfirmBackup
    call :%%A
    pause
    goto MAIN_MENU
)

for /f "delims=0123456789" %%x in ("%choice%") do (
    echo Invalid selection.
    color 4F
    pause
    goto MAIN_MENU
)
if %choice% LSS 1 (
    echo Invalid selection.
    color 4F
    pause
    goto MAIN_MENU
)
if %choice% GTR %numServices% (
    echo Invalid selection.
    color 4F
    pause
    goto MAIN_MENU
)

set "service=!services[%choice%]!"
set "servicename=!names[%choice%]!"
call src\Service_Menu.bat %service% "%servicename%"
goto MAIN_MENU

:ConfirmBackup
color 4F
echo.
echo WARNING: Highly recommended to run a backup before proceeding!
choice /m "Do you want to backup live service status now?"
if errorlevel 2 goto :eof
call :BackupServices
echo.
pause
color 0A
goto :eof

:ConfirmProceed
set "action=%~1"
color 4F
echo.
echo Are you sure you want to %action%? (y/n)
set /p confirm=Are you sure to continue? (y/n):
if /i "%confirm%"=="n" (echo Action aborted.& color 0A & goto MAIN_MENU)
if /i "%confirm%"=="y" (echo Proceeding with %action%...& color 0A) else (echo Invalid choice. Action aborted.& color 0A & goto MAIN_MENU)
goto :eof

:BackupServices
set "backupFile=%backupDir%\ServiceBackup.txt"
> "%backupFile%" (
    echo REM Backup created on %DATE% %TIME%
    for /L %%i in (1,1,%numServices%) do (
        set "svc=!services[%%i]!"
        for /f "tokens=3 delims=: " %%A in ('sc qc "!svc!" ^| findstr /i "START_TYPE"') do set "stype=%%A"
        sc query "!svc!" | findstr /i "RUNNING" >nul && set "state=Running" || set "state=Stopped"
        echo !svc! !stype! !state!
    )
)
echo Backup saved to "%backupFile%"
goto :eof

:RestoreBackup
set "restoreFile=%~1"
set "restorePath=%backupDir%\%restoreFile%"
if not exist "%restorePath%" (echo Backup file "%restorePath%" not found.& color 4F & goto :eof)
for /f "usebackq tokens=1,2,3" %%A in (`findstr /v "^REM" "%restorePath%"`) do (
    set "svc=%%A"
    set "stype=%%B"
    set "state=%%C"
    call :SetServiceStartup !svc! !stype! !state!
)
echo.& echo Restore completed from %restoreFile%
goto :eof

:SetServiceStartup
set "svcName=%~1"
set "inType=%~2"
set "inState=%~3"
if /i "%inType%"=="AUTO_START"   set "outType=auto"
if /i "%inType%"=="DEMAND_START" set "outType=demand"
if /i "%inType%"=="DISABLED"     set "outType=disabled"
if not defined outType set "outType=%inType%"
sc config "%svcName%" start= %outType% >nul 2>&1
if /i "%inState%"=="Running" (sc start "%svcName%" >nul) else (sc stop "%svcName%" >nul)
set "outType="
goto :eof

:ea
for /L %%i in (1,1,%numServices%) do sc config "!services[%%i]!" start= auto >nul
goto :eof

:da
for /L %%i in (1,1,%numServices%) do sc config "!services[%%i]!" start= disabled >nul
goto :eof

:mr
for /L %%i in (1,1,%numServices%) do (sc config "!services[%%i]!" start= demand >nul & sc start "!services[%%i]!" >nul)
goto :eof

:ms
for /L %%i in (1,1,%numServices%) do (sc config "!services[%%i]!" start= demand >nul & sc stop "!services[%%i]!" >nul)
goto :eof

:ra
for /L %%i in (1,1,%numServices%) do sc start "!services[%%i]!" >nul
goto :eof

:sa
for /L %%i in (1,1,%numServices%) do sc stop "!services[%%i]!" >nul
goto :eof
