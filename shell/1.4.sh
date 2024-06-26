#!/bin/bash

jsonData=$(cat <<-END
{
    "분류": "시스템 보안",
    "코드": "1.4",
    "위험도": "중간",
    "진단항목": "Telnet 서비스 보안 인증 방식 사용 여부",
    "진단결과": "변수: 양호",   # 이 부분은 스크립트 실행 중에 결정되어야 할 수 있음
    "현황": "Placeholder for Get-TelnetStatus function",
    "대응방안": "Telnet 서비스를 비활성화하거나 보안 인증 방식을 사용해야 합니다."
}
END
)

# 디렉터리 설정
output_dir="./aws_iam_groups_audit"
mkdir -p $output_dir

# IAM 그룹 및 그룹 사용자 조회
echo "Fetching IAM Groups and group members..."
aws iam list-groups --output json > $output_dir/groups.json

# 각 그룹별 사용자 목록 조회 및 불필요한 계정 식별
echo "[]" > $output_dir/group_audit_results.json  # 초기 JSON 배열 파일 생성

jq -r '.Groups[] | .GroupName' $output_dir/groups.json | while read group; do
  group_users=$(aws iam get-group --group-name "$group" --output json)
  group_users | jq -r '.Users[] | .UserName' | while read user; do
    if [[ "$user" == *"test"* ]]; then
      # 결과 생성 및 저장
      jq -n --arg group "$group" --arg user "$user" \
      '{"group": $group, "unnecessary_user": $user}' >> $output_dir/group_audit_results.json
    fi
  done
done

echo "Audit complete. Results saved in $output_dir."
