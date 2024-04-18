#!/bin/bash

{
  "분류": "가상 리소스 관리",
  "코드": "3.7",
  "위험도": "중요도 중",
  "진단_항목": "S3 버킷/객체 접근 관리",
  "대응방안": {
    "설명": "S3 버킷의 경우 리소스(버킷)를 생성한 소유자에 대해 리소스 액세스가 가능하며, 액세스 정책을 별도로 설정하여 다른 사람에게 액세스 권한을 부여할 수 있습니다. 퍼블릭 액세스 차단 설정이 되지 않을 경우, 외부로부터 버킷 및 객체가 노출되므로 안전한 버킷/객체 접근을 위해 목적에 맞는 접근 설정을 해야 합니다.",
    "설정방법": [
      "서비스 > S3 > 퍼블릭 액세스 차단을 위한 계정 설정 내 상태 확인",
      "서비스 > S3 > 퍼블릭 액세스 차단을 위한 계정 설정 > 편집 (비활성화 시)",
      "모든 퍼블릭 액세스 차단 활성화",
      "서비스 > S3 > 버킷 > 설정된 버킷 선택 > 권한 > ACL(액세스 제어 목록) 확인 및 편집 (기타 권한 존재 시 불필요 권한 비활성화)"
    ]
  },
  "현황": [],
  "진단_결과": "양호"
}


# Check for aws CLI tools
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install AWS CLI to run this script."
    exit 1
fi

# List all S3 buckets
echo "Retrieving S3 buckets..."
s3_buckets_output=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve S3 buckets. Please check your AWS CLI setup and permissions."
    exit 1
fi

if [ -z "$s3_buckets_output" ]; then
    echo "No S3 buckets found."
    exit 0
fi

echo "S3 Buckets:"
echo "$s3_buckets_output"

# User prompt to check a specific S3 bucket
read -p "Enter S3 bucket name to check: " bucket_name

# Check public access settings for the specific S3 bucket
echo "Checking public access settings for bucket '$bucket_name'..."
public_access_block=$(aws s3api get-public-access-block --bucket "$bucket_name" --output json)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve public access settings for '$bucket_name'."
    exit 1
fi

echo "Public Access Settings for '$bucket_name':"
echo "$public_access_block"

# Determine the status based on public access settings
if [[ $(echo "$public_access_block" | jq '.PublicAccessBlockConfiguration.BlockPublicAcls') == "true" ]]; then
    echo "Public access is properly blocked for '$bucket_name'."
    exit_status="양호"
else
    echo "Public access is not properly blocked for '$bucket_name'."
    exit_status="취약"
fi

# Update JSON diagnostic result directly using jq and sponge to avoid creating a temporary file
echo "Updating diagnosis result..."
jq --arg status "$exit_status" '.진단_결과 = $status' diagnosis.json | sponge diagnosis.json
echo "Diagnosis updated with result: $exit_status"
