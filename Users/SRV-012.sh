#!/bin/bash

. function.sh

# 결과 파일 초기화
TMP1=$(basename "$0").log
> $TMP1

BAR

CODE [SRV-012] .netrc 파일 내 중요 정보 노출

cat << EOF >> $TMP1
[양호]: 시스템 전체에서 .netrc 파일이 존재하지 않는 경우
[취약]: 시스템 전체에서 .netrc 파일이 존재하는 경우
EOF

BAR

# 시스템 전체에서 .netrc 파일 찾기
netrc_files=$(find / -name ".netrc" 2>/dev/null)

if [ -z "$netrc_files" ]; then
    echo "OK: 시스템에 .netrc 파일이 존재하지 않습니다." >> $TMP1
else
    echo "WARN: 다음 위치에 .netrc 파일이 존재합니다: $netrc_files" >> $TMP1
    # .netrc 파일의 권한 확인 및 출력
    for file in $netrc_files; do
        permissions=$(ls -l $file)
        echo "권한 확인: $permissions" >> $TMP1
    done
fi

BAR

cat $TMP1
echo ; echo
