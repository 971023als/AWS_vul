#!/usr/bin/python3

import boto3
import json

# Python dictionary for JSON data
jsonData = {
    "분류": "운영 관리",
    "코드": "4.15",
    "위험도": "중요도 중",
    "진단항목": "EKS Cluster 암호화 설정",
    "진단결과": "양호",  # '취약'으로 업데이트 가능
    "현황": [],
    "대응방안": {
        "설명": "Kubernetes 비밀(Secret)은 비밀번호, 토큰, 키와 같은 소량의 민감한 데이터를 포함하는 객체이며, 기본적으로 API 서버의 기본 데이터 저장소(etcd)에 암호화되지 않은 상태로 저장됩니다. 비밀 암호화를 활성화하면 AWS Key Management Service(AWS KMS) 키를 사용하여 Cluster의 etcd에 저장된 Kubernetes 비밀 암호화를 제공합니다. 이는 사용자가 정의하고 관리하는 AWS KMS 키로 Kubernetes 비밀을 암호화하여 Kubernetes 애플리케이션에 대한 안전한 배포를 할 수 있습니다.",
        "설정방법": [
            "EKS Cluster 내 [개요] – [암호 암호화] 설정 확인",
            "KMS 키 적용 후 암호 활성화",
            "암호 암호화 설정 시 유의 사항 확인 후 활성화 시도",
            "암호 암호화 설정 확인"
        ]
    }
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# 로그 파일 경로 정의
log_file_name = "eks_encryption_audit.log"

# 로그 파일 초기화 또는 생성
with open(log_file_name, 'w') as file:
    pass

bar()

# 로그에 초기 정보 기록
code = "[4.15] EKS 클러스터 암호화 설정 미적용"
initial_message = f"{code}\n[양호]: EKS 클러스터 암호화 설정이 활성화되어 있는 경우\n[취약]: EKS 클러스터 암호화 설정이 활성화되어 있지 않은 경우\n"
log_message(initial_message, log_file_name)

bar()

# Boto3 클라이언트 초기화
client = boto3.client('eks')

# EKS 클러스터 목록과 암호화 설정 확인
try:
    clusters = client.list_clusters()['clusters']
    for cluster_name in clusters:
        cluster_info = client.describe_cluster(name=cluster_name)
        encryption_config = cluster_info['cluster'].get('encryptionConfig', [])
        if encryption_config:
            resources_encrypted = [item for config in encryption_config for item in config.get('resources', [])]
            result = f"Cluster '{cluster_name}': 암호화 활성화된 리소스: {resources_encrypted}\n"
        else:
            result = f"Cluster '{cluster_name}': 암호화 미활성화\n"
        log_message(result, log_file_name)
except Exception as e:
    log_message(f"ERROR: 클러스터 정보를 가져오는 중 오류 발생. {str(e)}\n", log_file_name)

bar()

# 결과 출력
with open(log_file_name, 'r') as file:
    print(file.read())
