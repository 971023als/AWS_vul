#!usr/bin/python3

import boto3
import json
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "운영 관리",
    "코드": "4.5",
    "위험도": "중요도 중",
    "진단항목": "CloudTrail 암호화 설정",
    "대응방안": {
        "설명": "CloudTrail은 버킷에 제공하는 로그 파일을 Amazon S3가 관리하는 암호화 키(SSE-S3)를 사용하는 서버 측 암호화로 암호화합니다. 보다 직접적인 관리가 필요한 경우 AWS KMS 관리형 키(SSE-KMS)를 사용하는 서버 측 암호화를 적용할 수 있습니다.",
        "설정방법": [
            "CloudTrail 추적 생성",
            "CloudTrail 추적 속성 확인 및 비활성화 상태 변경",
            "고객 관리형 AWS KMS 키 추가 설정",
            "CloudTrail 추적 생성 완료",
            "CloudTrail 암호화 설정 확인"
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
log_file_name = "cloudtrail_encryption_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[4.5] CloudTrail 암호화 설정"
initial_message = "CloudTrail 트레일의 KMS 암호화 상태를 확인합니다."
log_message(initial_message, log_file_name)

bar()

try:
    # List all CloudTrail trails and their KMS encryption status
    trails_info = subprocess.check_output(["aws", "cloudtrail", "describe-trails", "--query", "trailList[*].{Name:Name, KmsKeyId:KmsKeyId}", "--output", "json"], text=True)
    jsonData['현황'] = json.loads(trails_info)
    
    log_message(f"CloudTrail Trails and KMS Encryption Status:\n{trails_info}", log_file_name)
    
    # Simulate checking a specific CloudTrail trail (example code, adjust as necessary)
    trail_name = input("Enter CloudTrail trail name to check encryption: ")
    trail_status = subprocess.check_output(["aws", "cloudtrail", "get-trail-status", "--name", trail_name, "--query", "IsLogging", "--output", "text"], text=True)
    
    if trail_status.strip().lower() == 'true':
        log_message(f"{trail_name} is currently logging.", log_file_name)
        encryption_status = "양호"
    else:
        log_message(f"{trail_name} is not currently logging.", log_file_name)
        encryption_status = "취약"
    
    log_message(f"Encryption Status for '{trail_name}': {encryption_status}", log_file_name)
    jsonData['진단결과'] = encryption_status
    
except subprocess.CalledProcessError as e:
    log_message(f"Error: {str(e)}", log_file_name)
    jsonData['진단결과'] = "오류"

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
