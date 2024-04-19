#!usr/bin/python3

import boto3
import json
import os
import subprocess
from datetime import datetime, timezone

def check_key_pairs_in_bucket(bucket_name):
    s3 = boto3.client('s3')
    try:
        response = s3.list_objects_v2(Bucket=bucket_name)
        key_pairs = [item for item in response.get('Contents', []) if item['Key'].endswith('.pem')]
        if not key_pairs:
            print(f"No Key Pair files found in the bucket {bucket_name}.")
            return "취약"
        else:
            print("Key Pair files found in the bucket {}: ".format(bucket_name))
            for key_pair in key_pairs:
                print(key_pair['Key'])
            return "양호"
    except ClientError as e:
        print(f"Error accessing bucket {bucket_name}: {e}")
        return "에러 발생"

def main():
    분류 = "계정 관리"
    코드 = "1.6"
    위험도 = "중요도 상"
    진단_항목 = "Key Pair 보관 관리"
    대응방안 = ("EC2는 키(Key)를 이용한 암호화 기법을 제공합니다. 해당 기법은 퍼블릭/프라이빗 키를 통해 각각 데이터의 암호화 및 해독을 하는 방식으로, 여기에 사용되는 키를 'Key Pair'라고 하며, 해당 암호화 기법을 사용할 시 "
                "EC2의 보안성을 향상시킬 수 있습니다. EC2 인스턴스 생성 시 Key Pair 등록을 권장합니다. 또한, Amazon EC2에 사용되는 키는 '2048비트 SSH-2 RSA 키'이며, Key Pair는 리전당 최대 5천 개까지 보유할 수 있습니다. "
                "Key Pair는 타 사용자가 확인이 가능한 공개된 위치에 보관하게 될 경우 EC2 Instance에 무단으로 접근이 가능해지므로 비인가자가 쉽게 유추 및 접근이 불가능한 장소에 보관해야 합니다.")
    설정방법 = "S3 버킷 내 Key Pair 관리하기: 1) 버킷 접근, 2) 버킷 생성하기, 3) 생성된 버킷 확인, 4) S3 버킷 내 KeyPair 업로드, 5) 업로드된 KeyPair 확인, 6) Key Pair 보관 확인(프라이빗 S3 버킷)"
    현황 = []

    bucket_name = input("Enter the S3 bucket name where Key Pairs are stored: ")
    진단_결과 = check_key_pairs_in_bucket(bucket_name)

    print(f"분류: {분류}")
    print(f"코드: {코드}")
    print(f"위험도: {위험도}")
    print(f"진단_항목: {진단_항목}")
    print(f"대응방안: {대응방안}")
    print(f"설정방법: {설정방법}")
    print(f"현황: {현황}")
    print(f"진단_결과: {진단_결과}")

if __name__ == "__main__":
    main()
