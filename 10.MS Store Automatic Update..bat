@echo off
setlocal enabledelayedexpansion

:: Check for admin rights
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

:: Set ANSI color escape codes using literal ESC (ASCII 27) character
set "GREEN=[1;32m"
set "RED=[31m"
set "YELLOW=[1;33m"
set "CYAN=[36m"
set "RESET=[0m"

:Menu
cls
REM ── 1) Query the policy key once; errorlevel=0 if it exists, 1 if not
reg query "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload >nul 2>&1
if errorlevel 1 (
    set "val=default"
) else (
    REM ── 2) Extract the DWORD value (0x2 or 0x4) into %val%
    for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload') do set "val=%%A"
)

REM ── 3) Show exactly one status line
if "%val%"=="default" (
    echo %CYAN%Current status: %YELLOW%Default ^(user choice^) %RESET%
) else if /i "%val%"=="0x4" (
    echo %CYAN%Current status: %GREEN%Enabled%RESET%
) else if /i "%val%"=="0x2" (
    echo %CYAN%Current status: %RED%Disabled%RESET%
) else (
    echo %CYAN%Current status: %RED%Unknown ^(%val% ^)%RESET%
)

echo.
echo %RED%1.%RESET% Disable automatic updates
echo %GREEN%2.%RESET% Enable automatic updates
echo %YELLOW%3.%RESET% Exit
set /p choice=%CYAN%Enter choice (1, 2 or 3): %RESET%

if "%choice%"=="1" goto Disable
if "%choice%"=="2" goto Enable
if "%choice%"=="3" goto End

echo %RED%Invalid choice. Try again.%RESET%
timeout /t 2 >nul
goto Menu

:Enable
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /t REG_DWORD /d 4 /f >nul
echo %GREEN%Automatic updates ENABLED%RESET%
timeout /t 2 >nul
goto Menu

:Disable
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /t REG_DWORD /d 2 /f >nul
echo %RED%Automatic updates DISABLED%RESET%
timeout /t 2 >nul
goto Menu

:End
endlocal
exit
