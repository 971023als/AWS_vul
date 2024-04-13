#!/bin/bash

# 변수 초기화
분류="권한 관리"
코드="1.7"
위험도="중요도 중"
진단_항목="Admin Console 관리자 정책 관리"
대응방안="AWS Cloud 사용을 위해 처음 발급한 계정은 IAM 사용자 계정과 달리 모든 서비스에 접근할 수 있는 최고 관리자 계정입니다. Cloud 서비스 특성 상 인터넷 연결이 가능한 망에서 계정정보를 입력하여 WEB Console에 접근하게 됩니다. 이는 최고 권한을 보유하고 있는 관리자 계정이 아닌 권한이 조정된 IAM 사용자 계정을 기본으로 사용해야 보다 안전한 접근이 이뤄질 수 있습니다."
설정방법="IAM 사용자 계정 생성: 1) 사용자 추가 버튼 클릭, 2) 사용자 추가 (기본설정 - 이름, 액세스 유형 선택), 3) 사용자 추가 (기존 정책 직접 연결하기), 4) 사용자 추가 (태그 계정 정보 입력), 5) 사용자 추가 (검토하기), 6) IAM 사용자에 추가된 신규 사용자 확인, 7) 사용자 권한 확인"
현황=()
진단_결과=""

echo "IAM 사용자 계정 생성 절차를 시작합니다."

# IAM 사용자 계정 생성 프로세스
# 사용자 입력을 통한 계정 생성 시뮬레이션 (실제 AWS CLI 명령은 아님)
read -p "Enter new IAM user name: " user_name
echo "Creating IAM user: $user_name"
echo "$user_name user created successfully."

# 사용자 권한 설정 시뮬레이션
read -p "Attach policy to the user (e.g., AdministratorAccess, ReadOnlyAccess): " policy_name
echo "Attaching policy $policy_name to $user_name"
echo "Policy $policy_name attached successfully."

# 진단 결과 설정
read -p "Is the Admin Console account used for service purposes? (yes/no): " service_use

if [ "$service_use" = "yes" ]; then
    진단_결과="취약"
else
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
