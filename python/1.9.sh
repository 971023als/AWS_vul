#!/bin/bash
import boto3
from botocore.exceptions import ClientError

def check_mfa_status(user_name):
    분류 = "계정 관리"
    코드 = "1.9"
    위험도 = "중요도 중"
    진단_항목 = "MFA (Multi-Factor Authentication) 설정"
    대응방안 = ("AWS Multi-Factor Authentication(MFA)은 사용자 이름과 암호 외에 보안을 한층 더 강화할 수 있는 방법으로, MFA를 활성화하면 사용자가 AWS 웹 사이트에 로그인할 때 사용자 이름과 암호뿐만 아니라 "
                "AWS MFA 디바이스의 인증 응답을 입력하라는 메시지가 표시됩니다. 이러한 다중 요소를 통해 AWS 계정 설정 및 리소스에 대한 보안을 높일 수 있습니다.")
    설정방법 = ("MFA 인증 설정 및 확인: 1) IAM 메인 → 우측상단 계정 → 내 보안 자격 증명 → 멀티 팩터 인증 → MFA 활성화, 2) MFA 디바이스 관리 → 가상 MFA 디바이스 선택 → 계속, "
                "3) Google OTP 어플 설치 → ‘+’ 버튼 → 바코드 스캔 → 나타난 QR코드를 어플에서 스캔, 4) 스캔 후 나타난 숫자 MFA 코드 1 입력 → 재 생성된 숫자 MFA 코드 2 입력, "
                "5) 2개의 연속된 MFA 코드 입력, 6) MFA 설정 완료, 7) 로그인 시 비밀번호 입력, 8) Google OTP 번호 입력 후 로그인 시도, 9) 로그인 확인")
    현황 = []
    진단_결과 = ""

    iam = boto3.client('iam')
    try:
        mfa_devices = iam.list_mfa_devices(UserName=user_name)
        if mfa_devices['MFADevices']:
            print("MFA is enabled for the user.")
            진단_결과 = "양호"
        else:
            print("No MFA devices configured for the user.")
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
    user_name = input("Enter IAM user name to check MFA status: ")
    check_mfa_status(user_name)

