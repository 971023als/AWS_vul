#!/bin/bash

{
  "분류": "운영 관리",
  "코드": "4.10",
  "위험도": "중요도 중",
  "진단_항목": "S3 버킷 로깅 설정",
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
  "진단_결과": "양호"  // '취약'으로 업데이트 가능
}


# List all S3 buckets and check for server access logging settings
s3_buckets_output=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)
if [ $? -eq 0 ]; then
    echo "$s3_buckets_output"
else
    echo "Failed to retrieve S3 buckets."
    exit 1
fi

# User prompt to check a specific S3 bucket for logging
read -p "Enter S3 Bucket name to check logging status: " s3_bucket_name

# Check server access logging status of the S3 bucket
logging_status_output=$(aws s3api get-bucket-logging --bucket "$s3_bucket_name" --output json)
if [ $? -eq 0 ]; then
    if [ -n "$(echo "$logging_status_output" | jq '.LoggingEnabled')" ]; then
        echo "S3 Bucket '$s3_bucket_name' has server access logging enabled."
    else
        echo "S3 Bucket '$s3_bucket_name' does not have server access logging enabled."
    fi
else
    echo "Failed to retrieve logging status for S3 Bucket '$s3_bucket_name'."
    exit 1
fi
