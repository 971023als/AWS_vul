#!/bin/bash

# 출력 디렉터리 설정
output_dir="./aws_audit_results"

# 오래된 액세스 키 교체 함수
function replace_expired_keys {
    local user_name=$1
    local old_key_id=$2

    echo "Creating new access key for user $user_name..."
    new_key=$(aws iam create-access-key --user-name $user_name)
    new_key_id=$(echo $new_key | jq -r '.AccessKey.AccessKeyId')

    echo "Deleting old access key $old_key_id for user $user_name..."
    aws iam delete-access-key --access-key-id $old_key_id --user-name $user_name

    echo "Access key $old_key_id for user $user_name has been replaced with new key $new_key_id."
}

# 감사 결과 검토
function review_audit_results {
    echo "Reviewing detailed results saved in $output_dir..."
    cat $output_dir/*.json
}

# 감사 결과에 따라 키 교체 실행
function apply_key_rotation_policy {
    echo "Applying key rotation policy for expired access keys..."
    while IFS= read -r line; do
        user=$(echo $line | jq -r '.user')
        key_id=$(echo $line | jq -r '.key_id')
        replace_expired_keys "$user" "$key_id"
    done < "$output_dir/expired_access_keys.json"
}

# AWS Config 또는 Security Hub를 사용하여 보안 설정 강화
function enhance_security_settings {
    echo "Enhancing security settings using AWS tools..."
    # AWS Config rules를 설정하는 예제
    aws configservice put-config-rule --config-rule file://security_config_rule.json
    # AWS Security Hub 분석 활성화
    aws securityhub enable-security-hub --region your-region
}

# 스크립트 실행
echo "Starting audit action script..."
review_audit_results
apply_key_rotation_policy
enhance_security_settings
echo "Audit actions completed successfully."
