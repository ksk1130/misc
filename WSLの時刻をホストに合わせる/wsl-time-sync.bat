@echo off

REM �X�N���v�g�̃p�X���擾(������\����)
set SCRIPT_PATH=%~dp0

Powershell.exe -executionpolicy remotesigned -File %SCRIPT_PATH%wsl-time-sync.ps1

PAUSE
