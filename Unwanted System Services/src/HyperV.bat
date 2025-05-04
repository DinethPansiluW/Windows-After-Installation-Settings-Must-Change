@echo off
setlocal EnableDelayedExpansion

:: Check Hyper-V status
for /f "tokens=2 delims=:" %%A in ('dism /online /get-featureinfo /featurename:Microsoft-Hyper-V-All ^| findstr /i "State"') do (
    set "state=%%A"
)

:: Clean up value
set "state=!state: =!"

:: Display current Hyper-V state
cls
echo.
echo ========================================
echo   Hyper-V is currently: !state!
echo ========================================
echo.

:: Provide options to user
echo Select an option:
echo 1. Enable Hyper-V
echo 2. Disable Hyper-V
echo 3. Return to Main Menu
set /p choice=Enter your choice (1/2/3): 

if "!choice!"=="1" (
    echo.
    echo Enabling Hyper-V...
    dism /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart
    echo Done. Please restart your system to apply changes.
) else if "!choice!"=="2" (
    echo.
    echo Disabling Hyper-V...
    dism /online /disable-feature /featurename:Microsoft-Hyper-V-All /norestart
    echo Done. Please restart your system to apply changes.
) else (
    echo.
    echo Returning to Main Menu...
)

echo.
pause
exit /b
