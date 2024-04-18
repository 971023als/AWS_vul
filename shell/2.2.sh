#!/bin/bash

# 변수 초기화
분류="권한 관리"
코드="2.2"
위험도="중요도 상"
진단_항목="네트워크 서비스 정책 관리"
대응방안="AWS 네트워크 서비스(VPC, Route 53, Direct Connect 등)는 IAM 자격 증명에 권한 정책을 연결하여 관리되어야 합니다. 적절한 권한을 통한 체계적인 관리는 보안과 효율성을 보장합니다."
설정방법="네트워크 서비스 별 IAM 관리자/운영자 권한 그룹 생성: 1) IAM 내 그룹 탭 접근, 2) 새로운 그룹 생성, 3) 필요한 권한 정책 연결, 4) 그룹 생성 확인"
현황=()
진단_결과=""

# IAM 정책 확인 및 그룹 관리
echo "Checking IAM policies and managing groups for VPC, Route 53, and Direct Connect..."
policy_attached=$(aws iam list-attached-group-policies --group-name NetworkAdmins --query 'AttachedPolicies[?PolicyName==`AmazonVPCFullAccess` || PolicyName==`AmazonRoute53FullAccess` || PolicyName==`AWSDirectConnectFullAccess`].PolicyName' --output text)

if [ -z "$policy_attached" ]; then
    echo "Required policies are not fully attached to the NetworkAdmins group."
    진단_결과="취약"
else
    echo "Required policies are correctly attached to the NetworkAdmins group:"
    echo "$policy_attached"
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
