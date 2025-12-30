# Pumpkin Flower Detection & Classification Model Training

This module handles the training and validation of ML models for detecting and classifying pumpkin flowers in various receptivity states.

## Model Stack

### 1. Object Detection - YOLOv8
- **Purpose**: Localize pumpkin flowers in drone imagery
- **Model**: YOLOv8 (nano/small for edge deployment)
- **Output**: Bounding boxes with flower locations
- **Latency Target**: <33ms (30 FPS @ 1080p)

### 2. Classification - Readiness Assessment
- **States**: 
  - `bud` - Early stage, not receptive
  - `open` - Receptive, ready for pollination
  - `post-pollination` - Already pollinated
- **Model**: YOLOv8-Classifier (lightweight)
- **Input**: Cropped flower region from detection
- **Confidence**: >85% for reliable operation

## Project Structure

```
ml-training/
├── data/                      # Training datasets
│   ├── detection/
│   │   ├── images/           # Raw flower images
│   │   └── labels/           # YOLO format annotations
│   └── classification/
│       ├── images/
│       └── labels/
├── models/                    # Trained model checkpoints
├── scripts/
│   ├── train_detector.py     # YOLOv8 detection training
│   ├── train_classifier.py   # YOLOv8 classification training
│   ├── validate_models.py    # Model validation & metrics
│   ├── prepare_dataset.py    # Dataset preparation utilities
│   └── export_models.py      # Export for edge deployment
├── notebooks/
│   ├── eda_detection.ipynb   # Data exploration - detection
│   ├── eda_classification.ipynb
│   └── model_evaluation.ipynb
├── configs/
│   ├── detector_config.yaml  # YOLOv8 detection config
│   └── classifier_config.yaml
├── requirements.txt
└── README.md
```

## Installation

```bash
cd ml-training
pip install -r requirements.txt
```

## Quick Start

### 1. Prepare Dataset
```bash
python scripts/prepare_dataset.py --data-dir ./data --split-ratio 0.8
```

### 2. Train Detection Model
```bash
python scripts/train_detector.py --config configs/detector_config.yaml
```

### 3. Train Classification Model
```bash
python scripts/train_classifier.py --config configs/classifier_config.yaml
```

### 4. Validate Models
```bash
python scripts/validate_models.py --detection-model models/detector/best.pt \
                                   --classifier-model models/classifier/best.pt
```

### 5. Export for Edge Deployment
```bash
python scripts/export_models.py --detection-model models/detector/best.pt \
                                 --classifier-model models/classifier/best.pt \
                                 --format onnx
```

## Expected Performance

| Model | Precision | Recall | mAP@0.5 | Inference Time |
|-------|-----------|--------|---------|---|
| YOLOv8n Detection | >92% | >88% | >85% | <20ms |
| YOLOv8-Classifier | >90% | >88% | - | <5ms |

## Dataset Requirements

### Object Detection Dataset
- **Min samples**: 500 images (bud, open, post-pollination states)
- **Format**: YOLO (txt annotations with normalized coordinates)
- **Image size**: 640x480 minimum
- **Annotations**: Bounding boxes around flower heads

### Classification Dataset  
- **Min samples**: 300 per class (900 total)
- **Classes**: bud, open, post-pollination
- **Crop size**: 224x224 (flower region)
- **Augmentation**: Rotation, brightness, contrast variations

## Training Parameters

### Detection (YOLOv8)
- Epochs: 100-150
- Batch size: 16-32 (depending on GPU memory)
- Image size: 640
- Optimizer: SGD with momentum
- Learning rate: 0.001 (with scheduler)
- Augmentation: Mosaic, mixup, auto-augment

### Classification
- Epochs: 50-100
- Batch size: 32-64
- Image size: 224
- Optimizer: Adam
- Learning rate: 0.001
- Early stopping: patience=20

## Data Augmentation Strategy

To improve model robustness for field conditions:
- **Lighting variations**: Brightness, contrast, saturation
- **Geometric**: Rotation (±15°), scale (0.8-1.2x)
- **Weather**: Gaussian blur, rain simulation
- **Color jitter**: Simulate different camera sensors
- **Mosaic augmentation**: Combine multiple images (YOLOv8 default)

## Model Validation Checklist

- [ ] Precision and recall per class >85%
- [ ] Inference latency <25ms (total pipeline)
- [ ] Tested on various lighting conditions
- [ ] Tested on various flower maturity stages
- [ ] Cross-validation with field data
- [ ] Edge device compatibility verified

## Deployment Pipeline

1. **Optimize**: Convert to ONNX/TensorRT for edge devices
2. **Quantize**: INT8 quantization for faster inference
3. **Benchmark**: Test on edge hardware (Jetson Nano/Orin)
4. **Integration**: Package for IoT device deployment
5. **Monitor**: Track inference times and detection confidence in field

## References

- YOLOv8 Documentation: https://docs.ultralytics.com/
- YOLO Dataset Format: https://docs.ultralytics.com/datasets/detect/
- Model Optimization: https://docs.ultralytics.com/modes/export/
