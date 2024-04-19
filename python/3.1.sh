#!/usr/python3

import boto3
import json
import os
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "가상 리소스 관리",
    "코드": "3.1",
    "위험도": "중요도 상",
    "진단항목": "보안 그룹 인/아웃바운드 ANY 설정 관리",
    "대응방안": "VPC 내 보안 그룹을 통한 인/아웃바운드 트래픽을 적절하게 제어해야 합니다. 인스턴스에 할당된 보안 그룹을 검토하여 모든 포트에 대한 넓은 범위의 허용이 설정되어 있지 않도록 관리해야 합니다.",
    "설정방법": "AWS Management Console 또는 AWS CLI를 사용하여 보안 그룹의 인/아웃바운드 규칙을 검토하고 수정합니다.",
    "현황": [],
    "진단결과": "(변수: 양호, 취약)"
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
code = "[3.1] 보안 그룹 인/아웃바운드 ANY 설정 관리"
initial_message = f"{code}\n[양호]: 보안 그룹 설정이 적절한 경우\n[취약]: 보안 그룹에 넓은 범위의 포트 허용이 설정된 경우\n"
log_message(initial_message, log_file_name)

bar()

# AWS SDK setup
ec2 = boto3.client('ec2')

# Listing all security groups
response = ec2.describe_security_groups()
security_groups = response['SecurityGroups']

# Check each security group for overly permissive rules
results = []
for sg in security_groups:
    sg_id = sg['GroupId']
    inbound_any = any(
        perm for perm in sg['IpPermissions']
        if any(cidr['CidrIp'] == '0.0.0.0/0' for cidr in perm.get('IpRanges', [])) or
           any(cidr['CidrIpv6'] == '::/0' for cidr in perm.get('Ipv6Ranges', []))
    )
    outbound_any = any(
        perm for perm in sg['IpPermissionsEgress']
        if any(cidr['CidrIp'] == '0.0.0.0/0' for cidr in perm.get('IpRanges', [])) or
           any(cidr['CidrIpv6'] == '::/0' for cidr in perm.get('Ipv6Ranges', []))
    )

    if inbound_any or outbound_any:
        result = f"WARNING: Security Group '{sg_id}' has overly permissive settings."
        jsonData['진단결과'] = "취약"
    else:
        result = f"OK: Security Group '{sg_id}' settings are appropriate."
        jsonData['진단결과'] = "양호"
    results.append(result)
    log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
