# -*- coding:utf-8 -*-

import ConfigParser
import csv
import json
import os
import sys
import traceback

import requests
import post_slack

OS_ENV_KEY_DEVELOPER = 'access_keys_Developer'
OS_ENV_KEY_AUTHORIZATION = 'access_keys_Authorization'

REQUEST_HEADER = {}

def lambda_handler(event, context):
    natgw_state = event['natgw_state']

    if (natgw_state.lower() == 'on'):
        natgw_state = True
    elif (natgw_state.lower() == 'off'):
        natgw_state = False
    else:
        print 'ON or OFFを指定してください'
        sys.exit(0)

    # is_productionがTrueなら実際にリクエストを飛ばす
    #　未定義ならリクエストを飛ばさない
    is_production = False
    if('is_production' in event):
        is_production = event['is_production']
        if(is_production == 1):
            is_production = True

