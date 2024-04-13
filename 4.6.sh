#!/bin/bash

{
  "분류": "운영 관리",
  "코드": "4.6",
  "위험도": "중요도 중",
  "진단_항목": "CloudWatch 암호화 설정",
  "대응방안": {
    "설명": "Amazon CloudWatch는 Key Management Service(KMS)와 사용자 지정 마스터 키(CMK)를 통해 관리되는 키를 사용하여 로그를 암호화할 수 있습니다. 로그 그룹을 생성할 때나 기존 로그 그룹에 CMK를 연결하여 로그 데이터를 암호화할 수 있으며, 이 데이터는 보존 기간 동안 암호화된 상태로 유지됩니다.",
    "설정방법": [
      "KMS Key ARN 확인 방법: 서비스 > KMS > 고객 관리형 키 접근 > 고객 관리형 키 > ARN 값 확인",
      "CloudWatch 로그 그룹 생성 및 KMS key ARN 설정: 서비스 > CloudWatch 로그 그룹 생성 > 로그 그룹 생성 시 사전 확인된 KMS key ARN 값 설정 필요 > 로그 그룹 생성 완료"
    ]
  },
  "현황": [],
  "진단_결과": "양호"
}



# Check for aws CLI tools
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install AWS CLI to run this script."
    exit 1
fi

# Retrieve KMS keys to check the existence of customer managed keys
echo "Retrieving KMS keys..."
kms_keys_output=$(aws kms list-keys --query 'Keys[*].KeyId' --output text)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve KMS keys. Please check your AWS CLI setup and permissions."
    exit 1
fi

if [ -z "$kms_keys_output" ]; then
    echo "No KMS keys found."
    exit 0
fi

echo "KMS Keys found:"
echo "$kms_keys_output"

# List all CloudWatch log groups and check if they are encrypted with KMS keys
echo "Retrieving CloudWatch log groups and checking encryption status..."
cloudwatch_log_groups=$(aws logs describe-log-groups --query 'logGroups[*].{logGroupName:logGroupName, kmsKeyId:kmsKeyId}' --output json)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve CloudWatch log groups. Please check your AWS CLI setup and permissions."
    exit 1
fi

echo "CloudWatch Log Groups and KMS Encryption Status:"
echo "$cloudwatch_log_groups"

# Determine the compliance status
encryption_compliance="취약"  # Default to vulnerable unless found otherwise
for log_group in $(echo "$cloudwatch_log_groups" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${log_group} | base64 --decode | jq -r ${1}
    }
    log_group_name=$(_jq '.logGroupName')
    kms_key_id=$(_jq '.kmsKeyId')
    if [[ -n "$kms_key_id" ]]; then
        echo "Log group '$log_group_name' is encrypted with KMS key ID: $kms_key_id."
        encryption_compliance="양호"
    else
        echo "Log group '$log_group_name' is not using KMS encryption."
        encryption_compliance="취약"
    fi
done

# Update JSON diagnostic result
echo "Updating diagnosis result..."
jq --arg status "$encryption_compliance" '.진단_결과 = $status' diagnosis.json | sponge diagnosis.json
echo "Diagnosis updated with result: $encryption_compliance"
