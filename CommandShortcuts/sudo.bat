@echo off
rem https://qiita.com/so_nkbys/items/47e32cbda6bb794c1cb6
powershell start-process cmd -verb runas -ArgumentList '/k ""cd /d %CD%""'