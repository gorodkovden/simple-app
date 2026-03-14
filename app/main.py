from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
import uvicorn


app = FastAPI(title="DevOps Task API", version="1.0.0")


# Модель данных
class User(BaseModel):
    id: int
    name: str = None


# Хранилище в памяти (для демонстрации)
users_db: List[User] = [
    User(id=1, name="Alex"),
    User(id=2, name="Boris"),
]


@app.get("/")
def hello():
    return {"message": "Hello, World!"}


@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.get("/api/users", response_model=List[User])
def get_users():
    return users_db


@app.get("/api/users/{user_id}", response_model=User)
def get_user(user_id: int):
    for user in users_db:
        if user.id == user_id:
            return user
    raise HTTPException(status_code=404, detail="User not found")


@app.post("/api/users", response_model=User)
def create_user(user: User):
    for existing_user in users_db:
        if existing_user.id == user.id:
            raise HTTPException(status_code=400, detail="User with this ID already exists")
    users_db.append(user)
    return user


@app.put("/api/users/{user_id}", response_model=User)
def update_user(user_id: int, user: User):
    for idx, existing_user in enumerate(users_db):
        if existing_user.id == user_id:
            users_db[idx] = user
            return user
    raise HTTPException(status_code=404, detail="User not found")


@app.delete("/api/users/{user_id}")
def delete_user(user_id: int):
    for idx, user in enumerate(users_db):
        if user.id == user_id:
            deleted_user = users_db.pop(idx)
            return {"message": f"User {user_id} deleted", "user": deleted_user}
    raise HTTPException(status_code=404, detail="User not found")


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=5000)
