#!usr/bin/python3

import boto3
import json
import os

# 디렉토리 설정
output_dir = "./aws_iam_audit"
os.makedirs(output_dir, exist_ok=True)

# AWS IAM 클라이언트 초기화
iam = boto3.client('iam')

# IAM 사용자 목록 조회
print("IAM 사용자 목록을 조회합니다...")
users = iam.list_users()

# 사용자 정보를 파일에 저장
users_file_path = os.path.join(output_dir, 'users.json')
with open(users_file_path, 'w') as f:
    json.dump(users['Users'], f)

# 각 사용자별 Access Key 개수 진단 및 결과 저장
results = []
for user in users['Users']:
    user_name = user['UserName']
    keys = iam.list_access_keys(UserName=user_name)
    key_count = len(keys['AccessKeyMetadata'])
    results.append({
        'user': user_name,
        'access_key_count': key_count
    })

# 결과를 JSON 배열로 저장
results_file_path = os.path.join(output_dir, 'account_singularity_audit.json')
with open(results_file_path, 'w') as f:
    json.dump(results, f)

print(f"감사가 완료되었습니다. 결과는 {output_dir}에 저장되었습니다.")

