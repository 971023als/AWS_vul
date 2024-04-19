#!/usr/python3

import boto3
from botocore.exceptions import ClientError
import json
import os
import subprocess

# JSON 데이터 설정
jsonData = {
    "분류": "계정 관리",
    "코드": "1.5",
    "위험도": "중요도 상",
    "진단_항목": "Key Pair 접근 관리",
    "진단결과": "양호",
    "현황": [],
    "대응방안": {
        "설명": "EC2는 키(Key)를 이용한 암호화 기법을 제공합니다. 해당 기법은 퍼블릭/프라이빗 키를 통해 각각 데이터의 암호화 및 해독을 하는 방식으로, 여기에 사용되는 키를 'Key Pair'라고 하며, 해당 암호화 기법을 사용할 시 EC2의 보안성을 향상시킬 수 있습니다. EC2 인스턴스 생성 시 Key Pair 등록을 권장합니다. 또한, Amazon EC2에 사용되는 키는 '2048비트 SSH-2 RSA 키'이며, Key Pair는 리전당 최대 5천 개까지 보유할 수 있습니다.",
        "설정방법": [
            "콘솔을 통한 키 생성: 네트워크 및 보안 → Key Pair → Key Pair 생성",
            "생성된 Key Pair 파일을 쉽게 유추 및 접근할 수 없는 공간에 보관",
            "인스턴스 생성 시 생성된 Key Pair 등록",
            "인스턴트 생성 완료 시 Key Pair 정상 등록여부 확인",
            "PuTTY-Gen을 통한 키 생성: PuTTYGen.exe → Conversions → Import Key → Save 퍼블릭/프라이빗 Key",
            "생성된 Key Pair 파일을 쉽게 유추 및 접근할 수 없는 공간에 보관",
            "생성된 키 콘솔로 가져오기: 네트워크 및 보안 → Key Pair → Key Pair 가져오기",
            "생성된 키가 콘솔에 정상적으로 등록되었는지 확인"
        ]
    }
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# 로그 파일 경로 설정 및 초기화
log_file_name = "ec2_key_pair_audit.log"
with open(log_file_name, 'w') as file:
    pass

bar()

# 초기 로그 정보
initial_message = "[1.5] EC2 Key Pair 관리 진단\n[양호]: 모든 EC2 인스턴스가 적절한 Key Pair와 연결되어 있음\n[취약]: Key Pair가 없거나 잘못 등록된 인스턴스가 있음"
log_message(initial_message, log_file_name)

bar()

# 모든 EC2 인스턴스의 ID와 Key Pair 이름 가져오기
def list_instances():
    ec2 = boto3.client('ec2')
    try:
        response = ec2.describe_instances()
        instances = response['Reservations']
        for reservation in instances:
            for instance in reservation['Instances']:
                instance_id = instance['InstanceId']
                key_name = instance.get('KeyName', 'No Key Pair')
                log_message(f"Instance ID: {instance_id}, Key Pair: {key_name}", log_file_name)
    except ClientError as e:
        log_message(f"Failed to retrieve instances: {e}", log_file_name)

def main():
    list_instances()

if __name__ == "__main__":
    main()

bar()

# 결과 출력
with open(log_file_name, 'r') as file:
    print(file.read())
