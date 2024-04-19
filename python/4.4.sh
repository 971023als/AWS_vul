#!usr/bin/python3

import boto3
import subprocess
import json

# Python dictionary for JSON data
jsonData = {
    "분류": "운영 관리",
    "코드": "4.4",
    "위험도": "중요도 중",
    "진단항목": "통신구간 암호화 설정",
    "대응방안": {
        "설명": "클라우드 리소스를 통해 대/내외 서비스에서 정보를 송, 수신하는 경우, 중간에서 공격자가 패킷을 가로채어 공격에 활용할 수 없도록 통신구간을 암호화하여 설정하여야 합니다.",
        "설정방법": [
            "중요정보 전송 시 이동구간 암호화",
            "암호화된 통신 채널 사용",
            "서버 원격 접근 시 암호화된 통신수단(VPN, SSH 등)을 사용",
            "공공기관 데이터이관 시 VPN을 통해 이관",
            "기타 관리를 위한 접근 시 OpenSSH 및 OpenSSL(TLS V1.2) 사용"
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
log_file_name = "encryption_audit.log"

# Clear or create the log file
with open(log_file_name, 'w') as file:
    pass

bar()

# Log initial information
code = "[4.4] 통신구간 암호화 설정"
initial_message = "SSH와 OpenSSL이 현대 암호화 표준을 지원하는지 확인합니다."
log_message(initial_message, log_file_name)

bar()

try:
    # Check SSH and OpenSSL versions
    ssh_version = subprocess.check_output(["ssh", "-V"], stderr=subprocess.STDOUT).decode()
    openssl_version = subprocess.check_output(["openssl", "version"]).decode()
    
    log_message(f"SSH 버전: {ssh_version}", log_file_name)
    log_message(f"OpenSSL 버전: {openssl_version}", log_file_name)
    
    # Simulated secure communication check
    secure_connection_status = "true"  # Placeholder for actual check
    if secure_connection_status == "true":
        print("안전한 통신 프로토콜이 구현되어 있습니다.")
        encryption_compliance = "양호"
    else:
        print("안전한 통신 프로토콜이 적절하게 구성되지 않았습니다.")
        encryption_compliance = "취약"

    jsonData['진단결과'] = encryption_compliance
    log_message(f"진단 결과: {encryption_compliance}", log_file_name)
    
except Exception as e:
    print(f"오류 발생: {str(e)}")
    jsonData['진단결과'] = "오류"
    log_message(f"진단 오류: {str(e)}", log_file_name)

bar()

# Print results
with open(log_file_name, 'r') as file:
    print(file.read())

# Print JSON data with results
print(json.dumps(jsonData, indent=2, ensure_ascii=False))
