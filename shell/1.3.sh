#!/bin/bash

# 시스템 보안 진단 결과 파일 생성 및 저장
security_output_dir="./aws_audit_results"
mkdir -p $security_output_dir

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
echo "$jsonData" > $security_output_dir/security_audit.json

# IAM 사용자 태그 조회 및 진단
tags_output_dir="./aws_iam_tags_audit"
mkdir -p $tags_output_dir
echo "Fetching IAM Users and evaluating tags..."
aws iam list-users --output json > $tags_output_dir/users.json

temp_file=$(mktemp)  # 임시 파일 생성
jq -r '.Users[] | .UserName' $tags_output_dir/users.json | while read user; do
  user_tags=$(aws iam list-user-tags --user-name "$user" --output json)
  name_tag=$(echo $user_tags | jq -r '.Tags[] | select(.Key == "Name") | .Value')
  email_tag=$(echo $user_tags | jq -r '.Tags[] | select(.Key == "Email") | .Value')
  department_tag=$(echo $user_tags | jq -r '.Tags[] | select(.Key == "Department") | .Value')

  jq -n --arg user "$user" --arg name_tag "$name_tag" --arg email_tag "$email_tag" --arg department_tag "$department_tag" \
  '{"user": $user, "Name": $name_tag, "Email": $email_tag, "Department": $department_tag}' >> $temp_file
done
jq -s '.' $temp_file > $tags_output_dir/tag_audit_results.json
rm $temp_file  # 임시 파일 삭제

echo "Audit complete. Results saved in $tags_output_dir and $security_output_dir."
