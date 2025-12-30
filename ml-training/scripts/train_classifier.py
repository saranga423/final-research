"""
YOLOv8 Classification Model Training Script
Trains a YOLOv8 classification model for flower receptivity assessment
Classes: bud, open, post-pollination
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

def train_classifier(config_path, data_dir, output_dir='models/classifier'):
    """
    Train YOLOv8 classification model
    
    Args:
        config_path: Path to classifier_config.yaml
        data_dir: Path to dataset directory with train/val subdirectories
        output_dir: Output directory for trained models
    """
    config = load_config(config_path)
    
    # Create output directory
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    # Load YOLOv8 classification model
    print(f"Loading YOLOv8 classification model: {config['model_size']}")
    model = YOLO(f"yolov8{config['model_size']}-cls.pt")
    
    # Check GPU availability
    device = 0 if torch.cuda.is_available() else 'cpu'
    print(f"Using device: {'GPU' if device == 0 else 'CPU'}")
    
    # Train the model
    print("Starting classification training...")
    results = model.train(
        data=data_dir,
        epochs=config['epochs'],
        imgsz=config['img_size'],
        batch=config['batch_size'],
        patience=config['patience'],
        device=device,
        project=output_dir,
        name='flower_classifier',
        exist_ok=True,
        
        # Optimization settings
        optimizer=config.get('optimizer', 'Adam'),
        lr0=config.get('lr0', 0.001),
        lrf=config.get('lrf', 0.01),
        weight_decay=config.get('weight_decay', 0.0005),
        
        # Augmentation settings for classification
        flipud=config.get('flipud', 0.5),
        fliplr=config.get('fliplr', 0.5),
        hsv_h=config.get('hsv_h', 0.015),
        hsv_s=config.get('hsv_s', 0.7),
        hsv_v=config.get('hsv_v', 0.4),
        degrees=config.get('degrees', 10.0),
        translate=config.get('translate', 0.1),
        scale=config.get('scale', 0.3),
        
        # Validation and saving
        save=True,
        save_period=5,
        val=True,
        plots=True,
        verbose=config.get('verbose', True),
    )
    
    print(f"Classification training completed!")
    print(f"Best model saved to: {output_dir}/flower_classifier/weights/best.pt")
    print(f"Last model saved to: {output_dir}/flower_classifier/weights/last.pt")
    
    return results

def validate_classifier(model_path, data_dir):
    """
    Validate classification model performance
    
    Args:
        model_path: Path to trained model (best.pt)
        data_dir: Path to dataset directory
    """
    print(f"Loading model: {model_path}")
    model = YOLO(model_path)
    
    print("Running validation...")
    metrics = model.val(data=data_dir)
    
    print("\n=== Classification Model Validation Results ===")
    print(f"Top-1 Accuracy: {metrics.top1:.4f}")
    print(f"Top-5 Accuracy: {metrics.top5:.4f}")
    
    # Per-class metrics
    if hasattr(metrics, 'per_class'):
        print("\nPer-Class Performance:")
        classes = ['bud', 'open', 'post-pollination']
        for i, class_name in enumerate(classes):
            if i < len(metrics.per_class):
                print(f"  {class_name}: {metrics.per_class[i]:.4f}")
    
    return metrics

def test_classifier(model_path, test_image_path):
    """
    Test model on a single image
    
    Args:
        model_path: Path to trained model
        test_image_path: Path to test image or directory
    """
    model = YOLO(model_path)
    
    print(f"Running inference on: {test_image_path}")
    results = model.predict(
        source=test_image_path,
        conf=0.5,  # Confidence threshold
        imgsz=224,
        verbose=True
    )
    
    # Print predictions
    classes = ['bud', 'open', 'post-pollination']
    for result in results:
        print(f"\nPredictions for {result.path}:")
        if result.probs is not None:
            for idx, prob in enumerate(result.probs.top5):
                print(f"  {classes[prob]}: {result.probs.top5conf[idx]:.2%}")
    
    return results

def batch_classify(model_path, image_dir, confidence_threshold=0.7):
    """
    Classify all images in a directory
    
    Args:
        model_path: Path to trained model
        image_dir: Directory containing images
        confidence_threshold: Minimum confidence for prediction
    """
    model = YOLO(model_path)
    
    print(f"Classifying images in: {image_dir}")
    results = model.predict(
        source=image_dir,
        conf=confidence_threshold,
        imgsz=224,
        verbose=False
    )
    
    # Aggregate results
    class_counts = {'bud': 0, 'open': 0, 'post-pollination': 0}
    classes = ['bud', 'open', 'post-pollination']
    
    for result in results:
        if result.probs is not None:
            top_class = result.probs.top1
            class_counts[classes[top_class]] += 1
    
    print("\n=== Classification Summary ===")
    total = sum(class_counts.values())
    for class_name, count in class_counts.items():
        percentage = (count / total * 100) if total > 0 else 0
        print(f"  {class_name}: {count} ({percentage:.1f}%)")
    
    return results, class_counts

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Train YOLOv8 Classification Model")
    parser.add_argument('--config', type=str, default='configs/classifier_config.yaml',
                        help='Path to classifier configuration file')
    parser.add_argument('--data', type=str, default='data/classification',
                        help='Path to dataset directory')
    parser.add_argument('--output-dir', type=str, default='models/classifier',
                        help='Output directory for trained models')
    parser.add_argument('--validate', action='store_true',
                        help='Validate existing model')
    parser.add_argument('--model', type=str, default=None,
                        help='Path to trained model (for validation/testing)')
    parser.add_argument('--test-image', type=str, default=None,
                        help='Path to test image or directory for inference')
    parser.add_argument('--batch-classify', action='store_true',
                        help='Batch classify images in a directory')
    
    args = parser.parse_args()
    
    if args.validate and args.model:
        validate_classifier(args.model, args.data)
    elif args.batch_classify and args.model and args.test_image:
        batch_classify(args.model, args.test_image)
    elif args.test_image and args.model:
        test_classifier(args.model, args.test_image)
    else:
        train_classifier(args.config, args.data, args.output_dir)
