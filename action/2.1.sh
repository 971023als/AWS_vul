#!/bin/bash

# 변수 초기화
분류="권한 관리"
코드="2.1"
위험도="중요도 상"
진단_항목="인스턴스 서비스 정책 관리"
대응방안="AWS 인스턴스 서비스(EC2, RDS, S3 등)의 리소스 생성 또는 액세스 권한은 IAM 자격 증명(사용자, 그룹, 역할)에 연결된 권한 정책에 따라 결정됩니다. 적절한 권한을 통한 서비스 관리가 이루어져야 하며, 서비스 별 관리형 정책을 철저히 설정해야 합니다."
설정방법="가. 인스턴스 IAM 관리자/운영자 권한 그룹 생성: 1) IAM 내 그룹 탭 접근, 2) 새로운 그룹 생성, 3) 필요한 권한 정책 연결, 4) 그룹 생성 확인"
현황=()
진단_결과=""

# IAM 정책 검사
echo "Checking IAM policies for EC2, RDS, S3, and other services..."
policy_check=$(aws iam list-policies --scope Local --query 'Policies[?PolicyName==`AmazonEC2FullAccess` || PolicyName==`AmazonRDSFullAccess` || PolicyName==`AmazonS3FullAccess`].PolicyName' --output text)

if [ -z "$policy_check" ]; then
    echo "Required policies are not fully attached."
    진단_결과="취약"
else
    echo "Required policies are correctly attached:"
    echo "$policy_check"
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
