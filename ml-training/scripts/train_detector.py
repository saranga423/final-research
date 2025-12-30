"""
YOLOv8 Detection Model Training Script
Trains a YOLOv8 object detection model for pumpkin flower localization
"""

import argparse
import yaml
from pathlib import Path
from ultralytics import YOLO
import torch

def load_config(config_path):
    """Load training configuration from YAML file"""
    with open(config_path, 'r') as f:
        return yaml.safe_load(f)

def train_detector(config_path, data_yaml_path, output_dir='models/detector'):
    """
    Train YOLOv8 detection model
    
    Args:
        config_path: Path to detector_config.yaml
        data_yaml_path: Path to dataset.yaml (YOLO format)
        output_dir: Output directory for trained models
    """
    config = load_config(config_path)
    
    # Create output directory
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    # Load YOLOv8 model
    print(f"Loading YOLOv8 model: {config['model_size']}")
    model = YOLO(f"yolov8{config['model_size']}.pt")
    
    # Check GPU availability
    device = 0 if torch.cuda.is_available() else 'cpu'
    print(f"Using device: {'GPU' if device == 0 else 'CPU'}")
    
    # Train the model
    print("Starting training...")
    results = model.train(
        data=data_yaml_path,
        epochs=config['epochs'],
        imgsz=config['img_size'],
        batch=config['batch_size'],
        patience=config['patience'],
        device=device,
        project=output_dir,
        name='flower_detector',
        exist_ok=True,
        
        # Optimization settings
        optimizer=config.get('optimizer', 'SGD'),
        lr0=config.get('lr0', 0.01),
        lrf=config.get('lrf', 0.01),
        momentum=config.get('momentum', 0.937),
        weight_decay=config.get('weight_decay', 0.0005),
        
        # Augmentation settings
        mosaic=config.get('mosaic', 1.0),
        mixup=config.get('mixup', 0.0),
        flipud=config.get('flipud', 0.5),
        fliplr=config.get('fliplr', 0.5),
        hsv_h=config.get('hsv_h', 0.015),
        hsv_s=config.get('hsv_s', 0.7),
        hsv_v=config.get('hsv_v', 0.4),
        degrees=config.get('degrees', 0.0),
        translate=config.get('translate', 0.1),
        scale=config.get('scale', 0.5),
        
        # Validation and saving
        save=True,
        save_period=10,
        val=True,
        plots=True,
        verbose=config.get('verbose', True),
    )
    
    print(f"Training completed!")
    print(f"Best model saved to: {output_dir}/flower_detector/weights/best.pt")
    print(f"Last model saved to: {output_dir}/flower_detector/weights/last.pt")
    
    return results

def validate_detector(model_path, data_yaml_path):
    """
    Validate detection model performance
    
    Args:
        model_path: Path to trained model (best.pt)
        data_yaml_path: Path to dataset.yaml
    """
    print(f"Loading model: {model_path}")
    model = YOLO(model_path)
    
    print("Running validation...")
    metrics = model.val(data=data_yaml_path)
    
    print("\n=== Detection Model Validation Results ===")
    print(f"mAP@0.5: {metrics.box.map50:.4f}")
    print(f"mAP@0.5-0.95: {metrics.box.map:.4f}")
    print(f"Precision: {metrics.box.mp:.4f}")
    print(f"Recall: {metrics.box.mr:.4f}")
    
    return metrics

def test_detector(model_path, test_image_path):
    """
    Test model on a single image
    
    Args:
        model_path: Path to trained model
        test_image_path: Path to test image
    """
    model = YOLO(model_path)
    
    print(f"Running inference on: {test_image_path}")
    results = model.predict(
        source=test_image_path,
        conf=0.5,  # Confidence threshold
        iou=0.45,  # NMS IOU threshold
        imgsz=640,
        verbose=True
    )
    
    return results

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Train YOLOv8 Detection Model")
    parser.add_argument('--config', type=str, default='configs/detector_config.yaml',
                        help='Path to detector configuration file')
    parser.add_argument('--data', type=str, default='data/detection/dataset.yaml',
                        help='Path to dataset.yaml file')
    parser.add_argument('--output-dir', type=str, default='models/detector',
                        help='Output directory for trained models')
    parser.add_argument('--validate', action='store_true', 
                        help='Validate existing model')
    parser.add_argument('--model', type=str, default=None,
                        help='Path to trained model (for validation/testing)')
    parser.add_argument('--test-image', type=str, default=None,
                        help='Path to test image for inference')
    
    args = parser.parse_args()
    
    if args.validate and args.model:
        validate_detector(args.model, args.data)
    elif args.test_image and args.model:
        test_detector(args.model, args.test_image)
    else:
        train_detector(args.config, args.data, args.output_dir)
