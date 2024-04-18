#!/bin/bash

{
  "분류": "운영 관리",
  "코드": "4.2",
  "위험도": "중요도 중",
  "진단_항목": "RDS 암호화 설정",
  "대응방안": {
    "설명": "RDS는 데이터 보호를 위해 DB 인스턴스에서 암호화 옵션 기능을 제공하며, 암호화 시 AES-256 암호화 알고리즘을 이용하여 DB 인스턴스의 모든 로그, 백업 및 스냅샷 암호화가 가능합니다.",
    "설정방법": [
      "데이터베이스 클릭",
      "DB 생성 방식 및 엔진 등 설정",
      "데이터베이스 암호화 설정",
      "데이터베이스 생성 확인",
      "데이터베이스 암호화 확인"
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

# List all RDS instances with their encryption status
echo "Retrieving RDS instances and encryption status..."
rds_instances_output=$(aws rds describe-db-instances --query 'DBInstances[*].{DBInstanceIdentifier:DBInstanceIdentifier, StorageEncrypted:StorageEncrypted}' --output json)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve RDS instances. Please check your AWS CLI setup and permissions."
    exit 1
fi

if [ -z "$rds_instances_output" ]; then
    echo "No RDS instances found."
    exit 0
fi

echo "RDS Instances and Encryption Status:"
echo "$rds_instances_output"

# User prompt to check a specific RDS instance
read -p "Enter RDS instance identifier to check encryption status: " db_instance_identifier

# Check specific RDS instance encryption status
echo "Checking encryption status for RDS instance '$db_instance_identifier'..."
db_encryption_status=$(aws rds describe-db-instances --db-instance-identifier "$db_instance_identifier" --query 'DBInstances[*].StorageEncrypted' --output text)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve encryption status for RDS instance '$db_instance_identifier'. Please check the instance identifier and your permissions."
    exit 1
fi

echo "Encryption Status for '$db_instance_identifier': $db_encryption_status"

# Determine the security status based on encryption status
if [[ "$db_encryption_status" == "true" ]]; then
    echo "RDS instance '$db_instance_identifier' is encrypted."
    exit_status="양호"
else
    echo "RDS instance '$db_instance_identifier' is not encrypted."
    exit_status="취약"
fi

# Update JSON diagnostic result directly using jq and sponge
echo "Updating diagnosis result..."
jq --arg status "$exit_status" '.진단_결과 = $status' diagnosis.json | sponge diagnosis.json
echo "Diagnosis updated with result: $exit_status"
