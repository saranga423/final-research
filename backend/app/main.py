from fastapi import FastAPI
from app.api import auth, sensor, readiness, image

app = FastAPI(
    title="PolliCare Backend API",
    version="1.0.0",
    description="Backend for Smart Pollination Assistant"
)

app.include_router(auth.router, prefix="/auth", tags=["Auth"])
app.include_router(sensor.router, prefix="/sensor", tags=["Sensor"])
app.include_router(readiness.router, prefix="/readiness", tags=["Pollination"])
app.include_router(image.router, prefix="/image", tags=["Image"])

@app.get("/")
def root():
    return {"status": "Backend running"}
