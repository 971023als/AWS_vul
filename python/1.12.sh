#!/usr/python3

import json
import os
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "계정 관리",
    "코드": "1.12",
    "위험도": "중요도 중",
    "진단항목": "EKS 서비스 어카운트 관리",
    "대응방안": "서비스 어카운트는 파드에 쿠버네티스 RBAC 역할을 할당할 수 있는 특수한 유형의 개체입니다. Cluster 내의 각 네임스페이스에 기본 서비스 어카운트가 자동으로 생성되며, 특정 서비스 어카운트를 참조하지 않고 네임스페이스에 파드를 배포하면, 해당 네임스페이스의 파드에 자동으로 할당됩니다. AutomountServiceAccountToken 속성을 false로 설정하여 불필요한 토큰 마운트를 방지해야 합니다.",
    "설정방법": "가. 서비스 어카운트 토큰 자동 마운트 비활성화: 1) 서비스 어카운트 토큰 자동 마운트 비활성화 여부 확인, 2) 서비스 어카운트 토큰 자동 마운트 비활성화 (false) 설정 및 확인",
    "현황": "Placeholder for Automount status",
    "진단결과": "(변수: 양호, 취약)"
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "eks_service_account_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[1.12] EKS 서비스 어카운트 관리"
initial_message = f"{code}\n[양호]: AutomountServiceAccountToken 설정이 비활성화된 경우\n[취약]: AutomountServiceAccountToken 설정이 활성화된 경우\n"
log_message(initial_message, log_file_name)

bar()

# Check the AutomountServiceAccountToken setting for the default service account in the kube-system namespace
try:
    automount_status = subprocess.check_output(
        ["kubectl", "get", "serviceaccount", "default", "-n", "kube-system", "-o", "json"],
        text=True
    )
    automount_status_json = json.loads(automount_status)
    token_setting = automount_status_json['automountServiceAccountToken']

    if not token_setting:
        result = "OK: AutomountServiceAccountToken is correctly set to false.\n"
        jsonData['진단결과'] = "양호"
    else:
        result = "WARNING: AutomountServiceAccountToken is set to true, which is not recommended.\n"
        jsonData['진단결과'] = "취약"
except subprocess.CalledProcessError as e:
    result = f"Failed to check AutomountServiceAccountToken setting: {e}\n"
    jsonData['진단결과'] = "에러 발생"

log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
