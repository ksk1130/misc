#!/usr/bin/bash

set -eu -o pipefail

# sarの結果をテキストファイルに出力する
# 引数1(必須): sarファイルのパス(例: /var/log/sa)
# 引数2(必須): テキストファイルのパス(例: /tmp)
# 引数3(必須): sar取得対象日付(YYYYMMDD)
# 引数4(任意): sar取得対象時間(Start)(HHMMSS)
# 引数5(任意): sar取得対象時間(End)(HHMMSS)

# sarコマンドの存否確認。sarコマンドがなければ終了する
which sar > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "sarコマンドがありません。"
  exit 1
fi

# 引数チェック
# 引数が3未満であれば終了
if [ $# -lt 3 ]; then
  echo "引数が足りません。"
  echo "Usage: $0 sarファイルのパス(/var/log/sa) テキストファイルのパス(/tmp) sar取得対象日付(YYYYMMDD) [sar取得対象時間(Start)(HHMMSS)] [sar取得対象時間(End)(HHMMSS)]"
  exit 1
fi

# YYYYMMDDからDDを日付を取得する
DATE_OF_MONTH=`echo $3 | cut -c 7-8`

# sarをテキストファイルに出力する
# 引数の数が3つの場合
if [ $# -eq 3 ]; then
  # ファイル名はsar_$HOSTNAME_YYYYMMDD.txtとする
  filename="sar_${HOSTNAME}_$3.txt"
  echo ファイル名:${filename}

  LC_ALL=C sar -A -f $1/sa${DATE_OF_MONTH} > $2/${filename}
fi

# 引数の数が5つの場合
if [ $# -eq 5 ]; then
  # HHMMSSをHH:MM:SSに変換する
  START_TIME=`echo $4 | sed -e 's/\(..\)\(..\)\(..\)/\1:\2:\3/'`
  END_TIME=`echo $5 | sed -e 's/\(..\)\(..\)\(..\)/\1:\2:\3/'`

  # ファイル名はsar_$HOSTNAME_YYYYMMDD_HHMMSS_HHMMSS.txtとする
  filename="sar_${HOSTNAME}_$3_$4_$5.txt"
  echo ファイル名:${filename}

  LC_ALL=C sar -A -f $1/sa${DATE_OF_MONTH} -s ${START_TIME} -e ${END_TIME} > $2/${filename}
fi

echo kSar5.06ではkbhugreeを処理できないため、別途削除してください

exit 0
