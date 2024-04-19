#!/usr/python3

import boto3
import json
import os
import subprocess

# 결과를 저장할 디렉터리 설정
output_dir = "./aws_iam_audit"
os.makedirs(output_dir, exist_ok=True)

# Python dictionary for JSON data
jsonData = {
    "분류": "운영 관리",
    "코드": "IAM-002",
    "위험도": "중간",
    "진단항목": "IAM 사용자 Access Key 개수 진단",
    "진단결과": "(변수: 양호, 취약)",
    "현황": "각 IAM 사용자별 Access Key 개수 조회 및 기록",
    "대응방안": "불필요한 Access Key 제거 및 관리 강화"
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# 로그 파일 경로 정의
log_file_name = os.path.join(output_dir, "iam_key_audit.log")

# 로그 파일 초기화
with open(log_file_name, 'w') as file:
    pass

bar()

# 초기 로그 정보 기록
code = "[IAM-002] IAM 사용자 Access Key 진단"
initial_message = f"{code}\n[양호]: Access Key가 하나만 있는 사용자\n[취약]: 여러 Access Key를 가진 사용자\n"
log_message(initial_message, log_file_name)

bar()

# AWS IAM 클라이언트 초기화
iam = boto3.client('iam')

# IAM 사용자 목록 조회
print("IAM 사용자 목록을 조회합니다...")
users = iam.list_users()

# 사용자 정보를 파일에 저장
users_file_path = os.path.join(output_dir, 'users.json')
with open(users_file_path, 'w') as f:
    json.dump(users['Users'], f)

# 각 사용자별 Access Key 개수 진단 및 결과 저장
results = []
for user in users['Users']:
    user_name = user['UserName']
    keys = iam.list_access_keys(UserName=user_name)
    key_count = len(keys['AccessKeyMetadata'])
    result = {
        'user': user_name,
        'access_key_count': key_count
    }
    results.append(result)
    log_message(f"User: {user_name}, Key Count: {key_count}", log_file_name)

# 결과를 JSON 배열로 저장
results_file_path = os.path.join(output_dir, 'account_singularity_audit.json')
with open(results_file_path, 'w') as f:
    json.dump(results, f)

bar()

# 로그 및 결과 출력
print(f"감사가 완료되었습니다. 결과는 {output_dir}에 저장되었습니다.")
with open(log_file_name, 'r') as file:
    print(file.read())
