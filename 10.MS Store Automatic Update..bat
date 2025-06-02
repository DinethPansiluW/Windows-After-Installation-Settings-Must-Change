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

REM ── 1) Query the policy key once; errorlevel=0 if it exists, 1 if not
reg query "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload >nul 2>&1
if errorlevel 1 (
    set "val=default"
) else (
    REM ── 2) Extract the DWORD value (0x2 or 0x4) into %val%
    for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload') do set "val=%%A"
)

REM ── 3) Show exactly one status line; escape parentheses with ^ so they don’t break the IF syntax
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
echo %GREEN%1.%RESET% Enable automatic updates
echo %RED%2.%RESET% Disable automatic updates
set /p choice=%CYAN%Enter choice (1 or 2): %RESET%

if "%choice%"=="1" goto Enable
if "%choice%"=="2" goto Disable

echo %RED%Invalid choice. Exiting.%RESET%
goto End

:Enable
REM ── 4) Set DWORD to 4 to enable auto‑updates
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /t REG_DWORD /d 4 /f
echo %GREEN%Automatic updates ENABLED%RESET%
goto End

:Disable
REM ── 5) Set DWORD to 2 to disable auto‑updates
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /t REG_DWORD /d 2 /f
echo %RED%Automatic updates DISABLED%RESET%
goto End

:End
pause
