#!usr/bin/python3
import json
import boto3
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "운영 관리",
    "코드": "4.8",
    "위험도": "중요도 중",
    "진단항목": "인스턴스 로깅 설정",
    "대응방안": {
        "설명": "Amazon CloudWatch Logs는 Amazon EC2 인스턴스, AWS CloudTrail, Route 53 및 기타 소스에서 로그 파일을 모니터링, 저장 및 액세스할 수 있습니다. 또한, 가상 인스턴스에 에이전트를 설치하여 로그 그룹에 등록된 로그 스트림을 통해 관련 로그를 확인할 수 있습니다.",
        "설정방법": [
            "EC2 내 CloudWatch 에이전트 설치",
            "CloudWatch 내 로그 그룹 확인",
            "로그 그룹 내 로그 스트림 확인",
            "로그 스트림 내 로깅 확인"
        ]
    },
    "현황": [],
    "진단결과": "양호"  # This can be updated to '취약' based on checks
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "instance_logging_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[4.8] 인스턴스 로깅 설정"
initial_message = "Amazon EC2 인스턴스의 CloudWatch 로깅 설정을 확인합니다."
log_message(initial_message, log_file_name)

bar()

# Use boto3 to interact with AWS services
ec2 = boto3.client('ec2')
logs = boto3.client('logs')

try:
    # List all instances
    instances = ec2.describe_instances()
    instance_ids = [instance['InstanceId'] for reservation in instances['Reservations'] for instance in reservation['Instances']]
    log_message(f"EC2 인스턴스 목록: {instance_ids}", log_file_name)

    # User input to select a specific instance (simulated here)
    instance_id = 'your-instance-id'  # Placeholder for user input
    log_message(f"선택된 인스턴스: {instance_id}", log_file_name)

    # Check CloudWatch Logs agent installation and log stream registration
    log_groups = logs.describe_log_groups()
    log_group_names = [log_group['logGroupName'] for log_group in log_groups['logGroups']]
    log_message(f"로그 그룹: {log_group_names}", log_file_name)

    # Assume the first log group is associated with the instance for demonstration
    log_streams = logs.describe_log_streams(logGroupName=log_group_names[0])
    log_stream_names = [log_stream['logStreamName'] for log_stream in log_streams['logStreams']]
    log_message(f"{log_group_names[0]} 내 로그 스트림: {log_stream_names}", log_file_name)

    # Set diagnostic result based on log configuration
    if log_stream_names:
        jsonData['진단결과'] = "양호"
    else:
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
