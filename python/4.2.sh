#!/bin/bash


import boto3
import json

# Python dictionary for JSON data
jsonData = {
    "분류": "운영 관리",
    "코드": "4.2",
    "위험도": "중요도 중",
    "진단항목": "RDS 암호화 설정",
    "대응방안": {
        "설명": "RDS는 데이터 보호를 위해 DB 인스턴스에서 암호화 옵션 기능을 제공하며, 암호화 시 AES-256 암호화 알고리즘을 이용하여 DB 인스턴스의 모든 로그, 백업 및 스냅샷 암호화가 가능합니다.",
        "설정방법": [
            "데이터베이스 클릭",
            "DB 생성 방식 및 엔진 등 설정",
            "데이터베이스 암호화 설정",
            "데이터베이스 생성 확인",
            "데이터베이스 암호화 확인"
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
log_file_name = "rds_security_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[4.2] RDS 암호화 설정"
initial_message = f"{code}\n[양호]: 모든 RDS 인스턴스가 암호화되어 있는 경우\n[취약]: 하나 이상의 RDS 인스턴스가 암호화되지 않은 경우\n"
log_message(initial_message, log_file_name)

bar()

# AWS SDK setup
rds = boto3.client('rds')

# Fetching all RDS instances
try:
    instances = rds.describe_db_instances()
    if instances['DBInstances']:
        print("RDS Instances and their encryption status:")
        for instance in instances['DBInstances']:
            print(f"Instance ID: {instance['DBInstanceIdentifier']}, Encrypted: {instance['StorageEncrypted']}")
            if not instance['StorageEncrypted']:
                jsonData['진단결과'] = "취약"
    else:
        print("No RDS instances found.")
except Exception as e:
    print("Failed to retrieve RDS instances. Error:", str(e))
    jsonData['진단결과'] = "취약"

# Log results
result_message = f"Diagnosis result: {jsonData['진단결과']}"
log_message(result_message, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
