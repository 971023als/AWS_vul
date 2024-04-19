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
    "코드": "4.12",
    "위험도": "중요도 중",
    "진단항목": "로그 보관 기간 설정",
    "대응방안": {
        "설명": "CloudWatch Logs에 저장되는 로그 데이터는 기본적으로 무기한 저장되므로, 기업 내부 정책 및 컴플라이언스 준수 등에 부합하도록 로그 데이터 저장 기간을 설정해야 합니다. AWS Management 콘솔의 CloudWatch 로그 그룹에서 저장 기간 설정이 가능합니다. 국내 클라우드 보안인증제 및 개인정보의 안전성 확보 조치 기준에 따라 보안감사 로그와 접근 기록은 최소 1년 이상 보존해야 합니다.",
        "설정방법": [
            "CloudWatch 로그 그룹 설정 확인",
            "로그 그룹 보존 기간 설정",
            "필요시 보존 기간 업데이트"
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
log_file_name = "cloudwatch_log_retention_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[4.12] CloudWatch 로그 보관 기간 설정"
initial_message = "CloudWatch 로그 그룹의 로그 보관 기간 설정을 진단합니다."
log_message(initial_message, log_file_name)

bar()

# Using boto3 to interact with AWS CloudWatch Logs
cloudwatch = boto3.client('logs')

try:
    # List all CloudWatch Logs groups and their retention settings
    log_groups = cloudwatch.describe_log_groups()
    if log_groups['logGroups']:
        for group in log_groups['logGroups']:
            retention = group.get('retentionInDays', 'Undefined')
            group_info = f"Log Group: {group['logGroupName']}, Retention (days): {retention}"
            log_message(group_info, log_file_name)
            if retention == 'Undefined' or retention < 365:
                jsonData['진단결과'] = "취약"
    else:
        log_message("활성화된 CloudWatch 로그 그룹이 없습니다.", log_file_name)
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

