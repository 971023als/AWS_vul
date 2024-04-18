#!/bin/bash

{
  "분류": "운영 관리",
  "코드": "4.7",
  "위험도": "중요도 상",
  "진단_항목": "AWS 사용자 계정 로깅 설정",
  "대응방안": {
    "설명": "AWS CloudTrail은 계정의 거버넌스, 규정 준수, 운영 및 위험 감사를 활성화하도록 도와주는 서비스입니다. 사용자, 역할 또는 AWS 서비스가 수행하는 작업들의 이벤트가 기록됩니다. CloudTrail은 생성 시 AWS 계정에서 활성화됩니다. 활동이 AWS 계정에서 이루어지면 해당 활동이 CloudTrail 이벤트에 기록됩니다.",
    "설정방법": [
      "CloudTrail 대시보드 진입 및 관리 이벤트 추적 확인",
      "CloudTrail 추적 생성 버튼 클릭",
      "CloudTrail 추적 속성 설정",
      "CloudTrail CloudWatch Logs 설정",
      "로그 이벤트 선택 – 관리 이벤트",
      "CloudTrail 검토 및 생성 내용 확인"
    ]
  },
  "현황": [],
  "진단_결과": "양호"
}


# CloudTrail 로깅 상태 체크
cloudtrail_logging_status=$(aws cloudtrail describe-trails --query 'trailList[*].Logging' --output text)

# 진단 결과 업데이트
if [[ $cloudtrail_logging_status == "true" ]]; then
    diagnostic_result="양호"
else
    diagnostic_result="취약"
fi

# 결과 출력
echo "AWS 사용자 계정 로깅 설정 진단 결과: $diagnostic_result"
