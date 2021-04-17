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

### テーブル作成

### データ投入

### データ検索

### データ削除

### テーブル削除

## boto3からDynamo

### テーブル一覧

### テーブル作成

### データ投入

### データ検索

### データ削除

### テーブル削除

## 4. EMRからDynamo

### boto3のインストール（ブートストラップアクション）

### データ投入（boto3から）