#!/usr/python3

import boto3
import json
import os
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "가상 리소스 관리",
    "코드": "3.7",
    "위험도": "중요도 중",
    "진단항목": "S3 버킷/객체 접근 관리",
    "대응방안": {
        "설명": ("S3 버킷에 대한 액세스 정책을 적절하게 설정하여 퍼블릭 액세스를 차단함으로써 외부로부터의 무단 접근을 방지합니다. "
                 "이는 데이터의 안전성을 보장하며, 퍼블릭 액세스 차단 설정이 중요한 보안 조치입니다."),
        "설정방법": [
            "AWS Management Console을 통해 S3 서비스에 접속",
            "버킷 선택 후 '권한' 탭에서 퍼블릭 액세스 차단 설정 확인 및 수정",
            "퍼블릭 액세스를 차단하는 모든 설정 활성화"
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
response = s3.list_buckets()
print("Available S3 Buckets:")
for bucket in response['Buckets']:
    print(bucket['Name'])

# User input for S3 bucket name
bucket_name = input("Enter S3 bucket name to check its public access settings: ")

# Check public access block settings for the specified S3 bucket
try:
    public_access_block = s3.get_public_access_block(Bucket=bucket_name)
    settings = public_access_block['PublicAccessBlockConfiguration']
    print("Public Access Block Settings for '{}':".format(bucket_name))
    print(json.dumps(settings, indent=2))
    if all(value for value in settings.values()):
        result = "Public access is properly blocked for '{}'. Setting is satisfactory.".format(bucket_name)
        jsonData['진단결과'] = "양호"
    else:
        result = "Public access is not properly blocked for '{}'. Setting is vulnerable.".format(bucket_name)
        jsonData['진단결과'] = "취약"
except s3.exceptions.NoSuchPublicAccessBlockConfiguration:
    result = "No public access block configuration found for '{}'.".format(bucket_name)
    jsonData['진단결과'] = "취약"
except Exception as e:
    result = "Error checking public access settings for '{}': {}".format(bucket_name, str(e))
    jsonData['진단결과'] = "에러 발생"

# Log results
log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
