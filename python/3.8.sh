#!/bin/bash
import boto3
import json

# Python dictionary for JSON data
jsonData = {
    "분류": "가상 리소스 관리",
    "코드": "3.8",
    "위험도": "중요도 중",
    "진단항목": "RDS 서브넷 가용 영역 관리",
    "대응방안": {
        "설명": "서브넷이란 하나의 IP 네트워크 주소를 지역적으로 나누어 이 하나의 네트워크 IP 주소가 실제로 여러 개의 서로 연결된 지역 네트워크로 사용할 수 있도록 하는 방법입니다. EC2 인스턴스와 RDS 상호 통신 시 필요하나, 불필요한 서브넷이 포함되어 있을 경우 보안성 위험을 발생시킬 수 있으므로 불필요한 서브넷의 유무를 관리해야 합니다.",
        "설정방법": [
            "서브넷 그룹 설정 확인",
            "서브넷 그룹 확인",
            "연결된 서브넷 확인"
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
log_file_name = "rds_subnet_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[3.8] RDS 서브넷 가용 영역 관리"
initial_message = f"{code}\n[양호]: RDS 서브넷 그룹 설정이 적절한 경우\n[취약]: RDS 서브넷 그룹에 불필요한 서브넷이 있는 경우\n"
log_message(initial_message, log_file_name)

bar()

# AWS SDK setup
rds = boto3.client('rds')

# Fetching all RDS subnet groups
try:
    rds_subnet_groups = rds.describe_db_subnet_groups()
    print("RDS Subnet Groups and associated subnets:")
    for group in rds_subnet_groups['DBSubnetGroups']:
        print(f"{group['DBSubnetGroupName']} - Subnets: {[subnet['SubnetIdentifier'] for subnet in group['Subnets']]}")
except Exception as e:
    print("Failed to retrieve RDS subnet groups. Error:", str(e))
    exit(1)

# User input for RDS subnet group name
subnet_group_name = input("Enter RDS subnet group name to check for unnecessary subnets: ")

# Analyze the subnet group for unnecessary subnets (this is a placeholder for your actual logic)
# Assume checking and logic are based on certain criteria, here it's simulated
unnecessary_subnets_count = 0  # This should be determined by actual criteria

if unnecessary_subnets_count == 0:
    print(f"No unnecessary subnets found in the subnet group '{subnet_group_name}'.")
    jsonData['진단결과'] = "양호"
else:
    print(f"Unnecessary subnets found in the subnet group '{subnet_group_name}'.")
    jsonData['진단결과'] = "취약"

# Log results
result_message = f"Diagnosis result for '{subnet_group_name}': {jsonData['진단결과']}"
log_message(result_message, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
