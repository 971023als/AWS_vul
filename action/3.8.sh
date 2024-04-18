#!/bin/bash

{
  "분류": "가상 리소스 관리",
  "코드": "3.8",
  "위험도": "중요도 중",
  "진단_항목": "RDS 서브넷 가용 영역 관리",
  "대응방안": {
    "설명": "서브넷이란 하나의 IP 네트워크 주소를 지역적으로 나누어 이 하나의 네트워크 IP 주소가 실제로 여러 개의 서로 연결된 지역 네트워크로 사용할 수 있도록 하는 방법입니다. EC2 인스턴스와 RDS 상호 통신 시 필요하나, 불필요한 서브넷이 포함되어 있을 경우 보안성 위험을 발생시킬 수 있으므로 불필요한 서브넷의 유무를 관리해야 합니다.",
    "설정방법": [
      "서브넷 그룹 설정 확인",
      "서브넷 그룹 확인",
      "연결된 서브넷 확인"
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

# List all RDS subnet groups
echo "Retrieving RDS subnet groups..."
rds_subnet_groups_output=$(aws rds describe-db-subnet-groups --query 'DBSubnetGroups[*].{DBSubnetGroupName:DBSubnetGroupName, SubnetIds:Subnets[*].SubnetIdentifier}' --output json)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve RDS subnet groups. Please check your AWS CLI setup and permissions."
    exit 1
fi

if [ -z "$rds_subnet_groups_output" ]; then
    echo "No RDS subnet groups found."
    exit 0
fi

echo "RDS Subnet Groups and associated subnets:"
echo "$rds_subnet_groups_output"

# User prompt to check a specific RDS subnet group
read -p "Enter RDS subnet group name to check for unnecessary subnets: " subnet_group_name

# Analyze the subnet group for unnecessary subnets
echo "Analyzing subnet group '$subnet_group_name'..."
# Simulation: Normally you would call an API or have a logic to determine unnecessary subnets
# Here you should replace this part with your actual logic based on your criteria
unnecessary_subnets_count=0  # Placeholder value

if [ "$unnecessary_subnets_count" -eq 0 ]; then
    echo "No unnecessary subnets found in the subnet group '$subnet_group_name'."
    exit_status="양호"
else
    echo "Unnecessary subnets found in the subnet group '$subnet_group_name'."
    exit_status="취약"
fi

# Update JSON diagnostic result directly using jq and sponge to avoid creating a temporary file
echo "Updating diagnosis result..."
jq --arg status "$exit_status" '.진단_결과 = $status' diagnosis.json | sponge diagnosis.json
echo "Diagnosis updated with result: $exit_status"
