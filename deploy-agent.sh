#!/bin/bash

# 모니터링 에이전트 배포 스크립트 (대상 서버용)

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 환경 변수 확인
check_env() {
    log_info "환경 변수 확인 중..."
    
    if [ -z "$MONITORING_SERVER_IP" ]; then
        log_error "MONITORING_SERVER_IP가 설정되지 않았습니다."
        echo "사용법: export MONITORING_SERVER_IP=<중앙모니터링서버IP>"
        echo "예시: export MONITORING_SERVER_IP=192.168.1.100"
        exit 1
    fi
    
    if [ -z "$SERVICE_NAME" ]; then
        log_warn "SERVICE_NAME이 설정되지 않았습니다. 기본값 'unknown'을 사용합니다."
        export SERVICE_NAME="unknown"
    fi
    
    log_info "중앙 모니터링 서버: $MONITORING_SERVER_IP"
    log_info "서비스 이름: $SERVICE_NAME"
}

# 에이전트 배포
deploy_agent() {
    log_info "모니터링 에이전트 배포 중..."
    
    # 환경 변수 설정
    export CENTRAL_LOKI_URL="http://$MONITORING_SERVER_IP:3100"
    export HOSTNAME=$(hostname)
    
    # 에이전트용 Docker Compose 실행
    docker compose -f agent-compose.yml up -d
    
    log_info "모니터링 에이전트가 시작되었습니다."
    log_info "Node Exporter: http://localhost:9100"
    log_info "Promtail: http://localhost:9080"
}

# 상태 확인
check_status() {
    log_info "에이전트 상태 확인 중..."
    
    docker compose -f agent-compose.yml ps
}

# 로그 확인
show_logs() {
    local service=${1:-""}
    
    if [ -n "$service" ]; then
        docker compose -f agent-compose.yml logs -f "$service"
    else
        docker compose -f agent-compose.yml logs -f
    fi
}

# 서비스 중지
stop_agent() {
    log_info "모니터링 에이전트 중지 중..."
    
    docker compose -f agent-compose.yml down
    log_info "모니터링 에이전트가 중지되었습니다."
}

# 메인 함수
main() {
    case "$1" in
        "start")
            check_env
            deploy_agent
            ;;
        "status")
            check_status
            ;;
        "logs")
            show_logs "$2"
            ;;
        "stop")
            stop_agent
            ;;
        "restart")
            stop_agent
            sleep 2
            check_env
            deploy_agent
            ;;
        *)
            echo "사용법: $0 {start|status|logs|stop|restart}"
            echo ""
            echo "  start   - 에이전트 시작"
            echo "  status  - 에이전트 상태 확인"
            echo "  logs    - 로그 확인 (선택: 서비스명)"
            echo "  stop    - 에이전트 중지"
            echo "  restart - 에이전트 재시작"
            echo ""
            exit 1
            ;;
    esac
}

main "$@" 