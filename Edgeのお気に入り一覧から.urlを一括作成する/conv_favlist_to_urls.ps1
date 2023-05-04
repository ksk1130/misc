# 各種パラメータ
param(
    [string]$input_favofite_list_path, # エクスポートしたお気に入りの格納パス(ファイル名含む)
    [string]$output_urls_path          # .urlファイルを出力するフォルダのパス
)

# 変数宣言を強制
set-psdebug -strict

# メイン処理
function script:Main($input_favofite_list_path, $output_urls_path) {
    try {
        # エクスポートしたHTMLはパースが難しいため、正規表現で<A HREF="***(1)">***(2)</A>の(1)、(2)を抽出する
        $content = Get-Content -LiteralPath $input_favofite_list_path -Encoding UTF8

        $regex = "<A HREF=""(.+?)"" (.+?)>(.*?)<\/A>"
        $matched = [regex]::Matches($content, $regex)
        
        foreach ($matched_item in $matched) {
            $item_url = $matched_item.Groups[1].Value
            $item_name = $matched_item.Groups[3].Value
    
            #お気に入り名をファイル名とするため、ファイル名に利用できない文字を置換
            $item_name = $item_name.Replace("\\", "-")
            $item_name = $item_name.Replace("/", "-")
            $item_name = $item_name.Replace(":", "-")
            $item_name = $item_name.Replace("*", "-")
            $item_name = $item_name.Replace("?", "-")
            $item_name = $item_name.Replace("""", "-")
            $item_name = $item_name.Replace("<", "-")
            $item_name = $item_name.Replace(">", "-")
            $item_name = $item_name.Replace("|", "-")

            # ファイル名は***(お気に入り名).urlとする
            $output_file_name = $item_name + ".url"
            
            $output_file_path = Join-Path $output_urls_path $output_file_name
            $output_url_item = "URL=" + $item_url
            
            # .urlファイルの中身は以下のようになっているため、以下のようなファイルを生成する
            #[InternetShortcut]
            #URL=***(URL)

            Set-Content -LiteralPath $output_file_path "[InternetShortcut]"
            Add-Content -LiteralPath $output_file_path $output_url_item

            Write-Host "作成完了しました:$output_file_path"
        }
    }
    catch {
        Write-Output "*** エラーが発生しました ***"
        Write-Output $_
    }
}

Main $input_favofite_list_path $output_urls_path
