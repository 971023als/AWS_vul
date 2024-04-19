#!usr/bin/python3

import boto3
import json
import os
import subprocess
from datetime import datetime, timezone

# 모든 인스턴스의 ID와 Key Pair 이름 가져오기
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,KeyName]' --output text


{
  "분류": "계정 관리",
  "코드": "1.5",
  "위험도": "중요도 상",
  "진단_항목": "Key Pair 접근 관리",
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
  },
  "현황": [],
  "진단_결과": "양호"
}
import boto3
from botocore.exceptions import ClientError

def list_instances():
    ec2 = boto3.client('ec2')
    try:
        response = ec2.describe_instances()
        instances = response['Reservations']
        for reservation in instances:
            for instance in reservation['Instances']:
                instance_id = instance['InstanceId']
                key_name = instance.get('KeyName', 'No Key Pair')
                print(f"Instance ID: {instance_id}, Key Pair: {key_name}")
    except ClientError as e:
        print(f"Failed to retrieve instances: {e}")

def check_key_pair(key_pair_name):
    ec2 = boto3.client('ec2')
    try:
        response = ec2.describe_key_pairs(KeyNames=[key_pair_name])
        if response['KeyPairs']:
            print(f"Key Pair '{key_pair_name}' is properly registered.")
        else:
            print(f"Key Pair '{key_pair_name}' is not registered or does not exist.")
    except ClientError as e:
        if e.response['Error']['Code'] == 'InvalidKeyPair.NotFound':
            print(f"Key Pair '{key_pair_name}' is not registered or does not exist.")
        else:
            print(f"Failed to retrieve Key Pair information: {e}")

def main():
    list_instances()
    key_pair_name = input("Enter Key Pair name to check: ")
    check_key_pair(key_pair_name)

if __name__ == "__main__":
    main()
