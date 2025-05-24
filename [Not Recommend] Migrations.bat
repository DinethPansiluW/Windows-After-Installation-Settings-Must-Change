@echo off
setlocal EnableDelayedExpansion

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


:: ANSI color codes
set "GREEN=[1;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "SKYBLUE=[96m"

:: -- Require elevation --
net session >nul 2>&1
if errorlevel 1 (
    echo %ORANGE%Requesting administrator privileges...%RESET%
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
    exit /b
)

:main
cls
echo %GREEN%Windows CPU & Kernel Mitigations Control%RESET%
echo =============================================
echo.
echo %GREEN%1.%RESET% Enable All Mitigations
echo %GREEN%2.%RESET% Disable All Mitigations
echo %GREEN%3.%RESET% Restore Windows Default Mitigations
echo %GREEN%4.%RESET% Exit
echo.
set /p choice=Select option [1-4]: 

if "%choice%"=="1" goto :enable_all
if "%choice%"=="2" goto :disable_all
if "%choice%"=="3" goto :restore_default
if "%choice%"=="4" exit
echo %RED%Invalid choice. Try again.%RESET%
pause
goto main

:enable_all
cls
echo %ORANGE%WARNING:%RESET% This will force-enable all Windows CPU & kernel mitigations.
echo It may impact performance on older hardware.
echo.
pause

:: Spectre & Meltdown
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /t REG_DWORD /d 3 /f >nul
wmic cpu get name | findstr /i "Intel" >nul && reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /t REG_DWORD /d 0 /f >nul
wmic cpu get name | findstr /i "AMD"   >nul && reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /t REG_DWORD /d 64 /f >nul

:: SEHOP
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v DisableExceptionChainValidation /t REG_DWORD /d 0 /f >nul

:: CFG
PowerShell -NoProfile -Command "Set-ProcessMitigation -System -Enable CFG" >nul

:: Kernel mitigation mask
for /f "tokens=3 skip=2" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v MitigationAuditOptions') do set "mask=%%A"
for /l %%i in (0,1,9) do set "mask=!mask:%%i=1!"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v MitigationAuditOptions /t REG_BINARY /d !mask! /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v MitigationOptions      /t REG_BINARY /d !mask! /f >nul

:: DEP AlwaysOn
bcdedit /set nx AlwaysOn >nul

:: File system mitigations
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v ProtectionMode /t REG_DWORD /d 1 /f >nul

:: Hyper‑V mitigations
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization" /v MinVmVersionForCpuBasedMitigations /t REG_SZ /d "1.0" /f >nul

echo.
echo %GREEN%All mitigations enabled. Please reboot to apply changes.%RESET%
pause
goto main

:disable_all
cls
echo %ORANGE%Disabling all Windows CPU & kernel mitigations...%RESET%

:: Spectre & Meltdown off
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /t REG_DWORD /d 3 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride     /t REG_DWORD /d 3 /f >nul

:: SEHOP off
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v DisableExceptionChainValidation /t REG_DWORD /d 1 /f >nul

:: CFG off
PowerShell -NoProfile -Command "Set-ProcessMitigation -System -Disable CFG" >nul

:: Kernel mitigation mask to “2”
for /f "tokens=3 skip=2" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v MitigationAuditOptions') do set "mask=%%A"
for /l %%i in (0,1,9) do set "mask=!mask:%%i=2!"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v MitigationAuditOptions /t REG_BINARY /d !mask! /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v MitigationOptions      /t REG_BINARY /d !mask! /f >nul

:: DEP OptIn
bcdedit /set nx OptIn >nul

:: File system mitigations off
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v ProtectionMode /t REG_DWORD /d 0 /f >nul

echo.
echo %RED%All mitigations disabled. Please reboot to apply changes.%RESET%
pause
goto main

:restore_default
cls
echo %ORANGE%Restoring Windows default mitigations...%RESET%

:: Remove Spectre & Meltdown overrides
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride     /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /f >nul 2>&1

:: Remove SEHOP override
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v DisableExceptionChainValidation /f >nul 2>&1

:: Remove mitigation masks
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v MitigationAuditOptions /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v MitigationOptions      /f >nul 2>&1

:: DEP OptIn
bcdedit /set nx OptIn >nul

:: File system mitigations default
reg add    "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v ProtectionMode /t REG_DWORD /d 1 /f >nul

:: Hyper‑V default
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization" /v MinVmVersionForCpuBasedMitigations /f >nul 2>&1

echo.
echo %ORANGE%Defaults restored. Please reboot to apply changes.%RESET%
pause
goto main
