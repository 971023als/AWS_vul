#!/bin/bash

# Initialize variables simulating JSON data structure
declare -A diagnostic_data=(
    [분류]="가상 리소스 관리"
    [코드]="3.4"
    [위험도]="중요도 중"
    [진단_항목]="라우팅 테이블 정책 관리"
    [대응방안]="라우팅 테이블에는 네트워크 트래픽을 전달할 위치 결정 시 사용되는 규칙입니다. VPC의 각 서브넷을 라우팅 테이블에 연결해야 하며, 테이블에서는 서브넷에 대한 라우팅을 제어하게 됩니다. 기본 라우팅 테이블은 다른 라우팅 테이블과 명시적으로 연결되지 않은 모든 서브넷에 대한 라우팅을 제어합니다."
    [설정방법]="VPC 내 라우팅 테이블 탭 접근 후 라우팅 편집 클릭, 라우팅 테이블 설정 및 저장"
    [진단_기준]="양호기준: 라우팅 테이블 내 ANY 정책이 설정되어 있지 않고 서비스 타깃 별로 설정되어 있을 경우, 취약기준: 라우팅 테이블 내 ANY 정책이 설정되어 있거나 서비스 타깃 별로 설정되어 있지 않을 경우"
    [현황]="[]"
    [진단_결과]="진단 필요"
)

echo "Fetching Routing Tables..."

# Retrieve all Routing Tables
routing_tables_output=$(aws ec2 describe-route-tables --query 'RouteTables[*].[RouteTableId, Routes]' --output text)
echo "Available Routing Tables:"
echo "$routing_tables_output"

# User prompt to select a specific Routing Table
read -p "Enter Routing Table ID to check policies: " rt_id

# Display the selected Routing Table's policies
echo "Routing Table Policies:"
aws ec2 describe-route-tables --route-table-id "$rt_id" --query 'RouteTables[*].Routes' --output json

# Assessing the Routing Table policies based on user checks
echo "Review the policies displayed above."
read -p "Does this Routing Table contain ANY policies or lacks service target specific policies? (yes/no): " policy_check

if [ "$policy_check" = "yes" ]; then
    echo "Routing Table contains ANY policies or lacks service target specific policies. It is vulnerable."
    diagnostic_data[진단_결과]="취약"
else
    echo "Routing Table policies are appropriate without ANY policies and are service target specific. It is satisfactory."
    diagnostic_data[진단_결과]="양호"
fi

# Output final assessment
echo "진단 결과: ${diagnostic_data[진단_결과]}"

# Output all diagnostic data
for key in "${!diagnostic_data[@]}"; do
    echo "$key: ${diagnostic_data[$key]}"
done
