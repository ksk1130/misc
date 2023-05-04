#!/usr/bin/bash

set -euo pipefail

# Get the date and time(yyyymmddhhmmss)
DATETIME=$(date +%Y%m%d%H%M%S)
echo $DATETIME

# ファイル名に識別文字列を付与したい場合は、suffixに値を設定する
suffix=hoge

# suffixが定義されている場合は、ファイル名に付与する
if [ -n "$suffix" ]; then
    FILENAME="$(hostname)_${DATETIME}_${suffix}.txt"
else
    FILENAME="$(hostname)_${DATETIME}.txt"
fi

echo $FILENAME

touch $FILENAME

echo "ホスト名・実行日時================================" >> $FILENAME 
hostname       >> $FILENAME
date           >> $FILENAME
echo           >> $FILENAME
echo "ファイルシステム別利用状況========================" >> $FILENAME
df -hT --total >> $FILENAME
echo           >> $FILENAME
echo "ファイルシステム別node利用状況====================" >> $FILENAME
df -i --total  >> $FILENAME
