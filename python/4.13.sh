#!/usr/bin/python3

import boto3
import subprocess
import json

# JSON 데이터를 위한 파이썬 딕셔너리
jsonData = {
    "분류": "운영 관리",
    "코드": "4.13",
    "위험도": "중요도 중",
    "진단항목": "백업 사용 여부",
    "진단결과": "양호",  # '취약'으로 업데이트 가능
    "현황": [],
    "대응방안": {
        "설명": "운영중인 클라우드 리소스에 대한 시스템 충돌, 장애 발생, 인적 재해 등 기업의 사업 연속성을 해치는 모든 상황에 대비해 백업 서비스를 구성해야 데이터를 안전하게 보관할 수 있습니다. 보안 담당자 및 관리자는 클라우드 리소스에 대한 백업을 설정하여 데이터 손실을 방지할 수 있도록 정책을 수립하고 관리해야 합니다.",
        "설정방법": [
            "백업 및 복구 절차 수립, 담당자 지정",
            "- 백업대상(서버 이미지, DB 데이터, 보안로그 등) 선정",
            "- 백업대상별 백업 주기 및 보존기한 정의",
            "- 백업 담당자 및 책임자 지정",
            "- 백업방법 및 절차: 백업시스템 활용, 매뉴얼 방식 등(백업매체 관리 포함)",
            "- 복구절차",
            "- 백업이력관리 (백업 관리 대장)",
            "- 백업 소산에 대한 물리적‧지역적 사항 고려",
            "- 백업 사이트 구축 및 운영"
        ]
    }
}

def bar():
    print("=" * 40)

def log_message(message, file_path):
    with open(file_path, 'a') as file:
        file.write(message + "\n")

# 로그 파일 경로 정의
log_file_name = "backup_audit.log"

# 로그 파일 초기화 또는 생성
with open(log_file_name, 'w') as file:
    pass

bar()

# 로그에 초기 정보 기록
code = "[4.13] 백업 정책 미적용"
initial_message = f"{code}\n[양호]: 백업 정책이 적절히 설정되어 있는 경우\n[취약]: 백업 정책이 설정되어 있지 않은 경우\n"
log_message(initial_message, log_file_name)

bar()

# EC2 인스턴스 목록과 백업 설정 확인
try:
    client = boto3.client('ec2')
    response = client.describe_instances()
    instances = response.get('Reservations', [])
    for reservation in instances:
        for instance in reservation.get('Instances', []):
            instance_id = instance.get('InstanceId')
            tags = instance.get('Tags', [])
            backup_tag = next((tag['Value'] for tag in tags if tag['Key'] == 'Backup'), None)
            if backup_tag:
                result = f"Instance ID: {instance_id}, Backup Tag: {backup_tag}\n"
            else:
                result = f"Instance ID: {instance_id}, No backup configuration.\n"
            log_message(result, log_file_name)
except Exception as e:
    log_message(f"ERROR: Failed to retrieve instance data. {str(e)}\n", log_file_name)

bar()

# 결과 출력
with open(log_file_name, 'r') as file:
    print(file.read())
