#!/bin/bash

# 디렉터리 설정
output_dir="./aws_iam_audit"
mkdir -p $output_dir

# IAM 사용자 목록 조회
echo "Fetching IAM Users..."
aws iam list-users --output json > $output_dir/users.json

# IAM 사용자 계정 단일화 진단 및 결과 저장
echo "Evaluating IAM user account singularity and saving results..."
echo "[]" > $output_dir/account_singularity_audit.json  # 초기 JSON 배열 파일 생성

# 사용자별로 Access Key 개수 확인
jq -r '.Users[] | .UserName' $output_dir/users.json | while read user; do
  key_count=$(aws iam list-access-keys --user-name "$user" --query 'AccessKeyMetadata | length' --output text)
  # 각 사용자별로 Access Key 개수 저장
  jq -n --arg user "$user" --argjson key_count "$key_count" '{"user": $user, "access_key_count": $key_count}' >> $output_dir/account_singularity_audit.json
done

echo "Audit complete. Results saved in $output_dir."
