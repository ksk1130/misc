@echo off

REM スクリプトのパスを取得(末尾に\あり)
set SCRIPT_PATH=%~dp0

Powershell.exe -executionpolicy remotesigned -File %SCRIPT_PATH%wsl-time-sync.ps1

PAUSE
