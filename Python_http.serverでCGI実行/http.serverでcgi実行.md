# http.serverでcgiを実行する方法

## 前提
python3系であること(検証はdockerコンテナで実施)
あらかじめコンテナ実行時に -p <ローカル側のポート>:8001としておくこと

## 実施手順
### python3コンテナに入った状態で以下を実行
```Shell
mkdir cgi-bin
touch cgi-bin/hoge.py
chmod +x cgi-bin/hoge.py
echo '#!/usr/local/bin/python'            >  cgi-bin/hoge.py
echo                                      >> cgi-bin/hoge.py
echo 'print("Content-Type: text/html\n")' >> cgi-bin/hoge.py
echo 'print("hoge")'                      >> cgi-bin/hoge.py
cat cgi-bin/hoge.py

# 8001で公開
python -m http.server 8001 --cgi
```
