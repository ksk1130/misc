param(
    [string]$s3path    # 処理対象パス
)

# エラーがあった時点で処理終了
$ErrorActionPreference = "stop"

function script:Main($filepath) {
    # 引数チェック
    if ($s3path -eq "") {
        Write-Host "S3パスを入力してください"
        exit 1
    }

    # awscliの存否確認
    Get-Command aws -ea SilentlyContinue | Out-Null
    if ($? -eq $false) {
        # awscliコマンドが存在しなければ(=awscli未インストールならば)終了
        Write-Host "awscliをインストールしてください"
        exit 1
    }

    # パスの末尾が"/"でなければ"/"を追加する(末尾"/"がないとファイル扱いになるため)
    if ( $s3path.Substring($s3path.Length - 1) -ne "/") {
        $s3path = $s3path + "/"
    }

    aws s3 ls $s3path --recursive --human-readable --summarize | `
    %{ 
         #$filename = $_.substring($_.lastindexof(" ") + 1, $_.Length - $_.lastindexof(" ") -1)
         #$s3path + $filename
         $_
    }
    
}

Main $filepath
