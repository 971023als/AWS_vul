#!/usr/python3

import boto3
import json
import os
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "가상 리소스 관리",
    "코드": "3.2",
    "위험도": "중요도 상",
    "진단항목": "보안 그룹 인/아웃바운드 불필요 정책 관리",
    "대응방안": {
        "설명": "VPC에서의 보안 그룹은 EC2 인스턴스에 대한 인/아웃바운드 트래픽을 제어하는 가상 방화벽 역할을 합니다. 보안 그룹을 통해 서브넷이 아닌 인스턴스 수준에서 트래픽을 제어하여, 각 인스턴스에 서로 다른 보안 그룹을 할당할 수 있습니다. 이를 통해 네트워크 프로토콜과 포트 범위에 따른 규칙을 설정하여 특정 소스에서만 통신이 가능하도록 합니다.",
        "설정방법": [
            "EC2 대시보드로 이동",
            "보안 그룹 선택 및 인바운드, 아웃바운드 규칙 검토",
            "불필요하거나 너무 넓은 범위로 설정된 규칙 수정 또는 삭제"
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
log_file_name = "security_group_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[3.2] 보안 그룹 인/아웃바운드 불필요 정책 관리"
initial_message = f"{code}\n[양호]: 보안 그룹 규칙이 적절한 경우\n[취약]: 보안 그룹에 불필요한 넓은 범위의 규칙이 있는 경우\n"
log_message(initial_message, log_file_name)

bar()

# AWS SDK setup
ec2 = boto3.client('ec2')

# Fetching all security groups
security_groups = ec2.describe_security_groups()
print("Available Security Groups:")
for sg in security_groups['SecurityGroups']:
    print(f"{sg['GroupId']} - {sg['GroupName']} - {sg['Description']}")

# User input for Security Group ID
sg_id = input("Enter Security Group ID to check inbound/outbound rules: ")

# Retrieve the specified security group's inbound and outbound rules
inbound_rules = ec2.describe_security_groups(GroupIds=[sg_id])['SecurityGroups'][0]['IpPermissions']
outbound_rules = ec2.describe_security_groups(GroupIds=[sg_id])['SecurityGroups'][0]['IpPermissionsEgress']

print("Inbound Rules:")
print(json.dumps(inbound_rules, indent=2))
print("Outbound Rules:")
print(json.dumps(outbound_rules, indent=2))

# Assessment based on user evaluation
inbound_status = input("Are there any unnecessary policies in inbound rules? (yes/no): ")
outbound_status = input("Are there any unnecessary policies in outbound rules? (yes/no): ")

if inbound_status == "yes" or outbound_status == "yes":
    result = "At least one security rule is identified as unnecessary. Recommend reviewing and updating the policies."
    jsonData['진단결과'] = "취약"
else:
    result = "No unnecessary policies detected. Security group settings are appropriate."
    jsonData['진단결과'] = "양호"

# Log results
log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii
