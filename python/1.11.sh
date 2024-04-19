#!/usr/python3

import json
import os
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "계정 관리",
    "코드": "1.11",
    "위험도": "중요도 상",
    "진단항목": "EKS 사용자 관리",
    "진단결과": "(변수: 양호, 취약)",
    "현황": "Placeholder for aws-auth ConfigMap status",
    "대응방안": "기본적으로 AWS 계정은 리소스에 대한 접근을 허용하는 최소한의 사용자 수와 권한으로 관리되어야 합니다. AWS에서는 IAM 사용자에게 EKS Cluster에 대한 액세스 권한을 부여할 경우 특정 쿠버네티스 RBAC 그룹에 매핑되는 사용자의 'aws-auth' ConfigMap을 제공합니다. 이 ConfigMap은 초기에는 노드를 Cluster에 연결 목적으로 만들어졌으나 IAM 보안 주체에 역할 기반 액세스 제어(RBAC) 액세스를 추가하여 사용할 수도 있습니다."
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "eks_user_management_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[1.11] EKS 사용자 관리"
initial_message = f"{code}\n[양호]: aws-auth ConfigMap이 적절한 권한 관리로 설정된 경우\n[취약]: aws-auth ConfigMap에 system:masters 역할이 설정된 경우\n"
log_message(initial_message, log_file_name)

bar()

# Check the aws-auth ConfigMap
try:
    configmap_status = subprocess.check_output(["kubectl", "describe", "configmap", "aws-auth", "-n", "kube-system"], text=True)
    if "system:masters" in configmap_status:
        result = "WARNING: System:masters role found in aws-auth ConfigMap.\n"
        jsonData['진단결과'] = "취약"
    else:
        result = "OK: System:masters role not found in aws-auth ConfigMap, which is good practice.\n"
        jsonData['진단결과'] = "양호"
except subprocess.CalledProcessError as e:
    result = f"Failed to check aws-auth ConfigMap: {e}\n"
    jsonData['진단결과'] = "에러 발생"

log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
