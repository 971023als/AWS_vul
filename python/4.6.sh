#!usr/bin/python3

import boto3
import json
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "운영 관리",
    "코드": "4.6",
    "위험도": "중요도 중",
    "진단항목": "CloudWatch 암호화 설정",
    "대응방안": {
        "설명": "Amazon CloudWatch는 Key Management Service(KMS)와 사용자 지정 마스터 키(CMK)를 통해 관리되는 키를 사용하여 로그를 암호화할 수 있습니다. 로그 그룹을 생성할 때나 기존 로그 그룹에 CMK를 연결하여 로그 데이터를 암호화할 수 있으며, 이 데이터는 보존 기간 동안 암호화된 상태로 유지됩니다.",
        "설정방법": [
            "KMS Key ARN 확인 방법: 서비스 > KMS > 고객 관리형 키 접근 > 고객 관리형 키 > ARN 값 확인",
            "CloudWatch 로그 그룹 생성 및 KMS key ARN 설정: 서비스 > CloudWatch 로그 그룹 생성 > 로그 그룹 생성 시 사전 확인된 KMS key ARN 값 설정 필요 > 로그 그룹 생성 완료"
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
log_file_name = "cloudwatch_encryption_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[4.6] CloudWatch 암호화 설정"
initial_message = "CloudWatch 로그 그룹의 KMS 암호화 상태를 확인합니다."
log_message(initial_message, log_file_name)

bar()

try:
    # List all CloudWatch log groups and check their encryption status
    cloudwatch_log_groups = subprocess.check_output(["aws", "logs", "describe-log-groups", "--query", "logGroups[*].{logGroupName:logGroupName, kmsKeyId:kmsKeyId}", "--output", "json"], text=True)
    jsonData['현황'] = json.loads(cloudwatch_log_groups)
    
    log_message(f"CloudWatch Log Groups and KMS Encryption Status:\n{cloudwatch_log_groups}", log_file_name)
    
    encryption_compliance = "취약"  # Default to vulnerable unless found otherwise
    for log_group in jsonData['현황']:
        if 'kmsKeyId' in log_group and log_group['kmsKeyId']:
            log_message(f"Log group '{log_group['logGroupName']}' is encrypted with KMS key ID: {log_group['kmsKeyId']}.", log_file_name)
            encryption_compliance = "양호"
        else:
            log_message(f"Log group '{log_group['logGroupName']}' is not using KMS encryption.", log_file_name)
    
    jsonData['진단결과'] = encryption_compliance
    log_message(f"Diagnosis updated with result: {encryption_compliance}", log_file_name)
    
except subprocess.CalledProcessError as e:
    log_message(f"Error: {str(e)}", log_file_name)
    jsonData['진단결과'] = "오류"

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
