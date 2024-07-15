# �e��p�����[�^
param(
    [string]$input_favofite_list_path, # �G�N�X�|�[�g�������C�ɓ���̊i�[�p�X(�t�@�C�����܂�)
    [string]$output_urls_path          # .url�t�@�C�����o�͂���t�H���_�̃p�X
)

# �ϐ��錾������
set-psdebug -strict

# ���C������
function script:Main($input_favofite_list_path, $output_urls_path) {
    try {
        # �G�N�X�|�[�g����HTML�̓p�[�X��������߁A���K�\����<A HREF="***(1)">***(2)</A>��(1)�A(2)�𒊏o����
        $content = Get-Content -LiteralPath $input_favofite_list_path -Encoding UTF8

        $regex = "<A HREF=""(.+?)"" (.+?)>(.*?)<\/A>"
        $matched = [regex]::Matches($content, $regex)
        
        foreach ($matched_item in $matched) {
            $item_url = $matched_item.Groups[1].Value
            $item_name = $matched_item.Groups[3].Value
    
            #���C�ɓ��薼���t�@�C�����Ƃ��邽�߁A�t�@�C�����ɗ��p�ł��Ȃ�������u��
            $item_name = $item_name.Replace("\\", "-")
            $item_name = $item_name.Replace("/", "-")
            $item_name = $item_name.Replace(":", "-")
            $item_name = $item_name.Replace("*", "-")
            $item_name = $item_name.Replace("?", "-")
            $item_name = $item_name.Replace("""", "-")
            $item_name = $item_name.Replace("<", "-")
            $item_name = $item_name.Replace(">", "-")
            $item_name = $item_name.Replace("|", "-")

            # �t�@�C������***(���C�ɓ��薼).url�Ƃ���
            $output_file_name = $item_name + ".url"
            
            $output_file_path = Join-Path $output_urls_path $output_file_name
            $output_url_item = "URL=" + $item_url
            
            # .url�t�@�C���̒��g�͈ȉ��̂悤�ɂȂ��Ă��邽�߁A�ȉ��̂悤�ȃt�@�C���𐶐�����
            #[InternetShortcut]
            #URL=***(URL)

            Set-Content -LiteralPath $output_file_path "[InternetShortcut]"
            Add-Content -LiteralPath $output_file_path $output_url_item

            Write-Host "�쐬�������܂���:$output_file_path"
        }
    }
    catch {
        Write-Output "*** �G���[���������܂��� ***"
        Write-Output $_
    }
}

Main $input_favofite_list_path $output_urls_path
