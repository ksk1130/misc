param(
    [string]$s3path    # �����Ώۃp�X
)

# �G���[�����������_�ŏ����I��
$ErrorActionPreference = "stop"

function script:Main($filepath) {
    # �����`�F�b�N
    if ($s3path -eq "") {
        Write-Host "S3�p�X����͂��Ă�������"
        exit 1
    }

    # awscli�̑��ۊm�F
    Get-Command aws -ea SilentlyContinue | Out-Null
    if ($? -eq $false) {
        # awscli�R�}���h�����݂��Ȃ����(=awscli���C���X�g�[���Ȃ��)�I��
        Write-Host "awscli���C���X�g�[�����Ă�������"
        exit 1
    }

    aws s3 ls $s3path --recursive --human-readable --summarize | `
    %{ 
         #$filename = $_.substring($_.lastindexof(" ") + 1, $_.Length - $_.lastindexof(" ") -1)
         #$s3path + $filename
         $_
    }
    
}

Main $filepath
