#!usr/bin/python3
import json
import boto3
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "운영 관리",
    "코드": "4.7",
    "위험도": "중요도 상",
    "진단항목": "AWS 사용자 계정 로깅 설정",
    "대응방안": {
        "설명": "AWS CloudTrail은 계정의 거버넌스, 규정 준수, 운영 및 위험 감사를 활성화하도록 도와주는 서비스입니다. 사용자, 역할 또는 AWS 서비스가 수행하는 작업들의 이벤트가 기록됩니다. CloudTrail은 생성 시 AWS 계정에서 활성화됩니다. 활동이 AWS 계정에서 이루어지면 해당 활동이 CloudTrail 이벤트에 기록됩니다.",
        "설정방법": [
            "CloudTrail 대시보드 진입 및 관리 이벤트 추적 확인",
            "CloudTrail 추적 생성 버튼 클릭",
            "CloudTrail 추적 속성 설정",
            "CloudTrail CloudWatch Logs 설정",
            "로그 이벤트 선택 – 관리 이벤트",
            "CloudTrail 검토 및 생성 내용 확인"
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
log_file_name = "cloudtrail_logging_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[4.7] AWS 사용자 계정 로깅 설정"
initial_message = "AWS CloudTrail 로깅 설정을 확인합니다."
log_message(initial_message, log_file_name)

bar()

try:
    # Checking CloudTrail logging status using AWS CLI
    cloudtrail_logging_status = subprocess.check_output(["aws", "cloudtrail", "describe-trails", "--query", "trailList[*].Logging", "--output", "text"], text=True).strip()
    log_message(f"CloudTrail 로깅 상태: {cloudtrail_logging_status}", log_file_name)

    # Update JSON data based on the CloudTrail logging status
    if cloudtrail_logging_status == "true":
        jsonData['진단결과'] = "양호"
    else:
        jsonData['진단결과'] = "취약"

except subprocess.CalledProcessError as e:
    log_message(f"Error: {str(e)}", log_file_name)
    jsonData['진단결과'] = "오류"

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
