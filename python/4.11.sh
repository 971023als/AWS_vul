#!usr/bin/python3


import json
import os
import stat
import pwd
import subprocess
import boto3

# Python dictionary for JSON data
jsonData = {
    "분류": "운영 관리",
    "코드": "4.11",
    "위험도": "중요도 중",
    "진단항목": "VPC 플로우 로깅 설정",
    "대응방안": {
        "설명": "VPC 플로우 로그는 VPC의 네트워크 인터페이스에서 송∙수신되는 IP 트래픽에 대한 정보를 수집할 수 있는 기능으로, VPC, 서브넷 또는 네트워크 인터페이스에 생성할 수 있습니다. 수집된 로그 데이터는 CloudWatch Logs 또는 S3로 저장할 수 있으며, AWS Management 콘솔의 [VPC] - [플로우 로그] 항목에서 설정할 수 있습니다.",
        "설정방법": [
            "VPC 플로우 로그 설정여부 확인",
            "VPC 플로우 로그 이름, 필터 설정",
            "VPC 플로우 로그 대상(CloudWatch), 로그 그룹, IAM 역할 및 로그 레코드 형식 설정",
            "VPC 플로우 로그 설정 확인",
            "VPC 플로우 로그 대상(S3), 로그 그룹, IAM 역할 및 로그 레코드 형식 설정"
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
log_file_name = "vpc_flow_logging_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[4.11] VPC 플로우 로깅 설정"
initial_message = "VPC의 플로우 로깅 설정 상태를 진단합니다."
log_message(initial_message, log_file_name)

bar()

# Using boto3 to interact with AWS EC2
ec2 = boto3.client('ec2')

try:
    # List all VPCs and their flow logging settings
    flow_logs = ec2.describe_flow_logs()
    if flow_logs['FlowLogs']:
        for log in flow_logs['FlowLogs']:
            log_message(f"VPC ID: {log['ResourceId']}, 로깅 상태: {log['FlowLogStatus']}, 로그 목적지: {log['LogDestinationType']}", log_file_name)
    else:
        log_message("활성화된 플로우 로그가 없습니다.", log_file_name)
        jsonData['진단결과'] = "취약"

except Exception as e:
    log_message(f"Error: {str(e)}", log_file_name)
    jsonData['진단결과'] = "오류 발생"

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
