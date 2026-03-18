# simple-app

**simple-app** — REST API приложение для управления пользователями, разработанное с использованием FastAPI. Проект включает полную DevOps инфраструктуру: Docker, Docker Compose, Ansible развертывание, bash-скрипты диагностики и автоматизацию через Makefile.

## Требования

- **Python**: 3.12+
- **Docker**: последняя стабильная версия
- **Docker Compose**: последняя стабильная версия
- **Ansible**: 2.9+
- **Make** (опционально, для использования Makefile)

## Быстрый старт

### Локальный запуск приложения

1. Установка зависимостей:
```bash
pip install -r app/requirements.txt
```

2. Запуск приложения:
```bash
python app/main.py
```

Или с использованием виртуального окружения:
```bash
cd app
python3 -m venv .venv
source .venv/bin/activate  # Linux/Mac
# или .venv\Scripts\activate  # Windows
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 5000 --reload
```

Приложение будет доступно по адресу: http://localhost:5000

### Запуск через Docker Compose

1. Сборка и запуск контейнеров:
```bash
docker-compose up -d
```

2. Проверка статуса:
```bash
docker-compose ps
```

3. Просмотр логов:
```bash
docker-compose logs -f
```

4. Остановка:
```bash
docker-compose down
```

Приложение будет доступно по адресу: http://localhost:5000

## API Endpoints

### 1. Корневой эндпоинт

**GET /** - Приветственное сообщение

**Пример curl:**
```bash
curl http://localhost:5000/
```

**Ответ:**
```json
{
  "message": "Hello, World!"
}
```

### 2. Health Check

**GET /health** - Проверка здоровья приложения

**Пример curl:**
```bash
curl http://localhost:5000/health
```

**Ответ:**
```json
{
  "status": "ok"
}
```

### 3. Получение списка пользователей

**GET /api/users** - Возвращает всех пользователей

**Пример curl:**
```bash
curl http://localhost:5000/api/users
```

**Ответ:**
```json
{
  "users": [
    {"id": 1, "name": "Alex"},
    {"id": 2, "name": "Boris"}
  ]
}
```

### 4. Получение пользователя по ID

**GET /api/users/{user_id}** - Возвращает конкретного пользователя

**Пример curl:**
```bash
curl http://localhost:5000/api/users/1
```

**Ответ (успех):**
```json
{
  "id": 1,
  "name": "Alex"
}
```

**Ответ (ошибка 404):**
```json
{
  "detail": "User not found"
}
```

### 5. Создание пользователя

**POST /api/users** - Создает нового пользователя

**Пример curl:**
```bash
curl -X POST http://localhost:5000/api/users \
  -H "Content-Type: application/json" \
  -d '{"id": 3, "name": "Charlie"}'
```

**Ответ (успех, 201):**
```json
{
  "id": 3,
  "name": "Charlie"
}
```

**Ответ (ошибка 400 - пользователь уже существует):**
```json
{
  "detail": "User with this ID already exists"
}
```

### 6. Удаление пользователя

**DELETE /api/users/{user_id}** - Удаляет пользователя

**Пример curl:**
```bash
curl -X DELETE http://localhost:5000/api/users/3
```

**Ответ (успех):**
```json
{
  "message": "User 3 deleted",
  "user": {"id": 3, "name": "Charlie"}
}
```

**Ответ (ошибка 404):**
```json
{
  "detail": "User not found"
}
```

### Автодокументация Swagger

Интерактивная документация API доступна по адресу: http://localhost:5000/docs

## Bash-скрипт

### server-info.sh - Скрипт диагностики сервера

Скрипт собирает подробную информацию о системе и проверяет доступность сервисов.

**Описание:**
- Информация о системе (OS, ядро, хостнейм, аптайм, архитектура)
- Использование ресурсов (CPU, Memory, Disk)
- Проверка наличия необходимых команд (docker, python, ansible и др.)
- Информация о Docker (версии, запущенные контейнеры, образы)
- Проверка сетевых интерфейсов и портов
- Проверка Python окружения
- Проверка доступности HTTP сервисов

**Использование:**

Только системная информация:
```bash
./scripts/server-info.sh
```

С проверкой HTTP сервисов:
```bash
./scripts/server-info.sh http://localhost:5000/health
```

С проверкой нескольких сервисов:
```bash
./scripts/server-info.sh http://localhost:5000/health http://localhost:5000/docs
```

**Параметры:**
- `--help` или `-h` - показать справку

**Возвращаемые коды:**
- `0` - Все сервисы доступны (или не указано URL для проверки)
- `1` - Один или более сервисов недоступны

**Лог-файл:**
Скрипт сохраняет подробный лог в `/tmp/server-info-YYYYMMDD-HHMMSS.log`

## Тестирование

### Запуск тестов локально

1. Установите зависимости (если не установлены):
```bash
pip install -r app/requirements.txt
```

2. Запустите тесты:
```bash
pytest app/tests/test_app.py -v
```

Или с использованием Makefile:
```bash
make test
```

### Запуск тестов через Docker

```bash
docker-compose up test
```

Или:
```bash
docker-compose run --rm test
```

Тесты покрывают:
- Корневой эндпоинт
- Health check
- Получение списка пользователей
- Получение пользователя по ID
- Получение несуществующего пользователя (404)
- Создание пользователя
- Создание дубликата пользователя (400)
- Удаление пользователя

## Ansible развертывание

### Структура Ansible

```
ansible/
├── inventory.ini          # Инвентарь хостов
├── playbook.yml           # Основной playbook
└── roles/
    ├── docker/           # Роль установки Docker
    │   └── tasks/
    │       └── main.yml
    └── app/              # Роль развертывания приложения
        └── tasks/
            └── main.yml
```

### Подготовка инвентаря

Отредактируйте `ansible/inventory.ini`:

```ini
[webservers]
app-server-1 ansible_host=ВАШ_IP ansible_user=ВАШ_ПОЛЬЗОВАТЕЛЬ
```

### Запуск развертывания

1. Проверка синтаксиса playbook:
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --syntax-check
```

2. Dry-run (проверка без внесения изменений):
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --check
```

3. Полное развертывание:
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

Или с использованием Makefile:
```bash
make ansible-run
```

### Что делает Ansible:

1. **Роль docker**:
   - Устанавливает Docker и Docker Compose
   - Настраивает службу Docker
   - Добавляет пользователя в группу docker

2. **Роль app**:
   - Создает директорию `/opt/simple-app`
   - Копирует файлы приложения на сервер
   - Собирает Docker образ
   - Запускает контейнеры через docker-compose
   - Проверяет здоровье приложения

### Требования к целевому серверу

- Ubuntu/Debian (поддерживаются другие дистрибутивы с адаптацией)
- SSH доступ
- Sudo права для пользователя
- Подключение к интернету (для загрузки пакетов)

## Структура проекта

```
simple-app/
├── .dockerignore              # Игнорируемые файлы для Docker
├── .gitignore                 # Игнорируемые файлы для Git
├── README.md                  # Эта документация
├── Dockerfile                 # Docker образ приложения
├── docker-compose.yml         # Docker Compose конфигурация
├── prometheus.yml             # Конфигурация Prometheus
├── Makefile                   # Make цели для автоматизации
│
├── app/                       # Исходный код приложения
│   ├── __init__.py
│   ├── main.py               # FastAPI приложение
│   ├── requirements.txt      # Python зависимости
│   └── tests/
│       ├── __init__.py
│       └── test_app.py       # Тесты
│
├── grafana/                   # Конфигурация Grafana
│   └── provisioning/
│       ├── datasources/
│       │   └── prometheus.yml   # Автоматическая настройка datasource
│       └── dashboards/
│           ├── dashboard.yml    # Конфигурация папки dashboards
│           └── simple-app-dashboard.json  # Готовый дашборд
│
├── ansible/                   # Ansible конфигурация
│   ├── inventory.ini          # Инвентарь хостов
│   ├── playbook.yml           # Основной playbook
│   └── roles/
│       ├── docker/            # Роль установки Docker
│       │   └── tasks/
│       │       └── main.yml
│       └── app/               # Роль развертывания приложения
│           └── tasks/
│               └── main.yml
│
└── scripts/                   # Bash скрипты
    └── server-info.sh         # Скрипт диагностики сервера
```

## Makefile команды

Для удобства проект включает Makefile с готовыми командами:

### Основные команды
- `make help` - показать все доступные команды
- `make run` - запуск приложения в development режиме
- `make test` - запуск тестов
- `make lint` - проверка кода (flake8 + shellcheck)
- `make install` - установка зависимостей

### Docker команды
- `make docker-build` - сборка Docker образа
- `make docker-run` - запуск контейнера через docker
- `make compose-up` - запуск через docker-compose
- `make compose-down` - остановка контейнеров
- `make compose-logs` - просмотр логов
- `make docker-clean` - очистка Docker ресурсов

### Ansible команды
- `make ansible-check` - проверка синтаксиса playbook
- `make ansible-dry` - dry-run Ansible
- `make ansible-run` - запуск playbook

### Утилиты
- `make server-info` - запуск скрипта диагностики
- `make clean` - очистка временных файлов
- `make reset` - полная очистка и пересборка
- `make status` - проверка статуса контейнеров и приложения
- `make setup` - быстрая настройка проекта

## Troubleshooting

### Проблема: Port 5000 already in use

**Симптомы:**
```
Error: Failed to start application: port is already allocated
```

**Решение:**
1. Найдите процесс, использующий порт:
```bash
lsof -i :5000
```

2. Остановите процесс:
```bash
kill -9 <PID>
```

Или измените порт в `docker-compose.yml` и `Dockerfile`:
```yaml
ports:
  - "5001:5000"  # хост:контейнер
```

### Проблема: Docker permission denied

**Симптомы:**
```
Got permission denied while trying to connect to the Docker daemon socket
```

**Решение:**
1. Добавьте пользователя в группу docker:
```bash
sudo usermod -aG docker $USER
```

2. Перезайдите в систему или выполните:
```bash
newgrp docker
```

### Проблема: Ansible connection failed

**Симптомы:**
```
UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh"}
```

**Решение:**
1. Проверьте SSH подключение:
```bash
ssh ВАШ_ПОЛЬЗОВАТЕЛЬ@ВАШ_IP
```

2. Убедитесь, что в `ansible/inventory.ini` указаны правильные:
   - `ansible_host` - IP адрес сервера
   - `ansible_user` - пользователь с sudo правами

3. Проверьте, что на сервере установлен Python:
```bash
ansible all -i ansible/inventory.ini -m raw -a "python3 --version"
```

### Проблема: Tests fail with connection errors

**Симптомы:**
```
requests.exceptions.ConnectionError
```

**Решение:**
Убедитесь, что приложение запущено перед выполнением тестов:
```bash
make run
# или
docker-compose up -d
```

### Проблема: Docker build fails

**Симптомы:**
```
ERROR: failed to solve: ...
```

**Решение:**
1. Очистите Docker кэш:
```bash
docker system prune -af
```

2. Пересоберите образ:
```bash
make docker-build
# или
docker-compose build --no-cache
```

### Проблема: Health check fails in Ansible

**Симптомы:**
```
FAILED! => {"changed": false, "msg": "Status code was 404 and not 200"}
```

**Решение:**
1. Проверьте, что контейнер запущен:
```bash
docker-compose ps
```

2. Проверьте логи:
```bash
docker-compose logs app
```

3. Убедитесь, что порт 5000 открыт и приложение слушает на 0.0.0.0

### Проблема: Bash script shows colored output incorrectly

**Симптомы:**
Отображаются escape-последовательности вместо цветов

**Решение:**
Скрипт автоматически определяет поддержку цветов. Если проблема persists, принудительно отключите цвета:
```bash
# Редактируйте скрипт, закомментируйте переменные цветов
# RED='\033[0;31m' -> #RED='\033[0;31m'
```

### Проблема: Python dependencies conflict

**Симптомы:**
```
ERROR: Cannot install -r app/requirements.txt (line 1) and ...
```

**Решение:**
1. Очистите кэш pip:
```bash
pip cache purge
```

2. Используйте виртуальное окружение:
```bash
make clean
make install
```

### Проблема: Make commands not found

**Симптомы:**
```
make: command not found
```

**Решение:**
Установите make:
- Ubuntu/Debian: `sudo apt-get install build-essential`
- CentOS/RHEL: `sudo yum groupinstall "Development Tools"`
- macOS: `xcode-select --install`

### Проблема: Slow Docker builds

**Решение:**
1. Используйте multi-stage builds (не реализовано в текущем проекте)
2. Кэшируйте зависимости - Dockerfile уже оптимизирован для кэширования слоя pip
3. Используйте docker-compose build с опцией `--parallel`

### Проверка работоспособности

После развертывания проверьте:

1. Приложение отвечает:
```bash
curl http://localhost:5000/health
```

2. API доступен:
```bash
curl http://localhost:5000/api/users
```

3. Docker контейнеры работают:
```bash
docker-compose ps
```

4. Ansible развертывание успешно:
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

## Дополнительная информация

### Версии компонентов

- **FastAPI**: 0.104.1
- **Uvicorn**: 0.24.0
- **Pydantic**: 2.5.0
- **Python**: 3.12+

### Безопасность

- Приложение запускается с `PYTHONUNBUFFERED=1` для корректного логирования
- Docker образ использует slim-версию Python для уменьшения размера
- Health check реализован для мониторинга состояния

### Мониторинг

- Health endpoint: `GET /health`
- Prometheus метрики: `GET /metrics`
- Логи Docker: `docker-compose logs -f`
- Логи приложения: `docker-compose logs app`

#### Prometheus + Grafana

Проект включает полноценный стек мониторинга:

**Запуск мониторинга:**
```bash
docker-compose up -d prometheus grafana
```

**Доступные эндпоинты:**
- **Prometheus**: http://localhost:9090
  - Проверка targets: `Status` → `Targets`
  - Запросы метрик: `http://localhost:9090/graph`
- **Grafana**: http://localhost:3000
  - Логин: `admin`, пароль: `admin`
  - Datasource Prometheus настраивается автоматически через provisioning
  - Дашборд "Simple App Monitoring" загружается автоматически

**Доступные метрики:**
- `http_requests_total` - счетчик HTTP запросов
- `http_request_duration_seconds` - гистограмма времени ответа
- `process_cpu_seconds_total` - использование CPU
- `process_resident_memory_bytes` - использование памяти
- `python_info` - информация о Python

**Структура provisioning:**
```
grafana/provisioning/
├── datasources/prometheus.yml   # Автоматическая настройка datasource
└── dashboards/
    ├── dashboard.yml            # Конфигурация папки dashboards
    └── simple-app-dashboard.json  # Дашборд с метриками
```

### Разработка

Для разработки рекомендуется:
1. Использовать `uvicorn main:app --reload` для автоматической перезагрузки
2. Запускать тесты при каждом коммите
3. Использовать pre-commit хуки для линтинга
4. Проверять код через `make lint`

## Контакты и поддержка

Для вопросов и предложений создайте issue в репозитории проекта.

---

**Лицензия**: MIT

**Автор**: gorodkovden

**Версия**: 1.0.0
