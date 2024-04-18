#!/bin/bash

{
  "분류": "운영 관리",
  "코드": "4.5",
  "위험도": "중요도 중",
  "진단_항목": "CloudTrail 암호화 설정",
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
  "진단_결과": "양호"
}

# Check for aws CLI tools
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install AWS CLI to run this script."
    exit 1
fi

# List all CloudTrail trails and their KMS encryption status
echo "Retrieving CloudTrail trails and encryption status..."
cloudtrail_encryption_status=$(aws cloudtrail describe-trails --query 'trailList[*].{Name:Name, KmsKeyId:KmsKeyId}' --output json)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve CloudTrail trails. Please check your AWS CLI setup and permissions."
    exit 1
fi

if [ -z "$cloudtrail_encryption_status" ]; then
    echo "No CloudTrail trails found or no encryption is applied."
    exit 0
fi

echo "CloudTrail Trails and KMS Encryption Status:"
echo "$cloudtrail_encryption_status"

# Simulate checking a specific CloudTrail trail
read -p "Enter CloudTrail trail name to check encryption: " trail_name

# Retrieve specific CloudTrail trail encryption configuration
echo "Checking encryption for CloudTrail trail '$trail_name'..."
trail_encryption_config=$(aws cloudtrail get-trail-status --name "$trail_name" --query 'TrailStatus.{IsLogging: IsLogging, LatestCloudWatchLogsDeliveryTime:LatestCloudWatchLogsDeliveryTime}' --output json)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve encryption status for CloudTrail trail '$trail_name'. Please check the trail name and your permissions."
    exit 1
fi

echo "Encryption Configuration for '$trail_name':"
echo "$trail_encryption_config"

# Determine the security status based on encryption status
encryption_status=$(echo "$trail_encryption_config" | jq -r '.KmsKeyId')
if [[ -z "$encryption_status" ]]; then
    echo "CloudTrail trail '$trail_name' does not use KMS encryption."
    compliance_status="취약"
else
    echo "CloudTrail trail '$trail_name' is using KMS encryption."
    compliance_status="양호"
fi

# Update JSON diagnostic result
echo "Updating diagnosis result..."
jq --arg status "$compliance_status" '.진단_결과 = $status' diagnosis.json | sponge diagnosis.json
echo "Diagnosis updated with result: $compliance_status"
