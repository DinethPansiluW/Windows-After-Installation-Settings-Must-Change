
@echo off
rem — Define your services and display names here —
set numServices=11

set services[1]=Spooler
set names[1]=Print Spooler
set desc[1]=Manages print jobs; disabling stops all printing.

set services[2]=SysMain
set names[2]=SysMain
set desc[2]=Preloads apps into memory; disabling may reduce disk usage.

set services[3]=wuauserv
set names[3]=Windows Update
set desc[3]=Windows Update; disabling stops automatic updates.

set services[4]=W32Time
set names[4]=Windows Time
set desc[4]=Time synchronization; disabling may desync clock.

set services[5]=Schedule
set names[5]=Task Scheduler
set desc[5]=Scheduled tasks engine; disabling breaks scheduled jobs.

set services[6]=WerSvc
set names[6]=Error Reporting
set desc[6]=Error reporting; disabling stops crash reports.

set services[7]=TermService
set names[7]=Remote Desktop
set desc[7]=Remote Desktop; disabling blocks RDP.

set services[8]=WinDefend
set names[8]=Windows Defender
set desc[8]=Antivirus protection; disabling removes real-time AV.

set services[9]=BITS
set names[9]=BITS
set desc[9]=Background file transfers; disabling may break downloads.

set services[10]=WSearch
set names[10]=Windows Search
set desc[10]=Indexing/search; disabling slows search.

set services[11]=HyperV
set names[11]=Launch Hyper-V
set desc[11]=Disabing may can't run virtual matchines.
