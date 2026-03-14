.PHONY: help run test lint docker-build docker-up docker-down docker-clean ansible-deploy ansible-docker ansible-app clean install

# Default target
help:
	@echo "DevOps Task API - доступные команды:"
	@echo ""
	@echo "  make run              - Запуск приложения в development режиме"
	@echo "  make test             - Запуск тестов"
	@echo "  make lint             - Проверка кода линтером"
	@echo "  make install          - Установка зависимостей"
	@echo ""
	@echo "Docker команды:"
	@echo "  make docker-build     - Сборка Docker образа"
	@echo "  make docker-up        - Запуск контейнеров через docker-compose"
	@echo "  make docker-down      - Остановка контейнеров"
	@echo "  make docker-logs      - Просмотр логов контейнеров"
	@echo "  make docker-clean     - Очистка Docker ресурсов"
	@echo ""
	@echo "Ansible команды:"
	@echo "  make ansible-deploy   - Полное развертывание через Ansible"
	@echo "  make ansible-docker   - Установка только Docker через Ansible"
	@echo "  make ansible-app      - Развертывание только приложения"
	@echo ""
	@echo "Утилиты:"
	@echo "  make server-info      - Запуск скрипта диагностики"
	@echo "  make clean            - Очистка временных файлов"
	@echo "  make reset            - Полная очистка и пересборка"

# Запуск приложения
run:
	@echo "Запуск приложения..."
	cd app && pip install -r requirements.txt && uvicorn main:app --host 0.0.0.0 --port 5000 --reload

# Запуск тестов
test:
	@echo "Запуск тестов..."
	cd app && python -m pytest tests/test_app.py -v

# Линтинг кода
lint:
	@echo "Проверка кода..."
	cd app && pip install flake8 && flake8 main.py --max-line-length=100

# Установка зависимостей
install:
	@echo "Установка зависимостей..."
	pip install --upgrade pip
	cd app && pip install -r requirements.txt

# Docker команды
docker-build:
	@echo "Сборка Docker образа..."
	docker build -t devops-task-api:latest .

docker-up:
	@echo "Запуск контейнеров..."
	docker-compose up -d

docker-down:
	@echo "Остановка контейнеров..."
	docker-compose down

docker-logs:
	@echo "Просмотр логов..."
	docker-compose logs -f

docker-clean:
	@echo "Очистка Docker ресурсов..."
	docker-compose down -v
	docker rmi devops-task-api:latest 2>/dev/null || true

# Ansible команды
ansible-deploy:
	@echo "Развертывание через Ansible..."
	ansible-playbook -i ansible/inventory.ini ansible/playbook.yml

ansible-docker:
	@echo "Установка Docker через Ansible..."
	ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --tags docker

ansible-app:
	@echo "Развертывание приложения через Ansible..."
	ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --tags app

# Утилиты
server-info:
	@echo "Запуск диагностики сервера..."
	@bash scripts/server-info.sh

clean:
	@echo "Очистка временных файлов..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type f -name ".coverage" -delete 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".coverage" -exec rm -rf {} + 2>/dev/null || true
	@echo "Очистка завершена"

reset: clean docker-clean
	@echo "Полный сброс проекта..."
	docker system prune -af 2>/dev/null || true
	@echo "Сброс завершен. Используйте 'make docker-up' для перезапуска."

# Проверка статуса
status:
	@echo "Проверка статуса контейнеров..."
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Контейнеры не запущены"
	@echo ""
	@echo "Проверка здоровья приложения..."
	@curl -s http://localhost:5000/health 2>/dev/null || echo "Приложение не доступно на порту 5000"

# Быстрая настройка
setup: install
	@echo "Настройка проекта завершена!"
	@echo "Используйте 'make run' для запуска приложения"
