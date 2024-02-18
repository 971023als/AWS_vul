#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

CODE [SRV-018] 불필요한 하드디스크 기본 공유 활성화

cat << EOF >> $result
[양호]: NFS 또는 SMB/CIFS의 불필요한 하드디스크 공유가 비활성화된 경우
[취약]: NFS 또는 SMB/CIFS에서 불필요한 하드디스크 기본 공유가 활성화된 경우
EOF

BAR

# NFS와 SMB/CIFS 설정 파일을 확인합니다.
NFS_EXPORTS_FILE="/etc/exports"
SMB_CONF_FILE="/etc/samba/smb.conf"

check_share_activation() {
  file=$1
  service_name=$2

  if [ -f "$file" ]; then
    if grep -E "^\s*\/" "$file" > /dev/null; then
      WARN "$service_name 서비스에서 불필요한 공유가 활성화되어 있습니다: $file"
    else
      OK "$service_name 서비스에서 불필요한 공유가 비활성화되어 있습니다: $file"
    fi
  else
    INFO "$service_name 서비스 설정 파일($file)을 찾을 수 없습니다."
  fi
}

check_share_activation "$NFS_EXPORTS_FILE" "NFS"
check_share_activation "$SMB_CONF_FILE" "SMB/CIFS"

cat "$TMP1"

echo
