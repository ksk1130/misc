# AWS CLIでのMVコマンドを調べる

## 目的

1. mvコマンドの挙動(移動がメイン、リネームもできる)を調べる
2. 以下の操作を行い、期待する挙動か確認する
   1. ローカル→S3
   2. S3→S3(場所移動あり、リネームなし)
   3. S3→S3(場所移動なし、リネームあり)
   4. S3→S3(場所移動あり、リネームあり)
3. まとめ

## 操作

### S3に実験用フォルダ作成

```sh
s3://targetbucket/test20210413/from/
s3://targetbucket/test20210413/to/
```

### ダミーファイル作成(ある程度大きいサイズが良いので100MBで)

```
# Windowsでダミーファイルを作る
fsutil file createnew dummyfile100mb 104857600
```

## 以下の操作を行い、期待する挙動か確認する

### ローカル→S3

```
aws s3 cp .\dummyfile100mb s3://targetbucket/test20210413/from/
aws s3 ls s3://targetbucket/test20210413/from/
→移動された
```

### S3→S3(場所移動あり、リネームなし)

```
aws s3 mv s3://targetbucket/test20210413/from/dummyfile100mb s3://targetbucket/test20210413/to/
aws s3 ls s3://targetbucket/test20210413/from/
aws s3 ls s3://targetbucket/test20210413/to/
→移動された
```

### S3→S3(場所移動なし、リネームあり)

```
aws s3 mv s3://targetbucket/test20210413/to/dummyfile100mb s3://targetbucket/test20210413/to/dummyfile100mb2
aws s3 ls s3://targetbucket/test20210413/to/
→リネームされた
```

### S3→S3(場所移動あり、リネームあり)

```
aws s3 mv s3://targetbucket/test20210413/to/dummyfile100mb2 s3://targetbucket/test20210413/from/dummyfile100mb3
aws s3 ls s3://targetbucket/test20210413/from/
aws s3 ls s3://targetbucket/test20210413/to/
→移動され、リネームされた
```

## まとめ

1. S3toS3でもmvでは移動できるし、リネームもできる(リネームしながら移動もできる)