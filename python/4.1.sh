#!/bin/bash


import boto3
import json

# Python dictionary for JSON data
jsonData = {
    "분류": "운영 관리",
    "코드": "4.1",
    "위험도": "중요도 중",
    "진단항목": "EBS 및 볼륨 암호화 설정",
    "대응방안": {
        "설명": "EBS는 EC2 인스턴스 생성 및 이용 시 사용되는 블록 형태의 스토리지 볼륨이며, AES-256 알고리즘을 사용하여 볼륨 암호화를 지원합니다. 이는 데이터 및 애플리케이션에 대한 보안을 강화하여 안전하게 정보를 저장할 수 있게 해줍니다.",
        "설정방법": [
            "인스턴스 시작 클릭",
            "AMI 선택",
            "인스턴스 유형 선택",
            "인스턴스 구성",
            "스토리지 추가",
            "태그 추가",
            "보안 그룹 구성",
            "스토리지 암호화 여부 확인",
            "EC2 인스턴스 클릭 및 스토리지 클릭",
            "스토리지 암호화 설정여부 확인",
            "Elastic Block Store 메뉴 내 볼륨 기능 선택",
            "볼륨 생성 메뉴 내 '암호화' 활성화 후 KMS 키 값을 추가하여 설정"
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
log_file_name = "ebs_security_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[4.1] EBS 및 볼륨 암호화 설정"
initial_message = f"{code}\n[양호]: 모든 EBS 볼륨이 암호화되어 있는 경우\n[취약]: 하나 이상의 EBS 볼륨이 암호화되지 않은 경우\n"
log_message(initial_message, log_file_name)

bar()

# AWS SDK setup
ec2 = boto3.client('ec2')

# Fetching all EBS volumes
try:
    volumes = ec2.describe_volumes()
    if volumes['Volumes']:
        print("EBS Volumes and their encryption status:")
        for volume in volumes['Volumes']:
            print(f"Volume ID: {volume['VolumeId']}, Encrypted: {volume['Encrypted']}")
            if not volume['Encrypted']:
                jsonData['진단결과'] = "취약"
    else:
        print("No EBS volumes found.")
except Exception as e:
    print("Failed to retrieve EBS volumes. Error:", str(e))
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
