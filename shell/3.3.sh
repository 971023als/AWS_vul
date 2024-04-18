#!/bin/bash

# Initialize variables simulating JSON data structure
declare -A diagnostic_data=(
    [분류]="가상 리소스 관리"
    [코드]="3.3"
    [위험도]="중요도 중"
    [진단_항목]="네트워크 ACL 인/아웃바운드 트래픽 정책 관리"
    [대응방안]="네트워크 ACL은 서브넷 내부와 외부의 트래픽을 제어하는 VPC의 선택적 보안 계층입니다. 이를 적절히 설정하면 VPC 내 리소스 보호를 강화할 수 있습니다."
    [설정방법]="AWS 콘솔 또는 CLI를 통해 네트워크 ACL 설정 접근, 규칙 추가 및 수정을 관리할 수 있습니다."
    [현황]="[]"
    [진단_결과]="진단 필요"
)

echo "Fetching Network ACLs and their rules..."

# Retrieve all Network ACLs
netacls_output=$(aws ec2 describe-network-acls --query 'NetworkAcls[*].[NetworkAclId, Entries]' --output text)
echo "Available Network ACLs:"
echo "$netacls_output"

# User prompt to select a specific Network ACL
read -p "Enter Network ACL ID to check rules: " acl_id

# Display the selected Network ACL's rules
echo "Network ACL Rules:"
aws ec2 describe-network-acls --network-acl-id "$acl_id" --query 'NetworkAcls[*].Entries' --output json

# Assessing the Network ACL rules based on user checks
echo "Review the rules displayed above."
read -p "Are there unnecessary allow policies in inbound rules? (yes/no): " inbound_check
read -p "Are there unnecessary allow policies in outbound rules? (yes/no): " outbound_check

if [ "$inbound_check" = "yes" ] || [ "$outbound_check" = "yes" ]; then
    echo "At least one unnecessary rule is found. Recommend revising the ACL settings."
    diagnostic_data[진단_결과]="취약"
else
    echo "No unnecessary rules found. ACL settings are appropriate."
    diagnostic_data[진단_결과]="양호"
fi

# Output final assessment
echo "진단 결과: ${diagnostic_data[진단_결과]}"

# Output all diagnostic data
for key in "${!diagnostic_data[@]}"; do
    echo "$key: ${diagnostic_data[$key]}"
done
