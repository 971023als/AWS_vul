#!/usr/python3

import boto3
from botocore.exceptions import ClientError
import json
import os
import subprocess

# JSON 데이터 설정
jsonData = {
    "분류": "계정 관리",
    "코드": "1.6",
    "위험도": "중요도 상",
    "진단_항목": "Key Pair 보관 관리",
    "대응방안": "EC2는 키(Key)를 이용한 암호화 기법을 제공합니다. 해당 기법은 퍼블릭/프라이빗 키를 통해 각각 데이터의 암호화 및 해독을 하는 방식으로, 여기에 사용되는 키를 'Key Pair'라고 하며, 해당 암호화 기법을 사용할 시 EC2의 보안성을 향상시킬 수 있습니다. EC2 인스턴스 생성 시 Key Pair 등록을 권장합니다. 또한, Amazon EC2에 사용되는 키는 '2048비트 SSH-2 RSA 키'이며, Key Pair는 리전당 최대 5천 개까지 보유할 수 있습니다. Key Pair는 타 사용자가 확인이 가능한 공개된 위치에 보관하게 될 경우 EC2 Instance에 무단으로 접근이 가능해지므로 비인가자가 쉽게 유추 및 접근이 불가능한 장소에 보관해야 합니다.",
    "설정방법": "S3 버킷 내 Key Pair 관리하기: 1) 버킷 접근, 2) 버킷 생성하기, 3) 생성된 버킷 확인, 4) S3 버킷 내 KeyPair 업로드, 5) 업로드된 KeyPair 확인, 6) Key Pair 보관 확인(프라이빗 S3 버킷)",
    "진단결과": "양호"
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# 로그 파일 경로 설정 및 초기화
log_file_name = "ec2_key_pair_s3_audit.log"
with open(log_file_name, 'w') as file:
    pass

bar()

# 로그 시작 정보
initial_message = "[1.6] EC2 Key Pair S3 보관 관리 진단\n[양호]: 모든 Key Pair 파일이 안전하게 S3 버킷에 저장되어 있음\n[취약]: Key Pair 파일이 S3 버킷에 없거나 보안 설정이 적절하지 않은 경우"
log_message(initial_message, log_file_name)

bar()

# S3 버킷 내 Key Pair 파일 확인
def check_key_pairs_in_bucket(bucket_name):
    s3 = boto3.client('s3')
    try:
        response = s3.list_objects_v2(Bucket=bucket_name)
        key_pairs = [item for item in response.get('Contents', []) if item['Key'].endswith('.pem')]
        if not key_pairs:
            result = "취약: 버킷 {}에 Key Pair 파일이 없습니다.\n".format(bucket_name)
        else:
            result = "양호: 버킷 {}에 Key Pair 파일이 확인되었습니다. 파일 목록:\n".format(bucket_name)
            for key_pair in key_pairs:
                result += "{}\n".format(key_pair['Key'])
        log_message(result, log_file_name)
        return result
    except ClientError as e:
        error_message = "에러 발생: 버킷 {} 접근 중 오류가 발생했습니다. {}\n".format(bucket_name, e)
        log_message(error_message, log_file_name)
        return error_message

def main():
    bucket_name = input("S3 버킷 이름을 입력하세요 (Key Pairs 저장소): ")
    진단결과 = check_key_pairs_in_bucket(bucket_name)

    # 진단 결과 및 설정
