#!/usr/python3

import boto3
from datetime import datetime, timedelta
from botocore.exceptions import ClientError
import json
import os
import subprocess

# JSON 데이터 설정
jsonData = {
    "분류": "계정 관리",
    "코드": "1.8",
    "위험도": "중요도 상",
    "진단항목": "Admin Console 계정 Access Key 활성화 및 사용주기 관리",
    "대응방안": "Access Key는 AWS의 CLI 도구나 API를 사용할 때 필요한 인증수단으로, 생성 사용자에 대한 결제정보를 포함한 모든 AWS 서비스의 전체 리소스에 대한 권한을 갖습니다. 유출 시 심각한 피해가 발생할 가능성이 높기에 AWS Admin Console Account에 대한 Access Key 삭제를 권장합니다. Access Key 관리 주기는 Key 수명(60일 이내), 비밀번호 수명(60일 이내), 마지막 활동(30일 이내)입니다.",
    "설정방법": "가. AWS Admin Console Account Access Key 삭제 방법: 1) 메인 우측 상단 계정 → 내 보안 자격 증명, 2) Access Key(Access Key ID 및 비밀 Access Key) → 삭제 → 예, 나. IAM User Account Access Key 삭제 방법: 1) 메인 우측 상단 계정 → 내 보안 자격 증명, 2) 사용자 → Access Key를 삭제할 계정 선택, 3) 요약 → 보안 자격 증명 탭, 4) Access Key → Access Key ID → ‘X’(삭제) 버튼, 5) Access Key 삭제 → 삭제",
    "현황": [],
    "진단결과": "양호"
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# 로그 파일 경로 설정 및 초기화
log_file_name = "access_key_lifecycle_audit.log"
with open(log_file_name, 'w') as file:
    pass

bar()

# 로그 시작 정보
initial_message = "[1.8] Access Key 활성화 및 사용주기 관리 진단 시작"
log_message(initial_message, log_file_name)

bar()

# Access Key 사용주기 체크
def check_access_keys_lifecycle():
    iam = boto3.client('iam')
    try:
        keys = iam.list_access_keys()
        now = datetime.now()
        max_age = timedelta(days=60)
        key_active = 0

        for key in keys['AccessKeyMetadata']:
            create_date = key['CreateDate'].replace(tzinfo=None)
            if key['Status'] == 'Active' and (now - create_date > max_age):
                key_active += 1

        if key_active == 0:
            result = "양호: 모든 Access Key가 권장 사용주기 내에 있습니다."
        else:
            result = "취약: 권장 사용주기를 초과하는 Access Key가 있습니다."

    except ClientError as e:
        result = f"에러 발생: {e}"

    log_message(result, log_file_name)
    return result

def main():
    result = check_access_keys_lifecycle()
    print(result)

if __name__ == "__main__":
    main()

bar()

# 결과 출력
with open(log_file_name, 'r') as file:
    print(file.read())
