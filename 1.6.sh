#!/bin/bash

# 초기 변수 설정
분류="계정 관리"
코드="1.6"
위험도="중요도 상"
진단_항목="Key Pair 보관 관리"
대응방안="EC2는 키(Key)를 이용한 암호화 기법을 제공합니다. 해당 기법은 퍼블릭/프라이빗 키를 통해 각각 데이터의 암호화 및 해독을 하는 방식으로, 여기에 사용되는 키를 'Key Pair'라고 하며, 해당 암호화 기법을 사용할 시 EC2의 보안성을 향상시킬 수 있습니다. EC2 인스턴스 생성 시 Key Pair 등록을 권장합니다. 또한, Amazon EC2에 사용되는 키는 '2048비트 SSH-2 RSA 키'이며, Key Pair는 리전당 최대 5천 개까지 보유할 수 있습니다. Key Pair는 타 사용자가 확인이 가능한 공개된 위치에 보관하게 될 경우 EC2 Instance에 무단으로 접근이 가능해지므로 비인가자가 쉽게 유추 및 접근이 불가능한 장소에 보관해야 합니다."
설정방법="S3 버킷 내 Key Pair 관리하기: 1) 버킷 접근, 2) 버킷 생성하기, 3) 생성된 버킷 확인, 4) S3 버킷 내 KeyPair 업로드, 5) 업로드된 KeyPair 확인, 6) Key Pair 보관 확인(프라이빗 S3 버킷)"
현황=()
진단_결과=""

# S3 버킷의 이름 입력 받기
read -p "Enter the S3 bucket name where Key Pairs are stored: " bucket_name

# S3 버킷의 내용을 검사하여 Key Pair 파일 확인
key_pair_files=$(aws s3 ls s3://$bucket_name/ --recursive | grep '.pem$')

if [ -z "$key_pair_files" ]; then
    echo "No Key Pair files found in the bucket $bucket_name."
    진단_결과="취약"
else
    echo "Key Pair files found in the bucket $bucket_name:"
    echo "$key_pair_files"
    진단_결과="양호"
fi

# 결과 출력
echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단_항목: $진단_항목"
echo "대응방안: $대응방안"
echo "설정방법: $설정방법"
echo "현황: ${현황[@]}"
echo "진단_결과: $진단_결과"
