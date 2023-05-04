@echo off 

set /p choice=設定を選択 (1:セットアップスクリプトを使う, 2:プロキシサーバを使う, 3:プロキシ設定をクリアする):

set pac=http://hoge.com/proxy.pac
set proxy=proxy.hoge.com
set port=8080
set exception=*.hoge.com;*.fuga.com

if %choice%==1 (
    echo セットアップスクリプトを利用します
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /t REG_SZ /d "%pac%" /f
) else if %choice%==2 (
    echo プロキシサーバを利用します
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /f
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "%proxy%:%port%" /f
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "%exception%" /f
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f
) else if %choice%==3 (
    echo プロキシ設定をクリアします
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /f
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /f
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /f
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
) else (
    echo 1,2,3のいずれかを入力してください。
)

pause
