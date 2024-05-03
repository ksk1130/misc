# PostgreSQLのマイグレ手順

## create database取得のため、全DBをダンプする
```
pg_dumpall -f pg96_all.sql -U postgres
```

## 各DBをダンプする
```
pg_dump iij    > /tmp/iij_$(date +%Y%m%d).dump
pg_dump postal > /tmp/postal_$(date +%Y%m%d).dump
```

## Container -> Host(コンテナID、ファイル名の日付は都度確認)
```
docker cp 03bc58d63507:/tmp/pg96_all.sql pg96_all.sql
docker cp 03bc58d63507:/tmp/iij_20220819.dump     iij_20220819.dump
docker cp 03bc58d63507:/tmp/postal_20220819.dump  postal_20220819.dump
```

## pg96_all.sqlにはデータも含まれるため、CREATE DATABASEのみ抜粋する
```
pg96_createdb.sql
```

## Host -> Container(コンテナID、ファイル名の日付は都度確認)
```
docker cp pg96_createdb.sql    326c81fe957a:/tmp/pg96_createdb.sql
docker cp iij_20220819.dump    326c81fe957a:/tmp/iij_20220819.dump
docker cp postal_20220819.dump 326c81fe957a:/tmp/postal_20220819.dump
```
## リストア手順
### DB作成
```
$ psql -f /tmp/pg96_createdb.sql -U postgres
```

### DBリストア
```
$ psql -f /tmp/iij_20220819.dump -U postgres -d iij
$ psql -f /tmp/postal_20220819.dump -U postgres -d postal
```
