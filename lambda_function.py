# -*- coding:utf-8 -*-

import os
import sys
import traceback

import boto3

client = boto3.client('ec2')


def start_natgw(Subnet, eip_id, is_production):
    if(is_production == False):
        return "dummy_start_natgw"

    response = client.create_nat_gateway(
        AllocationId=eip_id,
        SubnetId=Subnet
    )
    natid = response['NatGateway']['NatGatewayId']
    client.get_waiter('nat_gateway_available').wait(NatGatewayIds=[natid])
    print('start natgw')
    return(natid)


def atatch_natgw(natgw, Subnet, is_production):
    if(is_production == False):
        print("dummy_attach_route_table")
        return

    filters = [{'Name': 'association.subnet-id', 'Values': [Subnet]}]
    response = client.describe_route_tables(Filters=filters)
    rtb = response['RouteTables'][0]['Associations'][0]['RouteTableId']
    response = client.create_route(
        DestinationCidrBlock='0.0.0.0/0',
        NatGatewayId=natgw,
        RouteTableId=rtb
    )
    print('attached routetb')


def stop_natgw(Subnet, is_production):
    if(is_production == False):
        return "dummy_stop_nat_gw"

    filters = [{'Name': 'subnet-id', 'Values': [Subnet]},
               {'Name': 'state', 'Values': ['available']}]
    response = client.describe_nat_gateways(Filters=filters)
    natgw = response['NatGateways'][0]['NatGatewayId']
    client.delete_nat_gateway(NatGatewayId=natgw)
    print('stop natgw')


def detach_natgw(Subnet, is_production):
    if(is_production == False):
        print("dummy_detach_route_table")
        return

    filters = [{'Name': 'association.subnet-id', 'Values': [Subnet]}]
    response = client.describe_route_tables(Filters=filters)
    rtb = response['RouteTables'][0]['Associations'][0]['RouteTableId']
    response = client.delete_route(
        DestinationCidrBlock='0.0.0.0/0',
        RouteTableId=rtb
    )
    print('detach routetb')


def lambda_handler(event, context):
    natgw_state = event['natgw_state']
    subnet_id = event['subnet_id']
    eip_id = event['eip_id']

    # is_productionがTrueなら実際にリクエストを飛ばす
    #　未定義ならリクエストを飛ばさない
    is_production = False
    if('is_production' in event):
        is_production = event['is_production']
        if(is_production == 1):
            is_production = True

    if (natgw_state.lower() == 'on'):
        natgw = start_natgw(subnet_id, eip_id, is_production)
        atatch_natgw(natgw, subnet_id, is_production)
    elif (natgw_state.lower() == 'off'):
        detach_natgw(subnet_id, is_production)
        stop_natgw(subnet_id, is_production)
    else:
        print('ON or OFFを指定してください')
        sys.exit(0)
