@echo off
setlocal EnableDelayedExpansion

:: === Define Colors (ANSI escape codes) ===
set "RED=[31m"
set "GREEN=[32m"
set "YELLOW=[33m"
set "BLUE=[34m"
set "CYAN=[36m"
set "RESET=[0m"

:: === Get mode from parameter or default to AC ===
if "%~1" neq "" (
    set "mode=%~1"
) else (
    set "mode=AC"
)

:: === Get Lid Action Status ===
for /f "tokens=*" %%i in ('powercfg /query SCHEME_CURRENT SUB_BUTTONS LIDACTION ^| findstr /i /c:"Power Setting Index"') do (
    echo %%i | find /i "DC" >nul && set lineDC=%%i
    echo %%i | find /i "AC" >nul && set lineAC=%%i
)

:: Decode DC
for %%j in (!lineDC!) do set rawDC=%%j
if "!rawDC!"=="0x00000000" (set statusDC=Do Nothing)
if "!rawDC!"=="0x00000001" (set statusDC=Sleep)
if "!rawDC!"=="0x00000002" (set statusDC=Hibernate)
if "!rawDC!"=="0x00000003" (set statusDC=Shut Down)

:: Decode AC
for %%j in (!lineAC!) do set rawAC=%%j
if "!rawAC!"=="0x00000000" (set statusAC=Do Nothing)
if "!rawAC!"=="0x00000001" (set statusAC=Sleep)
if "!rawAC!"=="0x00000002" (set statusAC=Hibernate)
if "!rawAC!"=="0x00000003" (set statusAC=Shut Down)

:: === Display Current Info ===
cls
echo %CYAN%===============================%RESET%
echo %GREEN%Current lid close action when plugged in (AC) : %RED%!statusAC!%RESET%
echo %GREEN%Current lid close action on battery      (DC) : %RED%!statusDC!%RESET%
echo %CYAN%===============================%RESET%
echo %RESET%Current Mode : %YELLOW%!mode!%RESET%
echo.
echo %YELLOW%Select new lid close action:%RESET%
echo 1 - Toggle the Mode
echo 2 - Do Nothing
echo 3 - Sleep
echo 4 - Hibernate
echo 5 - Shut Down
echo %CYAN%===============================================%RESET%
set /p choice=%CYAN%Enter your choice (1-5): %RESET%

:: === Toggle Mode ===
if "%choice%"=="1" (
    if "!mode!"=="AC" (
        set "new_mode=DC"
    ) else (
        set "new_mode=AC"
    )
    echo %BLUE%Mode toggled. New Mode: %YELLOW%!new_mode!%RESET%
    pause
    call "%~f0" !new_mode!
    exit /b
)

:: === Set Action for Current Mode Only ===
if "%choice%"=="2" (set action=0)
if "%choice%"=="3" (set action=1)
if "%choice%"=="4" (set action=2)
if "%choice%"=="5" (set action=3)

if defined action (
    if "!mode!"=="AC" (
        powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LidAction !action!
    ) else (
        powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LidAction !action!
    )
    powercfg /S SCHEME_CURRENT
    echo %GREEN%Lid close action updated for !mode! mode.%RESET%
)

echo Press any key to refresh...
pause >nul
call "%~f0" !mode!
exit /b