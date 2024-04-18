#!/bin/bash

# 변수 초기화
분류="계정 관리"
코드="1.10"
위험도="중요도 중"
진단_항목="AWS 계정 패스워드 정책 관리"
대응방안="AWS Admin Console Account 계정 및 IAM 사용자 계정의 암호 설정 시 유추하기 쉬운 암호를 설정하는 경우 비 인가된 사용자가 해당 계정을 획득하여 접근 가능성이 존재합니다. 패스워드는 여러 문자 종류를 조합하여 구성하고, 연속적인 문자 사용을 금지하며, 패스워드 재사용을 제한합니다."
설정방법="IAM 계정 비밀번호 정책 확인: 1) 계정 설정 확인, 2) 암호 정책 설정 확인, 3) IAM 사용자 계정 암호 만료 및 재사용 제한 설정"
현황=()
진단_결과=""

# IAM 계정 비밀번호 정책 검사
password_policy=$(aws iam get-account-password-policy --query 'PasswordPolicy' --output json)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve password policy."
    진단_결과="취약"
    exit 1
fi

# 패스워드 정책 준수 여부 검사
minimum_length=$(echo $password_policy | jq '.MinimumPasswordLength')
require_symbols=$(echo $password_policy | jq '.RequireSymbols')
require_numbers=$(echo $password_policy | jq '.RequireNumbers')
password_reuse_prevention=$(echo $password_policy | jq '.PasswordReusePrevention')
max_age=$(echo $password_policy | jq '.MaxPasswordAge')

if [ $minimum_length -ge 8 ] && [ $require_symbols == "true" ] && [ $require_numbers == "true" ] && [ $password_reuse_prevention -ge 1 ] && [ $max_age -le 90 ]; then
    echo "Password policy meets the complexity requirements."
    진단_결과="양호"
else
    echo "Password policy does not meet the complexity requirements."
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
