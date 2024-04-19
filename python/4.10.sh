#!usr/bin/python3
import json
import boto3
import subprocess

# Python dictionary for JSON data
jsonData = {
    "분류": "운영 관리",
    "코드": "4.10",
    "위험도": "중요도 중",
    "진단항목": "S3 버킷 로깅 설정",
    "대응방안": {
        "설명": "S3(Simple Storage Service)는 기본적으로 서버 액세스 로그를 수집하지 않으며, AWS Management 콘솔을 통해 S3 버킷에 대한 서버 액세스 로깅을 활성화시킬 수 있습니다. 로깅을 활성화하면, S3 액세스 로그가 사용자가 선택한 대상 버킷에 저장되며, 로그 레코드에는 요청 유형, 요청된 리소스, 요청 처리 날짜 및 시간 등이 포함됩니다. 대상 버킷은 원본 버킷과 동일한 AWS 리전에 있어야 합니다.",
        "설정방법": [
            "CloudTrail 대시보드 진입 및 로깅 내용 확인",
            "CloudTrail 추적 로그 위치 확인",
            "CloudTrail 추적 로그 S3 버킷 위치 접근",
            "S3 버킷 서버 액세스 로깅 비활성화 확인 및 편집 버튼 클릭",
            "S3 버킷 서버 액세스 로깅 활성화",
            "S3 버킷 서버 액세스 로깅 활성화 확인"
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
log_file_name = "s3_logging_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[4.10] S3 버킷 로깅 설정"
initial_message = "S3 버킷의 서버 액세스 로깅 설정을 확인합니다."
log_message(initial_message, log_file_name)

bar()

# Using boto3 to interact with AWS S3
s3 = boto3.client('s3')

try:
    # List all S3 buckets
    buckets = s3.list_buckets()
    bucket_names = [bucket['Name'] for bucket in buckets['Buckets']]
    log_message(f"S3 버킷 목록: {bucket_names}", log_file_name)

    # User input to select a specific bucket (simulated here)
    bucket_name = 'your-bucket-name'  # Placeholder for user input
    log_message(f"선택된 S3 버킷: {bucket_name}", log_file_name)

    # Check if server access logging is enabled for the selected S3 bucket
    logging_status = s3.get_bucket_logging(Bucket=bucket_name)
    if 'LoggingEnabled' in logging_status:
        log_message(f"S3 버킷 '{bucket_name}'은 서버 액세스 로깅이 활성화되어 있습니다.", log_file_name)
        jsonData['진단결과'] = "양호"
    else:
        log_message(f"S3 버킷 '{bucket_name}'은 서버 액세스 로깅이 활성화되어 있지 않습니다.", log_file_name)
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
