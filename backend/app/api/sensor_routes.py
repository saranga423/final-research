
from fastapi import APIRouter
from pydantic import BaseModel
from datetime import datetime

router = APIRouter()

class SensorPayload(BaseModel):
    temperature: float
    humidity: float
    light: float
    soil_moisture: float

@router.post("/ingest-sensor")
def ingest_sensor(data: SensorPayload):
    record = data.dict()
    record["timestamp"] = datetime.utcnow()
    # Here you would store to MongoDB
    return {"status": "stored", "data": record}
