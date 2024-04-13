#!/bin/bash

{
  "분류": "운영 관리",
  "코드": "4.8",
  "위험도": "중요도 중",
  "진단_항목": "인스턴스 로깅 설정",
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
  "진단_결과": "양호"  // '취약'으로 업데이트 가능
}


# List all instances and their CloudWatch Logs agent status
instances_output=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --output text)
if [ $? -eq 0 ]; then
    echo "$instances_output"
else
    echo "Failed to retrieve instances."
    exit 1
fi

# User prompt to check a specific Instance ID
read -p "Enter Instance ID to check logging status: " instance_id

# Check CloudWatch Logs agent installation and log stream registration
log_agent_output=$(aws logs describe-log-groups --query 'logGroups[*].[logGroupName]' --output json)
log_streams_output=$(aws logs describe-log-streams --log-group-name "LogGroupNameHere" --query 'logStreams[*].[logStreamName]' --output json)
if [[ $(echo "$log_agent_output" | jq '. | length') -gt 0 && $(echo "$log_streams_output" | jq '. | length') -gt 0 ]]; then
    echo "Instance '$instance_id' has CloudWatch Logs agent installed and log streams registered."
else
    echo "Instance '$instance_id' does not have proper logging setup."
fi
