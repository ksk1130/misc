# rancher-desktop���f�t�H���g�f�B�X�g���r���[�V�����ɐݒ肷��
Write-host rancher-desktop���f�t�H���g�f�B�X�g���r���[�V�����ɐݒ肵�܂�
wsl.exe -s rancher-desktop

# ���݂̃z�X�g�̎����ƁAWSL�̎�����\������
Write-host ���݂̃z�X�g�̎����ƁAWSL�̎�����\�����܂�
Get-Date -Format $rfc3339;  wsl date

# ��s���o��
Write-host ""

# HW�N���b�N���z�X�g�Ɠ�������
Write-host HW�N���b�N���z�X�g�Ɠ������܂�
wsl.exe -u root hwclock -s

# ��s���o��
Write-host ""

# ���݂̃z�X�g�̎����ƁAWSL�̎�����\������
Write-host ���݂̃z�X�g�̎����ƁAWSL�̎�����\�����܂�
Get-Date -Format $rfc3339;  wsl date
