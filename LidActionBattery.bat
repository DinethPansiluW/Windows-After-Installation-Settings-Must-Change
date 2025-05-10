@echo off
setlocal EnableDelayedExpansion

:: === Define Colors (using literal escape sequences) ===
set "RED=[31m"
set "GREEN=[32m"
set "YELLOW=[33m"
set "BLUE=[34m"
set "CYAN=[36m"
set "RESET=[0m"

echo %CYAN%===============================%RESET%

:: Grab Power Setting Index for DC
for /f "tokens=*" %%i in ('powercfg /query SCHEME_CURRENT SUB_BUTTONS LIDACTION ^| findstr /i /c:"Power Setting Index"') do (
    echo %%i | find /i "DC" >nul && set line=%%i
)

:: Extract last token (hex value)
for %%j in (!line!) do set raw=%%j

:: Decode
if "!raw!"=="0x00000000" (
    set status=Do Nothing
) else if "!raw!"=="0x00000001" (
    set status=Sleep
) else if "!raw!"=="0x00000002" (
    set status=Hibernate
) else if "!raw!"=="0x00000003" (
    set status=Shut Down
) else (
    set status=Unknown (!raw!)
)

echo %GREEN%Current lid close action on battery: %RED%!status!%RESET%
echo %CYAN%===============================================%RESET%
echo %YELLOW%Select new lid close action (ON BATTERY):%RESET%
echo 1 - Do Nothing
echo 2 - Sleep
echo 3 - Hibernate
echo 4 - Shut Down
echo %CYAN%===============================================%RESET%
set /p choice=%CYAN%Enter your choice (1-4): %RESET%

if "%choice%"=="1" (
    set action=0
) else if "%choice%"=="2" (
    set action=1
) else if "%choice%"=="3" (
    set action=2
) else if "%choice%"=="4" (
    set action=3
) else (
    echo %RED%Invalid choice. Exiting...%RESET%
    pause
    exit /b
)

echo %BLUE%Applying your choice for ON BATTERY...%RESET%

powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LidAction !action!
powercfg /S SCHEME_CURRENT

echo %GREEN%Lid close action for ON BATTERY updated successfully.%RESET%
pause

:: Refresh terminal
echo %GREEN%Refreshing the terminal...%RESET%
timeout /t 1 >nul
cls
call "%~f0"
exit /b
