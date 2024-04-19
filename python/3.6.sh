#!/bin/bash
import boto3
import json

# Python dictionary for JSON data
jsonData = {
    "분류": "가상 리소스 관리",
    "코드": "3.6",
    "위험도": "중요도 중",
    "진단항목": "NAT 게이트웨이 연결 관리",
    "대응방안": {
        "설명": ("NAT 게이트웨이는 NAT 디바이스를 사용하여 프라이빗 서브넷의 인스턴스를 인터넷(예: 소프트웨어 업데이트용) 또는 기타 AWS 서비스에 연결하는 한편, "
                 "인터넷에서 해당 인스턴스와의 연결을 시작하지 못하도록 합니다. 트래픽이 인터넷으로 이동하면 소스 IPv4 주소가 NAT 디바이스의 주소로 대체되고, "
                 "이와 마찬가지로 응답 트래픽이 해당 인스턴스로 이동하면 NAT 디바이스에서 주소를 해당 인스턴스의 프라이빗 IPv4 주소로 다시 변환합니다."),
        "설정방법": [
            "NAT 게이트웨이 생성 및 프라이빗 연결 확인",
            "VPC 내 NAT 게이트웨이 탭 접근 후 NAT 게이트웨이 삭제 클릭"
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
initial_message = f"{code}\n[양호]: NAT 게이트웨이 설정이 적절한 경우\n[취약]: NAT 게이트웨이에 불필요한 연결이 있는 경우\n"
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

# Check for unnecessary connections to the NAT Gateway
network_interfaces = ec2.describe_network_interfaces(Filters=[{'Name': 'attachment.nat-gateway-id', 'Values': [nat_gateway_id]}])

# Determine if there are active connections
if network_interfaces['NetworkInterfaces']:
    result = f"NAT Gateway '{nat_gateway_id}' has connections: {len(network_interfaces['NetworkInterfaces'])}"
    jsonData['진단결과'] = "취약"
else:
    result = f"NAT Gateway '{nat_gateway_id}' has no active connections or is not connected to intended resources."
    jsonData['진단결과'] = "양호"

# Log results
log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
