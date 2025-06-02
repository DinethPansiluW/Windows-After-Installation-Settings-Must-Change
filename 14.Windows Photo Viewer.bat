@echo off
setlocal enabledelayedexpansion

:: ANSI color codes with literal ESC character
set "GREEN=[1;32m"
set "RED=[31m"
set "YELLOW=[1;33m"
set "CYAN=[36m"
set "RESET=[0m"

:: Registry keys for Windows Photo Viewer associations
set "WPV_Registry=HKCR\Applications\photoviewer.dll"

:: Check if Windows Photo Viewer is enabled (by checking a registry key)
reg query "HKCU\Software\Classes\Applications\photoviewer.dll" >nul 2>&1
if errorlevel 1 (
    set "wpv_status=Disabled"
) else (
    set "wpv_status=Enabled"
)

echo %CYAN%Current Windows Photo Viewer status: %YELLOW%!wpv_status!%RESET%
echo.
echo %GREEN%1.%RESET% Enable Windows Photo Viewer
echo %RED%2.%RESET% Disable Windows Photo Viewer
echo 3. Exit
echo.
set /p choice=%CYAN%Select option [1-3]: %RESET%

if "%choice%"=="1" goto EnableWPV
if "%choice%"=="2" goto DisableWPV
if "%choice%"=="3" exit

echo %RED%Invalid choice. Try again.%RESET%
pause
goto :eof

:EnableWPV
echo %GREEN%Enabling Windows Photo Viewer...%RESET%

:: Add registry keys to enable Windows Photo Viewer as default app for images
reg add "HKCU\Software\Classes\Applications\photoviewer.dll" /f >nul 2>&1

:: Set photo file associations to Windows Photo Viewer for common image types
for %%x in (jpg jpeg png bmp gif tif tiff) do (
    reg add "HKCU\Software\Classes\SystemFileAssociations\.%%x" /v "UserChoice" /t REG_SZ /d "" /f >nul 2>&1
    reg add "HKCU\Software\Classes\.%%x" /ve /t REG_SZ /d "photoviewer.dll" /f >nul 2>&1
)

echo %GREEN%Windows Photo Viewer Enabled.%RESET%
pause
goto :eof

:DisableWPV
echo %RED%Disabling Windows Photo Viewer...%RESET%

:: Remove the registry key to disable Windows Photo Viewer association
reg delete "HKCU\Software\Classes\Applications\photoviewer.dll" /f >nul 2>&1

:: Remove file associations pointing to Windows Photo Viewer
for %%x in (jpg jpeg png bmp gif tif tiff) do (
    reg delete "HKCU\Software\Classes\.%%x" /ve /f >nul 2>&1
)

echo %RED%Windows Photo Viewer Disabled.%RESET%
pause
goto :eof
