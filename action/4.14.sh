#!/bin/bash

{
  "분류": "운영 관리",
  "코드": "4.14",
  "위험도": "중요도 중",
  "진단_항목": "EKS Cluster 제어 플레인 로깅 설정",
  "대응방안": {
    "설명": "Amazon EKS 제어 플레인 로깅은 Amazon EKS 제어 플레인에서 계정의 CloudWatch Logs로 직접 감사 및 진단 로그를 제공합니다. 이러한 로그를 사용하면 Cluster를 쉽게 보호하고 실행할 수 있습니다. 필요한 정확한 로그 유형을 선택할 수 있으며, 로그는 CloudWatch의 각 Amazon EKS Cluster에 대한 그룹에 로그 스트림으로 전송됩니다.",
    "설정방법": [
      "EKS Cluster 접근",
      "Observability 메뉴 확인",
      "제어 플레인 로깅 관리 설정",
      "로그 유형 별 On/Off 설정 후 변경 사항 저장",
      "설정된 제어 플레인 로깅 확인",
      "CloudWatch의 로그 그룹 확인",
      "저장된 유형 별 로그 스트림 확인"
    ]
  },
  "현황": [],
  "진단_결과": "양호"  // '취약'으로 업데이트 가능
}


# List all EKS clusters and their control plane logging settings
eks_logging_output=$(aws eks list-clusters --query 'clusters' --output text)
if [ $? -eq 0 ]; then
    echo "Retrieved EKS clusters:"
    echo "$eks_logging_output"
else
    echo "Failed to retrieve EKS clusters."
    exit 1
fi

# User prompt to check a specific EKS cluster for control plane logging
read -p "Enter EKS Cluster name to check logging settings: " eks_cluster_name

# Check control plane logging settings for the specific EKS cluster
control_plane_logging_output=$(aws eks describe-cluster --name "$eks_cluster_name" --query 'cluster.logging.clusterLogging[*].types' --output json)
if [ $? -eq 0 ]; then
    enabled_logs=$(echo "$control_plane_logging_output" | jq '.[] | select(.enabled == true) | .types[]')
    if [ -n "$enabled_logs" ]; then
        echo "EKS Cluster '$eks_cluster_name' has the following control plane logging enabled: $enabled_logs"
    else
        echo "EKS Cluster '$eks_cluster_name' does not have control plane logging enabled or it is not active."
    fi
else
    echo "Failed to retrieve control plane logging settings for EKS Cluster '$eks_cluster_name'."
    exit 1
fi
