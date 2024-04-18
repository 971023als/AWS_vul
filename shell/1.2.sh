#!/bin/bash

# JSON 데이터 구조 생성 및 파일에 저장
output_dir="./aws_audit_results"
mkdir -p $output_dir

jsonData=$(cat <<-END
{
    "분류": "시스템 보안",
    "코드": "1.2",
    "위험도": "중간",
    "진단항목": "Telnet 서비스 보안 인증 방식 사용 여부",
    "진단결과": "변수: 양호",   # 이 부분은 스크립트 실행 중에 결정되어야 할 수 있음
    "현황": "Placeholder for Get-TelnetStatus function",
    "대응방안": "Telnet 서비스를 비활성화하거나 보안 인증 방식을 사용해야 합니다."
}
END
)

echo "$jsonData" > $output_dir/security_audit.json

# 디렉터리 설정
output_dir="./aws_iam_audit"
mkdir -p $output_dir

# IAM 사용자 목록 조회
echo "IAM 사용자 목록을 조회합니다..."
aws iam list-users --output json > $output_dir/users.json

# IAM 사용자 계정 단일화 진단 및 결과 저장
echo "IAM 사용자 계정 단일화를 진단하고 결과를 저장합니다..."
echo "[]" > $output_dir/account_singularity_audit.json  # 초기 JSON 배열 파일 생성

temp_file=$(mktemp)  # 임시 파일 생성

# 사용자별로 Access Key 개수 확인
jq -r '.Users[] | .UserName' $output_dir/users.json | while read user; do
  key_count=$(aws iam list-access-keys --user-name "$user" --query 'AccessKeyMetadata | length' --output text)
  # 각 사용자별로 Access Key 개수 저장
  jq -n --arg user "$user" --argjson key_count "$key_count" '{"user": $user, "access_key_count": $key_count}' >> $temp_file
done

# 임시 파일의 내용을 정확한 JSON 배열로 변환하여 저장
jq -s '.' $temp_file > $output_dir/account_singularity_audit.json
rm $temp_file  # 임시 파일 삭제

echo "감사가 완료되었습니다. 결과는 $output_dir에 저장되었습니다."
