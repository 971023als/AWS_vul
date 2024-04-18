#!/bin/bash

# JSON 데이터 구조 생성 및 파일에 저장
output_dir="./aws_audit_results"
mkdir -p $output_dir

jsonData='{
    "분류": "시스템 보안",
    "코드": "1.1",
    "위험도": "중간",
    "진단항목": "Telnet 서비스 보안 인증 방식 사용 여부",
    "진단결과": "변수: 양호",   # 이 부분은 스크립트 실행 중에 결정되어야 할 수 있음
    "현황": "Placeholder for Get-TelnetStatus function",
    "대응방안": "Telnet 서비스를 비활성화하거나 보안 인증 방식을 사용해야 합니다."
}'

echo "$jsonData" > $output_dir/security_audit.json

# 기존 감사 스크립트 실행
echo "Saving list of IAM Users, Groups, and Roles..."
aws iam list-users --output json > $output_dir/users.json
aws iam list-groups --output json > $output_dir/groups.json
aws iam list-roles --output json > $output_dir/roles.json

echo "Checking for accounts with administrative permissions and saving..."
aws iam list-users --query 'Users[?AttachedManagedPolicies[?PolicyName==`AdministratorAccess`]].UserName' --output json > $output_dir/admin_users.json

echo "Identifying unnecessary accounts (e.g., test accounts) and saving..."
aws iam list-users --query 'Users[?contains(UserName, `test`) || contains(UserName, `temp`)].UserName' --output json > $output_dir/unnecessary_users.json

echo "Checking for expired Access Keys and saving..."
current_date=$(date +%s)
echo "[]" > $output_dir/expired_access_keys.json  # 초기 JSON 배열 파일 생성

aws iam list-users --query 'Users[*].UserName' --output text | while read user; do
  aws iam list-access-keys --user-name "$user" --query 'AccessKeyMetadata[?Status==`Active`].[AccessKeyId,CreateDate]' --output json | jq -c '.[] | select(. != null)' | while read key_data; do
    key_id=$(echo $key_data | jq -r '.[0]')
    create_date=$(echo $key_data | jq -r '.[1]')
    key_date=$(date -d "$create_date" +%s)
    let age_days=($current_date-$key_date)/86400
    if [ $age_days -gt 180 ]; then
      echo "User $user has an active Access Key $key_id older than 180 days."
      jq -c --arg user "$user" --arg key_id "$key_id" --arg age_days "$age_days" '. += [{"user": $user, "key_id": $key_id, "age_days": $age_days}]' $output_dir/expired_access_keys.json > $output_dir/temp.json && mv $output_dir/temp.json $output_dir/expired_access_keys.json
    fi
  done
done

echo "Audit complete. Results saved in $output_dir."
