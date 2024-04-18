#!/bin/bash

{
  "분류": "운영 관리",
  "코드": "4.12",
  "위험도": "중요도 중",
  "진단_항목": "로그 보관 기간 설정",
  "대응방안": {
    "설명": "CloudWatch Logs에 저장되는 로그 데이터는 기본적으로 무기한 저장되므로, 기업 내부 정책 및 컴플라이언스 준수 등에 부합하도록 로그 데이터 저장 기간을 설정해야 합니다. AWS Management 콘솔의 CloudWatch 로그 그룹에서 저장 기간 설정이 가능합니다. 국내 클라우드 보안인증제 및 개인정보의 안전성 확보 조치 기준에 따라 보안감사 로그와 접근 기록은 최소 1년 이상 보존해야 합니다.",
    "설정방법": [
      "CloudTrail 대시보드 진입",
      "CloudTrail 로그 그룹 진입 및 보존 기간 확인",
      "CloudTrail 보존 설정 편집 버튼 클릭",
      "CloudTrail 보존 설정 기간 설정",
      "CloudTrail 보존 설정 기간 정책에 맞게 설정 완료"
    ]
  },
  "현황": [],
  "진단_결과": "양호"  // '취약'으로 업데이트 가능
}


# List CloudWatch Logs groups and their retention policies
log_groups_output=$(aws logs describe-log-groups --query 'logGroups[*].[logGroupName, retentionInDays]' --output text)
if [ $? -eq 0 ]; then
    echo "Retrieved log groups and retention settings:"
    echo "$log_groups_output"
else
    echo "Failed to retrieve log groups."
    exit 1
fi

# User prompt to check a specific CloudWatch Log Group for retention settings
read -p "Enter Log Group name to check retention policy: " log_group_name

# Check retention policy of the specific log group
retention_policy_output=$(aws logs describe-log-groups --log-group-name-prefix "$log_group_name" --query 'logGroups[*].[logGroupName, retentionInDays]' --output json)
if [ $? -eq 0 ]; then
    if [ "$(echo "$retention_policy_output" | jq -r '.[].retentionInDays')" -ge 365 ]; then
        echo "Log Group '$log_group_name' meets the minimum retention policy of 1 year."
    else
        echo "Log Group '$log_group_name' does not meet the minimum retention policy of 1 year."
    fi
else
    echo "Failed to retrieve retention policy for Log Group '$log_group_name'."
    exit 1
fi
