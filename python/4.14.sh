#!/usr/bin/python3

import boto3
import json

# Python dictionary for JSON data
jsonData = {
    "분류": "운영 관리",
    "코드": "4.14",
    "위험도": "중요도 중",
    "진단항목": "EKS Cluster 제어 플레인 로깅 설정",
    "진단결과": "양호",  # '취약'으로 업데이트 가능
    "현황": [],
    "대응방안": {
        "설명": "Amazon EKS 제어 플레인 로깅은 Amazon EKS 제어 플레인에서 계정의 CloudWatch Logs로 직접 감사 및 진단 로그를 제공합니다. 이러한 로그를 사용하면 Cluster를 쉽게 보호하고 실행할 수 있습니다. 필요한 정확한 로그 유형을 선택할 수 있으며, 로그는 CloudWatch의 각 Amazon EKS Cluster에 대한 그룹에 로그 스트림으로 전송됩니다.",
        "설정방법": [
            "EKS Cluster 접근",
            "Observability 메뉴 확인",
            "제어 플레인 로깅 관리 설정",
            "로그 유형 별 On/Off 설정 후 변경 사항 저장",
            "설정된 제어 플레인 로깅 확인",
            "CloudWatch의 로그 그룹 확인",
            "저장된 유형 별 로그 스트림 확인"
        ]
    }
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# 로그 파일 경로 정의
log_file_name = "eks_logging_audit.log"

# 로그 파일 초기화 또는 생성
with open(log_file_name, 'w') as file:
    pass

bar()

# 로그에 초기 정보 기록
code = "[4.14] EKS 제어 플레인 로깅 미설정"
initial_message = f"{code}\n[양호]: EKS Cluster의 제어 플레인 로깅이 활성화되어 있음\n[취약]: EKS Cluster의 제어 플레인 로깅이 활성화되어 있지 않음\n"
log_message(initial_message, log_file_name)

bar()

# Boto3 클라이언트 초기화
client = boto3.client('eks')

# EKS 클러스터 목록과 제어 플레인 로깅 설정 확인
try:
    clusters = client.list_clusters()['clusters']
    for cluster_name in clusters:
        cluster_info = client.describe_cluster(name=cluster_name)
        logging_info = cluster_info['cluster']['logging']['clusterLogging']
        enabled_logs = [log['types'] for log in logging_info if log['enabled']]
        if enabled_logs:
            result = f"Cluster '{cluster_name}': 로깅 활성화된 유형: {enabled_logs}\n"
        else:
            result = f"Cluster '{cluster_name}': 로깅 미활성화\n"
        log_message(result, log_file_name)
except Exception as e:
    log_message(f"ERROR: 클러스터 정보를 가져오는 중 오류 발생. {str(e)}\n", log_file_name)

bar()

# 결과 출력
with open(log_file_name, 'r') as file:
    print(file.read())
