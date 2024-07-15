cd /d %~dp0
set time_tmp=%time: =0%
REM 日時をYYYYMMDDhhmm形式で取得
set dt=%date:/=%%time_tmp:~0,2%%time_tmp:~3,2%

REM 残す世代数。現在取得中のファイルを含んだ世代数を指定する
set GEN=3
REM 取得間隔。1分おきなら60を指定
set INTERVAL_SEC=60
REM 取得回数。60秒間隔で1日中取得すると、1日に24*60=1440回
set COUNT_POINTS=1440

REM GEN-1を残すファイル数として変数に設定
set TEMP_GEN=%GEN%-1

REM GEN世代管理として古いファイルを削除。
for /f "skip=%TEMP_GEN%" %%a in ('dir /b /o-d *.blg') do del %%a

REM INTERVAL_SEC秒間隔で1日中取得する。
typeperf -cf CounterItems.txt -si %INTERVAL_SEC% -sc %COUNT_POINTS% -f bin -o counter_%dt%.blg

exit 0
