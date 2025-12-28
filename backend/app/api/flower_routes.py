
from fastapi import APIRouter, UploadFile, File
from app.services.prediction_service import predict

router = APIRouter()

@router.post("/predict-flower")
async def predict_flower(file: UploadFile = File(...)):
    image_path = f"/tmp/{file.filename}"
    with open(image_path, "wb") as f:
        f.write(await file.read())
    prediction = predict(image_path)
    return {"prediction": prediction}
