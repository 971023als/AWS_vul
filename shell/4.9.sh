#!/bin/bash

{
  "분류": "운영 관리",
  "코드": "4.9",
  "위험도": "중요도 중",
  "진단_항목": "RDS 로깅 설정",
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
  "진단_결과": "양호"  // '취약'으로 업데이트 가능
}


# List all RDS instances and check for logging settings
rds_instances_output=$(aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier, DBInstanceStatus]' --output text)
if [ $? -eq 0 ]; then
    echo "$rds_instances_output"
else
    echo "Failed to retrieve RDS instances."
    exit 1
fi

# User prompt to check a specific DB Instance Identifier for logging
read -p "Enter DB Instance Identifier to check logging status: " db_instance_id

# Check logging settings in CloudWatch for the specific RDS instance
logging_status_output=$(aws rds describe-db-log-files --db-instance-identifier "$db_instance_id" --query 'DescribeDBLogFiles[*].[LogFileName]' --output json)
if [[ $(echo "$logging_status_output" | jq '. | length') -gt 0 ]]; then
    echo "DB Instance '$db_instance_id' has logging enabled and logs are accessible in CloudWatch."
else
    echo "DB Instance '$db_instance_id' does not have proper logging setup or logs are not accessible."
fi
