# Cloudwatch検証

## 検証テーマ

- 用語確認
- cliからのメッセージ投稿
- boto2(3)からのメッセージ投稿
- EMRからのメッセージ投稿

## 用語確認

### ロググループ

- ログストリームの集まり

- EC2みたいな

### ログストリーム

- 複数のログイベントで構成

- モニタリングしているリソースごと（EC2ならインスタンス毎など)

## CLIからのメッセージ投稿
### ロググループの作成

```
LogGroupTest
```



### ログストリームの作成

```
LogStreamTest
```

### CLIからのメッセージ投稿

```
# Linux用
aws logs put-log-events --log-group-name "LogGroupTest" --log-stream-name "LogStreamTest" --log-events timestamp=$(date +%s)000,message='Hello1'
# どうやらunixtime*1000がミソ

# timestampはunixtimeなので、Powershellでunixtimeを生成する
((Get-Date("2021/4/12 00:47:00")) - (Get-Date("1970/1/1 0:0:0 GMT"))).TotalSeconds
```

  

[awscliからログを投稿する方法]: https://dev.classmethod.jp/articles/cloudwatch-logs-put-test-log/

## boto2(3)からのメッセージ投稿

```python
# boto3
# -*- coding:utf8 -*-

import boto3
import time

def main(message):
    session = boto3.Session(region_name="ap-northeast-1")
    logs_client   = session.client("logs", region_name="ap-northeast-1")

    res = logs_client.describe_log_streams(
        logGroupName='LogGroupTest',
        logStreamNamePrefix='LogStreamTest',
    )
    seq_token = res['logStreams'][0]['uploadSequenceToken']

    res = logs_client.put_log_events(
        logGroupName='LogGroupTest',
        logStreamName='LogStreamTest',
        logEvents=[
            {
                'timestamp': int(time.time()) * 1000,
                'message': '%s' % (message)
            },
        ],
        sequenceToken=seq_token
    )

if __name__ == '__main__':
    main("Message from boto3")
```

