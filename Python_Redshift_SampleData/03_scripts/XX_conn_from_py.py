#!/usr/bin/python3
# -*- coding:utf-8 -*-

import pg
import sys
import boto3
from redshift_module import rs_utils as rs_common

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
        con = rs_common.get_connection(hostname, port, db_name, db_user, db_pw)

        # S3からCopyスクリプトを取得
        bucket = "targetbucket"
        file = "sqls/04_copy_from_s3.sql"

        s3 = boto3.client('s3')
        sqls = s3.get_object(Bucket=bucket, Key=file)['Body'].read().decode('utf-8')
        sqls = sqls.split(';')
        sql = sqls[0]

        result = rs_common.query(con, "truncate table members")
        print(result)
        
        result = rs_common.query(con, sql)
        print(result)
        
        result = rs_common.query(con, "select count(*) from members")
        print(result)

        result = rs_common.query(con, "truncate table members")
        print(result)
    except pg.InternalError  as e:
        print(e)
    except Exception as e:
        print(e)
    finally:
        if con is not None:
           con.close()
    
