@echo off
setlocal enabledelayedexpansion

REM Check administrator privileges
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo This script must be run as administrator.
    echo Please right-click the script and select "Run as administrator".
    pause
    exit
)

echo Getting C drive information...
for /f "tokens=1,2" %%a in ('powershell -command "$d=Get-WmiObject Win32_LogicalDisk -Filter 'DeviceID=\"C:\"'; [math]::Round($d.Size/1GB, 2).ToString() + ' ' + [math]::Round($d.FreeSpace/1GB, 2).ToString()"') do (
    set "TotalGB=%%a"
    set "FreeGB=%%b"
)
echo.
echo [C Drive Space Status]
echo Total Space : !TotalGB! GB
echo Free Space  : !FreeGB! GB
echo.

echo [Current Virtual Memory Settings]
wmic pagefileset get Name, InitialSize, MaximumSize /format:table
echo.

:ask_ram
set /p "ram=What is the RAM of your Computer (GB): "
echo.
if not defined ram goto ask_ram
echo %ram%|findstr /r "^[0-9]*$" >nul
if %errorlevel% neq 0 (
    echo Invalid input. Please enter a numeric value.
    echo.
    goto ask_ram
)

set /a initialMB=%ram%*15*1024/10
set /a maxMB=%ram%*3*1024

echo [New Virtual Memory Settings]
echo Initial Size : %initialMB% MB
echo Maximum Size : %maxMB% MB
echo.

wmic computersystem where name="%computername%" set AutomaticManagedPagefile=False >nul
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=%initialMB%,MaximumSize=%maxMB% >nul

echo Virtual memory settings updated successfully!
echo.
echo [Updated Virtual Memory Settings]
wmic pagefileset get Name, InitialSize, MaximumSize /format:table
echo.
echo NOTE: Changes will take effect after system restart.
pause