#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

CODE [SRV-014] NFS 접근통제 미비

cat << EOF >> $TMP1
[양호]: 불필요한 NFS 서비스를 사용하지 않거나, 불가피하게 사용 시 everyone 공유를 제한한 경우
[취약]: 불필요한 NFS 서비스를 사용하거나, 불가피하게 사용 시 everyone 공유를 제한하지 않는 경우
EOF

BAR

# NFS 설정 파일을 확인합니다.
if [ `ps -ef | grep -iE 'nfs|rpc.statd|statd|rpc.lockd|lockd' | grep -ivE 'grep|kblockd|rstatd|' | wc -l` -gt 0 ]; then
		if [ -f /etc/exports ]; then
			etc_exports_all_count=`grep -vE '^#|^\s#' /etc/exports | grep '/' | grep '*' | wc -l`
			etc_exports_insecure_count=`grep -vE '^#|^\s#' /etc/exports | grep '/' | grep -i 'insecure' | wc -l`
			etc_exports_directory_count=`grep -vE '^#|^\s#' /etc/exports | grep '/' | wc -l`
			etc_exports_squash_count=`grep -vE '^#|^\s#' /etc/exports | grep '/' | grep -iE 'root_squash|all_squash' | wc -l`
			if [ $etc_exports_all_count -gt 0 ]; then
                WARN "/etc/exports 파일에 '*' 설정이 있습니다. " >> $TMP1
				INFO "설정 = 모든 클라이언트에 대해 전체 네트워크 공유 허용" >> $TMP1
				return 0
			elif [ $etc_exports_insecure_count -gt 0 ]; then
				WARN " /etc/exports 파일에 'insecure' 옵션이 설정되어 있습니다." >> $TMP1
				return 0
			else
				if [ $etc_exports_directory_count -ne $etc_exports_squash_count ]; then
					WARN " /etc/exports 파일에 'root_squash' 또는 'all_squash' 옵션이 설정되어 있지 않습니다." >> $TMP1
					return 0
				fi
			fi
		fi
	else
		OK "불필요한 NFS 서비스를 사용하지 않거나, 불가피하게 사용 시 everyone 공유를 제한" >> $TMP1
		return 0
	fi
	
BAR

cat $result

echo ; echo
