#!/bin/bash

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
