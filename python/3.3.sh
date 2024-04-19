#!/bin/bash
import boto3
import json

# Python dictionary for JSON data
jsonData = {
    "분류": "가상 리소스 관리",
    "코드": "3.3",
    "위험도": "중요도 중",
    "진단항목": "네트워크 ACL 인/아웃바운드 트래픽 정책 관리",
    "대응방안": "네트워크 ACL은 서브넷 내부와 외부의 트래픽을 제어하는 VPC의 선택적 보안 계층입니다. 이를 적절히 설정하면 VPC 내 리소스 보호를 강화할 수 있습니다.",
    "설정방법": "AWS 콘솔 또는 CLI를 통해 네트워크 ACL 설정 접근, 규칙 추가 및 수정을 관리할 수 있습니다.",
    "현황": [],
    "진단결과": "진단 필요"
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "network_acl_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[3.3] 네트워크 ACL 인/아웃바운드 트래픽 정책 관리"
initial_message = f"{code}\n[양호]: 네트워크 ACL 설정이 적절한 경우\n[취약]: 네트워크 ACL에 불필요한 규칙이 포함된 경우\n"
log_message(initial_message, log_file_name)

bar()

# AWS SDK setup
ec2 = boto3.client('ec2')

# Fetching all Network ACLs
network_acls = ec2.describe_network_acls()
print("Available Network ACLs:")
for acl in network_acls['NetworkAcls']:
    print(f"{acl['NetworkAclId']} - Entries: {len(acl['Entries'])}")

# User input for Network ACL ID
acl_id = input("Enter Network ACL ID to check rules: ")

# Retrieve the specified Network ACL's rules
acl_details = ec2.describe_network_acls(NetworkAclIds=[acl_id])
inbound_rules = [entry for entry in acl_details['NetworkAcls'][0]['Entries'] if not entry['Egress']]
outbound_rules = [entry for entry in acl_details['NetworkAcls'][0]['Entries'] if entry['Egress']]

print("Inbound Rules:")
print(json.dumps(inbound_rules, indent=2))
print("Outbound Rules:")
print(json.dumps(outbound_rules, indent=2))

# Assessing the Network ACL rules based on user checks
inbound_check = input("Are there unnecessary allow policies in inbound rules? (yes/no): ")
outbound_check = input("Are there unnecessary allow policies in outbound rules? (yes/no): ")

if inbound_check == "yes" or outbound_check == "yes":
    result = "At least one unnecessary rule is found. Recommend revising the ACL settings."
    jsonData['진단결과'] = "취약"
else:
    result = "No unnecessary rules found. ACL settings are appropriate."
    jsonData['진단결과'] = "양호"

# Log results
log_message(result, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
