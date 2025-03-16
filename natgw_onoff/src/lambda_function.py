# -*- coding:utf-8 -*-

import os
import sys
import traceback

import boto3

# NAT Gatewayを起動する
def start_natgw(client, Subnet, eip_id, is_production):
    # 検証用フラグがFalseの場合はダミーの値を返す
    if(is_production == False):
        return "dummy_start_natgw"

    response = client.create_nat_gateway(
        AllocationId=eip_id,
        SubnetId=Subnet
    )
    natid = response['NatGateway']['NatGatewayId']
    # Waiterを使ってNAT Gatewayが利用可能になるまで待つ
    client.get_waiter('nat_gateway_available').wait(NatGatewayIds=[natid])
    print('start natgw')
    return(natid)

# ルートテーブルのルートにNAT Gatewayをアタッチする
def atatch_natgw(client, natgw, Subnet, is_production):
    # 検証用フラグがFalseの場合はダミーの値を返す
    if(is_production == False):
        print("dummy_attach_route_table")
        return

    filters = [{'Name': 'association.subnet-id', 'Values': [Subnet]}]
    response = client.describe_route_tables(Filters=filters)
    rtb = response['RouteTables'][0]['Associations'][0]['RouteTableId']
    # ルートテーブルにNAT Gatewayをアタッチする
    response = client.create_route(
        DestinationCidrBlock='0.0.0.0/0',
        NatGatewayId=natgw,
        RouteTableId=rtb
    )
    print('attached routetb')

# NAT Gatewayを停止する
def stop_natgw(client, Subnet, is_production):
    # 検証用フラグがFalseの場合はダミーの値を返す
    if(is_production == False):
        return "dummy_stop_nat_gw"

    filters = [{'Name': 'subnet-id', 'Values': [Subnet]},
               {'Name': 'state', 'Values': ['available']}]
    response = client.describe_nat_gateways(Filters=filters)
    natgw = response['NatGateways'][0]['NatGatewayId']
    client.delete_nat_gateway(NatGatewayId=natgw)
    # Waiterを使ってNAT Gatewayが削除されるまで待つ
    client.get_waiter('nat_gateway_deleted').wait(NatGatewayIds=[natgw])
    print('stop natgw')

# ルートテーブルのルートからNAT Gatewayをデタッチする
def detach_natgw(client, Subnet, is_production):
    # 検証用フラグがFalseの場合はダミーの値を返す
    if(is_production == False):
        print("dummy_detach_route_table")
        return

    filters = [{'Name': 'association.subnet-id', 'Values': [Subnet]}]
    response = client.describe_route_tables(Filters=filters)
    rtb = response['RouteTables'][0]['Associations'][0]['RouteTableId']
    # ルートテーブルからNAT Gatewayをデタッチする
    response = client.delete_route(
        DestinationCidrBlock='0.0.0.0/0',
        RouteTableId=rtb
    )
    print('detach routetb')


def lambda_handler(event, context):
    client = boto3.client('ec2', region_name='ap-northeast-1')

    # 各種パラメータを環境変数から取得
    natgw_state = os.environ['natgw_state']
    subnet_id = os.environ['subnet_id']
    eip_id = os.environ['eip_id']

    # is_productionがTrueなら実際にリクエストを飛ばす
    #　未定義ならリクエストを飛ばさない
    is_production = False
    if('is_production' in event):
        is_production = event['is_production']
        if(is_production == 1):
            is_production = True

    if (natgw_state.lower() == 'on'):
        natgw = start_natgw(client, subnet_id, eip_id, is_production)
        atatch_natgw(client, natgw, subnet_id, is_production)
    elif (natgw_state.lower() == 'off'):
        detach_natgw(subnet_id, is_production)
        stop_natgw(subnet_id, is_production)
    else:
        print('ON or OFFを指定してください')
        sys.exit(0)
