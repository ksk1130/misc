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



```python
# boto2
# -*- coding:utf8 -*-

import boto.logs
import time

def put_message(logs,message):
    res = logs.describe_log_streams(
        log_group_name='LogGroupTest',
        log_stream_name_prefix='LogStreamTest'
    )
    seq_token = res['logStreams'][0]['uploadSequenceToken']

    res = logs.put_log_events(
        log_group_name='LogGroupTest',
        log_stream_name='LogStreamTest',
        log_events=[
            {
                'timestamp': int(time.time()) * 1000,
                'message': '%s' % (message)
            },
        ],
        sequence_token=seq_token
    )

if __name__ == '__main__':
    logs = boto.logs.connect_to_region('ap-northeast-1')

    put_message(logs,'Message from boto2')
```

## EMRからのメッセージ投稿

```python
# -*- coding:utf8 -*-

import boto.logs
import time

from pyspark.sql import SparkSession

def put_log(logs_client, message):
    res = logs_client.describe_log_streams(
        log_group_name='LogGroupTest',
        log_stream_name_prefix='LogStreamTest'
    )
    seq_token = res['logStreams'][0]['uploadSequenceToken']

    res = logs_client.put_log_events(
        log_group_name='LogGroupTest',
        log_stream_name='LogStreamTest',
        log_events=[
            {
                'timestamp': int(time.time()) * 1000,
                'message': '%s' % (message)
            },
        ],
        sequence_token=seq_token
    )

def main(logs_client):

    spark = SparkSession \
    .builder \
    .enableHiveSupport() \
    .getOrCreate()

    df = spark.sql("SELECT * FROM postal_db.p_postal_csv")
    message = "count: {}".format(df.count())

    df = spark.sql("select prefecture_kanji,count(*) from postal_db.p_postal_csv group by prefecture_kanji order by prefecture_kanji")
    message = "{}".format(df.rdd.take(10))
    put_log(logs_client,message)


if __name__ == '__main__':
    logs_client = boto.logs.connect_to_region('ap-northeast-1')
    main(logs_client)
```

