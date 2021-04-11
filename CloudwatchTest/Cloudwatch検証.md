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
aws logs put-log-events --log-group-name "LogGroupTest" --log-stream-name "LogStreamTest" --log-events timestamp=1618154580,message='Hello1'

# timestampはunixtimeなので、Powershellでunixtimeを生成する
((Get-Date("2021/4/12 00:23:00")) - (Get-Date("1970/1/1 0:0:0 GMT"))).TotalSeconds

```

  