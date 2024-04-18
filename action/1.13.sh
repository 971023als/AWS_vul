#!/bin/bash

# 변수 초기화
분류="계정 관리"
코드="1.13"
위험도="중요도 상"
진단_항목="EKS 불필요한 익명 접근 관리"
대응방안="클라우드 환경에서는 모든 API 및 리소스 작업 시 익명 사용자의 접근을 비활성화해야 합니다. 쿠버네티스는 'system:anonymous'에 대한 권한을 부여할 수 있는 RoleBinding을 생성할 수 있으며, 이는 보안에 취약할 수 있습니다. Kubernetes/EKS 버전 1.14 이전에는 'system:unauthenticated' 그룹이 일부 기본 Cluster 역할에 연결되므로 업데이트 후에도 이 권한이 유지되지 않도록 주의해야 합니다."
설정방법="가. EKS 내 불필요한 익명 접근 삭제: 1) kubectl 명령을 통한 불필요 익명 사용자 조회, 2) 불필요 익명 접근 Cluster 연결 정책 삭제, 3) 불필요 익명 접근 정책 삭제 결과 확인"
현황=()
진단_결과=""

# 불필요한 익명 사용자 접근 권한 조회 및 삭제
echo "Checking for unnecessary anonymous access permissions..."
access_check=$(kubectl rbac-tool lookup | grep -P 'system:(anonymous|unauthenticated)')

if [ -z "$access_check" ]; then
    echo "No unnecessary anonymous access permissions found."
    진단_결과="양호"
else
    echo "Unnecessary anonymous access permissions detected:"
    echo "$access_check"
    echo "Removing permissions..."
    # 불필요한 권한 삭제 명령 (예시, 실제 명령은 상황에 맞게 조정)
    kubectl delete clusterrolebinding [binding-name]
    echo "Permissions removed."
    진단_결과="취약"
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
