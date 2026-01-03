from fastapi import APIRouter

router = APIRouter()

@router.post("/login")
def login():
    return {"token": "dummy-jwt-token"}
@router.post("/register")
def register():
    return {"message": "User registered successfully"}
@router.get("/status")
def auth_status():
    return {"status": "Auth API is operational"}
  