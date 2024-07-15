# EMRからAthenaのViewにアクセスする

[TOC]

## 段取り
1. S3にフォルダ作成
2. サンプルデータ登録
3. GlueDB作成
4. Athenaテーブル作成
5. AthenaView作成
6. EMRからAthenaViewにアクセス(ダメでした)
7. Glue側からViewを作る

## 1. S3にフォルダ作成

```bash
s3://targetbucket/wk_0427/tdfk
s3://targetbucket/wk_0427/kencho
```



## 2. サンプルデータ登録

```bash
# tdfk
1,北海道
2,青森県
3,岩手県
4,宮城県
5,秋田県
6,山形県

# kencho
1,札幌市
2,青森市
3,盛岡市
4,仙台市
5,秋田市
6,山形市
```



## 3. GlueDB作成

```bash
wk_0427
```



## 4. Athenaテーブル作成

```sql
# tdfk(utf8、ヘッダなし、クオートなし)
CREATE EXTERNAL TABLE wk_0427.tdfk (
tdfk_no int,
tdfk_name string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
LOCATION 's3://targetbucket/wk_0427/tdfk';

# kencho(utf8、ヘッダなし、クオートなし)
CREATE EXTERNAL TABLE wk_0427.kencho (
tdfk_no int,
kencho_name string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
LOCATION 's3://targetbucket/wk_0427/kencho';
```



## 5. AthenaView作成

```sql
create view tdfk_kencho as
select t.tdfk_no,t.tdfk_name,k.kencho_name from wk_0427.tdfk t inner join wk_0427.kencho k on t.tdfk_no = k.tdfk_no;
```



## 6. EMRからAthenaViewにアクセス(ダメでした)

```sql
# テーブルとして表示されるか
spark-sql> use wk_0427;
21/04/26 16:18:04 WARN CatalogToHiveConverter: Hive Exception type not found for AccessDeniedException
Time taken: 0.305 seconds
21/04/26 16:18:04 INFO SparkSQLCLIDriver: Time taken: 0.305 seconds
spark-sql> show tables;
21/04/26 16:18:06 INFO CodeGenerator: Code generated in 30.48984 ms
wk_0427 kencho  false
wk_0427 tdfk    false
wk_0427 tdfk_kencho     false

# kencho
spark-sql> select * from kencho;
1       札幌市
2       青森市
3       盛岡市
4       仙台市
5       秋田市
6       山形市
7       福島市
8       水戸市

# tdfk_kencho → ダメでした
spark-sql> select * from tdfk_kencho;
Error in query: java.lang.IllegalArgumentException: Can not create a Path from an empty string;

```

## 7. Glue側からViewを作る

```sql
# originalsql.sql
select * from wk_0427.tdfk

# vieworiginaltext.json
{
  \"originalSql\": \"${original_sql}\",
  \"catalog\": \"awsdatacatalog\",
  \"schema\": \"wk_0427\",
  \"columns\": [
    {
      \"name\": \"tdfk_no\",
      \"type\": \"integer\"
    },
    {
      \"name\": \"tdfk_name\",
      \"type\": \"varchar\"
    }
  ]
}

# bashで実行
original_sql=$(eval "echo \"$(cat originalsql.sql)\"")
echo $original_sql
view_original_text=$(eval "echo \"$(cat vieworiginaltext.json)\"")
echo $view_original_text
view_original_text_b64encoded=$(echo -n $view_original_text | base64 -w 0)

# tableinput.json
{
  \"Name\": \"tdfk_kencho\",
  \"TableType\": \"VIRTUAL_VIEW\",
  \"Parameters\": {
    \"presto_view\": \"true\"
  },
  \"ViewOriginalText\": \"/* Presto View: ${view_original_text_b64encoded} */\",
  \"ViewExpandedText\": \"/* ${original_sql} */\",
  \"StorageDescriptor\": {
    \"SerdeInfo\": {},
    \"Columns\": [
      {
        \"Name\": \"tdfk_no\",
        \"Type\": \"integer\"
      },
      {
        \"Name\": \"tdfk_name\",
        \"Type\": \"string\"
      }
    ]
  }
}

# bashで実行
tableinput=$(eval "echo \"$(cat tableinput.json)\"")

# bash ⁺ awscliで実行
aws glue create-table \
  --database-name wk_0427 \
  --table-input "${tableinput}"
```

