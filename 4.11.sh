#!/bin/bash

{
  "분류": "운영 관리",
  "코드": "4.11",
  "위험도": "중요도 중",
  "진단_항목": "VPC 플로우 로깅 설정",
  "대응방안": {
    "설명": "VPC 플로우 로그는 VPC의 네트워크 인터페이스에서 송∙수신되는 IP 트래픽에 대한 정보를 수집할 수 있는 기능으로, VPC, 서브넷 또는 네트워크 인터페이스에 생성할 수 있습니다. 수집된 로그 데이터는 CloudWatch Logs 또는 S3로 저장할 수 있으며, AWS Management 콘솔의 [VPC] - [플로우 로그] 항목에서 설정할 수 있습니다.",
    "설정방법": [
      "VPC 플로우 로그 설정여부 확인",
      "VPC 플로우 로그 이름, 필터 설정",
      "VPC 플로우 로그 대상(CloudWatch), 로그 그룹, IAM 역할 및 로그 레코드 형식 설정",
      "VPC 플로우 로그 설정 확인",
      "VPC 플로우 로그 대상(S3), 로그 그룹, IAM 역할 및 로그 레코드 형식 설정"
    ]
  },
  "현황": [],
  "진단_결과": "양호"  // '취약'으로 업데이트 가능
}


# List all VPCs and check for flow logging settings
vpc_flow_logs_output=$(aws ec2 describe-flow-logs --query 'FlowLogs[*].[FlowLogId, ResourceId, LogDestinationType]' --output text)
if [ $? -eq 0 ]; then
    echo "$vpc_flow_logs_output"
else
    echo "Failed to retrieve VPC flow logs."
    exit 1
fi

# User prompt to check a specific VPC for flow logging
read -p "Enter VPC ID to check flow logging status: " vpc_id

# Check flow logging status of the specific VPC
flow_logging_status_output=$(aws ec2 describe-flow-logs --filter "Name=resource-id,Values=$vpc_id" --query 'FlowLogs[*].[FlowLogStatus, LogDestinationType]' --output json)
if [ $? -eq 0 ]; then
    if [ -n "$(echo "$flow_logging_status_output" | jq '.[] | select(.FlowLogStatus == "ACTIVE")')" ]; then
        echo "VPC '$vpc_id' has flow logging enabled."
    else
        echo "VPC '$vpc_id' does not have flow logging enabled or it is not active."
    fi
else
    echo "Failed to retrieve flow logging status for VPC '$vpc_id'."
    exit 1
fi
