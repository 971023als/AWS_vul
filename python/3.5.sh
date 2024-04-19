#!/usr/python3

import boto3
import json
import os
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "가상 리소스 관리",
    "코드": "3.5",
    "위험도": "중요도 하",
    "진단항목": "인터넷 게이트웨이 연결 관리",
    "대응방안": {
        "설명": "인터넷 게이트웨이는 VPC와 인터넷 간의 통신을 가능하게 하며, IPv4 및 IPv6 트래픽을 지원합니다. VPC 내의 모든 서브넷에 대한 인터넷 접근성을 제공하며, 설정을 적절히 관리하는 것이 중요합니다.",
        "설정방법": [
            "AWS 콘솔에서 인터넷 게이트웨이 접근",
            "VPC 내 인터넷 게이트웨이를 검토 및 필요 없는 게이트웨이 분리 및 삭제"
        ]
    },
    "현황": [],
    "진단결과": "진단 필요"
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "internet_gateway_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[3.5] 인터넷 게이트웨이 연결 관리"
initial_message = f"{code}\n[양호]: 인터넷 게이트웨이 설정이 적절한 경우\n[취약]: 인터넷 게이트웨이에 불필요한 연결이 있는 경우\n"
log_message(initial_message, log_file_name)

bar()

# AWS SDK setup
ec2 = boto3.client('ec2')

# Fetching all Internet Gateways
response = ec2.describe_internet_gateways()
print("Available Internet Gateways:")
for igw in response['InternetGateways']:
    print(f"{igw['InternetGatewayId']} - Attachments: {len(igw['Attachments'])}")

# User input for Internet Gateway ID
internet_gateway_id = input("Enter Internet Gateway ID to check: ")

# Check if the selected Internet Gateway is properly configured without any unnecessary connections
gateway_details = ec2.describe_internet_gateways(InternetGatewayIds=[internet_gateway_id])
attachments = gateway_details['InternetGateways'][0]['Attachments']
if any(att['State'] == 'available' for att in attachments):
    result = f"Internet Gateway '{internet_gateway_id}' is properly configured and active."
    jsonData['진단결과'] = "양호"
else:
    result = f"Internet Gateway '{internet_gateway_id}' has issues with its configuration or is not properly attached."
    jsonData['진단결과'] = "취약"

# Log results
log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
