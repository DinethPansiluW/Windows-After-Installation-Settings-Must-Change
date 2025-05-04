@echo off
setlocal EnableDelayedExpansion

:: -------------------------------------------------------
::            Hybrid Sleep Status Control Script
:: -------------------------------------------------------
:: This script allows you to toggle Hybrid Sleep settings
:: for both on battery (DC) and plugged-in (AC) power.
:: -------------------------------------------------------

:MENU
REM ----------------------- Display Current Hybrid Sleep Status ----------------------
cls
echo ***********************************************
echo **        Hybrid Sleep Control Panel       **
echo ***********************************************
echo.
echo Current Hybrid Sleep Status:
echo -----------------------------------------
echo On Battery:  %status_dc%
echo Plugged In:  %status_ac%
echo.
echo--- RECOMMENDED SETTINGS ---
echo PC     : Battery = ON | Plugged In = ON
echo Laptop : Battery = OFF | Plugged In = ON

REM ------------------- Get Current Power Scheme GUID ---------------------------
:: Get active power scheme GUID to query settings for hybrid sleep.
for /f "tokens=2 delims=:(" %%G in ('powercfg /getactivescheme') do set "scheme=%%G"

REM ------------------- Query Hybrid Sleep Settings ---------------------------
:: Query hybrid sleep settings for both DC (battery) and AC (plugged-in).
for /f "tokens=6" %%A in ('powercfg /query !scheme! 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e ^| findstr /C:"Current DC Power Setting Index"') do (
    set "hybrid_dc=%%A"
)
for /f "tokens=6" %%A in ('powercfg /query !scheme! 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e ^| findstr /C:"Current AC Power Setting Index"') do (
    set "hybrid_ac=%%A"
)

REM ------------------- Interpret and Update Status -----------------------------
:: Interpret the hybrid sleep setting (0=off, 1=on).
if "!hybrid_dc:~-1!"=="1" (set "status_dc=On") else (set "status_dc=Off")
if "!hybrid_ac:~-1!"=="1" (set "status_ac=On") else (set "status_ac=Off")

:: Display the updated status.
cls
echo ***********************************************
echo **        Hybrid Sleep Control Panel       **
echo ***********************************************
echo.
echo Current Hybrid Sleep Status:
echo -----------------------------------------
echo On Battery:  !status_dc!
echo Plugged In:  !status_ac!
echo.

:: ---------------------- Display Menu for User Selection ---------------------
echo Choose an option:
echo ----------------------
echo 1. Toggle On Battery
echo 2. Toggle Plugged In

:: Wait for user input and navigate based on choice
choice /c 12 /n /m "Enter your choice: "
if errorlevel 2 goto TOGGLE_AC
if errorlevel 1 goto TOGGLE_DC

goto MENU

:TOGGLE_DC
:: ------------- Toggle Hybrid Sleep Setting for On Battery (DC) -----------------
echo Toggling Hybrid Sleep (On Battery)...
if "!hybrid_dc:~-1!"=="1" (
    REM Current setting is ON, toggle to OFF.
    powercfg /setdcvalueindex !scheme! 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 0
) else (
    REM Current setting is OFF, toggle to ON.
    powercfg /setdcvalueindex !scheme! 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 1
)
REM Reapply the power scheme to apply changes.
powercfg /setactive !scheme!
goto MENU

:TOGGLE_AC
:: ------------- Toggle Hybrid Sleep Setting for Plugged In (AC) -----------------
echo Toggling Hybrid Sleep (Plugged In)...
if "!hybrid_ac:~-1!"=="1" (
    REM Current setting is ON, toggle to OFF.
    powercfg /setacvalueindex !scheme! 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 0
) else (
    REM Current setting is OFF, toggle to ON.
    powercfg /setacvalueindex !scheme! 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 1
)
REM Reapply the power scheme to apply changes.
powercfg /setactive !scheme!
goto MENU

:EXIT
:: ------------- Exit the Script ------------------------
cls
echo ***********************************************
echo **      Exiting Hybrid Sleep Control Panel   **
echo ***********************************************
endlocal
exit /B
