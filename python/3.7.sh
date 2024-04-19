#!/bin/bash
import boto3
import json

# Python dictionary for JSON data
jsonData = {
    "분류": "가상 리소스 관리",
    "코드": "3.7",
    "위험도": "중요도 중",
    "진단항목": "S3 버킷/객체 접근 관리",
    "대응방안": {
        "설명": "S3 버킷의 경우 리소스(버킷)를 생성한 소유자에 대해 리소스 액세스가 가능하며, 액세스 정책을 별도로 설정하여 다른 사람에게 액세스 권한을 부여할 수 있습니다. 퍼블릭 액세스 차단 설정이 되지 않을 경우, 외부로부터 버킷 및 객체가 노출되므로 안전한 버킷/객체 접근을 위해 목적에 맞는 접근 설정을 해야 합니다.",
        "설정방법": [
            "서비스 > S3 > 퍼블릭 액세스 차단을 위한 계정 설정 내 상태 확인",
            "서비스 > S3 > 퍼블릭 액세스 차단을 위한 계정 설정 > 편집 (비활성화 시)",
            "모든 퍼블릭 액세스 차단 활성화",
            "서비스 > S3 > 버킷 > 설정된 버킷 선택 > 권한 > ACL(액세스 제어 목록) 확인 및 편집 (기타 권한 존재 시 불필요 권한 비활성화)"
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
log_file_name = "s3_access_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[3.7] S3 버킷/객체 접근 관리"
initial_message = f"{code}\n[양호]: S3 버킷 설정이 적절한 경우\n[취약]: S3 버킷에 퍼블릭 액세스 차단 설정이 적절하지 않은 경우\n"
log_message(initial_message, log_file_name)

bar()

# AWS SDK setup
s3 = boto3.client('s3')

# Fetching all S3 buckets
buckets = s3.list_buckets()
print("Available S3 Buckets:")
for bucket in buckets['Buckets']:
    print(bucket['Name'])

# User input for S3 bucket name
bucket_name = input("Enter S3 bucket name to check: ")

# Check public access settings for the specific S3 bucket
try:
    public_access_block = s3.get_public_access_block(Bucket=bucket_name)
    settings = public_access_block['PublicAccessBlockConfiguration']
    print("Public Access Settings for '{}':".format(bucket_name))
    print(json.dumps(settings, indent=2))
    if settings.get('BlockPublicAcls', False):
        result = "Public access is properly blocked for '{}'. Setting is satisfactory.".format(bucket_name)
        jsonData['진단결과'] = "양호"
    else:
        result = "Public access is not properly blocked for '{}'. Setting is vulnerable.".format(bucket_name)
        jsonData['진단결과'] = "취약"
except Exception as e:
    result = str(e)

# Log results
log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
