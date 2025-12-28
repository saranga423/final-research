
from fastapi import FastAPI
from app.api import sensor_routes, flower_routes

app = FastAPI(title="Smart Pollination API")

app.include_router(sensor_routes.router, prefix="/api")
app.include_router(flower_routes.router, prefix="/api")

@app.get("/health")
def health():
    return {"status": "ok"}
