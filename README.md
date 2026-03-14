# DevOps Task API

Полнофункциональный REST API для задачи DevOps с полным циклом CI/CD, контейнеризацией и автоматизацией развертывания.

## 📋 Содержание

- [О проекте](#о-проекте)
- [Технологический стек](#технологический-стек)
- [Структура проекта](#структура-проекта)
- [Быстрый старт](#быстрый-старт)
- [Развертывание](#развертывание)
- [API Documentation](#api-documentation)
- [Тестирование](#тестирование)
- [CI/CD](#cicd)
- [Мониторинг и диагностика](#мониторинг-и-диагностика)
- [Вклад в проект](#вклад-в-проект)

## 🎯 О проекте

DevOps Task API - это учебный проект, демонстрирующий полный цикл разработки и развертывания современного REST API с использованием:

- **FastAPI** - современный веб-фреймворк для Python
- **Docker** - контейнеризация приложения
- **Docker Compose** - оркестрация контейнеров
- **Ansible** - автоматизация развертывания
- **GitHub Actions** - CI/CD пайплайн
- **Make** - управление задачами

## 🛠️ Технологический стек

| Технология | Версия | Назначение |
|------------|--------|------------|
| Python | 3.11+ | Язык программирования |
| FastAPI | 0.104+ | REST API фреймворк |
| Uvicorn | 0.24+ | ASGI сервер |
| Docker | latest | Контейнеризация |
| Docker Compose | v2+ | Оркестрация |
| Ansible | 2.9+ | Автоматизация |
| Pytest | 7.4+ | Тестирование |
| GitHub Actions | - | CI/CD |

## 📁 Структура проекта

```
.
├── app/                      # Python приложение
│   ├── main.py              # Основной файл FastAPI приложения
│   ├── requirements.txt      # Зависимости Python
│   └── tests/
│       └── test_app.py       # Тесты REST API
├── scripts/                  # Bash скрипты
│   └── server-info.sh        # Скрипт диагностики сервера
├── ansible/                  # Ansible конфигурация
│   ├── playbook.yml          # Основной playbook
│   ├── inventory.ini         # Инвентарь хостов
│   └── roles/
│       ├── docker/           # Роль установки Docker
│       │   └── tasks/main.yml
│       └── app/              # Роль развертывания приложения
│           └── tasks/main.yml
├── .github/
│   └── workflows/
│       └── build.yml         # GitHub Actions CI/CD
├── Dockerfile                # Docker образ
├── docker-compose.yml        # Docker Compose конфигурация
├── Makefile                  # Make команды
└── README.md                 # Документация
```

## 🚀 Быстрый старт

### Предварительные требования

- Python 3.11+
- Docker & Docker Compose
- Make (опционально)

### Локальный запуск

1. **Клонируйте репозиторий:**
```bash
git clone <repository-url>
cd tasks_Devops
```

2. **Установите зависимости:**
```bash
pip install -r app/requirements.txt
```

3. **Запустите приложение:**
```bash
cd app
uvicorn main:app --host 0.0.0.0 --port 5000 --reload
```

Или используйте Make:
```bash
make run
```

4. **Откройте в браузере:**
- API: http://localhost:5000
- Документация (Swagger UI): http://localhost:5000/docs
- ReDoc: http://localhost:5000/redoc

## 🐳 Развертывание

### С помощью Docker Compose

```bash
# Сборка и запуск
docker-compose up -d

# Просмотр логов
docker-compose logs -f

# Остановка
docker-compose down

# Запуск тестов
docker-compose run test
```

### С помощью Ansible

```bash
# Установка и настройка на целевом хосте
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml

# С указанием пользователя
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --ask-become-pass
```

## 📚 API Documentation

### Endpoints

| Метод | Путь | Описание |
|-------|------|----------|
| GET | `/` | Корневой эндпоинт |
| GET | `/health` | Проверка здоровья сервиса |
| GET | `/api/users` | Получить всех пользователей |
| GET | `/api/users/{id}` | Получить пользователя по ID |
| POST | `/api/users` | Создать нового пользователя |
| PUT | `/api/users/{id}` | Обновить пользователя |
| DELETE | `/api/users/{id}` | Удалить пользователя |

### Примеры запросов

**Получить всех пользователей:**
```bash
curl http://localhost:5000/api/users
```

**Создать пользователя:**
```bash
curl -X POST "http://localhost:8000/api/users" \
  -H "Content-Type: application/json" \
  -d '{"id": 3, "name": "Charlie"}'
```

**Проверка здоровья:**
```bash
curl http://localhost:5000/health
```

## 🧪 Тестирование

### Локальные тесты

```bash
cd app
python -m pytest tests/test_app.py -v
```

### Тесты через Docker

```bash
docker-compose run test
```

### Покрытие тестами

Проект включает полный набор тестов:
- ✅ Тесты CRUD операций
- ✅ Тесты обработки ошибок
- ✅ Тесты валидации данных
- ✅ Тесты health check

## 🔄 CI/CD

### GitHub Actions Workflow

Workflow состоит из трех этапов:

1. **Test** - запуск тестов и линтинг
2. **Build** - сборка Docker образа
3. **Deploy** - деплой на продакшен (только для main ветки)

### Запуск workflow

Workflow автоматически запускается при:
- Push в ветки `main` или `develop`
- Pull Request в ветку `main`

### Мониторинг статуса

Статус workflow отображается на странице репозитория:
- ✅ Все этапы пройдены
- ❌ Ошибка на одном из этапов
- ⏳ В процессе выполнения

## 🔧 Makefile команды

| Команда | Описание |
|---------|----------|
| `make run` | Запуск приложения в development режиме |
| `make test` | Запуск тестов |
| `make lint` | Проверка кода линтером |
| `make docker-build` | Сборка Docker образа |
| `make docker-up` | Запуск через Docker Compose |
| `make docker-down` | Остановка контейнеров |
| `make ansible-deploy` | Развертывание через Ansible |
| `make clean` | Очистка артефактов |
| `make help` | Показать все команды |

## 🩺 Мониторинг и диагностика

### Bash скрипт диагностики

Скрипт `scripts/server-info.sh` предоставляет полную информацию о системе:

```bash
# Запуск диагностики
./scripts/server-info.sh
```

Скрипт проверяет:
- ✅ Информацию о системе
- ✅ Использование ресурсов (CPU, Memory, Disk)
- ✅ Установленные инструменты (Docker, Python, Ansible)
- ✅ Статус портов
- ✅ Запущенные контейнеры
- ✅ Файлы проекта
- ✅ Git статус

## 📊 API Endpoints

### Полный список эндпоинтов

```
GET    /                    # Корневой эндпоинт
GET    /health              # Health check
GET    /api/users           # Получить всех пользователей
GET    /api/users/{id}      # Получить пользователя по ID
POST   /api/users           # Создать пользователя
PUT    /api/users/{id}      # Обновить пользователя
DELETE /api/users/{id}      # Удалить пользователя
```

### Модель данных

```json
{
  "id": 1,
  "name": "Alex"
}
```

## 🔒 Безопасность

- ✅ Валидация входных данных через Pydantic
- ✅ Обработка ошибок с корректными HTTP статусами
- ✅ Docker изоляция контейнеров
- ✅ Минимальные права в контейнерах

## 📈 Масштабирование

Проект готов к масштабированию:

1. **Горизонтальное масштабирование:**
   - Настройка реплика в docker-compose.yml
   - Load balancer (Nginx, Traefik)

2. **Вертикальное масштабирование:**
   - Увеличение ресурсов контейнера
   - Оптимизация приложения

3. **Кластерное развертывание:**
   - Kubernetes манифесты
   - Helm charts

## 🤝 Вклад в проект

1. Fork репозитория
2. Создайте feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit изменения (`git commit -m 'Add some AmazingFeature'`)
4. Push в branch (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

## 📝 Лицензия

Это учебный проект. Используйте свободно.

## 👨‍💻 Автор

DevOps Task API - учебный проект для демонстрации современных практик DevOps.

---

**Примечание:** Этот проект создан в образовательных целях и демонстрирует полный цикл разработки, тестирования и развертывания REST API с использованием современных DevOps инструментов.
