#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-003] SNMP 접근 통제 미설정

cat << EOF >> $result

[양호]: SNMP 접근 제어가 적절하게 설정된 경우
[취약]: SNMP 접근 제어가 설정되지 않거나 미흡한 경우

EOF

BAR

"[SRV-003] SNMP 접근 통제 미설정" >> $TMP1

SNMPD_CONF="/etc/snmp/snmpd.conf"
ACCESS_CONTROL_STRING="com2sec"

# SNMPD 설정 파일에서 com2sec가 적절하게 설정되었는지 확인합니다
if grep -q "^$ACCESS_CONTROL_STRING" "$SNMPD_CONF"; then
   # 여기서 추가적인 확인 로직을 넣을 수 있습니다, 예를 들어:
   # if grep -E "^$ACCESS_CONTROL_STRING[[:space:]]+[^default]" "$SNMPD_CONF"; then
   OK "SNMP 접근 제어가 적절하게 설정됨"
else
   WARN "SNMP 접근 제어가 설정되지 않음"
fi

BAR

cat $result

echo ; echo
