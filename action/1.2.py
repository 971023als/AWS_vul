#/usr/bin/python3

import boto3

# AWS IAM 클라이언트 초기화
iam = boto3.client('iam')

def deactivate_or_delete_access_keys(user_name, delete=False):
    """
    주어진 사용자의 모든 Access Key를 비활성화하거나 삭제합니다.
    
    :param user_name: 사용자 이름
    :param delete: True이면 Key를 삭제, False이면 비활성화
    """
    keys = iam.list_access_keys(UserName=user_name)['AccessKeyMetadata']
    for key in keys:
        access_key_id = key['AccessKeyId']
        if delete:
            # Access Key 삭제
            iam.delete_access_key(UserName=user_name, AccessKeyId=access_key_id)
            print(f"Deleted Access Key {access_key_id} for user {user_name}")
        else:
            # Access Key 비활성화
            iam.update_access_key(UserName=user_name, AccessKeyId=access_key_id, Status='Inactive')
            print(f"Deactivated Access Key {access_key_id} for user {user_name}")

# 사용자 이름 목록 (수정 필요)
users = ["Alice", "Bob", "Charlie"]

# 각 사용자의 Access Key 조치 수행
for user in users:
    deactivate_or_delete_access_keys(user_name=user, delete=False)  # True로 변경하면 삭제
