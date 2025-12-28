
from ultralytics import YOLO

model = YOLO("ml_models/yolo/weights/best.pt")

def predict(image_path: str):
    results = model(image_path)
    return results[0].boxes.cls.tolist()
