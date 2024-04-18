#!/bin/bash

{
  "분류": "운영 관리",
  "코드": "4.15",
  "위험도": "중요도 중",
  "진단_항목": "EKS Cluster 암호화 설정",
  "대응방안": {
    "설명": "Kubernetes 비밀(Secret)은 비밀번호, 토큰, 키와 같은 소량의 민감한 데이터를 포함하는 객체이며 기본적으로 API 서버의 기본 데이터 저장소(etcd)에 암호화되지 않은 상태로 저장됩니다. 비밀 암호화를 활성화하면 AWS Key Management Service(AWS KMS) 키를 사용하여 Cluster의 etcd에 저장된 Kubernetes 비밀 암호화를 제공합니다. 이는 사용자가 정의하고 관리하는 AWS KMS 키로 Kubernetes 비밀을 암호화하여 Kubernetes 애플리케이션에 대한 안전한 배포를 할 수 있습니다.",
    "설정방법": [
      "EKS Cluster 내 [개요] – [암호 암호화] 설정 확인",
      "KMS 키 적용 후 암호 활성화",
      "암호 암호화 설정 시 유의 사항 확인 후 활성화 시도",
      "암호 암호화 설정 확인"
    ]
  },
  "현황": [],
  "진단_결과": "양호"  // '취약'으로 업데이트 가능
}


# List all EKS clusters and their encryption settings
eks_clusters_output=$(aws eks list-clusters --query 'clusters[*]' --output text)
if [ $? -eq 0 ]; then
    echo "Retrieved EKS clusters:"
    for cluster in $eks_clusters_output; do
        echo "Checking encryption for cluster: $cluster"
        encryption_status=$(aws eks describe-cluster --name $cluster --query 'cluster.encryptionConfig[*].resources' --output json)
        if [[ "$encryption_status" == "[]" ]]; then
            echo "Cluster '$cluster' does not have encryption enabled."
        else
            echo "Cluster '$cluster' has encryption enabled with resources: $encryption_status"
        fi
    done
else
    echo "Failed to retrieve EKS clusters."
    exit 1
fi

# User prompt to check a specific EKS cluster for encryption settings
read -p "Enter EKS Cluster name to check encryption settings: " eks_cluster_name

# Check encryption settings for the specific EKS cluster
encryption_details=$(aws eks describe-cluster --name "$eks_cluster_name" --query 'cluster.encryptionConfig' --output json)
if [ $? -eq 0 ]; then
    if [ -n "$encryption_details" ]; then
        echo "EKS Cluster '$eks_cluster_name' has the following encryption settings enabled: $encryption_details"
    else
        echo "EKS Cluster '$eks_cluster_name' does not have encryption settings enabled."
    fi
else
    echo "Failed to retrieve encryption settings for EKS Cluster '$eks_cluster_name'."
    exit 1
fi
