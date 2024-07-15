# EMRへのPyArrowの導入

[TOC]

## 方針

NATGWをセットアップし、プライベートサブネットのEC2にPyArrowを導入したAMIを作成し、作成したAMIでEMRを起動する

## まとめ

- セットアップ済みのAMIでEMRが実行できた
- ストレージ構成もデフォルトAMIと同じ？のような感じになっていた

## 段取り

1. NATGWのセットアップ
2. プライベートサブネットのEC2にPyArrowを導入
3. AMIの作成
4. 作成したAMIからEMR起動、PyArrowの利用確認
5. 後始末

## 1. NATGWのセットアップ

###  1. パブリックサブネットの作成

```bash
# 既存のパブリックサブネットを使用
subnet-0ad0d84a03b6624db
192.168.1.0/24
```

### 2. プライベートサブネットの作成

```bash
# 既存のプライベートサブネットを使用
subnet-01bf116d808cf0009
192.168.2.0/24
```

### 3. NATGWの作成

```bash
# 作成するサブネット
subnet-0ad0d84a03b6624db(パブリックサブネット)
ElasticIPは新規割り当て→割り当て解除を忘れない

nat-05abd35748cfa7502
```

### 4. プライベートサブネットのルーティングテーブルにNATGWを追加

```
subnet-01bf116d808cf0009(プライベートサブネット)に割り当てられたルートテーブル「rtb-0b83f4db3b63fd7f5」に、以下の設定を追加する

送信先:0.0.0.0/0
ターゲット：nat-05abd35748cfa7502(先ほど作成したNATGW)
```

### 5. プライベートサブネットのEC2から外に出れることを確認

```bash
[ec2-user@ip-192-168-2-61 ~]$ wget www.google.com
--2021-04-25 03:04:21--  http://www.google.com/
Resolving www.google.com (www.google.com)... 216.58.220.132, 2404:6800:4004:81a::2004
Connecting to www.google.com (www.google.com)|216.58.220.132|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: unspecified [text/html]
Saving to: ‘index.html’

    [ <=>                                                               ] 14,290      --.-K/s   in 0.001s

2021-04-25 03:04:21 (13.0 MB/s) - ‘index.html’ saved [14290]
```

## 2. プライベートサブネットのEC2にPyArrowを導入

### 1. 現在の構成を確認

```bash
[ec2-user@ip-192-168-2-61 ~]$ cat /etc/*release
NAME="Amazon Linux"
VERSION="2"
ID="amzn"
ID_LIKE="centos rhel fedora"
VERSION_ID="2"
PRETTY_NAME="Amazon Linux 2"
ANSI_COLOR="0;33"
CPE_NAME="cpe:2.3:o:amazon:amazon_linux:2"
HOME_URL="https://amazonlinux.com/"
Amazon Linux release 2 (Karoo)

[ec2-user@ip-192-168-2-61 ~]$ which python
/usr/bin/python
[ec2-user@ip-192-168-2-61 ~]$ which python3
/usr/bin/which: no python3 in (/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/ec2-user/.local/bin:/home/ec2-user/bin)
[ec2-user@ip-192-168-2-61 ~]$ python --version
Python 2.7.18
[ec2-user@ip-192-168-2-61 ~]$ pip freeze
-bash: pip: command not found
[ec2-user@ip-192-168-2-61 ~]$ which pip
/usr/bin/which: no pip in (/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/ec2-user/.local/bin:/home/ec2-user/bin)
```

### 2. yumでpython3をインストール

```bash
[ec2-user@ip-192-168-2-61 ~]$ sudo yum install -y python3

[ec2-user@ip-192-168-2-61 ~]$ python3 --version
Python 3.7.9

[ec2-user@ip-192-168-2-61 ~]$ which pip3
/usr/bin/pip3
```

### 3. pip3でPyArrowをインストール

```bash
# pip3自体のアップデート
[ec2-user@ip-192-168-2-61 ~]$ sudo python3 -m pip install --upgrade pip

# PyArrowのインストール
[ec2-user@ip-192-168-2-61 ~]$ sudo python3 -m pip install pyarrow

# インストール済みのモジュールを確認
[ec2-user@ip-192-168-2-61 ~]$ pip3 freeze
numpy==1.20.2
pyarrow==3.0.0

# boto3もインストール
[ec2-user@ip-192-168-2-61 ~]$ sudo python3 -m pip install boto3

# インストール済みのモジュールを確認
[ec2-user@ip-192-168-2-61 ~]$ pip3 freeze
boto3==1.17.57
botocore==1.20.57
jmespath==0.10.0
numpy==1.20.2
pyarrow==3.0.0
python-dateutil==2.8.1
s3transfer==0.4.2
six==1.15.0
urllib3==1.26.4

# PyArrowはPandasも併せて使うことが多いらしいのでインストールする
[ec2-user@ip-192-168-2-61 wk_0425]$ sudo python3 -m pip install pandas

# インストール済みのモジュールを確認
[ec2-user@ip-192-168-2-61 wk_0425]$ pip3 freeze
boto3==1.17.57
botocore==1.20.57
jmespath==0.10.0
numpy==1.20.2
pandas==1.2.4
pyarrow==3.0.0
python-dateutil==2.8.1
pytz==2021.1
s3transfer==0.4.2
six==1.15.0
urllib3==1.26.4
```

### 4. PyArrowの動作確認

```python
# -*- coding:utf8 -*-
# Parquetフォーマットへの変換
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq

df = pd.read_csv('./tdfk.csv')
table = pa.Table.from_pandas(df)
pq.write_table(table, './tdfk.parquet')
```

```bash
[ec2-user@ip-192-168-2-61 wk_0425]$ head -5 tdfk.csv
1,北海道,札幌市
2,青森県,青森市
3,岩手県,盛岡市
4,宮城県,仙台市
5,秋田県,秋田市
```

```bash
[ec2-user@ip-192-168-2-61 wk_0425]$ python3 csv_to_parquet.py
[ec2-user@ip-192-168-2-61 wk_0425]$ ls -al
total 12
drwxrwxr-x  2 ec2-user ec2-user   67 Apr 25 03:30 .
drwxrwxrwt 10 root     root      257 Apr 25 03:29 ..
-rw-rw-r--  1 ec2-user ec2-user  237 Apr 25 03:28 csv_to_parquet.py
-rw-rw-r--  1 ec2-user ec2-user 1143 Apr 25 03:27 tdfk.csv
-rw-rw-r--  1 ec2-user ec2-user 4045 Apr 25 03:30 tdfk.parquet
```

## 3. AMIの作成

```
ami-089c520781145fd40 
※ブートボリュームのスナップショットがとられる(ことが後でどんな影響を及ぼすのか...？)
```

## 4. 作成したAMIからEMR起動、PyArrowの利用確認

```
前段として、NATGWを削除しておく
1. NATGWの削除
2. ElasticIPの解放
割り当てたElasticIPが宙ぶらりんになっていると課金されるのでElasticIPの割り当てを解除する。(NatGWがなくて、ElasticIPだけあると、ElasticIP費用が掛かる。NATGWが生きているとElasticIP費用は掛からない)
3. プライベートサブネットのルートテーブルからNATGWを削除
```

```
クラスターの作成-詳細オプション
ステップ3： クラスター全般設定
追加のオプション
カスタムAMI ID
再起動時にすべてのインストール済みパッケージを更新する(推奨)←チェック(EMR作成時にはNATを削除しておくので、意味はあるのか...？)
```

```bash
[hadoop@ip-192-168-2-85 ~]$ pip3 freeze
beautifulsoup4==4.9.3
boto==2.49.0
boto3==1.17.57
botocore==1.20.57
click==7.1.2
jmespath==0.10.0
joblib==0.17.0
lxml==4.6.1
mysqlclient==1.4.2
nltk==3.5
nose==1.3.4
numpy==1.20.2
pandas==1.2.4
py-dateutil==2.2
pyarrow==3.0.0
python-dateutil==2.8.1
python37-sagemaker-pyspark==1.4.1
pytz==2021.1
PyYAML==5.3.1
regex==2020.10.28
s3transfer==0.4.2
six==1.15.0
tqdm==4.51.0
urllib3==1.26.4
windmill==1.6
```

```bash
[hadoop@ip-192-168-2-85 ~]$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        3.9G     0  3.9G   0% /dev
tmpfs           3.9G     0  3.9G   0% /dev/shm
tmpfs           3.9G  1.1M  3.9G   1% /run
tmpfs           3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/xvda1       10G  6.5G  3.6G  65% /
/dev/xvdb1      5.0G   46M  5.0G   1% /emr
/dev/xvdb2       27G  933M   27G   4% /mnt
tmpfs           798M     0  798M   0% /run/user/994
tmpfs           798M     0  798M   0% /run/user/991
tmpfs           798M     0  798M   0% /run/user/992
tmpfs           798M     0  798M   0% /run/user/990
tmpfs           798M     0  798M   0% /run/user/986
tmpfs           798M     0  798M   0% /run/user/985
tmpfs           798M     0  798M   0% /run/user/988
tmpfs           798M     0  798M   0% /run/user/984
tmpfs           798M     0  798M   0% /run/user/987
tmpfs           798M     0  798M   0% /run/user/1001
```

```bash
# spark-sqlが失敗した → デフォルトAMIではどうか4-2で検証
21/04/25 13:09:29 ERROR SparkSQLDriver: Failed in [select * from wimax_usage limit 10]
org.apache.hadoop.net.ConnectTimeoutException: Call From ip-192-168-2-85.ap-northeast-1.compute.internal/192.168.2.85 to ip-192-168-0-240.ap-northeast-1.compute.internal:8020 failed on socket timeout exception: org.apache.hadoop.net.ConnectTimeoutException: 20000 millis timeout while waiting for channel to be ready for connect. ch : java.nio.channels.SocketChannel[connection-pending remote=ip-192-168-0-240.ap-northeast-1.compute.internal/192.168.0.240:8020]; For more details see:  http://wiki.apache.org/hadoop/SocketTimeout
        at sun.reflect.NativeConstructorAccessorImpl.newInstance0(Native Method)
        at sun.reflect.NativeConstructorAccessorImpl.newInstance(NativeConstructorAccessorImpl.java:62)
        at sun.reflect.DelegatingConstructorAccessorImpl.newInstance(DelegatingConstructorAccessorImpl.java:45)
        at java.lang.reflect.Constructor.newInstance(Constructor.java:423)
        at org.apache.hadoop.net.NetUtils.wrapWithMessage(NetUtils.java:827)
        at org.apache.hadoop.net.NetUtils.wrapException(NetUtils.java:777)
        at org.apache.hadoop.ipc.Client.getRpcResponse(Client.java:1553)
        at org.apache.hadoop.ipc.Client.call(Client.java:1495)
        at org.apache.hadoop.ipc.Client.call(Client.java:1394)
        at org.apache.hadoop.ipc.ProtobufRpcEngine$Invoker.invoke(ProtobufRpcEngine.java:232)
        at org.apache.hadoop.ipc.ProtobufRpcEngine$Invoker.invoke(ProtobufRpcEngine.java:118)
        at com.sun.proxy.$Proxy22.getFileInfo(Unknown Source)
        at org.apache.hadoop.hdfs.protocolPB.ClientNamenodeProtocolTranslatorPB.getFileInfo(ClientNamenodeProtocolTranslatorPB.java:800)
        at sun.reflect.GeneratedMethodAccessor13.invoke(Unknown Source)
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.lang.reflect.Method.invoke(Method.java:498)
        at org.apache.hadoop.io.retry.RetryInvocationHandler.invokeMethod(RetryInvocationHandler.java:422)
        at org.apache.hadoop.io.retry.RetryInvocationHandler$Call.invokeMethod(RetryInvocationHandler.java:165)
        at org.apache.hadoop.io.retry.RetryInvocationHandler$Call.invoke(RetryInvocationHandler.java:157)
        at org.apache.hadoop.io.retry.RetryInvocationHandler$Call.invokeOnce(RetryInvocationHandler.java:95)
        at org.apache.hadoop.io.retry.RetryInvocationHandler.invoke(RetryInvocationHandler.java:359)
        at com.sun.proxy.$Proxy23.getFileInfo(Unknown Source)
        at org.apache.hadoop.hdfs.DFSClient.getFileInfo(DFSClient.java:1673)
        at org.apache.hadoop.hdfs.DistributedFileSystem$29.doCall(DistributedFileSystem.java:1524)
        at org.apache.hadoop.hdfs.DistributedFileSystem$29.doCall(DistributedFileSystem.java:1521)
        at org.apache.hadoop.fs.FileSystemLinkResolver.resolve(FileSystemLinkResolver.java:81)
        at org.apache.hadoop.hdfs.DistributedFileSystem.getFileStatus(DistributedFileSystem.java:1536)
        at org.apache.hadoop.fs.Globber.getFileStatus(Globber.java:65)
        at org.apache.hadoop.fs.Globber.doGlob(Globber.java:281)
        at org.apache.hadoop.fs.Globber.glob(Globber.java:149)
        at org.apache.hadoop.fs.FileSystem.globStatus(FileSystem.java:2036)
        at org.apache.hadoop.mapred.FileInputFormat.singleThreadedListStatus(FileInputFormat.java:238)
        at org.apache.hadoop.mapred.FileInputFormat.listStatus(FileInputFormat.java:208)
        at org.apache.hadoop.mapred.FileInputFormat.getSplits(FileInputFormat.java:288)
        at org.apache.spark.rdd.HadoopRDD.getPartitions(HadoopRDD.scala:204)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:273)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:269)
        at scala.Option.getOrElse(Option.scala:121)
        at org.apache.spark.rdd.RDD.partitions(RDD.scala:269)
        at org.apache.spark.rdd.MapPartitionsRDD.getPartitions(MapPartitionsRDD.scala:49)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:273)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:269)
        at scala.Option.getOrElse(Option.scala:121)
        at org.apache.spark.rdd.RDD.partitions(RDD.scala:269)
        at org.apache.spark.rdd.MapPartitionsRDD.getPartitions(MapPartitionsRDD.scala:49)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:273)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:269)
        at scala.Option.getOrElse(Option.scala:121)
        at org.apache.spark.rdd.RDD.partitions(RDD.scala:269)
        at org.apache.spark.rdd.MapPartitionsRDD.getPartitions(MapPartitionsRDD.scala:49)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:273)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:269)
        at scala.Option.getOrElse(Option.scala:121)
        at org.apache.spark.rdd.RDD.partitions(RDD.scala:269)
        at org.apache.spark.rdd.MapPartitionsRDD.getPartitions(MapPartitionsRDD.scala:49)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:273)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:269)
        at scala.Option.getOrElse(Option.scala:121)
        at org.apache.spark.rdd.RDD.partitions(RDD.scala:269)
        at org.apache.spark.rdd.MapPartitionsRDD.getPartitions(MapPartitionsRDD.scala:49)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:273)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:269)
        at scala.Option.getOrElse(Option.scala:121)
        at org.apache.spark.rdd.RDD.partitions(RDD.scala:269)
        at org.apache.spark.sql.execution.SparkPlan.executeTake(SparkPlan.scala:384)
        at org.apache.spark.sql.execution.CollectLimitExec.executeCollect(limit.scala:38)
        at org.apache.spark.sql.execution.SparkPlan.executeCollectPublic(SparkPlan.scala:368)
        at org.apache.spark.sql.execution.QueryExecution.hiveResultString(QueryExecution.scala:244)
        at org.apache.spark.sql.hive.thriftserver.SparkSQLDriver$$anonfun$run$1.apply(SparkSQLDriver.scala:64)
        at org.apache.spark.sql.hive.thriftserver.SparkSQLDriver$$anonfun$run$1.apply(SparkSQLDriver.scala:64)
        at org.apache.spark.sql.execution.SQLExecution$.org$apache$spark$sql$execution$SQLExecution$$executeQuery$1(SQLExecution.scala:83)
        at org.apache.spark.sql.execution.SQLExecution$$anonfun$withNewExecutionId$1$$anonfun$apply$1.apply(SQLExecution.scala:94)
        at org.apache.spark.sql.execution.QueryExecutionMetrics$.withMetrics(QueryExecutionMetrics.scala:141)
        at org.apache.spark.sql.execution.SQLExecution$.org$apache$spark$sql$execution$SQLExecution$$withMetrics(SQLExecution.scala:178)
        at org.apache.spark.sql.execution.SQLExecution$$anonfun$withNewExecutionId$1.apply(SQLExecution.scala:93)
        at org.apache.spark.sql.execution.SQLExecution$.withSQLConfPropagated(SQLExecution.scala:200)
        at org.apache.spark.sql.execution.SQLExecution$.withNewExecutionId(SQLExecution.scala:92)
        at org.apache.spark.sql.hive.thriftserver.SparkSQLDriver.run(SparkSQLDriver.scala:63)
        at org.apache.spark.sql.hive.thriftserver.SparkSQLCLIDriver.processCmd(SparkSQLCLIDriver.scala:371)
        at org.apache.hadoop.hive.cli.CliDriver.processLine(CliDriver.java:376)
        at org.apache.spark.sql.hive.thriftserver.SparkSQLCLIDriver$.main(SparkSQLCLIDriver.scala:274)
        at org.apache.spark.sql.hive.thriftserver.SparkSQLCLIDriver.main(SparkSQLCLIDriver.scala)
        at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
        at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.lang.reflect.Method.invoke(Method.java:498)
        at org.apache.spark.deploy.JavaMainApplication.start(SparkApplication.scala:52)
        at org.apache.spark.deploy.SparkSubmit.org$apache$spark$deploy$SparkSubmit$$runMain(SparkSubmit.scala:853)
        at org.apache.spark.deploy.SparkSubmit.doRunMain$1(SparkSubmit.scala:161)
        at org.apache.spark.deploy.SparkSubmit.submit(SparkSubmit.scala:184)
        at org.apache.spark.deploy.SparkSubmit.doSubmit(SparkSubmit.scala:86)
        at org.apache.spark.deploy.SparkSubmit$$anon$2.doSubmit(SparkSubmit.scala:928)
        at org.apache.spark.deploy.SparkSubmit$.main(SparkSubmit.scala:937)
        at org.apache.spark.deploy.SparkSubmit.main(SparkSubmit.scala)
Caused by: org.apache.hadoop.net.ConnectTimeoutException: 20000 millis timeout while waiting for channel to be ready for connect. ch : java.nio.channels.SocketChannel[connection-pending remote=ip-192-168-0-240.ap-northeast-1.compute.internal/192.168.0.240:8020]
        at org.apache.hadoop.net.NetUtils.connect(NetUtils.java:535)
        at org.apache.hadoop.ipc.Client$Connection.setupConnection(Client.java:701)
        at org.apache.hadoop.ipc.Client$Connection.setupIOstreams(Client.java:814)
        at org.apache.hadoop.ipc.Client$Connection.access$3700(Client.java:423)
        at org.apache.hadoop.ipc.Client.getConnection(Client.java:1610)
        at org.apache.hadoop.ipc.Client.call(Client.java:1441)
        ... 86 more
```

```bash
# 成功
spark-sql> select * from fruit_order_pq;
2020-02-01      ぶどう  2       NULL
2020-02-01      ぶどう  3       NULL
2020-02-01      りんご  5       NULL
2020-02-02      りんご  1       NULL
2020-02-02      りんご  3       NULL
2020-02-02      ぶどう  4       NULL
2020-02-02      みかん  2       NULL
```

```bash
# PyArrowの検証 → できた
[hadoop@ip-192-168-2-85 wk_0425]$ python3 csv_to_parquet.py
[hadoop@ip-192-168-2-85 wk_0425]$ ls -al
total 16
drwxrwxr-x  2 hadoop hadoop   67 Apr 25 13:29 .
drwxrwxrwt 35 root   root   4096 Apr 25 13:29 ..
-rw-rw-r--  1 hadoop hadoop  237 Apr 25 03:28 csv_to_parquet.py
-rw-rw-r--  1 hadoop hadoop 1143 Apr 25 03:27 tdfk.csv
-rw-rw-r--  1 hadoop hadoop 4045 Apr 25 13:29 tdfk.parquet
```



## 4-2. 別のクラスタ(デフォルトAMI)で稼働確認

```bash
[hadoop@ip-192-168-2-144 ~]$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        3.9G     0  3.9G   0% /dev
tmpfs           3.9G     0  3.9G   0% /dev/shm
tmpfs           3.9G  1.2M  3.9G   1% /run
tmpfs           3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/xvda1       10G  6.3G  3.8G  63% /
/dev/xvdb1      5.0G   40M  5.0G   1% /emr
/dev/xvdb2       27G  778M   27G   3% /mnt
tmpfs           798M     0  798M   0% /run/user/0
tmpfs           798M     0  798M   0% /run/user/994
tmpfs           798M     0  798M   0% /run/user/991
tmpfs           798M     0  798M   0% /run/user/992
tmpfs           798M     0  798M   0% /run/user/990
tmpfs           798M     0  798M   0% /run/user/986
tmpfs           798M     0  798M   0% /run/user/985
tmpfs           798M     0  798M   0% /run/user/988
tmpfs           798M     0  798M   0% /run/user/984
tmpfs           798M     0  798M   0% /run/user/987
tmpfs           798M     0  798M   0% /run/user/996
```

```bash
# 同じように失敗(DBが悪い説、S3ファイルが存在しないなどあり)
21/04/25 13:15:39 ERROR SparkSQLDriver: Failed in [select * from wimax_usage limit 10]
org.apache.hadoop.net.ConnectTimeoutException: Call From ip-192-168-2-144/192.168.2.144 to ip-192-168-0-240.ap-northeast-1.compute.internal:8020 failed on socket timeout exception: org.apache.hadoop.net.ConnectTimeoutException: 20000 millis timeout while waiting for channel to be ready for connect. ch : java.nio.channels.SocketChannel[connection-pending remote=ip-192-168-0-240.ap-northeast-1.compute.internal/192.168.0.240:8020]; For more details see:  http://wiki.apache.org/hadoop/SocketTimeout
        at sun.reflect.NativeConstructorAccessorImpl.newInstance0(Native Method)
        at sun.reflect.NativeConstructorAccessorImpl.newInstance(NativeConstructorAccessorImpl.java:62)
        at sun.reflect.DelegatingConstructorAccessorImpl.newInstance(DelegatingConstructorAccessorImpl.java:45)
        at java.lang.reflect.Constructor.newInstance(Constructor.java:423)
        at org.apache.hadoop.net.NetUtils.wrapWithMessage(NetUtils.java:827)
        at org.apache.hadoop.net.NetUtils.wrapException(NetUtils.java:777)
        at org.apache.hadoop.ipc.Client.getRpcResponse(Client.java:1553)
        at org.apache.hadoop.ipc.Client.call(Client.java:1495)
        at org.apache.hadoop.ipc.Client.call(Client.java:1394)
        at org.apache.hadoop.ipc.ProtobufRpcEngine$Invoker.invoke(ProtobufRpcEngine.java:232)
        at org.apache.hadoop.ipc.ProtobufRpcEngine$Invoker.invoke(ProtobufRpcEngine.java:118)
        at com.sun.proxy.$Proxy22.getFileInfo(Unknown Source)
        at org.apache.hadoop.hdfs.protocolPB.ClientNamenodeProtocolTranslatorPB.getFileInfo(ClientNamenodeProtocolTranslatorPB.java:800)
        at sun.reflect.GeneratedMethodAccessor13.invoke(Unknown Source)
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.lang.reflect.Method.invoke(Method.java:498)
        at org.apache.hadoop.io.retry.RetryInvocationHandler.invokeMethod(RetryInvocationHandler.java:422)
        at org.apache.hadoop.io.retry.RetryInvocationHandler$Call.invokeMethod(RetryInvocationHandler.java:165)
        at org.apache.hadoop.io.retry.RetryInvocationHandler$Call.invoke(RetryInvocationHandler.java:157)
        at org.apache.hadoop.io.retry.RetryInvocationHandler$Call.invokeOnce(RetryInvocationHandler.java:95)
        at org.apache.hadoop.io.retry.RetryInvocationHandler.invoke(RetryInvocationHandler.java:359)
        at com.sun.proxy.$Proxy23.getFileInfo(Unknown Source)
        at org.apache.hadoop.hdfs.DFSClient.getFileInfo(DFSClient.java:1673)
        at org.apache.hadoop.hdfs.DistributedFileSystem$29.doCall(DistributedFileSystem.java:1524)
        at org.apache.hadoop.hdfs.DistributedFileSystem$29.doCall(DistributedFileSystem.java:1521)
        at org.apache.hadoop.fs.FileSystemLinkResolver.resolve(FileSystemLinkResolver.java:81)
        at org.apache.hadoop.hdfs.DistributedFileSystem.getFileStatus(DistributedFileSystem.java:1536)
        at org.apache.hadoop.fs.Globber.getFileStatus(Globber.java:65)
        at org.apache.hadoop.fs.Globber.doGlob(Globber.java:281)
        at org.apache.hadoop.fs.Globber.glob(Globber.java:149)
        at org.apache.hadoop.fs.FileSystem.globStatus(FileSystem.java:2036)
        at org.apache.hadoop.mapred.FileInputFormat.singleThreadedListStatus(FileInputFormat.java:238)
        at org.apache.hadoop.mapred.FileInputFormat.listStatus(FileInputFormat.java:208)
        at org.apache.hadoop.mapred.FileInputFormat.getSplits(FileInputFormat.java:288)
        at org.apache.spark.rdd.HadoopRDD.getPartitions(HadoopRDD.scala:204)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:273)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:269)
        at scala.Option.getOrElse(Option.scala:121)
        at org.apache.spark.rdd.RDD.partitions(RDD.scala:269)
        at org.apache.spark.rdd.MapPartitionsRDD.getPartitions(MapPartitionsRDD.scala:49)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:273)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:269)
        at scala.Option.getOrElse(Option.scala:121)
        at org.apache.spark.rdd.RDD.partitions(RDD.scala:269)
        at org.apache.spark.rdd.MapPartitionsRDD.getPartitions(MapPartitionsRDD.scala:49)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:273)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:269)
        at scala.Option.getOrElse(Option.scala:121)
        at org.apache.spark.rdd.RDD.partitions(RDD.scala:269)
        at org.apache.spark.rdd.MapPartitionsRDD.getPartitions(MapPartitionsRDD.scala:49)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:273)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:269)
        at scala.Option.getOrElse(Option.scala:121)
        at org.apache.spark.rdd.RDD.partitions(RDD.scala:269)
        at org.apache.spark.rdd.MapPartitionsRDD.getPartitions(MapPartitionsRDD.scala:49)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:273)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:269)
        at scala.Option.getOrElse(Option.scala:121)
        at org.apache.spark.rdd.RDD.partitions(RDD.scala:269)
        at org.apache.spark.rdd.MapPartitionsRDD.getPartitions(MapPartitionsRDD.scala:49)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:273)
        at org.apache.spark.rdd.RDD$$anonfun$partitions$2.apply(RDD.scala:269)
        at scala.Option.getOrElse(Option.scala:121)
        at org.apache.spark.rdd.RDD.partitions(RDD.scala:269)
        at org.apache.spark.sql.execution.SparkPlan.executeTake(SparkPlan.scala:384)
        at org.apache.spark.sql.execution.CollectLimitExec.executeCollect(limit.scala:38)
        at org.apache.spark.sql.execution.SparkPlan.executeCollectPublic(SparkPlan.scala:368)
        at org.apache.spark.sql.execution.QueryExecution.hiveResultString(QueryExecution.scala:244)
        at org.apache.spark.sql.hive.thriftserver.SparkSQLDriver$$anonfun$run$1.apply(SparkSQLDriver.scala:64)
        at org.apache.spark.sql.hive.thriftserver.SparkSQLDriver$$anonfun$run$1.apply(SparkSQLDriver.scala:64)
        at org.apache.spark.sql.execution.SQLExecution$.org$apache$spark$sql$execution$SQLExecution$$executeQuery$1(SQLExecution.scala:83)
        at org.apache.spark.sql.execution.SQLExecution$$anonfun$withNewExecutionId$1$$anonfun$apply$1.apply(SQLExecution.scala:94)
        at org.apache.spark.sql.execution.QueryExecutionMetrics$.withMetrics(QueryExecutionMetrics.scala:141)
        at org.apache.spark.sql.execution.SQLExecution$.org$apache$spark$sql$execution$SQLExecution$$withMetrics(SQLExecution.scala:178)
        at org.apache.spark.sql.execution.SQLExecution$$anonfun$withNewExecutionId$1.apply(SQLExecution.scala:93)
        at org.apache.spark.sql.execution.SQLExecution$.withSQLConfPropagated(SQLExecution.scala:200)
        at org.apache.spark.sql.execution.SQLExecution$.withNewExecutionId(SQLExecution.scala:92)
        at org.apache.spark.sql.hive.thriftserver.SparkSQLDriver.run(SparkSQLDriver.scala:63)
        at org.apache.spark.sql.hive.thriftserver.SparkSQLCLIDriver.processCmd(SparkSQLCLIDriver.scala:371)
        at org.apache.hadoop.hive.cli.CliDriver.processLine(CliDriver.java:376)
        at org.apache.spark.sql.hive.thriftserver.SparkSQLCLIDriver$.main(SparkSQLCLIDriver.scala:274)
        at org.apache.spark.sql.hive.thriftserver.SparkSQLCLIDriver.main(SparkSQLCLIDriver.scala)
        at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
        at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.lang.reflect.Method.invoke(Method.java:498)
        at org.apache.spark.deploy.JavaMainApplication.start(SparkApplication.scala:52)
        at org.apache.spark.deploy.SparkSubmit.org$apache$spark$deploy$SparkSubmit$$runMain(SparkSubmit.scala:853)
        at org.apache.spark.deploy.SparkSubmit.doRunMain$1(SparkSubmit.scala:161)
        at org.apache.spark.deploy.SparkSubmit.submit(SparkSubmit.scala:184)
        at org.apache.spark.deploy.SparkSubmit.doSubmit(SparkSubmit.scala:86)
        at org.apache.spark.deploy.SparkSubmit$$anon$2.doSubmit(SparkSubmit.scala:928)
        at org.apache.spark.deploy.SparkSubmit$.main(SparkSubmit.scala:937)
        at org.apache.spark.deploy.SparkSubmit.main(SparkSubmit.scala)
Caused by: org.apache.hadoop.net.ConnectTimeoutException: 20000 millis timeout while waiting for channel to be ready for connect. ch : java.nio.channels.SocketChannel[connection-pending remote=ip-192-168-0-240.ap-northeast-1.compute.internal/192.168.0.240:8020]
        at org.apache.hadoop.net.NetUtils.connect(NetUtils.java:535)
        at org.apache.hadoop.ipc.Client$Connection.setupConnection(Client.java:701)
        at org.apache.hadoop.ipc.Client$Connection.setupIOstreams(Client.java:814)
        at org.apache.hadoop.ipc.Client$Connection.access$3700(Client.java:423)
        at org.apache.hadoop.ipc.Client.getConnection(Client.java:1610)
        at org.apache.hadoop.ipc.Client.call(Client.java:1441)
        ... 86 more
```

```bash
spark-sql> select * from fruit_order_pq;
2020-02-01      ぶどう  2       NULL
2020-02-01      ぶどう  3       NULL
2020-02-01      りんご  5       NULL
2020-02-02      りんご  1       NULL
2020-02-02      りんご  3       NULL
2020-02-02      ぶどう  4       NULL
2020-02-02      みかん  2       NULL
```

## 5. ffspecのインストール

### 5.1 AMIからインスタンスを作成

- t2.micro(最安でよい。ただし、intel系のインスタンス(m6g等の"g"が付かないタイプ)を選択する)
- 対象のVPC
- プライベートサブネット(NATGWを使うため)
- ストレージ8GB(EMRのサイズとは関係ないため)
- 適切なSGを選択(EMRのSGとは関係なし。SSHアクセスができること)

### 5.2 NATGW経由でインターネットに出られることを確認

```
wget www.google.com
```

### 5.3 PyArrowが入っていることを確認

```
[ec2-user@ip-192-168-2-73 ~]$ python3 -m pip freeze
boto3==1.17.57
botocore==1.20.57
jmespath==0.10.0
numpy==1.20.2
pandas==1.2.4
pyarrow==3.0.0
python-dateutil==2.8.1
pytz==2021.1
s3transfer==0.4.2
six==1.15.0
urllib3==1.26.4
```

### 5.4 ffspecをインストール

```
# ポイントとしては、su権限でやること(グローバルにインストールされる)
[ec2-user@ip-192-168-2-154 wk_0425]$  sudo python3 -m pip install fsspec
WARNING: Value for scheme.platlib does not match. Please report this to <https://github.com/pypa/pip/issues/9617>
distutils: /usr/local/lib64/python3.7/site-packages
sysconfig: /usr/lib64/python3.7/site-packages

# s3アクセスには、併せてs3fsも必要そうだったため、併せてインストール
[ec2-user@ip-192-168-2-154 wk_0425]$  sudo python3 -m pip install s3fs
WARNING: Value for scheme.platlib does not match. Please report this to <https://github.com/pypa/pip/issues/9617>
distutils: /usr/local/lib64/python3.7/site-packages
sysconfig: /usr/lib64/python3.7/site-packages
```

### 5.5 インストール確認

```
[ec2-user@ip-192-168-2-154 wk_0425]$ pip3 freeze
aiobotocore==1.3.0
aiohttp==3.7.4.post0
aioitertools==0.7.1
async-timeout==3.0.1
attrs==21.2.0
boto3==1.17.57
botocore==1.20.49
chardet==4.0.0
fsspec==2021.5.0
idna==3.1
jmespath==0.10.0
multidict==5.1.0
numpy==1.20.2
pandas==1.2.4
pyarrow==3.0.0
python-dateutil==2.8.1
pytz==2021.1
s3fs==2021.5.0
s3transfer==0.4.2
six==1.15.0
typing-extensions==3.10.0.0
urllib3==1.26.4
wrapt==1.12.1
yarl==1.6.3
```

### 5.6 AMI作成

```
ami-0426b70696cbd037f
```

### 5.7 AMIからEMRクラスタを作成

```
再起動時にすべてのインストール済みパッケージを更新する (推奨)　にチェック
```

### 5.8 EMRでのモジュール確認

```
[hadoop@ip-192-168-2-190 ~]$ pip3 freeze
aiobotocore==1.3.0
aiohttp==3.7.4.post0
aioitertools==0.7.1
async-timeout==3.0.1
attrs==21.2.0
beautifulsoup4==4.9.3
boto==2.49.0
boto3==1.17.57
botocore==1.20.49
chardet==4.0.0
click==7.1.2
fsspec==2021.5.0
idna==3.1
jmespath==0.10.0
joblib==0.17.0
lxml==4.6.1
multidict==5.1.0
mysqlclient==1.4.2
nltk==3.5
nose==1.3.4
numpy==1.20.2
pandas==1.2.4
py-dateutil==2.2
pyarrow==3.0.0
python-dateutil==2.8.1
python37-sagemaker-pyspark==1.4.1
pytz==2021.1
PyYAML==5.3.1
regex==2020.10.28
s3fs==2021.5.0
s3transfer==0.4.2
six==1.15.0
tqdm==4.51.0
typing-extensions==3.10.0.0
urllib3==1.26.4
windmill==1.6
wrapt==1.12.1
yarl==1.6.3
```

### 5.9 EMRからPyArrow(S3ファイルアクセス)を実行

```python
# -*- coding:utf8 -*-
# Parquetフォーマットへの変換
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq

df = pd.read_csv('s3://targetbucket/wk_0520/tdfk.csv')
table = pa.Table.from_pandas(df)
pq.write_table(table, './tdfk.parquet')
```

