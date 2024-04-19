#!/bin/bash
import boto3
import json

# Python dictionary for JSON data
jsonData = {
    "분류": "권한 관리",
    "코드": "2.3",
    "위험도": "중요도 상",
    "진단항목": "기타 서비스 정책 관리",
    "대응방안": "AWS 기타 서비스(CloudWatch, CloudTrail, KMS 등)의 리소스 생성 또는 액세스 권한은 적절한 권한 정책에 따라 관리되어야 합니다.",
    "설정방법": "IAM 관리자/운영자 그룹 생성 및 사용자 추가: IAM 사용자 그룹 탭에서 새 그룹 생성, 필요한 권한 정책 연결, 사용자 추가.",
    "현황": [],
    "진단결과": "(변수: 양호, 취약)"
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "misc_service_policy_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[2.3] 기타 서비스 정책 관리"
initial_message = f"{code}\n[양호]: 필요한 정책이 그룹에 모두 연결되어 있는 경우\n[취약]: 필요한 정책이 그룹에 연결되어 있지 않은 경우\n"
log_message(initial_message, log_file_name)

bar()

# Check IAM policies using boto3
iam = boto3.client('iam')
group_name = 'MiscAdmins'  # This is the group name
try:
    response = iam.list_attached_group_policies(GroupName=group_name)
    attached_policies = [policy['PolicyName'] for policy in response['AttachedPolicies']]
    required_policies = ['CloudWatchFullAccess', 'AWSCloudTrailFullAccess', 'AWSKMSFullAccess']
    missing_policies = [policy for policy in required_policies if policy not in attached_policies]

    if not missing_policies:
        result = f"Required policies are correctly attached to the {group_name} group:\n" + ', '.join(attached_policies) + "\n"
        jsonData['진단결과'] = "양호"
    else:
        result = f"Required policies are not fully attached to the {group_name} group. Missing: " + ', '.join(missing_policies) + "\n"
        jsonData['진단결과'] = "취약"

except Exception as e:
    result = f"Failed to retrieve IAM policies for group {group_name}: {str(e)}\n"
    jsonData['진단결과'] = "에러 발생"

log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
