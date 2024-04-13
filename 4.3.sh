#!/bin/bash

{
  "분류": "운영 관리",
  "코드": "4.3",
  "위험도": "중요도 중",
  "진단_항목": "S3 암호화 설정",
  "대응방안": {
    "설명": "버킷 기본 암호화 설정은 S3 버킷에 저장되는 모든 객체를 암호화 되도록 하는 설정입니다. Amazon S3 관리형 키(SSE-S3) 또는 AWS KMS 관리형 키(SSE-KMS)로 서버 측 암호화를 사용하여 객체를 암호화합니다.",
    "설정방법": [
      "S3 버킷 선택",
      "S3 버킷 속성 확인",
      "S3 버킷의 기본 암호화 설정이 SSE-S3 또는 SSE-KMS로 되어 있는지 확인"
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

# List all S3 buckets and their default encryption settings
echo "Retrieving S3 buckets and encryption status..."
s3_buckets_encryption_output=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve S3 buckets. Please check your AWS CLI setup and permissions."
    exit 1
fi

if [ -z "$s3_buckets_encryption_output" ]; then
    echo "No S3 buckets found."
    exit 0
fi

# Check each bucket for encryption settings
for bucket in $s3_buckets_encryption_output; do
    echo "Checking encryption for bucket: $bucket"
    encryption_status=$(aws s3api get-bucket-encryption --bucket $bucket --query 'ServerSideEncryptionConfiguration.Rules[].ApplyServerSideEncryptionByDefault.SSEAlgorithm' --output text 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$encryption_status" ]; then
        echo "Bucket $bucket does not have default encryption enabled."
        encryption_compliance="취약"
    else
        echo "Bucket $bucket is encrypted with $encryption_status."
        encryption_compliance="양호"
    fi

    # Update JSON diagnostic result directly using jq and sponge
    echo "Updating diagnosis result for bucket $bucket..."
    jq --arg bucket "$bucket" --arg status "$encryption_compliance" '.현황 += [{"Bucket": $bucket, "Encryption Status": $status}]' diagnosis.json | sponge diagnosis.json
    echo "Diagnosis updated for bucket $bucket with result: $encryption_compliance"
done

# Final compliance check
if [[ "$encryption_compliance" == "취약" ]]; then
    overall_status="취약"
else
    overall_status="양호"
fi
jq --arg overall_status "$overall_status" '.진단_결과 = $overall_status' diagnosis.json | sponge diagnosis.json
echo "Final diagnosis updated with overall result: $overall_status"
