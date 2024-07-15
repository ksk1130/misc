# NFS調査

- [NFS調査](#nfs調査)
  - [参考URL](#参考url)
  - [想定環境](#想定環境)
  - [設定](#設定)
    - [1.NFSサーバ](#1nfsサーバ)
    - [2.NFSクライアント](#2nfsクライアント)
  - [気になる点](#気になる点)
    - [1. exportsの設定と違うマウント元を指定した場合、どのように見えるのか](#1-exportsの設定と違うマウント元を指定した場合どのように見えるのか)
    - [2. exportsの設定を書き換えた場合、NFSサーバのサービス再起動は必要か](#2-exportsの設定を書き換えた場合nfsサーバのサービス再起動は必要か)
    - [3. exportsの設定を書き換える時、NFSクライアントのアンマウントは必要か](#3-exportsの設定を書き換える時nfsクライアントのアンマウントは必要か)

## 参考URL
https://qiita.com/Higemal/items/f06a1dda931da3ac4f7a

## 想定環境
```sh
# NFSサーバ
バージョン          : 1.3.0

/share/parent.txt     # /shareをマウントできるクライアントに見せたい
      /dirA/dirA.txt  # /dirAをマウントできるクライアントに見せたい
      /dirB/dirB.txt  # /dirBをマウントできるクライアントに見せたい

# NFSクライアント
/share # クライアント側はここを固定。マウント元によって見える内容を替えてい

# クライアント
バージョン          : 1.3.0

192.168.0.31  # /share以下を見せたい
192.168.0.54  # /share/dirB以下を見せたい
```

## 設定
### 1.NFSサーバ
```sh
# /ext/exports

# /shareはraspiだけ見れる
/share 192.168.0.31/32(rw,no_root_squash,async)
# /share/dirBはdockerhostだけ見れる
/share/dirB 192.168.0.54/32(rw,no_root_squash,async)
```

### 2.NFSクライアント
```sh
# /etc/fstab

# 192.168.0.31
mount -v -t nfs 192.168.0.59:/share /share

# 192.168.0.54
mount -v -t nfs 192.168.0.59:/share/dirB /share
```

## 気になる点
### 1. exportsの設定と違うマウント元を指定した場合、どのように見えるのか
```sh
# 192.168.0.54に以下のように指定した場合、エラーとなるのか(192.168.0.59では、/share/dirBのみ定義している)
# →エラーとはならないが、アクセス可の「dirB」しか見えない
[root@localhost hoge]# mount -v -t nfs 192.168.0.59:/share /share
mount.nfs: timeout set for Sat Apr 22 19:06:45 2023
mount.nfs: trying text-based options 'vers=4.1,addr=192.168.0.59,clientaddr=192.168.0.54'

[root@localhost hoge]# ls -R /share
/share:
dirB

/share/dirB:
dirB.txt

# 想定通り、/shareとしてアクセスして、(NFS)/share/dirBが見えた(やりたいこと)
[root@localhost hoge]# mount -v -t nfs 192.168.0.59:/share/dirB /share
mount.nfs: timeout set for Sat Apr 22 19:07:29 2023
mount.nfs: trying text-based options 'vers=4.1,addr=192.168.0.59,clientaddr=192.168.0.54'

[root@localhost hoge]# ls -R /share/
/share/:
dirB.txt
```

### 2. exportsの設定を書き換えた場合、NFSサーバのサービス再起動は必要か
```sh
# 変更内容
# /share/dirBはdockerhostだけ見れる
/share/dirB 192.168.0.54/32(rw,no_root_squash,async)
↓
# /share/dirAはdockerhostだけ見れる
/share/dirA 192.168.0.54/32(rw,no_root_squash,async)
```

1. 192.168.0.54側はアンマウント
```sh
# umount /share
```

2. (NFSサーバ)exportsの設定を書き換え
```sh
# /share/dirAはdockerhostだけ見れる
/share/dirA 192.168.0.54/32(rw,no_root_squash,async)
```

3. NFSサーバのサービス再起動せずにクライアント側でマウント → 失敗
```sh
[root@localhost hoge]# mount -v -t nfs 192.168.0.59:/share/dirA /share
mount.nfs: timeout set for Sat Apr 22 19:11:28 2023
mount.nfs: trying text-based options 'vers=4.1,addr=192.168.0.59,clientaddr=192.168.0.54'
mount.nfs: mount(2): No such file or directory
mount.nfs: trying text-based options 'addr=192.168.0.59'
mount.nfs: prog 100003, trying vers=3, prot=6
mount.nfs: trying 192.168.0.59 prog 100003 vers 3 prot TCP port 2049
mount.nfs: prog 100005, trying vers=3, prot=17
mount.nfs: trying 192.168.0.59 prog 100005 vers 3 prot UDP port 20048
mount.nfs: mount(2): Permission denied
mount.nfs: mounting 192.168.0.59:/share/dirA failed, reason given by server: No such file or directory
```

4. NFSサーバのサービス再起動してからクライアント側でマウント → 成功
```sh
#NFSサーバ
[root@nfshost etc]# systemctl restart nfs-server
[root@nfshost etc]# systemctl status nfs-server
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
  Drop-In: /run/systemd/generator/nfs-server.service.d
           mqorder-with-mounts.conf
   Active: active (exited) since 土 2023-04-22 19:10:38 JST; 7s ago
  Process: 10137 ExecStopPost=/usr/sbin/exportfs -f (code=exited, status=0/SUCCESS)
  Process: 10136 ExecStopPost=/usr/sbin/exportfs -au (code=exited, status=0/SUCCESS)
  Process: 10133 ExecStop=/usr/sbin/rpc.nfsd 0 (code=exited, status=0/SUCCESS)
  Process: 10165 ExecStartPost=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)
  Process: 10150 ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS (code=exited, status=0/SUCCESS)
  Process: 10149 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
 Main PID: 10150 (code=exited, status=0/SUCCESS)
   CGroup: /system.slice/nfs-server.service

 4月 22 19:10:37 nfshost.local systemd[1]: Starting NFS server and services...
 4月 22 19:10:38 nfshost.local systemd[1]: Started NFS server and services.

#クライアント
[root@localhost hoge]# mount -v -t nfs 192.168.0.59:/share/dirA /share
mount.nfs: timeout set for Sat Apr 22 19:13:24 2023
mount.nfs: trying text-based options 'vers=4.1,addr=192.168.0.59,clientaddr=192.168.0.54'
[root@localhost hoge]# ls -R /share/
/share/:
dirA.txt
```

### 3. exportsの設定を書き換える時、NFSクライアントのアンマウントは必要か
1. 初期設定
```sh
# NFSサーバ
[root@nfshost hoge]# cat /etc/exports
# /shareはraspiだけ見れる
/share 192.168.0.31/32(rw,no_root_squash,async)
# /share/dirAはdockerhostだけ見れる
/share/dirA 192.168.0.54/32(rw,no_root_squash,async)
```

```sh
# NFSクライアント
[hoge@localhost ~]$ ls -aR /share/
/share/:
./
../
dirA.txt
```

2. 192.168.0.54の参照可能ディレクトリを/share/dirBに変更
```sh
# NFSサーバ
# /shareはraspiだけ見れる
/share 192.168.0.31/32(rw,no_root_squash,async)
# /share/dirBはdockerhostだけ見れる
/share/dirB 192.168.0.54/32(rw,no_root_squash,async)
```

3. NFSサービスを再起動
```sh
# NFSサーバ
[root@nfshost hoge]# systemctl restart nfs-server
[root@nfshost hoge]# systemctl status nfs-server
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
  Drop-In: /run/systemd/generator/nfs-server.service.d
           mqorder-with-mounts.conf
   Active: active (exited) since 水 2023-04-26 00:22:30 JST; 6s ago
```

4. NFSクライアントのマウント状態を確認
```sh
# NFSクライアント
[hoge@localhost ~]$ ls -aR /share
ls: /share にアクセスできません: 古いファイルハンドルです
```

5. NFSクライアントのマウントを解除 → 再マウント
```sh
# NFSクライアント
[root@localhost hoge]# umount /share
[root@localhost hoge]# mount -v -t nfs 192.168.0.59:/share/dirB /share
mount.nfs: timeout set for Wed Apr 26 00:27:22 2023
mount.nfs: trying text-based options 'vers=4.1,addr=192.168.0.59,clientaddr=192.168.0.54'
[hoge@localhost ~]$ ls -aR /share/
/share/:
./
../
dirB.txt
```


