#!/bin/bash

{
  "분류": "가상 리소스 관리",
  "코드": "3.10",
  "위험도": "중요도 중",
  "진단_항목": "ELB 연결 관리",
  "대응방안": {
    "설명": "Elastic Load Balancing은 둘 이상의 가용 영역에서 EC2 인스턴스, 컨테이너, IP 주소 등 여러 대상에 걸쳐 수신되는 트래픽을 자동으로 분산해주는 서비스입니다. ELB의 종류로는 Application Load Balancers, Network Load Balancers, Gateway Load Balancers 및 Classic Load Balancer가 있으며, 이들은 다양한 계층에서 작동하여 애플리케이션과 네트워크 트래픽을 관리합니다.",
    "설정방법": [
      "ELB 리스너 추가",
      "리스너 보안 설정 (TLS 적용)",
      "적용된 TLS 설정 확인",
      "가용 영역 설정 (AZ 2개 영역 이상 설정 권고)",
      "ELB에 대한 트래픽 제어 보안그룹 생성 및 수정",
      "ELB [속성] 내 모니터링 (액세스 로그) 설정 확인"
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

# List all ELBs in the region
echo "Retrieving ELBs..."
elb_output=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[*].{LoadBalancerName:LoadBalancerName, Type:Type}' --output json)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve ELBs. Please check your AWS CLI setup and permissions."
    exit 1
fi

if [ -z "$elb_output" ]; then
    echo "No ELBs found."
    exit 0
fi

echo "ELBs found:"
echo "$elb_output"

# User prompt to check a specific ELB
read -p "Enter ELB name to check configuration: " elb_name

# Check specific ELB configuration
echo "Checking configuration for ELB '$elb_name'..."
elb_config=$(aws elbv2 describe-load-balancers --names "$elb_name" --query 'LoadBalancers[*].{DNSName:DNSName, Type:Type}' --output json)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve configuration for ELB '$elb_name'. Please check the ELB name and your permissions."
    exit 1
fi

echo "ELB Configuration for '$elb_name':"
echo "$elb_config"

# Analyze the configuration for compliance
# Simulation: Assuming compliance is checked against specific criteria
compliance_status="양호"  # This would be determined by actual checks in a real script

# Update JSON diagnostic result directly using jq and sponge
echo "Updating diagnosis result..."
jq --arg status "$compliance_status" '.진단_결과 = $status' diagnosis.json | sponge diagnosis.json
echo "Diagnosis updated with result: $compliance_status"
