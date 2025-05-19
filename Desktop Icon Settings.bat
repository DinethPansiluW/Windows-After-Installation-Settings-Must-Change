@echo off
:: This opens the Desktop Icon Settings dialog using Rundll32
start rundll32.exe shell32.dll,Control_RunDLL desk.cpl,,0
