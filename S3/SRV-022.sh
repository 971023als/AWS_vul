#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-022] 계정의 비밀번호 미설정, 빈 암호 사용 관리 미흡

cat << EOF >> $TMP1
[양호]: 모든 계정에 비밀번호가 설정되어 있고 빈 비밀번호를 사용하는 계정이 없는 경우
[취약]: 비밀번호가 설정되지 않거나 빈 비밀번호를 사용하는 계정이 있는 경우
EOF

BAR

"CODE [SRV-022] 계정의 비밀번호 미설정, 빈 암호 사용 관리 미흡" >> $TMP1

# /etc/shadow 파일을 확인하여 빈 비밀번호가 설정된 계정을 찾습니다.
empty_passwords=0
while IFS=: read -r user enc_passwd rest; do
    if [[ "$enc_passwd" == "" ]]; then
        echo "WARN 비밀번호가 설정되지 않은 계정: $user" >> $TMP1
        empty_passwords=$((empty_passwords + 1))
    elif [[ "$enc_passwd" == "!" || "$enc_passwd" == "*" ]]; then
        echo "OK 비밀번호가 잠긴 계정: $user" >> $TMP1
    else
        echo "OK 비밀번호가 설정된 계정: $user" >> $TMP1
    fi
done < /etc/shadow

# 비밀번호가 설정되지 않거나 빈 비밀번호를 사용하는 계정이 있는지 확인합니다.
if [ $empty_passwords -gt 0 ]; then
    echo "[결과] 취약: 비밀번호가 설정되지 않거나 빈 비밀번호를 사용하는 계정이 존재합니다." >> $TMP1
else
    echo "[결과] 양호: 모든 계정에 비밀번호가 설정되어 있고 빈 비밀번호를 사용하는 계정이 없습니다." >> $TMP1
fi

BAR

# 최종 결과를 출력합니다.
cat $TMP1

echo ; echo
