@echo off
:: Show current mode
reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme >nul 2>&1
if %errorlevel% neq 0 (
    echo Failed to check current theme.
    pause
    exit /b
)

for /f "tokens=3" %%a in ('reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme') do set mode=%%a

if "%mode%"=="0x0" (
    echo Current Mode: Dark
) else (
    echo Current Mode: Light
)

echo.
echo Select a mode:
echo [1] Light Mode
echo [2] Dark Mode
set /p choice=Enter your choice (1 or 2): 

if "%choice%"=="1" (
    echo Switching to Light Mode...
    reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /t REG_DWORD /d 1 /f >nul
    reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 1 /f >nul
    echo Now in Light Mode.
    echo.
echo    Restarting File Explorer to apply changes...
echo.
timeout /t 2 /nobreak >nul
taskkill /f /im explorer.exe >nul
start explorer.exe

) else if "%choice%"=="2" (
    echo Switching to Dark Mode...
    reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /t REG_DWORD /d 0 /f >nul
    reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 0 /f >nul
    echo Now in Dark Mode.
    echo.
echo    Restarting File Explorer to apply changes...
echo.
timeout /t 2 /nobreak >nul
taskkill /f /im explorer.exe >nul
start explorer.exe

) else (
    echo Invalid choice.
)

pause