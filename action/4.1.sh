#!/bin/bash

{
  "분류": "운영 관리",
  "코드": "4.1",
  "위험도": "중요도 중",
  "진단_항목": "EBS 및 볼륨 암호화 설정",
  "대응방안": {
    "설명": "EBS는 EC2 인스턴스 생성 및 이용 시 사용되는 블록 형태의 스토리지 볼륨이며, AES-256 알고리즘을 사용하여 볼륨 암호화를 지원합니다. 이는 데이터 및 애플리케이션에 대한 보안을 강화하여 안전하게 정보를 저장할 수 있게 해줍니다.",
    "설정방법": [
      "인스턴스 시작 클릭",
      "AMI 선택",
      "인스턴스 유형 선택",
      "인스턴스 구성",
      "스토리지 추가",
      "태그 추가",
      "보안 그룹 구성",
      "스토리지 암호화 여부 확인",
      "EC2 인스턴스 클릭 및 스토리지 클릭",
      "스토리지 암호화 설정여부 확인",
      "Elastic Block Store 메뉴 내 볼륨 기능 선택",
      "볼륨 생성 메뉴 내 '암호화' 활성화 후 KMS 키 값을 추가하여 설정"
    ]
  },
  "현황": [],
  "진단_결과": "양호"
}


# Check for aws CLI tools
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install AWS CLI to run this script."
    exit 1
fi

# List all EBS volumes with their encryption status
echo "Retrieving EBS volumes and encryption status..."
ebs_volumes_output=$(aws ec2 describe-volumes --query 'Volumes[*].{VolumeId:VolumeId, Encrypted:Encrypted}' --output json)
if [ $? -ne 0 ]; then
    echo "Failed to retrieve EBS volumes. Please check your AWS CLI setup and permissions."
    exit 1
fi

if [ -z "$ebs_volumes_output" ]; then
    echo "No EBS volumes found."
    exit 0
fi

echo "EBS Volumes found:"
echo "$ebs_volumes_output"

# Analyze the encryption status for compliance
compliance_status="양호"  # Assume all volumes must be encrypted for a '양호' status
echo "Analyzing encryption status of EBS volumes..."
for row in $(echo "${ebs_volumes_output}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }
    volume_id=$(_jq '.VolumeId')
    encrypted=$(_jq '.Encrypted')
    if [ "$encrypted" == "false" ]; then
        echo "Volume $volume_id is not encrypted."
        compliance_status="취약"
        break
    fi
done

echo "Encryption compliance status: $compliance_status"

# Update JSON diagnostic result directly using jq and sponge
echo "Updating diagnosis result..."
jq --arg status "$compliance_status" '.진단_결과 = $status' diagnosis.json | sponge diagnosis.json
echo "Diagnosis updated with result: $compliance_status"
