#!/bin/bash

{
  "분류": "가상 리소스 관리",
  "코드": "3.2",
  "위험도": "중요도 상",
  "진단_항목": "보안 그룹 인/아웃바운드 불필요 정책 관리",
  "대응방안": {
    "설명": "VPC에서의 보안 그룹은 EC2 인스턴스에 대한 인/아웃바운드 트래픽을 제어하는 가상 방화벽 역할을 합니다. 보안 그룹을 통해 서브넷이 아닌 인스턴스 수준에서 트래픽을 제어하여, 각 인스턴스에 서로 다른 보안 그룹을 할당할 수 있습니다. 이를 통해 네트워크 프로토콜과 포트 범위에 따른 규칙을 설정하여 특정 소스에서만 통신이 가능하도록 합니다.",
    "설정방법": [
      "EC2 대시보드로 이동",
      "보안 그룹 선택 및 인바운드, 아웃바운드 규칙 검토",
      "불필요하거나 너무 넓은 범위로 설정된 규칙 수정 또는 삭제"
    ]
  },
  "현황": [],
  "진단_결과": "진단 필요"
}

# Script to manage Security Group Inbound/Outbound Unnecessary Policies
#!/bin/bash

echo "Fetching all security groups and their rules..."

# Retrieve all security groups
security_groups=$(aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId, GroupName, Description]' --output text)
echo "Available Security Groups:"
echo "$security_groups"

# User prompt to select a specific Security Group
read -p "Enter Security Group ID to check inbound/outbound rules: " sg_id

# Display the selected security group's inbound and outbound rules
echo "Inbound Rules:"
aws ec2 describe-security-groups --group-ids "$sg_id" --query 'SecurityGroups[*].IpPermissions' --output json
echo "Outbound Rules:"
aws ec2 describe-security-groups --group-ids "$sg_id" --query 'SecurityGroups[*].IpPermissionsEgress' --output json

# Assessment prompts based on user evaluation
read -p "Are there any unnecessary policies in inbound rules? (yes/no): " inbound_status
read -p "Are there any unnecessary policies in outbound rules? (yes/no): " outbound_status

if [ "$inbound_status" = "yes" ] || [ "$outbound_status" = "yes" ]; then
    echo "At least one security rule is identified as unnecessary. Recommend reviewing and updating the policies."
    진단_결과="취약"
else
    echo "No unnecessary policies detected. Security group settings are appropriate."
    진단_결과="양호"
fi

# Output final assessment
echo "진단 결과: $진단_결과"
