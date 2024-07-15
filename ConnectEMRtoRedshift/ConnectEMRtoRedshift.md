# EMRからRedshiftへ接続

# 段取り

1. 参考URL確認
2. EMRからRedshiftへ接続

## 1. 参考URL確認

[Connect AWS EMR to Redshift](https://blog.benthem.io/2020/04/21/connect-aws-emr-to-spark.html)

## 2. EMRからRedshiftへ接続

### ライブラリのダウンロード

```powershell
invoke-webrequest -uri https://repo1.maven.org/maven2/com/databricks/spark-redshift_2.10/2.0.1/spark-redshift_2.10-2.0.1.jar -outfile spark-redshift_2.10-2.0.1.jar
invoke-webrequest -uri https://repo1.maven.org/maven2/com/eclipsesource/minimal-json/minimal-json/0.9.5/minimal-json-0.9.5.jar -outfile minimal-json-0.9.5.jar
invoke-webrequest -uri https://repo1.maven.org/maven2/com/databricks/spark-avro_2.11/3.0.0/spark-avro_2.11-3.0.0.jar -outfile spark-avro_2.11-3.0.0.jar
invoke-webrequest -uri https://s3.amazonaws.com/redshift-downloads/drivers/jdbc/1.2.41.1065/RedshiftJDBC4-no-awssdk-1.2.41.1065.jar -outfile RedshiftJDBC4-no-awssdk-1.2.41.1065.jar
```

### S3へのライブラリ配置

```
s3://<bucket_name>/emr2redshift/libs/
```

### Redshiftのテーブル作成

```sql
create table public.target_tbl(
    id int,
    username varchar(10),
    dept_no int
);

insert into public.target_tbl values(1,'Taro'   ,10);
insert into public.target_tbl values(2,'Jiro'   ,20);
insert into public.target_tbl values(3,'Saburo' ,30);
insert into public.target_tbl values(4,'Shiro'  ,40);
insert into public.target_tbl values(5,'Goro'   ,50);
insert into public.target_tbl values(6,'Hanako' ,10);
insert into public.target_tbl values(7,'Emi'    ,20);
insert into public.target_tbl values(8,'Satoko' ,30);
insert into public.target_tbl values(9,'Hideko' ,40);
insert into public.target_tbl values(10,'Satomi',50);

select * from public.target_tbl;

```

### EMRでRedshiftへの疎通確認(psql)

```bash
# EMR→Redshiftが通信できることを確認する＆デバック簡便化のため、マスタノードにpsqlを入れる
sudo yum install postgresql
psql -h redshift-cluster-1.*******.ap-northeast-1.redshift.amazonaws.com -p 5439 -U awsuser -d dev
```

### SparkでRedshiftへ接続(Databrickライブラリ使用) pyspark->成功

```python
# pyspark --jars s3://target_bucket/emr2redshift/libs/RedshiftJDBC4-no-awssdk-1.2.41.1065.jar,s3://target_bucket/emr2redshift/libs/minimal-json-0.9.5.jar,s3://target_bucket/emr2redshift/libs/spark-avro_2.11-3.0.0.jar,s3://target_bucket/emr2redshift/libs/spark-redshift_2.10-2.0.1.jar
# ↑で実行したらできた(スクリプト直貼り付け)
from pyspark.sql import SQLContext
jdbcUrl = "jdbc:redshift://redshift-cluster-1.***.ap-northeast-1.redshift.amazonaws.com:5439/dev?user=***&password=***"

sc = spark
sc._jsc.hadoopConfiguration().set("fs.s3a.credentialsType", "AssumeRole")
sc._jsc.hadoopConfiguration().set("fs.s3a.stsAssumeRole.arn", "arn:aws:iam::***:role/EC2-S3FullAccess-Role")
sql_context = SQLContext(sc)

df_users = sql_context.read \
    .format("com.databricks.spark.redshift") \
    .option("url", jdbcUrl) \
    .option("query", "select * from public.target_tbl") \
    .option("tempdir","s3a://target_bucket/emr2redshift/tmp/")\
    .load()
    
df_users.show()
```
### SparkでRedshiftへ接続(Databrickライブラリ使用) spark-submit->成功
```python
# spark-submit --jars s3://target_bucket/emr2redshift/libs/RedshiftJDBC4-no-awssdk-1.2.41.1065.jar,s3://target_bucket/emr2redshift/libs/minimal-json-0.9.5.jar,s3://target_bucket/emr2redshift/libs/spark-avro_2.11-3.0.0.jar,s3://target_bucket/emr2redshift/libs/spark-redshift_2.10-2.0.1.jar conn_databrick_rs.py
# ↑でうまくいった

from pyspark.sql import SQLContext
from pyspark import SparkContext

jdbcUrl = "jdbc:redshift://redshift-cluster-1.****.ap-northeast-1.redshift.amazonaws.com:5439/dev?user=***&password=****"

sc = SparkContext()
sc._jsc.hadoopConfiguration().set("fs.s3a.credentialsType", "AssumeRole")
# S3への読み、書きの権限を持つIAMロールを指定
sc._jsc.hadoopConfiguration().set("fs.s3a.stsAssumeRole.arn", "arn:aws:iam::***:role/EC2-S3FullAccess-Role")
sql_context = SQLContext(sc)


# tempdirはRedshiftからの抽出結果が入っていた(テキスト形式)
# Redshiftからアンロード→Sparkでロードを透過的にやっている模様
# tempdirのクリアが必要になりそう
df_users = sql_context.read \
    .format("com.databricks.spark.redshift") \
    .option("url", jdbcUrl) \
    .option("query", "select * from public.target_tbl") \
    .option("tempdir","s3a://***/emr2redshift/tmp/")\
    .load()

df_users.show()
```
### SparkでRedshiftへ接続(通常のAPI用) pyspark->失敗
```python
# pysparkで以下のスクリプトは「pyspark.sql.utils.AnalysisException: 'Unable to infer schema for Parquet. It must be specified manually.;'」となりうまく実行できなかった
# https://stackoverflow.com/questions/34948296/using-pyspark-to-connect-to-postgresql

sqlContext = SQLContext(sc)

df = sqlContext.read\
.option("url","jdbc:redshift://redshift-cluster-1.***.ap-northeast-1.redshift.amazonaws.com:5439/dev;UID=***;PWD=***")\
.option("dbtable","public.target_tbl")\
.load()
```

### SparkでRedshiftへ接続(通常のAPI用) spark-submit->失敗
```python
# 下記のスクリプトは spark-submitではうまく動かなかった(No suitable Driverだそう)
# https://stackoverflow.com/questions/34948296/using-pyspark-to-connect-to-postgresql

from pyspark.sql import SparkSession

spark = SparkSession \
    .builder \
    .appName("Python Spark SQL basic example") \
    .getOrCreate()

df = spark.read \
    .format("jdbc") \
    .option("url", "jdbc:redshift://redshift-cluster-1.*****.ap-northeast-1.redshift.amazonaws.com:5439/dev;UID=***;PWD=***") \
    .option("dbtable", "public.target_tbl") \
    .load()

df.printSchema()
```
