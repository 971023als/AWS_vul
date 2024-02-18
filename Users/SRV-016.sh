#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-016] 불필요한 RPC서비스 활성화

cat << EOF >> $TMP1
[양호]: 불필요한 RPC 서비스가 비활성화 되어 있는 경우
[취약]: 불필요한 RPC 서비스가 활성화 되어 있는 경우
EOF

BAR

# RPC 관련 서비스 목록
rpc_services=("rpc.cmsd" "rpc.ttdbserverd" "sadmind" "rusersd" "walld" "sprayd" "rstatd" "rpc.nisd" "rexd" "rpc.pcnfsd" "rpc.statd" "rpc.ypupdated" "rpc.rquotad" "kcms_server" "cachefsd")
	if [ -d /etc/xinetd.d ]; then
		for ((i=0; i<${#rpc_services[@]}; i++))
		do
			if [ -f /etc/xinetd.d/${rpc_services[$i]} ]; then
				etc_xinetdd_rpcservice_disable_count=`grep -vE '^#|^\s#' /etc/xinetd.d/${rpc_services[$i]} | grep -i 'disable' | grep -i 'yes' | wc -l`
				if [ $etc_xinetdd_rpcservice_disable_count -eq 0 ]; then
					WARN " 불필요한 RPC 서비스가 /etc/xinetd.d 디렉터리 내 서비스 파일에서 실행 중입니다." >> $TMP1
					return 0
				fi
			fi
		done
	fi
	if [ -f /etc/inetd.conf ]; then
		for ((i=0; i<${#rpc_services[@]}; i++))
		do
			etc_inetdconf_rpcservice_enable_count=`grep -vE '^#|^\s#' /etc/inetd.conf | grep -w ${rpc_services[$i]} | wc -l`
			if [ $etc_inetdconf_rpcservice_enable_count -gt 0 ]; then
				WARN " 불필요한 RPC 서비스가 /etc/inetd.conf 파일에서 실행 중입니다." >> $TMP1
				return 0
			fi
		done
	fi
	OK "불필요한 RPC 서비스가 비활성화 되어 있는 경우" >> $TMP1
	return 0

cat $result

echo ; echo
