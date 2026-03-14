import pytest
from httpx import AsyncClient
from app.main import app

@pytest.mark.asyncio
async def test_read_root():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/")
        assert response.status_code == 200
        assert "message" in response.json()

@pytest.mark.asyncio
async def test_health_check():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "ok"

@pytest.mark.asyncio
async def test_get_users():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/api/users")
        assert response.status_code == 200
        assert len(response.json()) >= 2

@pytest.mark.asyncio
async def test_get_user():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/api/users/1")
        assert response.status_code == 200
        assert response.json()["id"] == 1
        assert response.json()["name"] == "Alex"

@pytest.mark.asyncio
async def test_get_user_not_found():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/api/users/999")
        assert response.status_code == 404

@pytest.mark.asyncio
async def test_create_user():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        new_user = {"id": 3, "name": "Charlie"}
        response = await ac.post("/api/users", json=new_user)
        assert response.status_code == 200
        assert response.json()["id"] == 3
        assert response.json()["name"] == "Charlie"

@pytest.mark.asyncio
async def test_create_duplicate_user():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        duplicate_user = {"id": 1, "name": "Alex"}
        response = await ac.post("/api/users", json=duplicate_user)
        assert response.status_code == 400

@pytest.mark.asyncio
async def test_update_user():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        updated_user = {"id": 2, "name": "Boris Updated"}
        response = await ac.put("/api/users/2", json=updated_user)
        assert response.status_code == 200
        assert response.json()["name"] == "Boris Updated"

@pytest.mark.asyncio
async def test_delete_user():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.delete("/api/users/3")
        assert response.status_code == 200
        assert "deleted" in response.json()["message"]
