#!/usr/bin/python3
# -*- coding:utf-8 -*-

import pg
import sys
import boto3

# Redshiftへクエリを送る
def query(con,statement):
    res = con.query(statement)
    return res

# Redshiftへの接続を行う
def get_connection(hostname, port, db_name, db_user, db_pw):

    rs_conn_string = "host=%s port=%s dbname=%s user=%s password=%s" % (hostname, port, db_name, db_user, db_pw)
    rs_conn = pg.connect(dbname=rs_conn_string)
    rs_conn.query("set statement_timeout = 1200000")

    return rs_conn

if __name__ == '__main__':
    args = sys.argv

    hostname = args[1]
    port = args[2]
    db_name = args[3]
    db_user = args[4]
    db_pw = args[5]

    con = None

    try:
        # コネクション確立
        con = get_connection(hostname, port, db_name, db_user, db_pw)

        # S3からCopyスクリプトを取得
        bucket = "targetbucket"
        #file = "sqls/06_select_sample.sql"

        s3 = boto3.client('s3',endpoint_url='http://192.168.0.54:9000',
                          aws_access_key_id='minio_access_key',
                          aws_secret_access_key='minio_secret_key')
        # 本番S3なら以下のように記述
        #s3 = boto3.client('s3')

        # 指定したバケットから、Prefixを含むオブジェクトを抽出
        response = s3.list_objects(
            Bucket=bucket,
            Prefix='sqls/'
        )

        # 抽出結果からキーを取得。*1,000件を超える場合は工夫が必要(1回に1,000件までしか取れないため)
        if 'Contents' in response:  
              keys = [content['Key'] for content in response['Contents']]
              print(keys)

        for key in keys:
            sqls = s3.get_object(Bucket=bucket, Key=key)['Body'].read().decode('utf-8')
            sqls = sqls.split(';')
            sql = sqls[0]
            print(sql)

        #result = query(con, sql)
        #print(result)

    except pg.InternalError  as e:
        print(e)
    except Exception as e:
        print(e)
    finally:
        if con is not None:
           con.close()
    
