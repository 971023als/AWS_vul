#!usr/bin/python3
import json
import boto3
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "운영 관리",
    "코드": "4.9",
    "위험도": "중요도 중",
    "진단항목": "RDS 로깅 설정",
    "대응방안": {
        "설명": "Amazon CloudWatch Logs를 통해 Amazon RDS 인스턴스의 로그를 모니터링, 저장 및 액세스할 수 있습니다. 데이터베이스 옵션을 수정하여 로그 그룹에 등록된 로그 스트림을 통해 RDS 로그를 확인할 수 있습니다.",
        "설정방법": [
            "RDS 내 데이터베이스 수정",
            "데이터베이스 수정 페이지 접근",
            "로그 내보내기 옵션 선택",
            "DB 인스턴스 수정 클릭",
            "로그 그룹 확인 및 클릭",
            "로그 스트림 확인 및 클릭",
            "로그 스트림 내 RDS 로깅 확인"
        ]
    },
    "현황": [],
    "진단결과": "양호"  # '취약'으로 업데이트 가능
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "rds_logging_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[4.9] RDS 로깅 설정"
initial_message = "Amazon RDS 인스턴스의 CloudWatch 로깅 설정을 확인합니다."
log_message(initial_message, log_file_name)

bar()

# Use boto3 to interact with AWS services
rds = boto3.client('rds')
logs = boto3.client('logs')

try:
    # List all RDS instances
    instances = rds.describe_db_instances()
    instance_ids = [instance['DBInstanceIdentifier'] for instance in instances['DBInstances']]
    log_message(f"RDS 인스턴스 목록: {instance_ids}", log_file_name)

    # User input to select a specific instance (simulated here)
    instance_id = 'your-db-instance-id'  # Placeholder for user input
    log_message(f"선택된 RDS 인스턴스: {instance_id}", log_file_name)

    # Check if CloudWatch Logs is enabled for the selected RDS instance
    logs_enabled = any(['EnabledCloudwatchLogsExports' in db_instance and 'audit' in db_instance['EnabledCloudwatchLogsExports'] for db_instance in instances['DBInstances'] if db_instance['DBInstanceIdentifier'] == instance_id])
    log_message(f"CloudWatch 로그 설정 상태: {'활성화' if logs_enabled else '비활성화'}", log_file_name)

    # Set diagnostic result based on log configuration
    jsonData['진단결과'] = "양호" if logs_enabled else "취약"

except Exception as e:
    log_message(f"Error: {str(e)}", log_file_name)
    jsonData['진단결과'] = "오류 발생"

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
