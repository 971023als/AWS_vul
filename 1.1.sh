#!/bin/bash

# 디렉터리 설정
output_dir="./aws_audit_results"
mkdir -p $output_dir

# IAM 사용자, 그룹, 역할 리스트업
echo "Saving list of IAM Users, Groups, and Roles..."
aws iam list-users --output json > $output_dir/users.json
aws iam list-groups --output json > $output_dir/groups.json
aws iam list-roles --output json > $output_dir/roles.json

# 관리자 권한을 보유한 계정 확인
echo "Checking for accounts with administrative permissions and saving..."
aws iam list-users --query 'Users[?AttachedManagedPolicies[?PolicyName==`AdministratorAccess`]].UserName' --output json > $output_dir/admin_users.json

# 불필요한 계정 식별
echo "Identifying unnecessary accounts (e.g., test accounts) and saving..."
aws iam list-users --query 'Users[?contains(UserName, `test`) || contains(UserName, `temp`)].UserName' --output json > $output_dir/unnecessary_users.json

# Access Key 유효기간 확인 및 저장
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
