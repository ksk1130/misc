@echo off 

set /p choice=�ݒ��I�� (1:�Z�b�g�A�b�v�X�N���v�g���g��, 2:�v���L�V�T�[�o���g��, 3:�v���L�V�ݒ���N���A����):

set pac=http://hoge.com/proxy.pac
set proxy=proxy.hoge.com
set port=8080
set exception=*.hoge.com;*.fuga.com

if %choice%==1 (
    echo �Z�b�g�A�b�v�X�N���v�g�𗘗p���܂�
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /t REG_SZ /d "%pac%" /f
) else if %choice%==2 (
    echo �v���L�V�T�[�o�𗘗p���܂�
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /f
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "%proxy%:%port%" /f
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "%exception%" /f
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f
) else if %choice%==3 (
    echo �v���L�V�ݒ���N���A���܂�
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /f
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /f
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /f
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
) else (
    echo 1,2,3�̂����ꂩ����͂��Ă��������B
)

pause
