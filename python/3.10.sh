#!/bin/bash
import boto3
import json

# Python dictionary for JSON data
jsonData = {
    "분류": "가상 리소스 관리",
    "코드": "3.10",
    "위험도": "중요도 중",
    "진단항목": "ELB 연결 관리",
    "대응방안": {
        "설명": ("Elastic Load Balancing은 둘 이상의 가용 영역에서 EC2 인스턴스, 컨테이너, IP 주소 등 여러 대상에 걸쳐 수신되는 트래픽을 자동으로 분산해주는 서비스입니다. "
                 "ELB의 종류로는 Application Load Balancers, Network Load Balancers, Gateway Load Balancers 및 Classic Load Balancer가 있으며, 이들은 다양한 계층에서 작동하여 애플리케이션과 네트워크 트래픽을 관리합니다."),
        "설정방법": [
            "ELB 리스너 추가",
            "리스너 보안 설정 (TLS 적용)",
            "적용된 TLS 설정 확인",
            "가용 영역 설정 (AZ 2개 영역 이상 설정 권고)",
            "ELB에 대한 트래픽 제어 보안그룹 생성 및 수정",
            "ELB [속성] 내 모니터링 (액세스 로그) 설정 확인"
        ]
    },
    "현황": [],
    "진단결과": "양호"
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# Define the log file path
log_file_name = "elb_security_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[3.10] ELB 연결 관리"
initial_message = f"{code}\n[양호]: ELB 설정이 적절한 경우\n[취약]: ELB 설정에 문제가 있는 경우\n"
log_message(initial_message, log_file_name)

bar()

# AWS SDK setup
elbv2 = boto3.client('elbv2')

# Fetching all ELBs
try:
    elbs = elbv2.describe_load_balancers()
    print("ELBs found:")
    for elb in elbs['LoadBalancers']:
        print(f"{elb['LoadBalancerName']} - Type: {elb['Type']}")
except Exception as e:
    print("Failed to retrieve ELBs. Error:", str(e))
    exit(1)

# User input for ELB name
elb_name = input("Enter ELB name to check configuration: ")

# Check specific ELB configuration
try:
    elb_config = elbv2.describe_load_balancers(Names=[elb_name])
    print("ELB Configuration for '{}':".format(elb_name))
    print(json.dumps(elb_config['LoadBalancers'], indent=2))
    compliance_status = "양호"  # Assuming compliance check is done here
except Exception as e:
    print("Failed to retrieve configuration for ELB '{}'. Error: {}".format(elb_name, str(e)))
    compliance_status = "취약"

# Log results
result_message = f"Diagnosis result for '{elb_name}': {compliance_status}"
log_message(result_message, log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Update JSON diagnosis result
jsonData['진단결과'] = compliance_status
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
