#!/bin/bash

import boto3
import json

# Python dictionary for JSON data
jsonData = {
    "분류": "운영 관리",
    "코드": "4.3",
    "위험도": "중요도 중",
    "진단항목": "S3 암호화 설정",
    "대응방안": {
        "설명": "버킷 기본 암호화 설정은 S3 버킷에 저장되는 모든 객체를 암호화 되도록 하는 설정입니다. Amazon S3 관리형 키(SSE-S3) 또는 AWS KMS 관리형 키(SSE-KMS)로 서버 측 암호화를 사용하여 객체를 암호화합니다.",
        "설정방법": [
            "S3 버킷 선택",
            "S3 버킷 속성 확인",
            "S3 버킷의 기본 암호화 설정이 SSE-S3 또는 SSE-KMS로 되어 있는지 확인"
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
log_file_name = "s3_security_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[4.3] S3 암호화 설정"
initial_message = f"{code}\n[양호]: 모든 S3 버킷이 적절히 암호화되어 있는 경우\n[취약]: 하나 이상의 S3 버킷이 암호화되지 않은 경우\n"
log_message(initial_message, log_file_name)

bar()

# AWS SDK setup
s3 = boto3.client('s3')

# Fetching all S3 buckets
try:
    buckets = s3.list_buckets()
    if buckets['Buckets']:
        print("S3 Buckets and their encryption status:")
        for bucket in buckets['Buckets']:
            bucket_name = bucket['Name']
            try:
                encryption = s3.get_bucket_encryption(Bucket=bucket_name)
                print(f"Bucket {bucket_name} is encrypted.")
                jsonData['현황'].append({"Bucket": bucket_name, "Encryption Status": "양호"})
            except s3.exceptions.ClientError as e:
                print(f"Bucket {bucket_name} is not encrypted.")
                jsonData['현황'].append({"Bucket": bucket_name, "Encryption Status": "취약"})
                jsonData['진단결과'] = "취약"
    else:
        print("No S3 buckets found.")
except Exception as e:
    print("Failed to retrieve S3 buckets. Error:", str(e))
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
