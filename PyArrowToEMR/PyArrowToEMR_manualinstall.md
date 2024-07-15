# EMRへのPyArrowの導入

## 方針

極力外部からのrpmとAmazonLinuxのリポジトリのモジュールでPyArrowをセットアップする

## 必要なファイルの入手

```bash
wget https://files.pythonhosted.org/packages/d3/38/adc49a5aca4f644e6322237089fdcf194084f5fe41445e6e632f28b32bf7/Cython-0.29.22.tar.gz
wget https://github.com/numpy/numpy/releases/download/v1.20.2/numpy-1.20.2.tar.gz
wget https://files.pythonhosted.org/packages/e8/81/f7be049fe887865200a0450b137f2c574647b9154503865502cfd720ab5d/pandas-1.2.4.tar.gz
wget https://files.pythonhosted.org/packages/62/d3/a482d8a4039bf931ed6388308f0cc0541d0cab46f0bbff7c897a74f1c576/pyarrow-3.0.0.tar.gz
wget https://files.pythonhosted.org/packages/c4/d5/e50358c82026f44cd8810c8165002746cd3f8b78865f6bcf5d7f0fe4f652/setuptools_scm-6.0.1-py3-none-any.whl
wget https://files.pythonhosted.org/packages/ae/42/2876a3a136f8bfa9bd703518441c8db78ff1eeaddf174baa85c083c1fd15/setuptools-56.0.0-py3-none-any.whl
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
wget https://apache.bintray.com/arrow/centos/7/apache-arrow-release-latest.rpm
```

## インストール

```bash
sudo yum install python3-devel
sudo yum install git
sudo yum install cmake3
sudo ln -s /usr/bin/cmake3 /usr/bin/cmake
sudo pip3 install ./Cython-0.29.22.tar.gz
sudo pip3 install ./numpy-1.20.2.tar.gz
sudo pip3 install setuptools-56.0.0-py3-none-any.whl
sudo pip3 install setuptools_scm-6.0.1-py3-none-any.whl

sudo rpm -ivh epel-release-latest-7.noarch.rpm
sudo rpm -ivh apache-arrow-release-latest.rpm
sudo pip3 install ./pyarrow-3.0.0.tar.gz
```

## 結論

どうやらAmazonLinuxのリポジトリにあるモジュールではPyArrowをセットアップできなさそうなため、NatGW経由でPyArrowを導入したAMIを使ってEMRを起動することとする。