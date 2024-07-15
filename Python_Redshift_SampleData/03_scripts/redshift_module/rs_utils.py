#!/usr/bin/python3
# -*- coding:utf-8 -*-

import pg

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
    
