#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

CODE [SRV-023] 원격 터미널 서비스의 암호화 수준 설정 미흡

cat << EOF >> $result
[양호]: SSH 서비스의 암호화 수준이 적절하게 설정된 경우
[취약]: SSH 서비스의 암호화 수준 설정이 미흡한 경우
EOF

BAR

# SSH 설정 파일을 확인합니다.
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# SSH 암호화 관련 설정을 확인합니다.
# 여기서는 예시로 KexAlgorithms, Ciphers, MACs 설정을 확인합니다.
ENCRYPTION_SETTINGS=("KexAlgorithms" "Ciphers" "MACs")

for setting in "${ENCRYPTION_SETTINGS[@]}"; do
  if grep -q "^$setting" "$SSH_CONFIG_FILE"; then
    OK "$SSH_CONFIG_FILE 파일에서 $setting 설정이 적절하게 구성되어 있습니다."
  else
    WARN "$SSH_CONFIG_FILE 파일에서 $setting 설정이 미흡합니다."
  fi
done

cat $result

echo ; echo
