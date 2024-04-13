# AWS 취약점 진단 자동화 스크립트

이 프로젝트는 2024 클라우드 보안가이드(AWS) 기반으로 취약점을 점검하고 평가하는 자동화 스크립트를 제공합니다. 목표는 서버의 보안 상태를 평가하여 취약한 부분을 식별하고, 보안 조치를 취할 수 있도록 하는 것입니다.


```json
{
  "점검항목명": {
    "status": "취약" | "양호",
    "description": "항목에 대한 설명 및 조치 사항"
  },
  ...
}
```


```python
cd root
```

```python
sudo yum install git -y
```

```python
sudo apt-get install git -y
```


```python
sudo git clone https://github.com/971023als/linux_vul
```

```python
cd linux_vul/Python_json/ubuntu/
```

cd linux_vul/change/
```

```python
chmod +x vul.sh
```


```python
./vul.sh
```
