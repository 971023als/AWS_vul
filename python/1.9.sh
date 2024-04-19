#!/usr/python3

import boto3
from botocore.exceptions import ClientError
import json
import os
import subprocess

# JSON 데이터 설정
jsonData = {
    "분류": "계정 관리",
    "코드": "1.9",
    "위험도": "중요도 중",
    "진단항목": "MFA (Multi-Factor Authentication) 설정",
    "대응방안": "AWS Multi-Factor Authentication(MFA)은 사용자 이름과 암호 외에 보안을 한층 더 강화할 수 있는 방법으로, MFA를 활성화하면 사용자가 AWS 웹 사이트에 로그인할 때 사용자 이름과 암호뿐만 아니라 AWS MFA 디바이스의 인증 응답을 입력하라는 메시지가 표시됩니다. 이러한 다중 요소를 통해 AWS 계정 설정 및 리소스에 대한 보안을 높일 수 있습니다.",
    "설정방법": "MFA 인증 설정 및 확인: 1) IAM 메인 → 우측상단 계정 → 내 보안 자격 증명 → 멀티 팩터 인증 → MFA 활성화, 2) MFA 디바이스 관리 → 가상 MFA 디바이스 선택 → 계속, 3) Google OTP 어플 설치 → ‘+’ 버튼 → 바코드 스캔 → 나타난 QR코드를 어플에서 스캔, 4) 스캔 후 나타난 숫자 MFA 코드 1 입력 → 재 생성된 숫자 MFA 코드 2 입력, 5) 2개의 연속된 MFA 코드 입력, 6) MFA 설정 완료, 7) 로그인 시 비밀번호 입력, 8) Google OTP 번호 입력 후 로그인 시도, 9) 로그인 확인",
    "현황": [],
    "진단결과": "양호"
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# 로그 파일 경로 설정 및 초기화
log_file_name = "mfa_status_audit.log"
with open(log_file_name, 'w') as file:
    pass

bar()

# 로그 시작 정보
initial_message = "[1.9] MFA 설정 상태 진단 시작"
log_message(initial_message, log_file_name)

bar()

# MFA 상태 확인
def check_mfa_status(user_name):
    iam = boto3.client('iam')
    try:
        mfa_devices = iam.list_mfa_devices(UserName=user_name)
        if mfa_devices['MFADevices']:
            result = "양호: 사용자에게 MFA가 활성화되어 있습니다."
        else:
            result = "취약: 사용자에게 MFA가 구성되어 있지 않습니다."
    except ClientError as e:
        result = f"에러 발생: {e}"

    log_message(result, log_file_name)
    return result

def main():
    user_name = input("IAM 사용자 이름을 입력하세요 (MFA 상태 확인): ")
    result = check_mfa_status(user_name)
    print(result)

if __name__ == "__main__":
    main()

bar()

# 결과 출력
with open(log_file_name, 'r') as file:
    print(file.read())
