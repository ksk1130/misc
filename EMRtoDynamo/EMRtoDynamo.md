#  EMR to Dynamo

## 段取り

1. 用語確認
2. awscliからDynamo
3. boto3からDynamo
4. EMRからDynamo

## 1.用語確認
|用語      | RDBMS                                         | DynamoDB     |
| :--------| :-------------------------------------------- | :------------|
|表        | Table                                         | Table        |
|行        | Row                                           | Item         |
|列        | Column                                        | Attributes   |
|主キー    | Primary Key                                   | Partition Key|
|ソートキー| 指定する場合はPrimary Keyを構成する一部になる | Sort Key     |

## 2.awscliからDynamo

### テーブル一覧

```bash
aws dynamodb --region ap-northeast-1 list-tables
```

### テーブル作成

```
(後ほど)
```



### データ投入

```bash
aws dynamodb put-item --table-name test_tbl --item '{ "item_id": { "S": "abc123" }, "date_mod": { "S": "1950-6-22" }, "name": { "S": "足利" } }'
```

### データ検索

```bash
aws dynamodb --region ap-northeast-1 scan --table-name test_tbl
```

### データ削除

```
(後ほど)
```



### テーブル削除

```
(後ほど)
```



## boto2からDynamo

### テーブル一覧

```python
# -*- coding:utf8 -*-

import boto
from boto.dynamodb2.layer1 import DynamoDBConnection

def tables():
    conn = boto.dynamodb2.connect_to_region(
    'ap-northeast-1'
    )
    tables = conn.list_tables()

    return tables

if __name__ == '__main__':
    res = tables()
    print(res)
```



### テーブル作成

```
(あとで)
```



### データ投入

```python
# -*- coding:utf8 -*-

import boto
from boto.dynamodb2.table import Table
from boto.dynamodb2.layer1 import DynamoDBConnection

def put_item(item_id, title,str_date):
    conn = boto.dynamodb2.connect_to_region(
    'ap-northeast-1'
    )

    table = Table('test_tbl', connection = conn)
    response = table.put_item(
       data={
            'item_id': item_id,
            'title': title,
            'str_date': str_date,
        }
    )
    return response

if __name__ == '__main__':
    movie_resp = put_item("item_001","The Big New Movie",
            "2021-04-19 23:20:00")
    print("Put item succeeded:")
```



### データ検索

```
後ほど
```



### データ削除

```
後ほど
```



### テーブル削除

```
後ほど
```



## 4. EMRからDynamo

### boto3のインストール（ブートストラップアクション）

```
(いったん後で)
```



### データ投入（boto2から）

```python
# -*- coding:utf8 -*-

import boto
from boto.dynamodb2.table import Table
from boto.dynamodb2.layer1 import DynamoDBConnection
from datetime import datetime as dt

from pyspark.sql import SparkSession

def put_item(item_id, count,str_date):
    conn = boto.dynamodb2.connect_to_region(
    'ap-northeast-1'
    )

    table = Table('test_tbl', connection = conn)
    response = table.put_item(
       data={
            'item_id': item_id,
            'count': count,
            'str_date': str_date,
        }
    )
    return response

def main():
    items_csv = "s3://target_bucket/postal_csv/ken_all.csv"

    spark = SparkSession\
          .builder\
          .getOrCreate()

    df = spark.read\
      .format("csv")\
      .load(items_csv)

    # CSVの行数を取得
    count = df.count()

    # 日付を文字列に変換
    tdatetime = dt.now()
    tstr = tdatetime.strftime('%Y/%m/%d %H:%M:%S')

    res = put_item("item_002",count,
            tstr)
    print("Put item succeeded:")


if __name__ == '__main__':
    main()
```

