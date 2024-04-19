#!/usr/python3

import json
import os
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "계정 관리",
    "코드": "1.13",
    "위험도": "중요도 상",
    "진단항목": "EKS 불필요한 익명 접근 관리",
    "대응방안": "클라우드 환경에서는 모든 API 및 리소스 작업 시 익명 사용자의 접근을 비활성화해야 합니다. 쿠버네티스는 'system:anonymous'에 대한 권한을 부여할 수 있는 RoleBinding을 생성할 수 있으며, 이는 보안에 취약할 수 있습니다. Kubernetes/EKS 버전 1.14 이전에는 'system:unauthenticated' 그룹이 일부 기본 Cluster 역할에 연결되므로 업데이트 후에도 이 권한이 유지되지 않도록 주의해야 합니다.",
    "설정방법": "가. EKS 내 불필요한 익명 접근 삭제: 1) kubectl 명령을 통한 불필요 익명 사용자 조회, 2) 불필요 익명 접근 Cluster 연결 정책 삭제, 3) 불필요 익명 접근 정책 삭제 결과 확인",
    "현황": "Placeholder for Anonymous Access Checks",
    "진단결과": "(변수: 양호, 취약)"
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "eks_anonymous_access_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[1.13] EKS 불필요한 익명 접근 관리"
initial_message = f"{code}\n[양호]: 불필요한 익명 접근 권한이 없는 경우\n[취약]: 불필요한 익명 접근 권한이 발견된 경우\n"
log_message(initial_message, log_file_name)

bar()

# Check for unnecessary anonymous access permissions
print("Checking for unnecessary anonymous access permissions...")
try:
    access_check = subprocess.check_output(["kubectl", "get", "clusterrolebindings", "clusterroles", "-o", "json"], text=True)
    if 'system:anonymous' in access_check or 'system:unauthenticated' in access_check:
        result = "WARNING: Unnecessary anonymous access permissions detected:\n" + access_check
        jsonData['진단결과'] = "취약"
    else:
        result = "OK: No unnecessary anonymous access permissions found.\n"
        jsonData['진단결과'] = "양호"
except subprocess.CalledProcessError as e:
    result = f"Failed to check for anonymous access permissions: {e}\n"
    jsonData['진단결과'] = "에러 발생"

log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
