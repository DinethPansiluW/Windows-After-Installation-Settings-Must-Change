@echo off
setlocal

REM ── 1) Query the policy key once; errorlevel=0 if it exists, 1 if not :contentReference[oaicite:0]{index=0}
reg query "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload >nul 2>&1
if errorlevel 1 (
    set "val=default"
) else (
    REM ── 2) Extract the DWORD value (0x2 or 0x4) into %val% :contentReference[oaicite:1]{index=1}
    for /f "tokens=3" %%A in ('
      reg query "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload
    ') do set "val=%%A"
)

REM ── 3) Show exactly one status line; escape parentheses with ^ so they don’t break the IF syntax :contentReference[oaicite:2]{index=2}
if "%val%"=="default" (
    echo Current status: Default ^(user choice^)
) else if /i "%val%"=="0x4" (
    echo Current status: Enabled
) else if /i "%val%"=="0x2" (
    echo Current status: Disabled
) else (
    echo Current status: Unknown ^(%val% ^)
)

echo.
echo 1. Enable automatic updates
echo 2. Disable automatic updates
set /p choice=Enter choice (1 or 2): 

if "%choice%"=="1" goto Enable
if "%choice%"=="2" goto Disable

echo Invalid choice. Exiting.
goto End

:Enable
REM ── 4) Set DWORD to 4 to enable auto‑updates :contentReference[oaicite:3]{index=3}
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /t REG_DWORD /d 4 /f
echo Automatic updates ENABLED
goto End

:Disable
REM ── 5) Set DWORD to 2 to disable auto‑updates :contentReference[oaicite:4]{index=4}
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v AutoDownload /t REG_DWORD /d 2 /f
echo Automatic updates DISABLED
goto End

:End
pause
