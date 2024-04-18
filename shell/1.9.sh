#!/bin/bash

# 변수 초기화
분류="계정 관리"
코드="1.9"
위험도="중요도 중"
진단_항목="MFA (Multi-Factor Authentication) 설정"
대응방안="AWS Multi-Factor Authentication(MFA)은 사용자 이름과 암호 외에 보안을 한층 더 강화할 수 있는 방법으로, MFA를 활성화하면 사용자가 AWS 웹 사이트에 로그인할 때 사용자 이름과 암호뿐만 아니라 AWS MFA 디바이스의 인증 응답을 입력하라는 메시지가 표시됩니다. 이러한 다중 요소를 통해 AWS 계정 설정 및 리소스에 대한 보안을 높일 수 있습니다."
설정방법="MFA 인증 설정 및 확인: 1) IAM 메인 → 우측상단 계정 → 내 보안 자격 증명 → 멀티 팩터 인증 → MFA 활성화, 2) MFA 디바이스 관리 → 가상 MFA 디바이스 선택 → 계속, 3) Google OTP 어플 설치 → ‘+’ 버튼 → 바코드 스캔 → 나타난 QR코드를 어플에서 스캔, 4) 스캔 후 나타난 숫자 MFA 코드 1 입력 → 재 생성된 숫자 MFA 코드 2 입력, 5) 2개의 연속된 MFA 코드 입력, 6) MFA 설정 완료, 7) 로그인 시 비밀번호 입력, 8) Google OTP 번호 입력 후 로그인 시도, 9) 로그인 확인"
현황=()
진단_결과=""

# MFA 상태 확인
mfa_status=$(aws iam list-mfa-devices --user-name <IAM_USER_NAME> --query 'MFADevices' --output json)
if [ -z "$mfa_status" ]; then
    echo "No MFA devices configured for the user."
    진단_결과="취약"
else
    echo "MFA is enabled for the user."
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
