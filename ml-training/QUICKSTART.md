# Quick Start Guide: Model Training Pipeline

## Overview
Complete ML pipeline for training YOLOv8 models for pumpkin flower detection and classification.

**Models:**
- **Detection**: YOLOv8 for flower localization
- **Classification**: YOLOv8-Classifier for readiness assessment (bud/open/post-pollination)

## Installation

### 1. Setup Environment
```bash
# Windows
setup.bat

# macOS/Linux
bash setup.sh
```

This will:
- Create virtual environment
- Install all dependencies
- Create project directories
- Setup Jupyter kernel

### 2. Prepare Your Dataset

#### Detection Dataset (YOLO Format)
```
data/detection/
├── images/
│   ├── train/  (flowers images)
│   └── val/
└── labels/
    ├── train/  (YOLO .txt annotations)
    └── val/
```

**YOLO format** (.txt files):
```
<class_id> <x_center> <y_center> <width> <height>
```
- All values normalized (0-1)
- One object per line
- Classes: 0 = flower

#### Classification Dataset
```
data/classification/
├── train/
│   ├── bud/                 (early stage flowers)
│   ├── open/                (receptive flowers)
│   └── post-pollination/    (already pollinated)
└── val/
    ├── bud/
    ├── open/
    └── post-pollination/
```

## Training Pipeline

### Option 1: Using Python Scripts

#### Prepare Dataset
```bash
python scripts/prepare_dataset.py \
    --detection-images /path/to/raw/images \
    --detection-labels /path/to/raw/labels \
    --classification-dir /path/to/class/images \
    --split-ratio 0.8 \
    --validate
```

#### Train Detection Model
```bash
python scripts/train_detector.py \
    --config configs/detector_config.yaml \
    --data data/detection/dataset.yaml \
    --output-dir models/detector
```

#### Train Classification Model
```bash
python scripts/train_classifier.py \
    --config configs/classifier_config.yaml \
    --data data/classification \
    --output-dir models/classifier
```

#### Validate Models
```bash
python scripts/validate_models.py \
    --detection-model models/detector/flower_detector/weights/best.pt \
    --classifier-model models/classifier/flower_classifier/weights/best.pt \
    --detection-data data/detection/dataset.yaml \
    --classifier-data data/classification \
    --test-image path/to/test/image.jpg \
    --output-report validation_report.json
```

#### Export Models
```bash
# Export detection model
python scripts/export_models.py \
    --model models/detector/flower_detector/weights/best.pt \
    --format all

# Export classification model
python scripts/export_models.py \
    --model models/classifier/flower_classifier/weights/best.pt \
    --format all
```

### Option 2: Using Jupyter Notebooks

```bash
jupyter notebook notebooks/
```

1. **eda_detection.ipynb** - Data exploration and analysis
2. **model_training.ipynb** - Complete training pipeline
3. **model_evaluation.ipynb** - Performance evaluation

## Model Performance Targets

| Metric | Detection | Classification |
|--------|-----------|-----------------|
| Precision | >92% | - |
| Recall | >88% | - |
| mAP@0.5 | >85% | - |
| Top-1 Accuracy | - | >90% |
| Inference Time | <20ms | <5ms |
| FPS | >30 | >100 |

## Configuration

### Detection Model (`configs/detector_config.yaml`)
```yaml
model_size: 'n'  # nano for edge, small for accuracy
epochs: 100
batch_size: 32
img_size: 640
lr0: 0.01
```

### Classification Model (`configs/classifier_config.yaml`)
```yaml
model_size: 's'  # small is recommended
epochs: 100
batch_size: 64
img_size: 224
lr0: 0.001
```

## Training Tips

### Data Augmentation
- Mosaic: Combines 4 images during training
- Mixup: Blends images
- Color jitter: Simulates lighting variations
- Geometric: Rotation, scaling, translation

### Optimization
1. **Start with nano model** (YOLOv8n) for edge deployment
2. **Use small batches** (16-32) if GPU memory is limited
3. **Enable early stopping** (patience=20)
4. **Monitor validation loss** to prevent overfitting

### Best Practices
- Ensure min 500 detection images, 300 per class for classification
- Balance classes in classification dataset
- Verify annotations are in YOLO format
- Test on diverse lighting/weather conditions
- Cross-validate with field data

## Model Deployment

### Export Formats

```bash
# Recommended for edge devices
python scripts/export_models.py --model best.pt --format onnx

# For NVIDIA Jetson
python scripts/export_models.py --model best.pt --format tensorrt

# For mobile devices
python scripts/export_models.py --model best.pt --format tflite

# For Intel devices
python scripts/export_models.py --model best.pt --format openvino
```

### Integration with IoT Device
1. Export model to ONNX format
2. Copy to `iot-device/models/` directory
3. Update IoT device inference script to load exported model
4. Test inference speed on target hardware

## Troubleshooting

### GPU Issues
```bash
# Check CUDA availability
python -c "import torch; print(torch.cuda.is_available())"

# Use CPU if GPU unavailable
# Modify scripts to use device='cpu'
```

### Out of Memory
- Reduce batch_size
- Use smaller model (nano instead of small)
- Reduce image size

### Poor Performance
- Verify dataset quality and annotations
- Check data augmentation parameters
- Increase epochs and reduce learning rate
- Ensure sufficient training data (min 500 images)

## Output Structure

```
models/
├── detector/
│   └── flower_detector/
│       ├── weights/
│       │   ├── best.pt      # Best model
│       │   └── last.pt      # Last checkpoint
│       └── results/         # Training plots
├── classifier/
│   └── flower_classifier/
│       ├── weights/
│       │   ├── best.pt
│       │   └── last.pt
│       └── results/
└── exported/
    ├── detector.onnx        # ONNX format
    ├── detector.engine      # TensorRT
    └── ...                  # Other formats
```

## References

- **YOLOv8 Documentation**: https://docs.ultralytics.com/
- **Dataset Format**: https://docs.ultralytics.com/datasets/detect/
- **Model Export**: https://docs.ultralytics.com/modes/export/
- **PyTorch**: https://pytorch.org/

## Support

For issues or questions:
1. Check validation report: `validation_report.json`
2. Review training logs in `models/*/results/`
3. Test on sample images: `scripts/train_detector.py --test-image image.jpg --model best.pt`
