#!/usr/bin/python3

import boto3
import json
import os
import subprocess
from datetime import datetime, timezone

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# 디렉터리 설정
output_dir = "./aws_iam_tags_audit"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# 로그 파일 초기화
log_file_name = "aws_iam_tags_audit.log"
with open(log_file_name, 'w') as file:
    pass

bar()

# IAM 사용자 태그 조회 및 진단 로그
log_message("IAM 사용자 및 태그 평가를 시작합니다...", log_file_name)

# boto3 클라이언트 설정
iam = boto3.client('iam')

# 사용자 목록 가져오기
users = iam.list_users()
users_json_path = f"{output_dir}/users.json"
with open(users_json_path, 'w') as file:
    json.dump(users, file)

# 태그 평가 결과 파일 초기화
tag_audit_results_path = f"{output_dir}/tag_audit_results.json"
with open(tag_audit_results_path, 'w') as file:
    file.write("[]")

# 사용자별 태그 평가
for user in users['Users']:
    user_name = user['UserName']
    user_tags = iam.list_user_tags(UserName=user_name)
    
    # 태그 추출
    name_tag = next((tag['Value'] for tag in user_tags['Tags'] if tag['Key'] == 'Name'), None)
    email_tag = next((tag['Value'] for tag in user_tags['Tags'] if tag['Key'] == 'Email'), None)
    department_tag = next((tag['Value'] for tag in user_tags['Tags'] if tag['Key'] == 'Department'), None)
    
    # 결과 JSON 파일에 저장
    with open(tag_audit_results_path, 'a') as file:
        json.dump({"user": user_name, "Name": name_tag, "Email": email_tag, "Department": department_tag}, file)
        file.write(",\n")  # JSON 배열 요소 구분

bar()

# 로그 및 결과 출력
log_message("태그 평가가 완료되었습니다. 결과는 {}에 저장되었습니다.".format(output_dir), log_file_name)

with open(log_file_name, 'r') as file:
    print(file.read())
