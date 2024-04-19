#!/usr/python3

import boto3
import json
import os
import subprocess

# JSON 데이터 설정
jsonData = {
    "분류": "권한 관리",
    "코드": "1.7",
    "위험도": "중요도 중",
    "진단항목": "Admin Console 관리자 정책 관리",
    "대응방안": "AWS Cloud 사용을 위해 처음 발급한 계정은 IAM 사용자 계정과 달리 모든 서비스에 접근할 수 있는 최고 관리자 계정입니다. Cloud 서비스 특성 상 인터넷 연결이 가능한 망에서 계정정보를 입력하여 WEB Console에 접근하게 됩니다. 이는 최고 권한을 보유하고 있는 관리자 계정이 아닌 권한이 조정된 IAM 사용자 계정을 기본으로 사용해야 보다 안전한 접근이 이뤄질 수 있습니다.",
    "설정방법": "IAM 사용자 계정 생성: 1) 사용자 추가 버튼 클릭, 2) 사용자 추가 (기본설정 - 이름, 액세스 유형 선택), 3) 사용자 추가 (기존 정책 직접 연결하기), 4) 사용자 추가 (태그 계정 정보 입력), 5) 사용자 추가 (검토하기), 6) IAM 사용자에 추가된 신규 사용자 확인, 7) 사용자 권한 확인",
    "현황": [],
    "진단결과": "양호"
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# 로그 파일 경로 설정 및 초기화
log_file_name = "iam_user_simulation_audit.log"
with open(log_file_name, 'w') as file:
    pass

bar()

# 로그 시작 정보
initial_message = "[1.7] Admin Console 사용자 계정 관리 시뮬레이션 시작"
log_message(initial_message, log_file_name)

bar()

def simulate_iam_user_creation():
    print("IAM 사용자 계정 생성 절차를 시작합니다.")
    user_name = input("새 IAM 사용자 이름을 입력하세요: ")
    log_message(f"Creating IAM user: {user_name}", log_file_name)

    policy_name = input("사용자에게 부여할 정책을 입력하세요 (예: AdministratorAccess, ReadOnlyAccess): ")
    log_message(f"Attaching policy {policy_name} to {user_name}", log_file_name)

    service_use = input("Admin Console 계정을 서비스 목적으로 사용하나요? (yes/no): ")
    진단결과 = "취약" if service_use.lower() == "yes" else "양호"
    log_message(f"진단결과: {진단결과}", log_file_name)

    result_message = f"분류: {jsonData['분류']}\n코드: {jsonData['코드']}\n위험도: {jsonData['위험도']}\n진단항목: {jsonData['진단항목']}\n대응방안: {jsonData['대응방안']}\n설정방법: {jsonData['설정방법']}\n진단결과: {진단결과}"
    log_message(result_message, log_file_name)

    return result_message

def main():
    result = simulate_iam_user_creation()
    print(result)

if __name__ == "__main__":
    main()

bar()

# 결과 출력
with open(log_file_name, 'r') as file:
    print(file.read())
