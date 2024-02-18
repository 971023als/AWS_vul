#!/bin/bash

. function.sh

TMP1=$(basename "$0").log
> $TMP1

BAR 

CODE [SRV-009] SMTP 서비스 스팸 메일 릴레이 제한 미설정

cat << EOF >> $TMP1
[양호]: SMTP 서비스를 사용하지 않거나 릴레이 제한이 설정되어 있는 경우
[취약]: SMTP 서비스를 사용하거나 릴레이 제한이 설정이 없는 경우
EOF

BAR

if [ -f /etc/services ]; then
		smtp_port_count=`grep -vE '^#|^\s#' /etc/services | awk 'tolower($1)=="smtp" {print $2}' | awk -F / 'tolower($2)=="tcp" {print $1}' | wc -l`
		if [ $smtp_port_count -gt 0 ]; then
			smtp_port=(`grep -vE '^#|^\s#' /etc/services | awk 'tolower($1)=="smtp" {print $2}' | awk -F / 'tolower($2)=="tcp" {print $1}'`)
			for ((i=0; i<${#smtp_port[@]}; i++))
			do
				netstat_smtp_count=`netstat -nat 2>/dev/null | grep -w 'tcp' | grep -Ei 'listen|established|syn_sent|syn_received' | grep ":${smtp_port[$i]} " | wc -l`
				if [ $netstat_smtp_count -gt 0 ]; then
					sendmailcf_exists_count=`find / -name 'sendmail.cf' -type f 2>/dev/null | wc -l`
					if [ $sendmailcf_exists_count -gt 0 ]; then
						sendmailcf_files=(`find / -name 'sendmail.cf' -type f 2>/dev/null`)
						if [ ${#sendmailcf_files[@]} -gt 0 ]; then
							for ((j=0; j<${#sendmailcf_files[@]}; j++))
							do
								sendmailcf_relaying_denied_count=`grep -vE '^#|^\s#' ${sendmailcf_files[$j]} | grep -i 'R$\*' | grep -i 'Relaying denied' | wc -l`
								if [ $sendmailcf_relaying_denied_count -eq 0 ]; then
									WARN " ${sendmailcf_files[$j]} 파일에 릴레이 제한이 설정되어 있지 않습니다." >> $TMP1
									return 0
								fi
							done
						fi
					fi
				fi
			done
		fi
	fi
	ps_smtp_count=`ps -ef | grep -iE 'smtp|sendmail' | grep -v 'grep' | wc -l`
	if [ $ps_smtp_count -gt 0 ]; then
		sendmailcf_exists_count=`find / -name 'sendmail.cf' -type f 2>/dev/null | wc -l`
		if [ $sendmailcf_exists_count -gt 0 ]; then
			sendmailcf_files=(`find / -name 'sendmail.cf' -type f 2>/dev/null`)
			if [ ${#sendmailcf_files[@]} -gt 0 ]; then
				for ((i=0; i<${#sendmailcf_files[@]}; i++))
				do
					sendmailcf_relaying_denied_count=`grep -vE '^#|^\s#' ${sendmailcf_files[$i]} | grep -i 'R$\*' | grep -i 'Relaying denied' | wc -l`
					if [ $sendmailcf_relaying_denied_count -eq 0 ]; then
						WARN " ${sendmailcf_files[$i]} 파일에 릴레이 제한이 설정되어 있지 않습니다." >> $TMP1
						return 0
					fi
				done
			fi
		fi
	fi
	OK "SMTP 서비스를 사용하지 않거나 릴레이 제한이 설정" >> $TMP1
	return 0
cat $result

echo ; echo
