#!/bin/bash
import boto3
import json

# Python dictionary for JSON data
jsonData = {
    "분류": "가상 리소스 관리",
    "코드": "3.4",
    "위험도": "중요도 중",
    "진단항목": "라우팅 테이블 정책 관리",
    "대응방안": "라우팅 테이블에는 네트워크 트래픽을 전달할 위치 결정 시 사용되는 규칙입니다. VPC의 각 서브넷을 라우팅 테이블에 연결해야 하며, 테이블에서는 서브넷에 대한 라우팅을 제어하게 됩니다. 기본 라우팅 테이블은 다른 라우팅 테이블과 명시적으로 연결되지 않은 모든 서브넷에 대한 라우팅을 제어합니다.",
    "설정방법": "VPC 내 라우팅 테이블 탭 접근 후 라우팅 편집 클릭, 라우팅 테이블 설정 및 저장",
    "진단기준": "양호기준: 라우팅 테이블 내 ANY 정책이 설정되어 있지 않고 서비스 타깃 별로 설정되어 있을 경우, 취약기준: 라우팅 테이블 내 ANY 정책이 설정되어 있거나 서비스 타깃 별로 설정되어 있지 않을 경우",
    "현황": [],
    "진단결과": "진단 필요"
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "routing_table_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[3.4] 라우팅 테이블 정책 관리"
initial_message = f"{code}\n[양호]: 라우팅 테이블 설정이 적절한 경우\n[취약]: 라우팅 테이블에 적절하지 않은 정책이 포함된 경우\n"
log_message(initial_message, log_file_name)

bar()

# AWS SDK setup
ec2 = boto3.client('ec2')

# Fetching all Routing Tables
response = ec2.describe_route_tables()
print("Available Routing Tables:")
for rt in response['RouteTables']:
    print(f"{rt['RouteTableId']} - Routes: {len(rt['Routes'])}")

# User input for Routing Table ID
rt_id = input("Enter Routing Table ID to check policies: ")

# Retrieve the specified Routing Table's policies
routing_table_details = ec2.describe_route_tables(RouteTableIds=[rt_id])
routes = routing_table_details['RouteTables'][0]['Routes']

print("Routing Table Policies:")
print(json.dumps(routes, indent=2))

# Assessing the Routing Table policies based on user checks
policy_check = input("Does this Routing Table contain ANY policies or lacks service target specific policies? (yes/no): ")

if policy_check == "yes":
    result = "Routing Table contains ANY policies or lacks service target specific policies. It is vulnerable."
    jsonData['진단결과'] = "취약"
else:
    result = "Routing Table policies are appropriate without ANY policies and are service target specific. It is satisfactory."
    jsonData['진단결과'] = "양호"

# Log results
log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
