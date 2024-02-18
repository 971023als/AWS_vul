#!/bin/bash

. function.sh

# 결과 파일 정의
TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-010] SMTP 서비스의 메일 queue 처리 권한 설정 미흡

cat << EOF >> $TMP1
[양호]: SMTP 서비스의 메일 queue 처리 권한을 업무 관리자에게만 부여되도록 설정한 경우
[취약]: SMTP 서비스의 메일 queue 처리 권한이 업무와 무관한 일반 사용자에게도 부여되도록 설정된 경우
EOF

BAR

"[SRV-010] SMTP 서비스의 메일 queue 처리 권한 설정 미흡" >> $TMP1

# Sendmail 설정 점검
SENDMAIL_CF="/etc/mail/sendmail.cf"
if grep -q "O PrivacyOptions=.*restrictqrun" "$SENDMAIL_CF"; then
    echo "OK: Sendmail의 PrivacyOptions에 restrictqrun 설정이 적용되어 있습니다." >> $TMP1
else
    echo "WARN: Sendmail의 PrivacyOptions에 restrictqrun 설정이 누락되었습니다." >> $TMP1
fi

# Postfix 메일 queue 디렉터리 권한 확인
POSTSUPER="/usr/sbin/postsuper"
if [ -x "$POSTSUPER" ]; then
    # others 권한 점검
    if ls -l "$POSTSUPER" | grep -q "r-xr-x---"; then
        echo "OK: Postfix의 postsuper 실행 파일이 others에 대해 실행 권한이 없습니다." >> $TMP1
    else
        echo "WARN: Postfix의 postsuper 실행 파일이 others에 대해 과도한 권한을 부여하고 있습니다." >> $TMP1
    fi
else
    echo "INFO: Postfix postsuper 실행 파일이 존재하지 않습니다." >> $TMP1
fi

cat $TMP1
echo ; echo
