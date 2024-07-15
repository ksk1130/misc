FROM python:3.8-slim

run apt -y update && apt -y upgrade
run apt -y install libpq-dev
run apt -y install gcc
run apt clean

run pip3 install -U pip
run pip3 install setuptools
run pip3 install wheel
run pip3 install PyGreSQL
run pip3 install boto3

copy 03_scripts/ /tmp/03_scripts/
workdir /tmp/03_scripts
run python3 setup.py bdist_egg
run python3 /usr/local/lib/python3.8/site-packages/setuptools/command/easy_install.py dist/redshift_module-0.1-py3.8.egg

CMD ["sh"]
