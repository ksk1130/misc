# パーテション列は右端限定か検証
[TOC]

## 目的

パーテション列は右端でなくてはならないのか、列追加の場合はどうなるのかを検証。また、parquetは列定義とファイルの内容が連動していなくても問題ないことを確認する。

## 手順

### 1. 元ネタのCSVデータ作成(SJISで作成)

| 商品(item_name) | 年月( regist_ym,partition_key) | 年月日(regist_ymd) | 価格(item_value) | 色(item_color) |
| --------------- | ------------------------------ | ------------------ | ---------------- | -------------- |
| バット          | 202104                         | 20210401           | 10000            | silver         |
| グローブ        | 202104                         | 20210403           | 15000            | brown          |
| ボール          | 202103                         | 20210323           | 300              | white          |

### 2. GCDのデータベース作成

```sh
testdb0407
```

###  3. S3のフォルダ作成

```sh
target_bucket/testdb0407/csv
target_bucket/testdb0407/pq
```



### 4. (CSV)GCD用のテーブル作成→パーティションなし

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
LOCATION 's3://target_bucket/testdb0407/csv/'
TBLPROPERTIES (
'serialization.encoding'='SJIS'
);
```



### 5. (Parquet)GCD用のテーブル作成 → パーティションあり(元ファイルの右端以外の列でパーティション列を定義する)

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
LOCATION 's3://target_bucket/testdb0407/pq/';
```



### 6. PySparkでCSV→Parquet化するスクリプトを書く

```python
# スクリプト test.py
# -*- coding:utf8 -*-

# スクリプト test.py
from pyspark.sql import SparkSession
from pyspark.sql.functions import col

spark = SparkSession \
    .builder \
    .enableHiveSupport() \
    .getOrCreate()

# Success
#df = spark.sql("insert overwrite table testdb0407.items_pq partition(regist_ym='202104') select item_name,regist_ymd,item_value,item_color from testdb0407.items_csv")

# ↓3行ワンセットで成功
spark.sql("set hive.exec.dynamic.partition = true")
spark.sql("set hive.exec.dynamic.partition.mode = nonstrict")
df = spark.sql("select * from testdb0407.items_csv")

# 右端にregist_ym列を追加(列名重複NGなので、いったん別名付与)
df = df.withColumn('regist_ym_temp',col("regist_ym"))
# 元の列を削除
df = df.drop("regist_ym")
# 列名をregist_ymに変更
df = df.withColumnRenamed('regist_ym_temp', 'regist_ym')
df.registerTempTable("items_csv2")
df.show()

df = spark.sql("insert overwrite table testdb0407.items_pq select * from items_csv2")

df2 = spark.sql("select * from testdb0407.items_pq")
df2.show()
```

### 7. 上記で出力されたParquetファイルの中身を確認(ParquetViewerで)

```bash
# Athenaでは右端にパーティション列が表示されるが、
# パーティション項目のregist_ymは含まれてない
item_name,regist_ymd,item_value,item_color
ボール,20210323,300,white
```

### 8. データフォーマットを変更したCSVを新たに作成する(SJIS) ※元のCSVは削除する

右端に列を追加する

| 商品(item_name) | 年月( regist_ym,partition_key) | 年月日(regist_ymd) | 価格(item_value) | 色(item_color) | 大きさ(item_size) |
| --------------- | ------------------------------ | ------------------ | ---------------- | -------------- | ----------------- |
| シャツ          | 202104                         | 20210402           | 13000            | black          | L                 |
| ハーフパンツ    | 202104                         | 20210404           | 12000            | green          | M                 |
| ソックス        | 202103                         | 20210326           | 3000             | red            | S                 |

### 9. (CSVテーブル)ALTER TABLEで列を追加する

```sql
-- テーブル名修飾したらNGだったので削除
ALTER TABLE items_csv ADD COLUMNS (item_size varchar(3));
```

### 10. Athenaで変更後のＣＳＶテーブルの内容を確認する(列と値のマッピングがなされているか)

```bash
# 列は右端に追加されたため、CSVファイルとのマッピングもうまくいった
"item_name","regist_ym","regist_ymd","item_value","item_color","item_size"
"シャツ","202104","20210402","13000","black","L"
"ハーフパンツ","202104","20210404","12000","green","M"
"ソックス","202103","20210326","3000","red","Sgr"
→alter tableで列を追加するなら右端に追加していく必要あり
→レイアウトを変えてよいなら、丸っとテーブル作り直しでもよさそう
```

### 11. (Parquetテーブル)ALTER TABLEで列を追加する

```sql
-- テーブル名修飾したらNGだったので削除
ALTER TABLE items_pq ADD COLUMNS (item_size varchar(3));
```

### 12. Athenaで変更後のParquetテーブルの内容を確認する(列と値のマッピングがなされているか)

```bash
# 列は右端に追加されたようだが、パーティション列が自動的に(？)右端に追加されたため、右から2番目に空値の列として表示される
"item_name","regist_ymd","item_value","item_color","item_size","regist_ym"
"バット","20210401","10000","silver",,"202104"
"グローブ","20210403","15000","brown",,"202104"
"ボール","20210323","300","white",,"202103"
```

### 13. 再度Parquetファイルの中身を見てみる

```bash
# 別のregist_ymのファイルを見てみた
item_name,regist_ymd,item_value,item_color
バット,20210401,10000,silver
→Parquetファイルの中身自体は変わってない。GDC側に定義が追加されただけ
```

### 14. PySparkでCSV→Parquet化するスクリプトを書く(その2)

```python
# スクリプト test.py
# -*- coding:utf8 -*-

from pyspark.sql import SparkSession
from pyspark.sql.functions import col

spark = SparkSession \
    .builder \
    .enableHiveSupport() \
    .getOrCreate()

# ↓3行ワンセットで成功
spark.sql("set hive.exec.dynamic.partition = true")
spark.sql("set hive.exec.dynamic.partition.mode = nonstrict")
df = spark.sql("select * from testdb0407.items_csv")

# 右端にregist_ym列を追加(列名重複NGなので、いったん別名付与)
df = df.withColumn('regist_ym_temp',col("regist_ym"))
# 元の列を削除
df = df.drop("regist_ym")
# 列名をregist_ymに変更
df = df.withColumnRenamed('regist_ym_temp', 'regist_ym')
df.registerTempTable("items_csv2")
df.show()

df = spark.sql("insert into table testdb0407.items_pq select * from items_csv2")

df2 = spark.sql("select * from testdb0407.items_pq")
df2.show()
```

### 15. 上記で出力されたParquetファイルの中身を確認(ParquetViewerで)

```bash
# Athenaでは右端にパーティション列が表示されるが、
# パーティション項目のregist_ymは含まれてない
# 追加したitem_sizeが右端に追加されている(右端に追加したからか)
item_name,regist_ymd,item_value,item_color,item_size
シャツ,20210402,13000,black,L
```

### 16.(Parquetテーブル)Athena側でParquetテーブルを確認してみる

```bash
# 見づらいが、item_sizeがある(新しい)データには値が、古いデータは空値で問い合わせできている
"item_name","regist_ymd","item_value","item_color","item_size","regist_ym"
"シャツ","20210402","13000","black","L","202104"
"ハーフパンツ","20210404","12000","green","M","202104"
"バット","20210401","10000","silver",,"202104"
"ソックス","20210326","3000","red","S","202103"
"グローブ","20210403","15000","brown",,"202104"
"ボール","20210323","300","white",,"202103"
```

### 17. (補足)新旧レイアウトが混在したCSVテーブルはAthenaでどう表示されるのか

```bash
# 見づらいが、item_sizeがある(新しい)データには値が、古いデータは空値で問い合わせできている
"item_name","regist_ym","regist_ymd","item_value","item_color","item_size"
"バット","202104","20210401","10000","silver",
"グローブ","202104","20210403","15000","brown",
"ボール","202103","20210323","300","whiterown",
"シャツ","202104","20210402","13000","black","L"
"ハーフパンツ","202104","20210404","12000","green","M"
"ソックス","202103","20210326","3000","red","Sgr" ←「gr」は謎
```

### 18. (補足2) 上記手順で生成したParquetファイルはそのままに、drop table → create table で列の並びを変更したらどうなるか？

```sql
drop table items_pq;

-- item_sizeをitem_valueとitem_colorの間に入れる
CREATE EXTERNAL TABLE IF NOT EXISTS testdb0407.items_pq (
    item_name string,
    regist_ymd string,
    item_value int,
    item_size varchar(3),
    item_color string
)
partitioned by (
    regist_ym string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = '1'
)
LOCATION 's3://target_bucket/testdb0407/pq/';

-- パーティションロードが必要な旨通知されたので、下記コマンドを実行
MSCK REPAIR TABLE items_pq;

-- 問い合わせ
select * from items_pq;
→Zero records returned.が返ってきた。元のテーブル定義でも変わらず...これ禁忌なのか...？
→ ...と思ったが、s3://target_bucket/testdb0407/に「pq」というファイルがあったせいでした(クローラが誤認したっぽい)
　削除したらうまく検出されました

-- このように、item_valueと、item_colorの間に、「item_size」が入っています
-- 古いデータは空値、新データは入力値が入っています
"item_name","regist_ymd","item_value","item_size","item_color","regist_ym"
"グローブ","20210403","15000",,"brown","202104"
"ボール","20210323","300",,"white","202103"
"バット","20210401","10000",,"silver","202104"
"ハーフパンツ","20210404","12000","M","green","202104"
"シャツ","20210402","13000","L","black","202104"
"ソックス","20210326","3000","S","red","202103"

-- CSVテーブルでは期待通りの結果が得られた
drop table items_csv;

-- CSVレイアウトの通りにテーブルを作成
create external table testdb0407.items_csv (
    item_name string,
    regist_ym string,
    regist_ymd string,
    item_value int,
    item_color string,
    item_size varchar(3)
)
ROW FORMAT SerDe 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
'field.delim' = ','
)
LOCATION 's3://target_bucket/testdb0407/csv/'
TBLPROPERTIES (
'serialization.encoding'='SJIS'
);

select * from items_csv;
```



## 得られた知見

1. AthenaでAlter tableすると右端に追加される
2. Parquetは新レイアウトと旧レイアウトが混在していても問題ない(名前で列とスキーマ情報を紐づけているから)
3. Parquetファイル内にはパーティション列情報は入ってない(GDC側で持っている)
4. Parquetについては、(パーティション列を除いて)列の並べ替え(Drop→Create)もOK

## 参考リンク

### ParquetViewer

[ParquetViewerV2.3.1](https://github.com/mukunku/ParquetViewer/releases/tag/v2.3.1)