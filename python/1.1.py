#!usr/bin/python3

import boto3
import json
from datetime import datetime, timezone

# AWS 서비스 클라이언트 설정
iam = boto3.client('iam')

# 결과를 저장할 디렉터리
output_dir = "./aws_audit_results"

# IAM 사용자, 그룹, 역할 리스트업
def list_iam_details():
    users = iam.list_users()
    groups = iam.list_groups()
    roles = iam.list_roles()
    
    # 결과를 JSON 파일로 저장
    with open(f"{output_dir}/users.json", 'w') as f:
        json.dump(users, f)
    with open(f"{output_dir}/groups.json", 'w') as f:
        json.dump(groups, f)
    with open(f"{output_dir}/roles.json", 'w') as f:
        json.dump(roles, f)

# 관리자 권한을 가진 계정 확인
def check_admin_accounts():
    admin_users = iam.list_users(
        Query='Users[?AttachedManagedPolicies[?PolicyName==`AdministratorAccess`]].UserName'
    )
    with open(f"{output_dir}/admin_users.json", 'w') as f:
        json.dump(admin_users, f)

# 불필요한 계정 식별
def identify_unnecessary_accounts():
    unnecessary_users = iam.list_users(
        Query='Users[?contains(UserName, `test`) || contains(UserName, `temp`)].UserName'
    )
    with open(f"{output_dir}/unnecessary_users.json", 'w') as f:
        json.dump(unnecessary_users, f)

# Access Key 유효기간 확인
def check_expired_access_keys():
    users = iam.list_users()['Users']
    expired_keys = []

    for user in users:
        username = user['UserName']
        access_keys = iam.list_access_keys(UserName=username)['AccessKeyMetadata']
        
        for key in access_keys:
            if key['Status'] == 'Active':
                create_date = key['CreateDate'].replace(tzinfo=timezone.utc)
                age_days = (datetime.now(timezone.utc) - create_date).days
                if age_days > 180:
                    expired_keys.append({'user': username, 'key_id': key['AccessKeyId'], 'age_days': age_days})
    
    with open(f"{output_dir}/expired_access_keys.json", 'w') as f:
        json.dump(expired_keys, f)

if __name__ == "__main__":
    list_iam_details()
    check_admin_accounts()
    identify_unnecessary_accounts()
    check_expired_access_keys()
    print("Audit complete. Results saved in", output_dir)
