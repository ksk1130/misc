@echo off
setlocal

:: データコレクターセットの名前(データコレクターセットを識別する名前)
set DCS_NAME=NewDCS

:: データコレクターの名前(ログファイルの接頭辞)
set DC_NAME=NewDC

:: サンプル間隔（秒）
set SAMPLE_INTERVAL=15

:: 管理者権限で実行されていない場合は警告表示して終了
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo 管理者権限で実行してください
  goto :eof
)

:: 各変数の内容を表示
echo データコレクターセットの名前: %DCS_NAME%
echo データコレクターの名前: %DC_NAME%
echo サンプル間隔: %SAMPLE_INTERVAL% 秒
echo ログファイルの出力先: %~dp0%DC_NAME%

:: counters.txtの内容を表示
echo 取得対象のパフォーマンスカウンター(counters.txt):
type counters.txt
echo.

:: データコレクターセットの作成
logman create counter %DCS_NAME% -o "%~dp0\%DC_NAME%" -f csv -si %SAMPLE_INTERVAL% -cf "%~dp0\counters.txt"

:: データコレクターセットの開始
echo データコレクターセットを開始する場合は、管理者権限で「logman start %DCS_NAME%」を実行してください

endlocal

pause
