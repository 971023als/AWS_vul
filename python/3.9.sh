#!/bin/bash

import subprocess
import json
import boto3

# Python dictionary for JSON data
jsonData = {
    "분류": "가상 리소스 관리",
    "코드": "3.9",
    "위험도": "중요도 상",
    "진단항목": "EKS Pod 보안 정책 관리",
    "대응방안": {
        "설명": ("Pod 보안을 제어하기 위해 쿠버네티스는 (버전 1.23부터) Pod Security Standards(PSS)에 설명된 보안 제어를 구현하는 기본 제공 "
                 "어드미션 컨트롤러인 Pod Security Admission (PSA)을 제공합니다. 이는 Amazon Elastic Kubernetes Service(EKS)에서 활성화되어 있으며, "
                 "Pod Security Standards는 Kubernetes Cluster에서 실행되는 모든 Pod에 대한 일관된 보안 수준을 유지합니다."),
        "설정방법": [
            "네임스페이스 내 PSS / PSA 설정 및 확인",
            "PSS / PSA를 적용하기 위한 네임스페이스 생성",
            "생성된 네임스페이스 라벨 내 PSS / PSA 적용 (enforce=restricted)",
            "네임스페이스 내 파드 생성 시도를 통해 PSS / PSA 적용 확인 (파드 생성 실패)"
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
initial_message = f"{code}\n[양호]: PSA 설정이 적절하게 구성된 경우\n[취약]: PSA 설정이 적절하게 구성되지 않은 경우\n"
log_message(initial_message, log_file_name)

bar()

# Check for kubectl command
try:
    subprocess.check_output(["kubectl", "--version"])
except subprocess.CalledProcessError:
    print("kubectl is not installed. Please install kubectl to run this script.")
    exit(1)

# AWS SDK setup
eks = boto3.client('eks')

# Fetching all EKS clusters
try:
    clusters = eks.list_clusters()
    print("EKS Clusters found:")
    for cluster in clusters['clusters']:
        print(cluster)
except Exception as e:
    print("Failed to retrieve EKS clusters or no clusters found. Error:", str(e))
    exit(1)

# User input for EKS cluster name
cluster_name = input("Enter EKS cluster name to check the Pod Security Policies: ")

# Configure kubectl to use the selected EKS cluster
subprocess.run(["aws", "eks", "update-kubeconfig", "--name", cluster_name])

# Check if Pod Security Admission (PSA) is enabled
try:
    psa_status = subprocess.check_output(
        ["kubectl", "get", "configurations", "pod-security.admission.config.k8s.io", "-o=jsonpath='{.spec.modes}'"]
    ).decode('utf-8')
    if not psa_status:
        print("Pod Security Admission is not configured.")
        jsonData['진단결과'] = "취약"
    else:
        print(f"Pod Security Admission is configured with modes: {psa_status.strip('\"')}")
        jsonData['진단결과'] = "양호"
except subprocess.CalledProcessError as e:
    print(f"Error checking PSA settings: {str(e)}")
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
