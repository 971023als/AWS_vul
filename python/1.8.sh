#!/bin/bash
import boto3
from datetime import datetime, timedelta
from botocore.exceptions import ClientError

def check_access_keys_lifecycle():
    분류 = "계정 관리"
    코드 = "1.8"
    위험도 = "중요도 상"
    진단_항목 = "Admin Console 계정 Access Key 활성화 및 사용주기 관리"
    대응방안 = ("Access Key는 AWS의 CLI 도구나 API를 사용할 때 필요한 인증수단으로, 생성 사용자에 대한 결제정보를 포함한 모든 AWS 서비스의 전체 리소스에 대한 권한을 갖습니다. "
                "유출 시 심각한 피해가 발생할 가능성이 높기에 AWS Admin Console Account에 대한 Access Key 삭제를 권장합니다. "
                "Access Key 관리 주기는 Key 수명(60일 이내), 비밀번호 수명(60일 이내), 마지막 활동(30일 이내)입니다.")
    설정방법 = ("가. AWS Admin Console Account Access Key 삭제 방법: 1) 메인 우측 상단 계정 → 내 보안 자격 증명, 2) Access Key(Access Key ID 및 비밀 Access Key) → 삭제 → 예, "
                "나. IAM User Account Access Key 삭제 방법: 1) 메인 우측 상단 계정 → 내 보안 자격 증명, 2) 사용자 → Access Key를 삭제할 계정 선택, 3) 요약 → 보안 자격 증명 탭, 4) Access Key → Access Key ID → ‘X’(삭제) 버튼, 5) Access Key 삭제 → 삭제")
    현황 = []
    진단_결과 = ""

    try:
        iam = boto3.client('iam')
        keys = iam.list_access_keys()
        now = datetime.now()
        max_age = timedelta(days=60)
        key_active = 0
        
        for key in keys['AccessKeyMetadata']:
            create_date = key['CreateDate'].replace(tzinfo=None)
            if key['Status'] == 'Active' and (now - create_date > max_age):
                key_active += 1

        if key_active == 0:
            print("All Access Keys are within the recommended lifecycle.")
            진단_결과 = "양호"
        else:
            print("There are Access Keys that exceed the recommended lifecycle.")
            진단_결과 = "취약"
    except ClientError as e:
        print(f"An error occurred: {e}")
        진단_결과 = "에러 발생"

    print(f"분류: {분류}")
    print(f"코드: {코드}")
    print(f"위험도: {위험도}")
    print(f"진단_항목: {진단_항목}")
    print(f"대응방안: {대응방안}")
    print(f"설정방법: {설정방법}")
    print(f"현황: {현황}")
    print(f"진단_결과: {진단_결과}")

if __name__ == "__main__":
    check_access_keys_lifecycle()

