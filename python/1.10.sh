#!/usr/python3

import boto3
from botocore.exceptions import ClientError
import json
import os
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "계정 관리",
    "코드": "1.10",
    "위험도": "중요도 중",
    "진단항목": "AWS 계정 패스워드 정책 관리",
    "진단결과": "(변수: 양호, 취약)",
    "현황": "Placeholder for password policy status",
    "대응방안": "AWS Admin Console Account 계정 및 IAM 사용자 계정의 암호 설정 시 유추하기 쉬운 암호를 설정하는 경우 비 인가된 사용자가 해당 계정을 획득하여 접근 가능성이 존재합니다. 패스워드는 여러 문자 종류를 조합하여 구성하고, 연속적인 문자 사용을 금지하며, 패스워드 재사용을 제한합니다."
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "iam_password_policy_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[1.10] IAM 계정 패스워드 정책 관리"
initial_message = f"{code}\n[양호]: 패스워드 정책이 복잡성 요구 사항을 충족하는 경우\n[취약]: 패스워드 정책이 복잡성 요구 사항을 충족하지 않는 경우\n"
log_message(initial_message, log_file_name)

bar()

# Check IAM account password policy
try:
    iam = boto3.client('iam')
    policy = iam.get_account_password_policy()['PasswordPolicy']

    # Check the compliance of the password policy
    if (
        policy['MinimumPasswordLength'] >= 8 and
        policy['RequireSymbols'] and
        policy['RequireNumbers'] and
        policy['PasswordReusePrevention'] >= 1 and
        policy['MaxPasswordAge'] <= 90
    ):
        result = "Password policy meets the complexity requirements.\n"
        jsonData['진단결과'] = "양호"
    else:
        result = "Password policy does not meet the complexity requirements.\n"
        jsonData['진단결과'] = "취약"
except ClientError as e:
    result = f"Failed to retrieve password policy: {e}\n"
    jsonData['진단결과'] = "취약"

log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
