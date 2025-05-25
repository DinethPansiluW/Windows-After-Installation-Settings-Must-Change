@echo off
:: Opens “Change settings for the plan” for the active power scheme
start "" "%SystemRoot%\system32\control.exe" /name Microsoft.PowerOptions /page pagePlanSettings
