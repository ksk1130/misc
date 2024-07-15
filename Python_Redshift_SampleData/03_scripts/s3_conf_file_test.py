#!/usr/bin/python3
# -*- coding:utf-8 -*-

import sys
import boto3

if __name__ == '__main__':
    args = sys.argv

    targets = ['s3/table_a','s3/table_b','s3/table_c','s3/table_d']

    try:
        # S3からCopyスクリプトを取得
        bucket = "targetbucket"
        file = "sqls/07_tables.sql"

        s3 = boto3.client('s3',endpoint_url='http://192.168.0.54:9000',
                          aws_access_key_id='minio_access_key',
                          aws_secret_access_key='minio_secret_key')
        # 本番S3なら以下のように記述
        #s3 = boto3.client('s3')
        sqls = s3.get_object(Bucket=bucket, Key=file)['Body'].read().decode('utf-8')
        sqls = sqls.split('\n')
        sqls = [s for s in sqls if len(s) > 0]

        newl = []
        for sql in sqls:
            newl = newl + [s for s in targets if sql in s]

        for l in newl:
          print(l)

    except Exception as e:
        print(e)
    
