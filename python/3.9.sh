#!/usr/python3

import json
import os
import stat
import pwd
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "가상 리소스 관리",
    "코드": "3.9",
    "위험도": "중요도 상",
    "진단항목": "EKS Pod 보안 정책 관리",
    "대응방안": {
        "설명": "EKS에서 Pod 보안을 제어하기 위한 설정은 시스템의 보안을 강화하고 취약성을 줄입니다. 쿠버네티스의 Pod Security Admission (PSA)을 이용하여, 특정 보안 기준에 따라 Pod 생성을 제한할 수 있습니다.",
        "설정방법": [
            "EKS 클러스터 내에서 PSA 설정 확인",
            "PSA 정책을 적용하여 클러스터 내의 네임스페이스 설정",
            "적절한 네임스페이스 라벨 지정 및 정책 테스트"
        ]
    },
    "현황": [],
    "진단결과": "양호"
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "eks_pod_security_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[3.9] EKS Pod 보안 정책 관리"
initial_message = f"{code}\n[양호]: PSA 설정이 적절한 경우\n[취약]: PSA 설정이 부적절한 경우\n"
log_message(initial_message, log_file_name)

bar()

# Check for kubectl command
try:
    subprocess.check_output(["kubectl", "--version"])
except subprocess.CalledProcessError:
    print("kubectl is not installed. Please install kubectl to proceed.")
    exit(1)

# AWS SDK setup
eks = boto3.client('eks')

# Fetching all EKS clusters
try:
    clusters = eks.list_clusters()
    print("Available EKS Clusters:")
    for cluster in clusters['clusters']:
        print(cluster)
except Exception as e:
    print("Failed to retrieve EKS clusters. Error:", str(e))
    exit(1)

# User input for EKS cluster name
cluster_name = input("Enter EKS cluster name to check the Pod Security Admission settings: ")

# Configure kubectl to use the selected EKS cluster
subprocess.run(["aws", "eks", "update-kubeconfig", "--name", cluster_name])

# Check PSA settings
try:
    psa_status = subprocess.check_output(
        ["kubectl", "get", "psa", "-o=jsonpath='{.items[*].spec.enforce}'", "--all-namespaces"]
    ).decode('utf-8')
    if 'enforce=restricted' in psa_status:
        print("PSA settings are properly configured.")
        jsonData['진단결과'] = "양호"
    else:
        print("PSA settings are not properly configured.")
        jsonData['진단결과'] = "취약"
except subprocess.CalledProcessError as e:
    print(f"Failed to check PSA settings: {str(e)}")
    jsonData['진단결과'] = "취약"

# Log results
result_message = f"Diagnosis result for '{cluster_name}': {jsonData['진단결과']}"
log_message(result_message, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
