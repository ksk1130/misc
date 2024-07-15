#!/usr/bin/python3
# -*- coding:utf-8 -*-

import sys
import boto3

if __name__ == '__main__':
    args = sys.argv

    if len(args) < 4:
      print("引数は4つ指定してください")
      sys.exit()

    path1 = args[1]
    path2 = args[2]
    path3 = args[3]
    path4 = args[4]

    try:
        # S3からCopyスクリプトを取得
        bucket = "targetbucket"
        file = "sqls/05_copy_replace_sample.sql"

        s3 = boto3.client('s3',endpoint_url='http://192.168.0.54:9000',
                           aws_access_key_id='minio_access_key',
                           aws_secret_access_key='minio_secret_key')
        sqls = s3.get_object(Bucket=bucket, Key=file)['Body'].read().decode('utf-8')
        sqls = sqls.split(';')

        for i in range(len(sqls)):
          # %s×4より長かったら処理実行
          if len(sqls[i]) > 8:
              sql = sqls[i] % (path1,path2,path3,path4)
              print(sql)

    except Exception as e:
        print(e)
    
