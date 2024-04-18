#bin/usr/python3

import boto3
import json

# AWS IAM 클라이언트 초기화
iam = boto3.client('iam')

def replace_expired_keys():
    # 모든 사용자의 액세스 키 목록을 가져옴
    users = iam.list_users()
    for user in users['Users']:
        username = user['UserName']
        keys = iam.list_access_keys(UserName=username)

        # 만료된 액세스 키 찾기
        for key in keys['AccessKeyMetadata']:
            if key['Status'] == 'Active':
                age_days = (datetime.now(timezone.utc) - key['CreateDate']).days
                if age_days > 90:  # 90일이 넘은 키를 만료된 것으로 간주
                    print(f"Replacing expired key {key['AccessKeyId']} for user {username}")
                    # 새 액세스 키 생성
                    new_key = iam.create_access_key(UserName=username)
                    print(f"New key {new_key['AccessKey']['AccessKeyId']} created for user {username}")

                    # 오래된 액세스 키 삭제
                    iam.delete_access_key(UserName=username, AccessKeyId=key['AccessKeyId'])
                    print(f"Old key {key['AccessKeyId']} deleted for user {username}")

def main():
    replace_expired_keys()
    print("Expired access keys have been replaced successfully.")

if __name__ == "__main__":
    main()
