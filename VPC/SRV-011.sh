#!/bin/bash

. function.sh

# 결과 파일 초기화
TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-011] 시스템 관리자 계정의 FTP 사용 제한 미비

cat << EOF >> $TMP1
[양호]: FTP 서비스에서 시스템 관리자 계정의 접근이 제한되는 경우
[취약]: FTP 서비스에서 시스템 관리자 계정의 접근이 제한되지 않는 경우
EOF

BAR

# FTP 사용자 제한 설정 파일 경로
FTP_USERS_FILE="/etc/vsftpd/ftpusers"

# 'root' 계정의 FTP 접근 제한 여부 확인
if [ -f "$FTP_USERS_FILE" ]; then
    if grep -q "^root" "$FTP_USERS_FILE"; then
        echo "OK: FTP 서비스에서 root 계정의 접근이 제한됩니다." >> $TMP1
    else
        echo "WARN: FTP 서비스에서 root 계정의 접근이 제한되지 않습니다." >> $TMP1
    fi
else
    echo "WARN: FTP 사용자 제한 설정 파일($FTP_USERS_FILE)이 존재하지 않습니다." >> $TMP1
fi

cat $TMP1
echo ; echo