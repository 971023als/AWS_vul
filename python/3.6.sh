#!/usr/python3

import boto3
import json
import os
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "가상 리소스 관리",
    "코드": "3.6",
    "위험도": "중요도 중",
    "진단항목": "NAT 게이트웨이 연결 관리",
    "대응방안": {
        "설명": "NAT 게이트웨이는 프라이빗 서브넷의 인스턴스가 인터넷과 통신할 수 있게 해주면서, 인터넷에서 직접적인 연결을 차단합니다. 이는 인스턴스의 보안을 강화하는 중요한 요소입니다.",
        "설정방법": [
            "AWS Management Console에서 VPC 섹션으로 이동",
            "NAT 게이트웨이 설정 검토 및 적절한 서브넷에 연결"
        ]
    },
    "현황": [],
    "진단결과": "양호"
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "nat_gateway_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[3.6] NAT 게이트웨이 연결 관리"
initial_message = f"{code}\n[양호]: NAT 게이트웨이 설정이 적절하게 관리되고 있는 경우\n[취약]: NAT 게이트웨이에 불필요한 연결이 존재하는 경우\n"
log_message(initial_message, log_file_name)

bar()

# AWS SDK setup
ec2 = boto3.client('ec2')

# Fetching all NAT Gateways
nat_gateways = ec2.describe_nat_gateways()
print("Available NAT Gateways:")
for ngw in nat_gateways['NatGateways']:
    print(f"{ngw['NatGatewayId']} - State: {ngw['State']} - SubnetId: {ngw['SubnetId']} - VpcId: {ngw['VpcId']}")

# User input for NAT Gateway ID
nat_gateway_id = input("Enter NAT Gateway ID to check: ")

# Check the NAT Gateway's connections and configurations
nat_details = ec2.describe_nat_gateways(NatGatewayIds=[nat_gateway_id])
if nat_details['NatGateways']:
    ngw_details = nat_details['NatGateways'][0]
    if ngw_details['State'] == 'available' and ngw_details['SubnetId']:
        result = f"NAT Gateway '{nat_gateway_id}' is properly configured in Subnet '{ngw_details['SubnetId']}'"
        jsonData['진단결과'] = "양호"
    else:
        result = f"NAT Gateway '{nat_gateway_id}' is not properly configured."
        jsonData['진단결과'] = "취약"
else:
    result = "NAT Gateway not found or incorrect ID."
    jsonData['진단결과'] = "에러 발생"

# Log results
log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
