
from ultralytics import YOLO

def train():
    model = YOLO("yolov8n.pt")
    model.train(
        data="dataset/pumpkin_flower.yaml",
        epochs=50,
        imgsz=640,
        batch=16
    )

if __name__ == "__main__":
    train()
