import os
import boto3
from moto import mock_aws
import pytest
from lambda_function import start_natgw, atatch_natgw, stop_natgw, detach_natgw
from unittest.mock import patch

REGION = "ap-northeast-1"

@pytest.fixture
def ec2_client():
    with mock_aws():
        client = boto3.client("ec2", region_name=REGION)

        # VPCを作成
        vpc = client.create_vpc(CidrBlock="10.0.0.0/16")
        vpc_id = vpc["Vpc"]["VpcId"]

        # 必要に応じてリソースを作成
        subnet = client.create_subnet(CidrBlock="10.0.0.0/24", VpcId=vpc_id)
        eip = client.allocate_address(Domain="vpc")
        yield client, subnet["Subnet"]["SubnetId"], eip["AllocationId"], vpc_id

@mock_aws
def test_start_natgw(ec2_client):
    client, subnet_id, eip_id, vpc_id = ec2_client
    
    # テストの実行
    natgw_id = start_natgw(client, subnet_id, eip_id, True)
    assert natgw_id.startswith("nat-")

    # モックされたNAT Gatewayが作成されているかを確認
    response = client.describe_nat_gateways(NatGatewayIds=[natgw_id])
    assert response["NatGateways"][0]["State"] == "available"

@mock_aws
def test_atatch_natgw(ec2_client):
    client, subnet_id, eip_id, vpc_id = ec2_client

    # 必要なリソースを作成
    rtb = client.create_route_table(VpcId=vpc_id)["RouteTable"]["RouteTableId"]
    client.associate_route_table(SubnetId=subnet_id, RouteTableId=rtb)

    # テストの実行
    atatch_natgw(client, "nat-123456", subnet_id, True)

    # モックされたルートが作成されているかを確認
    response = client.describe_route_tables(RouteTableIds=[rtb])
    routes = response["RouteTables"][0]["Routes"]
    print(response["RouteTables"])
    assert any(route["DestinationCidrBlock"] == "0.0.0.0/0" for route in routes)

@mock_aws
def test_stop_natgw(ec2_client):
    client, subnet_id, eip_id, vpc_id = ec2_client

    # 必要なNAT Gatewayを作成
    natgw = client.create_nat_gateway(AllocationId=eip_id, SubnetId=subnet_id)
    natgw_id = natgw["NatGateway"]["NatGatewayId"]

    # テストの実行
    stop_natgw(client, subnet_id, True)

    # モックされたNAT Gatewayが削除されているかを確認
    response = client.describe_nat_gateways(NatGatewayIds=[natgw_id])
    assert response['NatGateways'][0]['State'] == 'deleted'

@mock_aws
def test_detach_natgw(ec2_client):
    client, subnet_id, eip_id, vpc_id = ec2_client

    # 必要なリソースを作成
    rtb = client.create_route_table(VpcId=vpc_id)["RouteTable"]["RouteTableId"]
    client.associate_route_table(SubnetId=subnet_id, RouteTableId=rtb)
    client.create_route(
        RouteTableId=rtb,
        DestinationCidrBlock="0.0.0.0/0",
        NatGatewayId="nat-123456"
    )

    # テストの実行
    detach_natgw(client, subnet_id, True)

    # モックされたルートが削除されているかを確認
    response = client.describe_route_tables(RouteTableIds=[rtb])
    routes = response["RouteTables"][0]["Routes"]
    assert not any("NatGatewayId" in route for route in routes)
