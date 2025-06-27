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
powershell -command "Get-WmiObject Win32_PageFileSetting | Format-Table Name, InitialSize, MaximumSize -AutoSize"
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

REM Disable automatic management via registry
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "AutoManagePagefiles" /t REG_DWORD /d 0 /f >nul

REM Set pagefile parameters in registry
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagingFiles" /t REG_MULTI_SZ /d "C:\pagefile.sys %initialMB% %maxMB%" /f >nul

REM Create or update pagefile using WMI
powershell -command ^
    "try { ^
        \$pagefile = Get-WmiObject Win32_PageFileSetting | Where-Object { \$_.Name -eq 'C:\\pagefile.sys' }; ^
        if (-not \$pagefile) { ^
            \$class = [wmiclass]'Win32_PageFileSetting'; ^
            \$new = \$class.CreateInstance(); ^
            \$new.Name = 'C:\\pagefile.sys'; ^
            \$new.InitialSize = %initialMB%; ^
            \$new.MaximumSize = %maxMB%; ^
            \$new.Put() ^
        } else { ^
            \$pagefile.InitialSize = %initialMB%; ^
            \$pagefile.MaximumSize = %maxMB%; ^
            \$pagefile.Put() ^
        } ^
    } catch { ^
        echo Error configuring pagefile: $_ ^
        exit 1 ^
    }"

echo.
echo Virtual memory settings updated successfully!
timeout /t 2 /nobreak >nul
echo.
echo [Updated Virtual Memory Settings]
powershell -command "Get-WmiObject Win32_PageFileSetting | Format-Table Name, InitialSize, MaximumSize -AutoSize"
echo.
echo NOTE: Changes will take effect after system restart.
pause