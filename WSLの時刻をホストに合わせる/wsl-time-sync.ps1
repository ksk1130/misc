# rancher-desktopをデフォルトディストリビューションに設定する
Write-host rancher-desktopをデフォルトディストリビューションに設定します
wsl.exe -s rancher-desktop

# 現在のホストの時刻と、WSLの時刻を表示する
Write-host 現在のホストの時刻と、WSLの時刻を表示します
Get-Date -Format $rfc3339;  wsl date

# 空行を出力
Write-host ""

# HWクロックをホストと同期する
Write-host HWクロックをホストと同期します
wsl.exe -u root hwclock -s

# 空行を出力
Write-host ""

# 現在のホストの時刻と、WSLの時刻を表示する
Write-host 現在のホストの時刻と、WSLの時刻を表示します
Get-Date -Format $rfc3339;  wsl date
