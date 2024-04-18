#!/bin/bash

{
  "분류": "가상 리소스 관리",
  "코드": "3.9",
  "위험도": "중요도 상",
  "진단_항목": "EKS Pod 보안 정책 관리",
  "대응방안": {
    "설명": "Pod 보안을 제어하기 위해 쿠버네티스는 (버전 1.23부터) Pod Security Standards(PSS)에 설명된 보안 제어를 구현하는 기본 제공 어드미션 컨트롤러인 Pod Security Admission (PSA)을 제공합니다. 이는 Amazon Elastic Kubernetes Service(EKS)에서 활성화되어 있으며, Pod Security Standards는 Kubernetes Cluster에서 실행되는 모든 Pod에 대한 일관된 보안 수준을 유지합니다.",
    "설정방법": [
      "네임스페이스 내 PSS / PSA 설정 및 확인",
      "PSS / PSA를 적용하기 위한 네임스페이스 생성",
      "생성된 네임스페이스 라벨 내 PSS / PSA 적용 (enforce=restricted)",
      "네임스페이스 내 파드 생성 시도를 통해 PSS / PSA 적용 확인 (파드 생성 실패)"
    ]
  },
  "현황": [],
  "진단_결과": "양호"
}


# Check for kubectl command
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install kubectl to run this script."
    exit 1
fi

# List all EKS clusters (assuming AWS CLI v2 and configured profiles)
echo "Retrieving EKS clusters..."
eks_clusters=$(aws eks list-clusters --query 'clusters' --output text)
if [ $? -ne 0 ] || [ -z "$eks_clusters" ]; then
    echo "Failed to retrieve EKS clusters or no clusters found."
    exit 1
fi

echo "EKS Clusters found:"
echo "$eks_clusters"

# User prompt to select an EKS cluster
read -p "Enter EKS cluster name to check the Pod Security Policies: " cluster_name

# Configure kubectl to use the selected EKS cluster
aws eks update-kubeconfig --name "$cluster_name"
if [ $? -ne 0 ]; then
    echo "Failed to configure kubectl for cluster '$cluster_name'."
    exit 1
fi

# Check if Pod Security Admission (PSA) is enabled
echo "Checking Pod Security Admission settings for '$cluster_name'..."
psa_status=$(kubectl get configurations pod-security.admission.config.k8s.io -o=jsonpath='{.spec.modes}')
if [ -z "$psa_status" ]; then
    echo "Pod Security Admission is not configured."
    exit_status="취약"
else
    echo "Pod Security Admission is configured with modes: $psa_status"
    exit_status="양호"
fi

# Update JSON diagnostic result directly using jq and sponge
echo "Updating diagnosis result..."
jq --arg status "$exit_status" '.진단_결과 = $status' diagnosis.json | sponge diagnosis.json
echo "Diagnosis updated with result: $exit_status"
