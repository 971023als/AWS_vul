#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-013] Anonymous 계정의 FTP 서비스 접속 제한 미비

cat << EOF >> $TMP1
[양호]: Anonymous FTP (익명 ftp) 접속을 차단한 경우
[취약]: Anonymous FTP (익명 ftp) 접속을 차단하지 않는 경우
EOF

BAR

if [ -f /etc/passwd ]; then
		if [ `awk -F : '$1=="ftp" || $1=="anonymous"' /etc/passwd | wc -l` -gt 0 ]; then
			file_exists_count=0
			if [ `find / -name 'proftpd.conf' -type f 2>/dev/null | wc -l` -gt 0 ]; then
				proftpdconf_settings_files=(`find / -name 'proftpd.conf' -type f 2>/dev/null`)
				for ((i=0; i<${#proftpdconf_settings_files[@]}; i++))
				do
					((file_exists_count++))
					proftpdconf_anonymous_start_line_count=`grep -vE '^#|^\s#' ${proftpdconf_settings_files[$i]} | grep '<Anonymous' | wc -l`
					proftpdconf_anonymous_end_line_count=`grep -vE '^#|^\s#' ${proftpdconf_settings_files[$i]} | grep '</Anonymous>' | wc -l`
					if [ $proftpdconf_anonymous_start_line_count -gt 0 ] && [ $proftpdconf_anonymous_end_line_count -gt 0 ]; then
						proftpdconf_anonymous_start_line=`grep -vE '^#|^\s#' ${proftpdconf_settings_files[$i]} | grep -n '<Anonymous' | awk -F : '{print $1}'`
						proftpdconf_anonymous_end_line=`grep -vE '^#|^\s#' ${proftpdconf_settings_files[$i]} | grep -n '</Anonymous>' | awk -F : '{print $1}'`
						proftpdconf_anonymous_contents_range=$((proftpdconf_anonymous_end_line-proftpdconf_anonymous_start_line))
						proftpdconf_anonymous_enable_count=`grep -vE '^#|^\s#' ${proftpdconf_settings_files[$i]} | grep -A $proftpdconf_anonymous_contents_range '<Anonymous' | grep -wE 'User|UserAlias' | wc -l`
						if [ $proftpdconf_anonymous_enable_count -gt 0 ]; then
							WARN " ${proftpdconf_settings_files[$i]} 파일에서 'User' 또는 'UserAlias' 옵션이 삭제 또는 주석 처리되어 있지 않습니다." >> $TMP1
							return 0
						fi
					fi
				done
			fi
			if [ `find / -name 'vsftpd.conf' -type f 2>/dev/null | wc -l` -gt 0 ]; then
				((file_exists_count++))
				vsftpdconf_settings_files=(`find / -name 'vsftpd.conf' -type f 2>/dev/null`)
				settings_in_vsftpdconf=0
				for ((i=0; i<${#vsftpdconf_settings_files[@]}; i++))
				do
					vsftpdconf_anonymous_enable_count=`grep -vE '^#|^\s#' ${vsftpdconf_settings_files[$i]} | grep -i 'anonymous_enable' | wc -l`
					if [ $vsftpdconf_anonymous_enable_count -gt 0 ]; then
						((settings_in_vsftpdconf++))
						vsftpdconf_anonymous_enable_value=`grep -vE '^#|^\s#' ${vsftpdconf_settings_files[$i]} | grep -i 'anonymous_enable' | awk '{gsub(" ", "", $0); print tolower($0)}' | awk -F 'anonymous_enable=' '{print $2}'`
						if [[ $vsftpdconf_anonymous_enable_value =~ yes ]]; then
							WARN " ${vsftpdconf_settings_files[$i]} 파일에서 익명 ftp 접속을 허용하고 있습니다." >> $TMP1
							return 0
						fi
					fi
				done
				if [ $settings_in_vsftpdconf -eq 0 ]; then
					WARN " vsftpd.conf 파일에 익명 ftp 접속을 설정하는 옵션이 없습니다." >> $TMP1
					return 0
				fi
			fi
			if [ $file_exists_count -eq 0 ]; then
				WARN " 익명 ftp 접속을 설정하는 파일이 없습니다." > $TMP1
				return 0
			fi
		fi
	fi
	OK "Anonymous FTP (익명 ftp) 접속을 차단" >> $TMP1
	return 0

cat $result

echo ; echo
