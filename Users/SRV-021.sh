#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-021] FTP 서비스 접근 제어 설정 미비

cat << EOF >> $TMP1
[양호]: ftpusers 파일의 소유자가 root이고, 권한이 640 이하인 경우
[취약]: ftpusers 파일의 소유자가 root가 아니고, 권한이 640 이상인 경우
EOF

BAR

# FTP 서비스 구성 파일에서 익명 사용자 접속을 확인합니다.
file_exists_count=0
	ftpusers_files=("/etc/ftpusers" "/etc/pure-ftpd/ftpusers" "/etc/wu-ftpd/ftpusers" "/etc/vsftpd/ftpusers" "/etc/proftpd/ftpusers" "/etc/ftpd/ftpusers" "/etc/vsftpd.ftpusers" "/etc/vsftpd.user_list" "/etc/vsftpd/user_list")
	for ((i=0; i<${#ftpusers_files[@]}; i++))
	do
		if [ -f ${ftpusers_files[$i]} ]; then
			((file_exists_count++))
			ftpusers_file_owner_name=`ls -l ${ftpusers_files[$i]} | awk '{print $3}'`
			if [[ $ftpusers_file_owner_name =~ root ]]; then
				ftpusers_file_permission=`stat ${ftpusers_files[$i]} | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,3,3)}'`
				if [ $ftpusers_file_permission -le 640 ]; then
					ftpusers_file_owner_permission=`stat ${ftpusers_files[$i]} | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,3,1)}'`
					if [ $ftpusers_file_owner_permission -eq 6 ] || [ $ftpusers_file_owner_permission -eq 4 ] || [ $ftpusers_file_owner_permission -eq 2 ] || [ $ftpusers_file_owner_permission -eq 0 ]; then
						ftpusers_file_group_permission=`stat ${ftpusers_files[$i]} | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,4,1)}'`
						if [ $ftpusers_file_group_permission -eq 4 ] || [ $ftpusers_file_group_permission -eq 0 ]; then
							ftpusers_file_other_permission=`stat ${ftpusers_files[$i]} | grep -i 'Uid' | awk '{print $2}' | awk -F / '{print substr($1,5,1)}'`
							if [ $ftpusers_file_other_permission -ne 0 ]; then
								WARN " ${ftpusers_files[$i]} 파일의 다른 사용자(other)에 대한 권한이 취약합니다." >> $TMP1
								return 0
							fi
						else
							WARN " ${ftpusers_files[$i]} 파일의 그룹 사용자(group)에 대한 권한이 취약합니다." >> $TMP1
							return 0
						fi
					else
						WARN " ${ftpusers_files[$i]} 파일의 사용자(owner)에 대한 권한이 취약합니다." >> $TMP1
						return 0
					fi
				else
					WARN " ${ftpusers_files[$i]} 파일의 권한이 640보다 큽니다." >> $TMP1
					return 0
				fi
			else
				WARN " ${ftpusers_files[$i]} 파일의 소유자(owner)가 root가 아닙니다." >> $TMP1
				return 0
			fi
		fi
	done
	if [ $file_exists_count -eq 0 ]; then
		WARN " ftp 접근제어 파일이 없습니다." >> $TMP1
		return 0
	else
		OK "※ U-63 결과 : 양호(Good)" >> $TMP1
		return 0
	fi

cat $TMP1

echo ; echo
