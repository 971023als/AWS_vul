#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-015] 불필요한 NFS 서비스 실행

cat << EOF >> $TMP1
[양호]: 불필요한 NFS 서비스 관련 데몬이 비활성화 되어 있는 경우
[취약]: 불필요한 NFS 서비스 관련 데몬이 활성화 되어 있는 경우
EOF

BAR

if [ `ps -ef | grep -iE 'nfs|rpc.statd|statd|rpc.lockd|lockd' | grep -ivE 'grep|kblockd|rstatd|' | wc -l` -gt 0 ]; then
		WARN " 불필요한 NFS 서비스 관련 데몬이 실행 중입니다." >> $TMP1
		return 0
	else
		OK "불필요한 NFS 서비스 관련 데몬이 비활성화" >> $TMP1
		return 0
	fi

cat $result

echo ; echo
