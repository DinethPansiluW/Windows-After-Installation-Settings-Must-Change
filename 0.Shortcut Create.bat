@echo off

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

:: Set ANSI color escape codes
set "GREEN=[1;32m"
set "GREENU=[4;32m"
set "RED=[91m"
set "ORANGE=[33m"
set "RESET=[0m"
set "PINK=[3;35m"
set "SKYBLUE=[96m"

setlocal

:: Get script folder path and name
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
for %%F in ("%SCRIPT_DIR%") do set "FOLDER_NAME=%%~nxF"

:: Define desktop path and shortcut path
set "DESKTOP_PATH=%USERPROFILE%\Desktop"
set "SHORTCUT_NAME=- %FOLDER_NAME%"
set "VBS_FILE=%TEMP%\create_folder_shortcut.vbs"

:: Create VBScript to make the shortcut
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%VBS_FILE%"
echo sLinkFile = oWS.ExpandEnvironmentStrings("%DESKTOP_PATH%\%SHORTCUT_NAME%.lnk") >> "%VBS_FILE%"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%VBS_FILE%"
echo oLink.TargetPath = "%SCRIPT_DIR%" >> "%VBS_FILE%"
echo oLink.WindowStyle = 1 >> "%VBS_FILE%"
echo oLink.Save >> "%VBS_FILE%"

:: Run VBScript
cscript //nologo "%VBS_FILE%"

:: Clean up
del "%VBS_FILE%"


echo.
echo.
echo Shortcut to folder "%SHORTCUT_NAME%" created on Desktop.

echo.
echo %GREEN%Done....
echo. 
echo.

timeout /t 3 /nobreak >nul

exit