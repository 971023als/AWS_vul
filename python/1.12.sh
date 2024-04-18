#!/bin/bash

# 변수 초기화
분류="계정 관리"
코드="1.12"
위험도="중요도 중"
진단_항목="EKS 서비스 어카운트 관리"
대응방안="서비스 어카운트는 파드에 쿠버네티스 RBAC 역할을 할당할 수 있는 특수한 유형의 개체입니다. Cluster 내의 각 네임스페이스에 기본 서비스 어카운트가 자동으로 생성되며, 특정 서비스 어카운트를 참조하지 않고 네임스페이스에 파드를 배포하면, 해당 네임스페이스의 파드에 자동으로 할당됩니다. AutomountServiceAccountToken 속성을 false로 설정하여 불필요한 토큰 마운트를 방지해야 합니다."
설정방법="가. 서비스 어카운트 토큰 자동 마운트 비활성화: 1) 서비스 어카운트 토큰 자동 마운트 비활성화 여부 확인, 2) 서비스 어카운트 토큰 자동 마운트 비활성화 (false) 설정 및 확인"
현황=()
진단_결과=""

# 서비스 어카운트 토큰 자동 마운트 설정 확인
automount_status=$(kubectl get serviceaccount default -n kube-system -o json | jq '.automountServiceAccountToken')

if [ "$automount_status" == "false" ]; then
    echo "AutomountServiceAccountToken is correctly set to false."
    진단_결과="양호"
else
    echo "AutomountServiceAccountToken is set to true, which is not recommended."
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
