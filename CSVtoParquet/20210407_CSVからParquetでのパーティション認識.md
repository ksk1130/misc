# CSV→Parquetにおいて、CSVの右端列以外の列がパーティション列の時に、なるべく苦労なくParquet化とパーティション化ができるのか

## 段取り

### 元ネタのCSVデータ作成

| 商品     | 年月   | 年月日   | 価格  | 色     |
| -------- | ------ | -------- | ----- | ------ |
| バット   | 202104 | 20210401 | 10000 | silver |
| グローブ | 202104 | 20210403 | 15000 | brown  |
| ボール   | 202103 | 20210323 | 300   | white  |



### GCDのデータベース作成

```sh
testdb0407
```



###  S3のフォルダ作成

```sh
targetbucket/testdb0407/csv
targetbucket/testdb0407/pq
```



### GCD用のテーブル作成(CSV)→パーティションなし

```sql
create external table testdb0407.items_csv (
    item_name string,
    regist_ym string,
    regist_ymd string,
    item_value int,
    item_color string
)
ROW FORMAT SerDe 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
'field.delim' = ','
)
LOCATION 's3://targetbucket/testdb0407/csv/'
TBLPROPERTIES (
'serialization.encoding'='SJIS'
);
```



### GCD用のテーブル作成(Parquet) → パーティションあり(右端以外の列で)

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS testdb0407.items_pq (
    item_name string,
    regist_ymd string,
    item_value int,
    item_color string
)
partitioned by (
    regist_ym string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
)
LOCATION 's3://targetbucket/testdb0407/pq/';
```



### PySparkでCSV→Parquet化するスクリプトを書く

```python
# スクリプト test.py
from pyspark.sql import SparkSession

spark = SparkSession \
    .builder \
    .enableHiveSupport() \
    .getOrCreate()

# Fail...
#df = spark.sql("insert overwrite table testdb0407.items_pq select * from testdb0407.items_csv")
#df = spark.sql("insert overwrite table testdb0407.items_pq select item_name,regist_ymd,item_value,item_color,regist_ym from testdb0407.items_csv")
#df = spark.sql("insert overwrite table testdb0407.items_pq select item_name,regist_ymd,item_value,item_color from testdb0407.items_csv")

# Success
#df = spark.sql("insert overwrite table testdb0407.items_pq partition(regist_ym='202104') select item_name,regist_ymd,item_value,item_color from testdb0407.items_csv")

# ↓3行ワンセットで成功
#spark.sql("set hive.exec.dynamic.partition = true")
#spark.sql("set hive.exec.dynamic.partition.mode = nonstrict")
#df = spark.sql("insert overwrite table testdb0407.items_pq select item_name,regist_ymd,item_value,item_color,regist_ym from testdb0407.items_csv")

# ↓うまく働かなかった(右端の列がパーティションになってしまった)
spark.sql("set hive.exec.dynamic.partition = true")
spark.sql("set hive.exec.dynamic.partition.mode = nonstrict")
df = spark.sql("insert overwrite table testdb0407.items_pq select * from testdb0407.items_csv")

df2 = spark.sql("select * from testdb0407.items_pq")
df2.show()
```

### 結果確認

今取り組まれているCSV→Parquet変換処理は、Hive(HadoopのSQLインタフェース)の
「動的パーティション」機能を使っている。動的パーティション機能を利用する場合には、
パーティション列は右端(一番最後)に指定される必要がある、とのこと

・結論
insert overwrite table parquet_table select * from csv_table
↑のようにselect * としたければ、データの右端がパーティション列である必要あり
　つまり、CSVファイルの右端列がパーティション列(prac_ym)である必要あり

・回避策(美しくないですが...)
insert overwrite table parquet_table select col1,col2,... partition_col from csv_table のように、
selectでカラム名を列挙し、パーティション列を右端に指定する。
この場合、CSVファイルの途中にprac_ymが入っていてもOKだが、
select col1,col2,...のように列名を1つ1つ指定する必要が生じる...

参考にしたURL
https://tagomoris.hatenablog.com/entry/20141114/1415938647
https://www.it-mure.jp.net/ja/hadoop/spark-hive%E3%81%AE%E5%8B%95%E7%9A%84%E3%83%91%E3%83%BC%E3%83%86%E3%82%A3%E3%82%B7%E3%83%A7%E3%83%B3%E3%83%86%E3%83%BC%E3%83%96%E3%83%AB%E3%81%A8%E3%81%97%E3%81%A6%E3%81%AE%E3%83%87%E3%83%BC%E3%82%BF%E3%83%95%E3%83%AC%E3%83%BC%E3%83%A0/1054535346/

### 後片付け

