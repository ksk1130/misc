param(
    [string]$s3path    # 処理対象パス
)

# エラーがあった時点で処理終了
$ErrorActionPreference = "stop"

function script:convertStdOutToArray($stdout) {
    # \rを削除
    $stdout1 = $stdout.Replace("`r", "")
    # \nで分割して文字列配列化
    $stdout2 = $stdout1.Split("`n")
    
    return $stdout2
}

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

    try {
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = "aws.exe"
        $pinfo.RedirectStandardError = $true
        $pinfo.RedirectStandardOutput = $true
        $pinfo.UseShellExecute = $false
        $pinfo.Arguments = "s3 ls " + $s3path
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        $p.Start() | Out-Null
        $p.WaitForExit()
        $stdout = $p.StandardOutput.ReadToEnd()
        $stderr = $p.StandardError.ReadToEnd()

        $exitCode = $p.ExitCode

        #Write-Host "stdout:" $stdout
        #Write-Host "stderr:" $stderr
        #Write-Host "exitcode:" $exitCode

        if ($exitCode -ne 0) {
            # クレデンシャルエラー
            if ($stderr -match "SignatureDoesNotMatch") {
                Write-Host "正しい認証情報を設定してください"
                exit $exitCode
            }

            # パスに該当する結果なし
            if ($stdout -eq "" -and $stderr -eq "" -and $exitCode -eq 1) { 
                Write-Host "引数に対応するパスが存在しません"
                exit $exitCode
            }

            # 上記以外であればメッセージを表示して終了
            Write-Host $stderr
            exit $exitCode
        }

        $lsArray = convertStdOutToArray $stdout

        for ($i = 0; $i -lt $lsArray.Length; $i++) {

            $splittedArray = $lsArray[$i].split(" ")

            # 配列の要素から""を削除
            $arrayWithoutEmpty = @()

            for ($j = 0; $j -lt $splittedArray.Length; $j++) {
                if ($splittedArray[$j] -ne "") {
                    $arrayWithoutEmpty += $splittedArray[$j]
                }
            }

            # 配列の要素数が2ならディレクトリ(配下にさらに要素あり)
            if ( $arrayWithoutEmpty.Length -eq 2) {
                $joined = $s3path + $arrayWithoutEmpty[1]
                Write-Host "ディレクトリです：" $joined
            }


            # 配列の要素数が4ならファイル(配下に要素なし)
            if ( $arrayWithoutEmpty.Length -eq 4) {
                $joined = $s3path + $arrayWithoutEmpty[3]
                Write-Host "ファイルです：" $joined
            }
        }
    }
    finally {
        $p.Dispose()
    }

}

Main $filepath
