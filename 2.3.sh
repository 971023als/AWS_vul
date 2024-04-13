#!/bin/bash

# 변수 초기화
분류="권한 관리"
코드="2.3"
위험도="중요도 상"
진단_항목="기타 서비스 정책 관리"
대응방안="AWS 기타 서비스(CloudWatch, CloudTrail, KMS 등)의 리소스 생성 또는 액세스 권한은 적절한 권한 정책에 따라 관리되어야 합니다."
설정방법="IAM 관리자/운영자 그룹 생성 및 사용자 추가: IAM 사용자 그룹 탭에서 새 그룹 생성, 필요한 권한 정책 연결, 사용자 추가."
현황=()
진단_결과=""

echo "Starting the policy check and group management for CloudWatch, CloudTrail, KMS..."

# IAM 정책 확인
policy_check=$(aws iam list-attached-group-policies --group-name MiscAdmins --query 'AttachedPolicies[?PolicyName==`CloudWatchFullAccess` || PolicyName==`AWSCloudTrailFullAccess` || PolicyName==`AWSKMSFullAccess`].PolicyName' --output text)

if [ -z "$policy_check" ]; then
    echo "Required policies are not fully attached to the MiscAdmins group."
    진단_결과="취약"
else
    echo "Required policies are correctly attached to the MiscAdmins group:"
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
