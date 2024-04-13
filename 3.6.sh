#!/bin/bash

{
  "분류": "가상 리소스 관리",
  "코드": "3.6",
  "위험도": "중요도 중",
  "진단_항목": "NAT 게이트웨이 연결 관리",
  "대응방안": {
    "설명": "NAT 게이트웨이는 NAT 디바이스를 사용하여 프라이빗 서브넷의 인스턴스를 인터넷(예: 소프트웨어 업데이트용) 또는 기타 AWS 서비스에 연결하는 한편, 인터넷에서 해당 인스턴스와의 연결을 시작하지 못하도록 합니다. NAT 디바이스는 프라이빗 서브넷의 인스턴스에서 인터넷 또는 기타 AWS 서비스로 트래픽을 전달한 다음 인스턴스에 응답을 다시 보냅니다. 트래픽이 인터넷으로 이동하면 소스 IPv4 주소가 NAT 디바이스의 주소로 대체되고, 이와 마찬가지로 응답 트래픽이 해당 인스턴스로 이동하면 NAT 디바이스에서 주소를 해당 인스턴스의 프라이빗 IPv4 주소로 다시 변환합니다.",
    "설정방법": [
      "NAT 게이트웨이 생성 및 프라이빗 연결 확인",
      "VPC 내 NAT 게이트웨이 탭 접근 후 NAT 게이트웨이 삭제 클릭"
    ]
  },
  "현황": [],
  "진단_결과": "양호"
}

# Check for jq and aws CLI tools
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install jq to run this script."
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install AWS CLI to run this script."
    exit 1
fi

# List all NAT Gateways and their connections
echo "Retrieving NAT Gateways..."
nat_gateways_output=$(aws ec2 describe-nat-gateways --query 'NatGateways[*].[NatGatewayId, State, SubnetId, VpcId]' --output text)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve NAT Gateways. Please check your AWS CLI setup and permissions."
    exit 1
fi

if [ -z "$nat_gateways_output" ]; then
    echo "No NAT Gateways found."
    exit 0
fi

echo "NAT Gateways and Connections:"
echo "$nat_gateways_output"

# User prompt to check a specific NAT Gateway
read -p "Enter NAT Gateway ID to check: " nat_gateway_id

# Check for unnecessary connections to the NAT Gateway
echo "Checking connections for NAT Gateway ID '$nat_gateway_id'..."
nat_gateway_connections=$(aws ec2 describe-network-interfaces --filters "Name=nat-gateway-id,Values=$nat_gateway_id" --query 'NetworkInterfaces[*].Attachment.InstanceId' --output json)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve connection information for NAT Gateway '$nat_gateway_id'. Please check your AWS CLI setup and permissions."
    exit 1
fi

if [ "$(echo "$nat_gateway_connections" | jq '. | length')" -gt 0 ]; then
    echo "NAT Gateway '$nat_gateway_id' has connections:"
    echo "$nat_gateway_connections"
    exit_status="양호"
else
    echo "NAT Gateway '$nat_gateway_id' has no active connections or is not connected to intended resources."
    exit_status="취약"
fi

# Update JSON diagnostic result directly using jq and sponge to avoid creating a temporary file
echo "Updating diagnosis result..."
jq --arg status "$exit_status" '.진단_결과 = $status' diagnosis.json | sponge diagnosis.json
echo "Diagnosis updated with result: $exit_status"
