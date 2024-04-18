#!/bin/bash

{
  "분류": "운영 관리",
  "코드": "4.13",
  "위험도": "중요도 중",
  "진단_항목": "백업 사용 여부",
  "대응방안": {
    "설명": "운영중인 클라우드 리소스에 대한 시스템 충돌, 장애 발생, 인적 재해 등 기업의 사업 연속성을 해치는 모든 상황에 대비하기 위해 백업 서비스를 구성해야 데이터를 안전하게 보관할 수 있습니다. 보안 담당자 및 관리자는 클라우드 리소스에 대한 백업을 설정하여 데이터 손실을 방지할 수 있도록 정책을 수립하고 관리해야 합니다.",
    "설정방법": [
      "백업 및 복구 절차 수립, 담당자 지정",
      "- 백업대상(서버 이미지, DB 데이터, 보안로그 등) 선정",
      "- 백업대상별 백업 주기 및 보존기한 정의",
      "- 백업 담당자 및 책임자 지정",
      "- 백업방법 및 절차: 백업시스템 활용, 매뉴얼 방식 등(백업매체 관리 포함)",
      "- 복구절차",
      "- 백업이력관리 (백업 관리 대장)",
      "- 백업 소산에 대한 물리적‧지역적 사항 고려",
      "- 백업 사이트 구축 및 운영"
    ]
  },
  "현황": [],
  "진단_결과": "양호"  // '취약'으로 업데이트 가능
}


# List all instances and check for backup configurations
instances_backup_output=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId, Tags[?Key==`Backup`].Value | [0]]' --output text)
if [ $? -eq 0 ]; then
    echo "Retrieved instances and backup tags:"
    echo "$instances_backup_output"
else
    echo "Failed to retrieve backup configurations."
    exit 1
fi

# User prompt to check a specific instance for backup settings
read -p "Enter Instance ID to check backup status: " instance_id

# Check backup configuration for the specific instance
backup_config_output=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" "Name=key,Values=Backup" --query 'Tags[*].[Value]' --output json)
if [ $? -eq 0 ]; then
    if [ "$(echo "$backup_config_output" | jq -r '. | length')" -gt 0 ]; then
        echo "Instance '$instance_id' has backup policies tagged: $(echo "$backup_config_output" | jq -r '.[]')"
    else
        echo "Instance '$instance_id' does not have backup policies configured or tagged."
    fi
else
    echo "Failed to retrieve backup configuration for Instance '$instance_id'."
    exit 1
fi
