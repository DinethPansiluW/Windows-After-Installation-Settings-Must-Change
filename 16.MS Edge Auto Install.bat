@echo off
setlocal enabledelayedexpansion

:: Admin check
net session >nul 2>&1
if %errorlevel% neq 0 (
    >"%temp%\getadmin.vbs" (
        echo Set UAC = CreateObject^("Shell.Application"^)
        echo UAC.ShellExecute "%~f0", "", "", "runas", 1
    )
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit
)

:: Colors
set "GREEN=[1;32m"
set "RED=[31m"
set "ORANGE=[33m"
set "RESET=[0m"
set "SKYBLUE=[96m"

:main_menu
cls
call :show_status
echo.
echo %GREEN%Microsoft Edge Auto-Install Blocker Panel%RESET%
echo ================================================
echo.
echo %GREEN%1.%RESET% Block Edge Auto-Install
echo %GREEN%2.%RESET% Unblock Edge Auto-Install
echo %GREEN%3.%RESET% Exit
echo.
set /p choice=Select option [1-3]: 

if "%choice%"=="1" call :block_edge
if "%choice%"=="2" call :unblock_edge
if "%choice%"=="3" exit
echo %RED%Invalid choice. Try again.%RESET%
pause
goto main_menu

:show_status
set "edge_block_status=Unblocked"
reg query "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v DoNotUpdateToEdgeWithChromium >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v DoNotUpdateToEdgeWithChromium') do (
        if %%a equ 0x1 (
            set "edge_block_status=Blocked"
        )
    )
)
echo %SKYBLUE%Current Edge Auto-Install Status:%RESET%
echo - Status: %ORANGE%!edge_block_status!%RESET%
echo.
exit /b

:block_edge
echo %RED%Blocking Edge Auto-Install and Removing Lock...%RESET%
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v DoNotUpdateToEdgeWithChromium /t REG_DWORD /d 1 /f >nul
takeown /f "%ProgramFiles(x86)%\Microsoft\Edge" /r /d y >nul 2>&1
icacls "%ProgramFiles(x86)%\Microsoft\Edge" /grant administrators:F /t >nul 2>&1
echo %RED%Edge Auto-Install Blocked and Lock Removed.%RESET%
pause
goto main_menu

:unblock_edge
echo %GREEN%Removing Edge Block...%RESET%
reg delete "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v DoNotUpdateToEdgeWithChromium /f >nul 2>&1
echo %GREEN%Edge Auto-Install Unblocked.%RESET%
pause
goto main_menu
