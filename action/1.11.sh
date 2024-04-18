#!/bin/bash

# 변수 초기화
분류="계정 관리"
코드="1.11"
위험도="중요도 상"
진단_항목="EKS 사용자 관리"
대응방안="기본적으로 AWS 계정은 리소스에 대한 접근을 허용하는 최소한의 사용자 수와 권한으로 관리되어야 합니다. AWS에서는 IAM 사용자에게 EKS Cluster에 대한 액세스 권한을 부여할 경우 특정 쿠버네티스 RBAC 그룹에 매핑되는 사용자의 ‘aws-auth’ ConfigMap을 제공합니다. 이 ConfigMap은 초기에는 노드를 Cluster에 연결 목적으로 만들어졌으나 IAM 보안 주체에 역할 기반 액세스 제어(RBAC) 액세스를 추가하여 사용할 수도 있습니다."
설정방법="가. EKS ConfigMap(aws-auth) 사용자 접근 권한 확인: 1) ConfigMap(aws-auth) 설정 확인, 2) 권한 부여된 계정으로 EKS 리소스 접근 시도, 3) 권한 미부여된 계정으로 EKS 리소스 접근 시도, 나. ClusterRole/ClusterRoleBinding 생성 및 등록: 1) ClusterRole 파일 생성, 2) ClusterRoleBinding 파일 생성, 3) ClusterRole/ClusterRoleBinding 파일 적용, 4) 생성 확인"
현황=()
진단_결과=""

# EKS ConfigMap(aws-auth) 확인
configmap_status=$(kubectl describe configmap aws-auth -n kube-system)
if [[ "$configmap_status" == *"system:masters"* ]]; then
    echo "System:masters role found in aws-auth ConfigMap."
    진단_결과="취약"
else
    echo "System:masters role not found in aws-auth ConfigMap, which is good practice."
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
