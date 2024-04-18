#!/bin/bash

# JSON 데이터 구조 생성 및 파일에 저장
output_dir="./aws_audit_results"
mkdir -p $output_dir

jsonData=$(cat <<-END
{
    "분류": "시스템 보안",
    "코드": "1.3",
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
output_dir="./aws_iam_tags_audit"
mkdir -p $output_dir

# IAM 사용자 태그 조회 및 진단
echo "Fetching IAM Users and evaluating tags..."
aws iam list-users --output json > $output_dir/users.json

# 태그 평가 및 결과 저장
echo "[]" > $output_dir/tag_audit_results.json  # 초기 JSON 배열 파일 생성

jq -r '.Users[] | .UserName' $output_dir/users.json | while read user; do
  user_tags=$(aws iam list-user-tags --user-name "$user" --output json)
  name_tag=$(echo $user_tags | jq -r '.Tags[] | select(.Key == "Name") | .Value')
  email_tag=$(echo $user_tags | jq -r '.Tags[] | select(.Key == "Email") | .Value')
  department_tag=$(echo $user_tags | jq -r '.Tags[] | select(.Key == "Department") | .Value')

  # 결과 생성 및 저장
  jq -n --arg user "$user" --arg name_tag "$name_tag" --arg email_tag "$email_tag" --arg department_tag "$department_tag" \
  '{"user": $user, "Name": $name_tag, "Email": $email_tag, "Department": $department_tag}' >> $output_dir/tag_audit_results.json
done

echo "Audit complete. Results saved in $output_dir."
