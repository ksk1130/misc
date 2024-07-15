@echo off
setlocal

:: �f�[�^�R���N�^�[�Z�b�g�̖��O(�f�[�^�R���N�^�[�Z�b�g�����ʂ��閼�O)
set DCS_NAME=NewDCS

:: �f�[�^�R���N�^�[�̖��O(���O�t�@�C���̐ړ���)
set DC_NAME=NewDC

:: �T���v���Ԋu�i�b�j
set SAMPLE_INTERVAL=15

:: �Ǘ��Ҍ����Ŏ��s����Ă��Ȃ��ꍇ�͌x���\�����ďI��
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo �Ǘ��Ҍ����Ŏ��s���Ă�������
  goto :eof
)

:: �e�ϐ��̓��e��\��
echo �f�[�^�R���N�^�[�Z�b�g�̖��O: %DCS_NAME%
echo �f�[�^�R���N�^�[�̖��O: %DC_NAME%
echo �T���v���Ԋu: %SAMPLE_INTERVAL% �b
echo ���O�t�@�C���̏o�͐�: %~dp0%DC_NAME%

:: counters.txt�̓��e��\��
echo �擾�Ώۂ̃p�t�H�[�}���X�J�E���^�[(counters.txt):
type counters.txt
echo.

:: �f�[�^�R���N�^�[�Z�b�g�̍쐬
logman create counter %DCS_NAME% -o "%~dp0\%DC_NAME%" -f csv -si %SAMPLE_INTERVAL% -cf "%~dp0\counters.txt"

:: �f�[�^�R���N�^�[�Z�b�g�̊J�n
echo �f�[�^�R���N�^�[�Z�b�g���J�n����ꍇ�́A�Ǘ��Ҍ����Łulogman start %DCS_NAME%�v�����s���Ă�������

endlocal

pause
