#!/bin/bash

# 변수 초기화
분류="가상 리소스 관리"
코드="3.1"
위험도="중요도 상"
진단_항목="보안 그룹 인/아웃바운드 ANY 설정 관리"
대응방안="VPC 내 보안 그룹을 통한 인/아웃바운드 트래픽을 적절하게 제어해야 합니다. 인스턴스에 할당된 보안 그룹을 검토하여 모든 포트에 대한 넓은 범위의 허용이 설정되어 있지 않도록 관리해야 합니다."
설정방법="AWS Management Console 또는 AWS CLI를 사용하여 보안 그룹의 인/아웃바운드 규칙을 검토하고 수정합니다."
현황=()
진단_결과=""

echo "Checking Security Group settings for any wide open ports..."

# 보안 그룹 설정 검토
security_groups=$(aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId,GroupName]' --output text)

echo "Available Security Groups:"
echo "$security_groups"

# User prompt to select a specific Security Group
read -p "Enter Security Group ID to check: " sg_id

# Check inbound and outbound rules for 'ANY' settings (0.0.0.0/0 or ::/0)
inbound_any=$(aws ec2 describe-security-groups --group-ids "$sg_id" --query 'SecurityGroups[*].IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`] || Ipv6Ranges[?CidrIpv6==`::/0`]].FromPort' --output text)
outbound_any=$(aws ec2 describe-security-groups --group-ids "$sg_id" --query 'SecurityGroups[*].IpPermissionsEgress[?IpRanges[?CidrIp==`0.0.0.0/0`] || Ipv6Ranges[?CidrIpv6==`::/0`]].FromPort' --output text)

# Result processing and diagnosis
if [ -n "$inbound_any" ] || [ -n "$outbound_any" ]; then
    echo "Security Group '$sg_id' has open 'ANY' settings on these ports:"
    echo "Inbound Open Ports: $inbound_any"
    echo "Outbound Open Ports: $outbound_any"
    진단_결과="취약"
else
    echo "Security Group '$sg_id' does not have any wide open 'ANY' settings."
    진단_결과="양호"
fi

# 결과 출력
echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단_항목: $진단_항목"
echo "대응방안: $대응방안"
echo "설정방법: $설정방법"
echo "현황: ${현황[@]}"
echo "진단_결과: $진단_결과"
