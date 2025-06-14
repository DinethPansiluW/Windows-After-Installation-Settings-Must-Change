@echo off
setlocal

:: Get the current Windows edition
for /f "tokens=2 delims==" %%I in ('"wmic os get caption /value | findstr Caption"') do set "win_edition=%%I"
echo Detected Windows Edition: %win_edition%

:: Convert to lowercase and remove spaces for easy matching
set "edition=%win_edition: =%"
set "edition=%edition:~0,30%"
set "edition=%edition:~0,30%"
set "edition=%edition:Windows%"
set "edition=%edition:windows=%"
set "edition=%edition:Windows=%"
set "edition=%edition:Windows10=%"
set edition=%edition:"=%

:: Assign key based on edition
set "key="

if /i "%win_edition%"=="Windows 10 Home" set "key=TX9XD-98N7V-6WMQ6-BX7FG-H8Q99"
if /i "%win_edition%"=="Windows 10 Home N" set "key=3KHY7-WNT83-DGQKR-F7HPR-844BM"
if /i "%win_edition%"=="Windows 10 Home Single Language" set "key=7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH"
if /i "%win_edition%"=="Windows 10 Home China" set "key=PVMJN-6DFY6-9CCP6-7BKTT-D3WVR"
if /i "%win_edition%"=="Windows 10 Professional" set "key=W269N-WFGWX-YVC9B-4J6C9-T83GX"
if /i "%win_edition%"=="Windows 10 Professional N" set "key=MH37W-N47XK-V7XM9-C7227-GCQG9"
if /i "%win_edition%"=="Windows 10 Education" set "key=NW6C2-QMPVW-D7KKK-3GKT6-VCFB2"
if /i "%win_edition%"=="Windows 10 Education N" set "key=2WH4N-8QGBV-H22JP-CT43Q-MDWWJ"
if /i "%win_edition%"=="Windows 10 Enterprise" set "key=NPPR9-FWDCX-D2C8J-H872K-2YT43"
if /i "%win_edition%"=="Windows 10 Enterprise N" set "key=DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4"

if "%key%"=="" (
    echo Edition not recognized or not supported in this script.
    pause
    exit /b
)

:: Uninstall current product key
echo Removing existing product key...
slmgr.vbs /upk

:: Install new key
echo Installing key: %key%
slmgr /ipk %key%

:: Set KMS server
echo Setting KMS server to zh.us.to
slmgr /skms zh.us.to

:: Activate Windows
echo Activating...
slmgr /ato

echo Done.
pause
