@echo off
setlocal EnableDelayedExpansion

:: Enable Virtual Terminal Processing (for color support)
for /f "tokens=2 delims==" %%i in ('"prompt $H & for %%b in (1) do rem"') do set "BS=%%i"
echo.|set /p="[?25l" >nul 2>&1

:: Define colors
set "ESC="
set "RESET=%ESC%[0m"
set "CYAN=%ESC%[96m"
set "YELLOW=%ESC%[93m"
set "GREEN=%ESC%[92m"
set "RED=%ESC%[91m"
set "WHITE=%ESC%[97m"
set "BOLD=%ESC%[1m"

:MENU
:: Get current power scheme GUID
for /f "tokens=2 delims=:(" %%G in ('powercfg /getactivescheme') do set "scheme=%%G"

:: Get hybrid sleep settings
for /f "tokens=6" %%A in ('powercfg /query !scheme! 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e ^| findstr /C:"Current DC Power Setting Index"') do set "hybrid_dc=%%A"
for /f "tokens=6" %%A in ('powercfg /query !scheme! 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e ^| findstr /C:"Current AC Power Setting Index"') do set "hybrid_ac=%%A"

:: Interpret status
if "!hybrid_dc:~-1!"=="1" (set "status_dc=%GREEN%ON%RESET%") else (set "status_dc=%RED%OFF%RESET%")
if "!hybrid_ac:~-1!"=="1" (set "status_ac=%GREEN%ON%RESET%") else (set "status_ac=%RED%OFF%RESET%")

:: UI
cls
echo %CYAN%***********************************************%RESET%
echo %CYAN%**       %BOLD%Hybrid Sleep Control Panel       %RESET%%CYAN%**%RESET%
echo %CYAN%***********************************************%RESET%
echo.
echo %YELLOW%Recommend :%RESET%
echo PC      : Battery = %GREEN%ON%RESET%    ^| Plugged In = %GREEN%ON%RESET%
echo Laptop  : Battery = %RED%OFF%RESET%   ^| Plugged In = %GREEN%ON%RESET%
echo %CYAN%-----------%RESET%
echo.
echo %WHITE%Current Hybrid Sleep Status:%RESET%
echo -----------------------------------------
echo On Battery :  !status_dc!
echo Plugged In :  !status_ac!
echo.
echo %WHITE%Choose an option:%RESET%
echo ----------------------
echo 1. Toggle On Battery
echo 2. Toggle Plugged In
echo.
echo 0. Exit to Previous Menu
echo.

set /p choice=%BOLD%Enter your choice (0, 1, or 2):%RESET% 

if "!choice!"=="1" goto TOGGLE_DC
if "!choice!"=="2" goto TOGGLE_AC
if "!choice!"=="0" exit /b

echo %RED%Invalid choice. Please enter 0, 1, or 2.%RESET%
timeout /t 2 >nul
goto MENU

:TOGGLE_DC
echo %YELLOW%Toggling Hybrid Sleep (On Battery)...%RESET%
if "!hybrid_dc:~-1!"=="1" (
    powercfg /setdcvalueindex !scheme! 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 0
) else (
    powercfg /setdcvalueindex !scheme! 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 1
)
powercfg /setactive !scheme!
timeout /t 1 >nul
goto MENU

:TOGGLE_AC
echo %YELLOW%Toggling Hybrid Sleep (Plugged In)...%RESET%
if "!hybrid_ac:~-1!"=="1" (
    powercfg /setacvalueindex !scheme! 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 0
) else (
    powercfg /setacvalueindex !scheme! 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 1
)
powercfg /setactive !scheme!
timeout /t 1 >nul
goto MENU

:EXIT
cls
echo %CYAN%***********************************************%RESET%
echo %CYAN%**    %BOLD%Exiting Hybrid Sleep Control Panel   %RESET%%CYAN%**%RESET%
echo %CYAN%***********************************************%RESET%
endlocal
exit /B
