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
output_dir = "./aws_iam_groups_audit"
os.makedirs(output_dir, exist_ok=True)

# 로그 파일 경로 정의 및 초기화
log_file_name = "aws_iam_groups_audit.log"
with open(log_file_name, 'w') as file:
    pass

bar()

# 로그 시작 정보
log_message("IAM 그룹 및 그룹 사용자 정보 조회를 시작합니다...", log_file_name)

# boto3 IAM 클라이언트 생성
iam = boto3.client('iam')

# IAM 그룹 목록 가져오기
groups = iam.list_groups()
groups_json_path = f"{output_dir}/groups.json"
with open(groups_json_path, 'w') as file:
    json.dump(groups, file)

# 각 그룹별 사용자 목록 평가
group_audit_results_path = f"{output_dir}/group_audit_results.json"
with open(group_audit_results_path, 'w') as file:
    file.write("[]")

for group in groups['Groups']:
    group_name = group['GroupName']
    group_users = iam.get_group(GroupName=group_name)

    for user in group_users['Users']:
        user_name = user['UserName']
        # 불필요한 계정 식별 (예: 이름에 'test'가 포함된 경우)
        if 'test' in user_name:
            with open(group_audit_results_path, 'a') as file:
                json.dump({"group": group_name, "unnecessary_user": user_name}, file)
                file.write(",\n")

bar()

# 로그 완료 정보 및 결과 출력
log_message("그룹 평가가 완료되었습니다. 결과는 {}에 저장되었습니다.".format(output_dir), log_file_name)

with open(log_file_name, 'r') as file:
    print(file.read())
