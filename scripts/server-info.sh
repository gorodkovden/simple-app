#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Лог-файл
LOG_FILE="/tmp/server-info-$(date +%Y%m%d-%H%M%S).log"

# Функция для логирования
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Функция для вывода заголовка
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Функция для вывода успешного статуса
print_success() {
    echo -e "${GREEN}✓${NC} $1"
    log_message "SUCCESS: $1"
}

# Функция для вывода предупреждения
print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    log_message "WARNING: $1"
}

# Функция для вывода ошибки
print_error() {
    echo -e "${RED}✗${NC} $1"
    log_message "ERROR: $1"
}

# Функция для проверки команды
check_command() {
    if command -v $1 &> /dev/null; then
        print_success "$1 установлен"
        return 0
    else
        print_error "$1 не установлен"
        return 1
    fi
}

# Функция для проверки порта
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_success "Порт $1 открыт и слушает"
        return 0
    else
        print_warning "Порт $1 не используется"
        return 1
    fi
}

# Функция для проверки HTTP сервиса
check_http_service() {
    local url=$1
    local timeout=10
    
    print_warning "Проверка $url ..."
    
    # Проверяем доступность через curl
    if curl --fail --silent --connect-timeout $timeout "$url" > /dev/null 2>&1; then
        local response_time=$(curl -s -o /dev/null -w "%{time_total}" "$url")
        print_success "$url доступен (время ответа: ${response_time}s)"
        log_message "HEALTH_CHECK_OK: $url (response time: ${response_time}s)"
        return 0
    else
        print_error "$url недоступен"
        log_message "HEALTH_CHECK_FAILED: $url"
        return 1
    fi
}

# Функция для вывода справки
show_help() {
    echo "Использование: $0 [URL...]"
    echo ""
    echo "Описание:"
    echo "  Скрипт собирает информацию о сервере и проверяет доступность сервисов."
    echo ""
    echo "Аргументы:"
    echo "  URL       Адреса HTTP сервисов для проверки (например, http://localhost:5000/health)"
    echo ""
    echo "Примеры:"
    echo "  $0                              # Только информация о системе"
    echo "  $0 http://localhost:5000/health # Проверка доступности сервиса"
    echo "  $0 http://localhost:5000/health http://localhost:8080/health"
    echo ""
    echo "Возвращаемые коды:"
    echo "  0 - Все сервисы доступны (или не было указано URL для проверки)"
    echo "  1 - Один или более сервисов недоступны"
    echo ""
    echo "Лог-файл: $LOG_FILE"
    exit 0
}

# Обработка аргументов
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
fi

# Проверяем, переданы ли URL для проверки
SERVICE_URLS=("$@")
SERVICES_TO_CHECK=()

if [ ${#SERVICE_URLS[@]} -gt 0 ]; then
    for url in "${SERVICE_URLS[@]}"; do
        # Базовая валидация URL
        if [[ $url =~ ^https?:// ]]; then
            SERVICES_TO_CHECK+=("$url")
        else
            print_warning "Пропущен некорректный URL: $url (должен начинаться с http:// или https://)"
            log_message "INVALID_URL: $url"
        fi
    done
fi

# Начало логирования
log_message "===== Диагностика сервера начата ====="
log_message "Проверяемые сервисы: ${SERVICES_TO_CHECK[*]:-нет}"

print_header "Диагностика сервера - $(date)"

# 1. Информация о системе
print_header "1. Информация о системе"
echo "Hostname: $(hostname)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"')"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Architecture: $(uname -m)"

# 2. Использование ресурсов
print_header "2. Использование ресурсов"
echo -e "\nCPU использование:"
top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1
echo -e "\nMemory использование:"
free -h | grep "Mem:"
echo -e "\nDisk использование:"
df -h / | tail -1

# 3. Проверка необходимых команд
print_header "3. Проверка необходимых команд"
check_command "docker"
check_command "docker-compose"
check_command "python3"
check_command "pip"
check_command "git"
check_command "ansible"
check_command "curl"

# 4. Проверка Docker
print_header "4. Проверка Docker"
if command -v docker &> /dev/null; then
    echo "Docker версия: $(docker --version)"
    echo "Docker Compose версия: $(docker-compose --version)"
    echo -e "\nЗапущенные контейнеры:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Нет запущенных контейнеров"
    echo -e "\nОбразы Docker:"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null || echo "Нет локальных образов"
fi

# 5. Проверка сети
print_header "5. Проверка сети"
echo "Внешний IP: $(curl -s ifconfig.me 2>/dev/null || echo 'Нет доступа к интернету')"
echo -e "\nАктивные сетевые интерфейсы:"
ip -br addr show | grep -v LOOPBACK || echo "Нет активных интерфейсов"

# 6. Проверка портов
print_header "6. Проверка портов"
check_port 5000
check_port 80
check_port 443
check_port 22

# 7. Проверка Python окружения
print_header "7. Проверка Python окружения"
if command -v python3 &> /dev/null; then
    echo "Python версия: $(python3 --version)"
    echo "Pip версия: $(pip3 --version)"
    echo -e "\nУстановленные пакеты Python:"
    pip3 list 2>/dev/null | grep -E "(fastapi|uvicorn|pydantic)" || echo "Необходимые пакеты не найдены"
fi

# 8. Проверка файлов проекта
print_header "8. Проверка файлов проекта"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "Директория проекта: $PROJECT_DIR"

files_to_check=(
    "app/main.py"
    "app/requirements.txt"
    "app/tests/test_app.py"
    "scripts/server-info.sh"
    "Dockerfile"
    "docker-compose.yml"
    "ansible/playbook.yml"
    ".github/workflows/build.yml"
    "README.md"
    "Makefile"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$PROJECT_DIR/$file" ]; then
        print_success "$file существует"
    else
        print_error "$file не найден"
    fi
done

# 9. Проверка Ansible
print_header "9. Проверка Ansible"
if command -v ansible &> /dev/null; then
    echo "Ansible версия: $(ansible --version | head -1)"
    if [ -f "$PROJECT_DIR/ansible/inventory.ini" ]; then
        echo -e "\nИнвентарь Ansible:"
        cat "$PROJECT_DIR/ansible/inventory.ini"
    fi
fi

# 10. Проверка Git
print_header "10. Проверка Git"
if command -v git &> /dev/null; then
    echo "Git версия: $(git --version)"
    if [ -d "$PROJECT_DIR/.git" ]; then
        echo "Git репозиторий инициализирован"
        echo -e "\nТекущая ветка: $(git branch --show-current)"
        echo -e "\nПоследние коммиты:"
        git log --oneline -5 2>/dev/null
    else
        print_warning "Git репозиторий не инициализирован"
    fi
fi

# 11. Проверка HTTP сервисов (если переданы URL)
if [ ${#SERVICES_TO_CHECK[@]} -gt 0 ]; then
    print_header "11. Проверка доступности HTTP сервисов"
    ALL_SERVICES_OK=true
    
    for url in "${SERVICES_TO_CHECK[@]}"; do
        if ! check_http_service "$url"; then
            ALL_SERVICES_OK=false
        fi
    done
    
    echo ""
    if [ "$ALL_SERVICES_OK" = true ]; then
        print_success "Все сервисы доступны"
        log_message "All services are healthy"
    else
        print_error "Один или более сервисов недоступны"
        log_message "Some services are unhealthy"
    fi
fi

print_header "Диагностика завершена"
echo -e "${GREEN}Все проверки выполнены${NC}"
echo -e "Лог сохранен в: ${YELLOW}$LOG_FILE${NC}"
echo -e "Для запуска приложения используйте: ${YELLOW}make run${NC}"

# Возвращаем exit code в зависимости от состояния сервисов
if [ ${#SERVICES_TO_CHECK[@]} -gt 0 ] && [ "$ALL_SERVICES_OK" = false ]; then
    exit 1
else
    exit 0
fi
