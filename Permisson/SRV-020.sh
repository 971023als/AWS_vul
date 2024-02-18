#!/bin/bash

. function.sh

TMP1=$(SCRIPTNAME).log
> $TMP1

BAR

CODE [SRV-020] 공유에 대한 접근 통제 미비

cat << EOF >> $result
[양호]: NFS 또는 SMB/CIFS 공유에 대한 접근 통제가 적절하게 설정된 경우
[취약]: NFS 또는 SMB/CIFS 공유에 대한 접근 통제가 미비한 경우
EOF

BAR

# NFS와 SMB/CIFS 설정 파일을 확인합니다.
NFS_EXPORTS_FILE="/etc/exports"
SMB_CONF_FILE="/etc/samba/smb.conf"

check_access_control() {
  file=$1
  service_name=$2

  if [ -f "$file" ]; then
    # 공유 설정에 'everyone' 또는 비슷한 느슨한 설정이 있는지 확인합니다.
    if grep -E "everyone|public" "$file"; then
      WARN "$service_name 서비스에서 느슨한 공유 접근 통제가 발견됨: $file"
    else
      OK "$service_name 서비스에서 공유 접근 통제가 적절함: $file"
    fi
  else
    INFO "$service_name 서비스 설정 파일($file)을 찾을 수 없습니다."
  fi
}

check_nfs_shares() {
  # NFS 공유 목록을 확인합니다.
  showmount -e localhost > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    WARN "NFS 서비스에서 공유 목록이 발견됨"
    showmount -e localhost
  else
    OK "NFS 서비스에서 공유 목록이 발견되지 않음"
  fi
}

check_smb_shares() {
  # Samba 공유 목록을 확인합니다.
  smbclient -L localhost -N > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    WARN "SMB/CIFS 서비스에서 공유 목록이 발견됨"
    smbclient -L localhost -N
  else
    OK "SMB/CIFS 서비스에서 공유 목록이 발견되지 않음"
  fi
}

check_access_control "$NFS_EXPORTS_FILE" "NFS"
check_access_control "$SMB_CONF_FILE" "SMB/CIFS"
check_nfs_shares
check_smb_shares

cat $result

echo ; echo
