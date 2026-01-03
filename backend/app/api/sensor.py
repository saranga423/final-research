from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

class SensorPayload(BaseModel):
    temperature: float
    humidity: float
    light: float

@router.post("/ingest")
def ingest_sensor_data(data: SensorPayload):
    return {"message": "Sensor data received", "data": data}
@router.get("/status")
def sensor_status():
    return {"status": "Sensor API is operational"}
  