# 모니터링 에이전트: 대상 서버용

## 구성 요소

- **Node Exporter**: 시스템 메트릭 수집 (CPU, 메모리, 디스크 등)
- **Promtail**: 로그 수집 및 중앙 Loki 서버로 전송

## 배포 방법

### 1. 디렉토리 내 파일 세팅
```bash
cp -r monitoring/ ~/
cd ~/monitoring
```

### 2. 실행 권한
```bash
chmod +x monitoring/deploy-agent.sh
```

### 3. 환경 변수 설정
```bash
# 중앙 모니터링 서버 IP
export MONITORING_SERVER_IP=<중앙모니터링서버IP>
# 서비스 이름 (기본값: unknown)
export SERVICE_NAME=<서비스이름>
```

### 4. 에이전트 시작
```bash
./deploy-agent.sh start
```

## 사용법

```bash
# 에이전트 시작
./deploy-agent.sh start

# 상태 확인
./deploy-agent.sh status

# 로그 확인
./deploy-agent.sh logs
./deploy-agent.sh logs promtail
./deploy-agent.sh logs node-exporter

# 에이전트 중지
./deploy-agent.sh stop

# 에이전트 재시작
./deploy-agent.sh restart
```

## 포트 사용

- **9100**: Node Exporter (시스템 메트릭)
- **9080**: Promtail (로그 수집)

## 로그 수집 경로

Promtail이 수집하는 로그 경로들:
- `/var/log/utils_logs/` - 유틸리티 로그
- `/var/log/fastapi/` - FastAPI 애플리케이션 로그
- `/var/log/coach-assistant/` - Coach Assistant 서버 로그
- `/var/log/predict-server/` - Predict 서버 로그
- `/var/lib/docker/containers/` - Docker 컨테이너 로그

- 중앙 모니터링 서버의 Loki(3100)로 로그 전송
- 중앙 모니터링 서버의 Prometheus가 이 서버의 9100 포트에서 메트릭 수집합

## 문제해결

```bash
# 포트 충돌 확인
netstat -tlnp | grep -E ':(9100|9080)'

# docker 로그
docker logs node-exporter
docker logs promtail

# 환경변수
echo "MONITORING_SERVER_IP: $MONITORING_SERVER_IP"
echo "SERVICE_NAME: $SERVICE_NAME"
``` 