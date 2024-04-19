#!/bin/bash
import boto3
import json

# Python dictionary for JSON data
jsonData = {
    "분류": "권한 관리",
    "코드": "2.1",
    "위험도": "중요도 상",
    "진단항목": "인스턴스 서비스 정책 관리",
    "대응방안": ("AWS 인스턴스 서비스(EC2, RDS, S3 등)의 리소스 생성 또는 액세스 권한은 IAM 자격 증명(사용자, 그룹, 역할)에 연결된 권한 정책에 따라 결정됩니다. "
                 "적절한 권한을 통한 서비스 관리가 이루어져야 하며, 서비스 별 관리형 정책을 철저히 설정해야 합니다."),
    "설정방법": ("가. 인스턴스 IAM 관리자/운영자 권한 그룹 생성: 1) IAM 내 그룹 탭 접근, 2) 새로운 그룹 생성, 3) 필요한 권한 정책 연결, 4) 그룹 생성 확인"),
    "현황": [],
    "진단결과": "(변수: 양호, 취약)"
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "instance_service_policy_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[2.1] 인스턴스 서비스 정책 관리"
initial_message = f"{code}\n[양호]: 필요한 정책이 모두 연결되어 있는 경우\n[취약]: 필요한 정책이 모두 연결되어 있지 않은 경우\n"
log_message(initial_message, log_file_name)

bar()

# Check IAM policies using boto3
iam = boto3.client('iam')
try:
    response = iam.list_policies(Scope='Local')
    policy_names = [policy['PolicyName'] for policy in response['Policies'] if policy['PolicyName'] in ['AmazonEC2FullAccess', 'AmazonRDSFullAccess', 'AmazonS3FullAccess']]
    
    if not policy_names:
        result = "Required policies are not fully attached.\n"
        jsonData['진단결과'] = "취약"
    else:
        result = "Required policies are correctly attached:\n" + ', '.join(policy_names) + "\n"
        jsonData['진단결과'] = "양호"

except Exception as e:
    result = f"Failed to retrieve IAM policies: {str(e)}\n"
    jsonData['진단결과'] = "에러 발생"

log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
