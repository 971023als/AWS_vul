#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-004] 불필요한 SMTP 서비스 실행

cat << EOF >> $result
[양호]: SMTP 서비스가 비활성화되어 있거나 필요한 경우에만 실행되는 경우
[취약]: SMTP 서비스가 필요하지 않음에도 실행되고 있는 경우
EOF

BAR

"[SRV-004] 불필요한 SMTP 서비스 실행" >> $TMP1

# SMTP 서비스 (예: postfix)가 실행 중인지 확인합니다.
SMTP_SERVICE="postfix"

if systemctl is-active --quiet $SMTP_SERVICE; then
    WARN "$SMTP_SERVICE 서비스가 실행 중입니다." >> $TMP1
else
    OK "$SMTP_SERVICE 서비스가 비활성화되어 있거나 실행 중이지 않습니다." >> $TMP1
fi

# Additional check for SMTP service on port 25
SMTP_PORT_STATUS=$(ss -tuln | grep -q ':25 ' && echo "OPEN" || echo "CLOSED")

if [ "$SMTP_PORT_STATUS" = "OPEN" ]; then
    WARN "SMTP 포트(25)가 열려 있습니다. 불필요한 서비스가 실행 중일 수 있습니다." >> $TMP1
else
    OK "SMTP 포트(25)는 닫혀 있습니다." >> $TMP1
fi

BAR

cat $TMP1
echo ; echo

