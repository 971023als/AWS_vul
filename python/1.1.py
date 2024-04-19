#!/usr/bin/python3

import boto3
import json
import os
import subprocess
from datetime import datetime, timezone

# 결과를 저장할 디렉터리 설정
output_dir = "./aws_audit_results"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# JSON 데이터 정의
jsonData = {
    "분류": "운영 관리",
    "코드": "IAM-001",
    "위험도": "중요도 중",
    "진단항목": "IAM 계정 감사",
    "진단결과": "진행중",
    "현황": "IAM 사용자, 그룹, 역할 리스트업 및 관리자 권한 계정, 불필요한 계정 식별, 만료된 Access Key 확인",
    "대응방안": "리소스 접근 관리 강화, 불필요한 계정 제거, Access Key 주기적 갱신"
}

def bar():
    print("=" * 40)

# 로그 메시지 기록 함수
def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# 로그 파일 경로 정의
log_file_name = f"{output_dir}/iam_audit.log"

# 로그 파일 초기화
with open(log_file_name, 'w') as file:
    pass

bar()

# 초기 로그 정보 기록
code = "[IAM-001] IAM 계정 감사"
initial_message = "IAM 계정 감사 시작"
log_message(initial_message, log_file_name)

bar()

# AWS 서비스 클라이언트 설정
iam = boto3.client('iam')

# IAM 사용자, 그룹, 역할 리스트업
def list_iam_details():
    users = iam.list_users()
    groups = iam.list_groups()
    roles = iam.list_roles()

    # 결과를 JSON 파일로 저장
    with open(f"{output_dir}/users.json", 'w') as f:
        json.dump(users, f)
    with open(f"{output_dir}/groups.json", 'w') as f:
        json.dump(groups, f)
    with open(f"{output_dir}/roles.json", 'w') as f:
        json.dump(roles, f)
    log_message("IAM 사용자, 그룹, 역할 정보 저장 완료", log_file_name)

# 관리자 권한을 가진 계정 확인
def check_admin_accounts():
    admin_users = iam.list_users(
        Query='Users[?AttachedManagedPolicies[?PolicyName==`AdministratorAccess`]].UserName'
    )
    with open(f"{output_dir}/admin_users.json", 'w') as f:
        json.dump(admin_users, f)
    log_message("관리자 권한 계정 정보 저장 완료", log_file_name)

# 불필요한 계정 식별
def identify_unnecessary_accounts():
    unnecessary_users = iam.list_users(
        Query='Users[?contains(UserName, `test`) || contains(UserName, `temp`)].UserName'
    )
    with open(f"{output_dir}/unnecessary_users.json", 'w') as f:
        json.dump(unnecessary_users, f)
    log_message("불필요한 계정 식별 정보 저장 완료", log_file_name)

# Access Key 유효기간 확인
def check_expired_access_keys():
    users = iam.list_users()['Users']
    expired_keys = []

    for user in users:
        username = user['UserName']
        access_keys = iam.list_access_keys(UserName=username)['AccessKeyMetadata']
        
        for key in access_keys:
            if key['Status'] == 'Active':
                create_date = key['CreateDate'].replace(tzinfo=timezone.utc)
                age_days = (datetime.now(timezone.utc) - create_date).days
                if age_days > 180:
                    expired_keys.append({'user': username, 'key_id': key['AccessKeyId'], 'age_days': age_days})
    
    with open(f"{output_dir}/expired_access_keys.json", 'w') as f:
        json.dump(expired_keys, f)
    log_message("만료된 Access Key 확인 정보 저장 완료", log_file_name)

bar()

# 감사 실행
if __name__ == "__main__":
    list_iam_details()
    check_admin_accounts()
    identify_unnecessary_accounts()
    check_expired_access_keys()
    log_message("IAM 감사 완료", log_file_name)
    print("Audit complete. Results saved in", output_dir)

    # 결과 출력
    with open(log_file_name, 'r') as file:
        print(file.read())
