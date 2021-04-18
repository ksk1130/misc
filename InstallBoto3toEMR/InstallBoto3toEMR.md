# オフライン環境(EMR)にBoto3をインストールする

## 段取り

1. オンライン環境でboto3をダウンロード
2. ダウンロードしたboto3からrequirements.txtを取得し、boto3自身も追加
3. requirements.txtを基に依存ライブラリを取得
4. 依存ライブラリを含めたすべてを固める
5. EMRに転送
6. 解凍してインストール
7. (補足)yumでインストール
## 1. オンライン環境でboto3をダウンロード

```bash
wget https://files.pythonhosted.org/packages/40/60/78919d8b178668aac44b5d5f4fbe660880179ada1e9000cf3ee3bfcb6421/boto3-1.17.50.tar.gz
```

## 2.ダウンロードしたboto3からrequirements.txtを取得し、boto3自身も追加

```
tar xvf boto3-1.17.50.tar.gz
mv boto3-1.17.50/requirements.txt .
echo boto3==1.17.50 >> requirements.txt
```

## 3.requirements.txtを基に依存ライブラリを取得

```bash
[ec2-user@ip-192-168-1-152 tmp]$ mkdir src
[ec2-user@ip-192-168-1-152 tmp]$ cat requirements.txt
-e git://github.com/boto/botocore.git@develop#egg=botocore
-e git://github.com/boto/jmespath.git@develop#egg=jmespath
-e git://github.com/boto/s3transfer.git@develop#egg=s3transfer
nose==1.3.3
mock==1.3.0
wheel==0.24.0
boto3==1.17.50
[ec2-user@ip-192-168-1-152 tmp]$ pip3 download -d ./src -r requirements.txt
```
## 4.依存ライブラリを含めたすべてを固める

```bash
[ec2-user@ip-192-168-1-152 tmp]$ tar czf src.tar.gz src
```

## 5.EMRに転送

```bash
[ec2-user@ip-192-168-1-152 tmp]$ sftp -i ~/.ssh/aws_kp01.pem hadoop@192.168.2.114
Connected to 192.168.2.114.
sftp> put src.tar.gz
```

## 6.解凍してインストール

```bash
tar xzf src.tar.gz
cd src/

[hadoop@ip-192-168-2-114 src]$ sudo pip3 install ./wheel-0.24.0-py2.py3-none-any.whl
[hadoop@ip-192-168-2-114 src]$ sudo pip3 install ./pbr-5.5.1-py2.py3-none-any.whl
[hadoop@ip-192-168-2-114 src]$ sudo pip3 install ./mock-1.3.0-py2.py3-none-any.whl
[hadoop@ip-192-168-2-114 src]$ sudo pip3 install ./nose-1.3.3.tar.gz
[hadoop@ip-192-168-2-114 src]$ sudo pip3 install ./python_dateutil-2.8.1-py2.py3-none-any.whl
[hadoop@ip-192-168-2-114 src]$ sudo pip3 install ./urllib3-1.26.4-py2.py3-none-any.whl
[hadoop@ip-192-168-2-114 src]$ sudo pip3 install ./botocore-1.20.50.zip
[hadoop@ip-192-168-2-114 src]$ sudo pip3 install ./s3transfer-0.3.6.zip
[hadoop@ip-192-168-2-114 src]$ sudo pip3 install ./jmespath-0.10.0.zip
[hadoop@ip-192-168-2-114 src]$ sudo pip3 install ./boto3-1.17.50.tar.gz
```

## 7. (補足)yumでインストール

```bash
# Amazon Linuxのyumリポジトリには以下のパッケージがある
python2-boto3.noarch : The AWS SDK for Python
```