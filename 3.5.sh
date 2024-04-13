#!/bin/bash

{
  "분류": "가상 리소스 관리",
  "코드": "3.5",
  "위험도": "중요도 하",
  "진단_항목": "인터넷 게이트웨이 연결 관리",
  "대응방안": {
    "설명": "인터넷 게이트웨이는 수평 확장되고 가용성이 높은 중복 VPC 구성요소로, VPC의 인스턴스와 인터넷 간에 통신이 가능할 수 있게 해주는 기능이며 네트워크 트래픽 가용성 위험이나 대역폭 제약조건이 별도로 발생하진 않습니다. 인터넷 게이트웨이는 VPC 라우팅 테이블에 인터넷 Route 가능 트래픽에 대한 대상을 제공하며, 퍼블릭 IPv4 주소가 할당된 인스턴스에 대해 NAT를 수행합니다. 이는 IPv4, IPv6 트래픽을 모두 지원합니다.",
    "설정방법": [
      "인터넷 게이트웨이 설정 확인",
      "VPC → '인터넷 게이트웨이' → '인터넷 게이트웨이' 선택 → 작업 → VPC에서 분리하여 인터넷 게이트웨이 삭제 방법"
    ]
  },
  "현황": [],
  "진단_결과": "양호"
}


# Ensure jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found, please install it to run this script."
    exit 1
fi

# List all Internet Gateways and their VPC Connections
internet_gateways_output=$(aws ec2 describe-internet-gateways --query 'InternetGateways[*].[InternetGatewayId, Attachments]' --output text)
if [ $? -eq 0 ]; then
    echo "Internet Gateways and VPC Attachments:"
    echo "$internet_gateways_output"
else
    echo "Failed to retrieve Internet Gateways. Please check your AWS CLI setup and permissions."
    exit 1
fi

# User prompt to check a specific Internet Gateway
echo "Available Internet Gateways:"
echo "$internet_gateways_output" | awk '{print $1}'  # Assuming the first column is the ID
read -p "Enter Internet Gateway ID to check: " internet_gateway_id

# Check for unnecessary NAT Gateways connected to the Internet Gateway
nat_gateway_output=$(aws ec2 describe-nat-gateways --filter "Name=internet-gateway-id,Values=$internet_gateway_id" --query 'NatGateways' --output json)
if [ $? -eq 0 ]; then
    nat_gateway_count=$(echo "$nat_gateway_output" | jq '. | length')
    if [ "$nat_gateway_count" -eq "0" ]; then
        echo "Internet Gateway '$internet_gateway_id' has no unnecessary NAT Gateways connected."
        exit_status="양호"
    else
        echo "Internet Gateway '$internet_gateway_id' has one or more unnecessary NAT Gateways connected."
        exit_status="취약"
    fi
else
    echo "Failed to retrieve NAT Gateway information. Please check your AWS CLI setup and permissions."
    exit 1
fi

# Update JSON diagnostic result
jq --arg status "$exit_status" '.진단_결과 = $status' diagnosis.json | sponge diagnosis.json
echo "Diagnosis updated with result: $exit_status"