@echo off
title Power Plan Manager
color 0A

:MENU
cls
echo ================================
echo      POWER PLAN SELECTOR
echo ================================
echo 1. Recommend Power Plan (Balanced - Recommended for Laptops)
echo 2. High Performance (Recommended for PCs)
echo 3. Power Saver
echo 4. Remove All Custom Power Plans
echo 5. Open Power Options (Control Panel)
echo 0. Exit to Previous Menu
echo.
set /p choice=Select an option (0-4): 

if "%choice%"=="1" goto ImportBackup
if "%choice%"=="2" goto HighPerformance
if "%choice%"=="3" goto PowerSaver
if "%choice%"=="4" goto ConfirmDelete
if "%choice%"=="5" goto OpenPowerOptions
if "%choice%"=="0" exit /b
goto MENU

:HighPerformance
echo Activating High Performance plan...
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
echo Done.
pause
goto MENU

:Balanced
echo Activating Balanced plan...
powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e
echo Done.
pause
goto MENU

:PowerSaver
echo Activating Power Saver plan...
powercfg -setactive a1841308-3541-4fab-bc81-f71556f20b4a
echo Done.
pause
goto MENU

:ImportBackup
REM Ensure we're running as admin
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

set "POWFILE=%~dp0Backup Power Plan.pow"
echo Importing from "%POWFILE%"...

for /f "tokens=2 delims=:" %%G in ('powercfg -import "%POWFILE%" ^| findstr /R /C:"GUID"') do (
    set "NEW_GUID=%%G"
)
set "NEW_GUID=%NEW_GUID:~1%"

echo Activating imported plan %NEW_GUID%...
powercfg -setactive %NEW_GUID%
echo Done.
pause
goto MENU

:ConfirmDelete
set /p confirm=Are you sure you want to delete all power plans except default ones? (y/n): 
if /i "%confirm%"=="y" goto RemovePlans
if /i "%confirm%"=="n" goto MENU
echo Invalid input. Please type yes or no.
pause
goto ConfirmDelete

:RemovePlans
echo Removing all custom power plans...

echo Deleting all power plans...
echo.

REM List only lines containing “Power Scheme GUID”,
REM then extract the 4th token (the actual GUID) and delete it.
for /f "tokens=4" %%G in ('powercfg /list ^| findstr /i "Power Scheme GUID"') do (
    echo Deleting plan %%G
    powercfg /delete %%G
)

echo.
echo All power plans removed.
pause
goto MENU

:TrimGuid
setlocal
set "rawGuid=%~1"
set "rawGuid=%rawGuid:~6,36%"
REM Do not delete default plans
if /I not "%rawGuid%"=="381b4222-f694-41f0-9685-ff5bb260df2e" if /I not "%rawGuid%"=="8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" if /I not "%rawGuid%"=="a1841308-3541-4fab-bc81-f71556f20b4a" (
    powercfg -delete %rawGuid%
    echo Deleted %rawGuid%
)
endlocal

:OpenPowerOptions
echo Opening Power Options Control Panel...
start control.exe powercfg.cpl
pause
goto MENU


exit /b
