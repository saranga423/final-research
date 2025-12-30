# ML Training Module - Complete Structure

## Directory Overview

```
ml-training/
│
├── README.md                          # Module overview & features
├── QUICKSTART.md                      # Quick start guide
├── INTEGRATION_GUIDE.md               # Integration with IoT device
├── requirements.txt                   # Python dependencies
│
├── setup.sh                           # Setup script (Linux/macOS)
├── setup.bat                          # Setup script (Windows)
├── Dockerfile                         # Docker container setup
├── docker-compose.yml                 # Docker compose config
│
├── configs/
│   ├── detector_config.yaml           # YOLOv8 detection config
│   └── classifier_config.yaml         # Classification config
│
├── scripts/
│   ├── train_detector.py              # Train detection model
│   ├── train_classifier.py            # Train classification model
│   ├── validate_models.py             # Validate trained models
│   ├── prepare_dataset.py             # Dataset preparation utilities
│   └── export_models.py               # Export to different formats
│
├── notebooks/
│   ├── eda_detection.ipynb            # Data exploration notebook
│   ├── model_training.ipynb           # Complete training notebook
│   └── model_evaluation.ipynb         # Evaluation & metrics notebook
│
├── flower_inference.py                # Unified inference pipeline
│
├── data/                              # Training data (to be populated)
│   ├── detection/
│   │   ├── images/
│   │   │   ├── train/                 # Detection training images
│   │   │   └── val/                   # Detection validation images
│   │   └── labels/
│   │       ├── train/                 # YOLO format annotations
│   │       └── val/
│   └── classification/
│       ├── train/
│       │   ├── bud/                   # Early stage flowers
│       │   ├── open/                  # Receptive flowers
│       │   └── post-pollination/      # Already pollinated
│       └── val/
│           ├── bud/
│           ├── open/
│           └── post-pollination/
│
├── models/                            # Trained models (generated)
│   ├── detector/
│   │   └── flower_detector/
│   │       ├── weights/
│   │       │   ├── best.pt            # Best detection model
│   │       │   └── last.pt            # Last checkpoint
│   │       └── results/               # Training plots & logs
│   ├── classifier/
│   │   └── flower_classifier/
│   │       ├── weights/
│   │       │   ├── best.pt            # Best classifier
│   │       │   └── last.pt
│   │       └── results/
│   └── exported/                      # Exported models
│       ├── detector.onnx
│       ├── detector.engine
│       ├── classifier.onnx
│       └── ...
│
└── runs/                              # Training logs & artifacts
    ├── detect/
    │   └── flower_detector/
    └── classify/
        └── flower_classifier/
```

## Key Features

### 1. Model Stack
- **Object Detection**: YOLOv8 (nano/small for edge)
  - Input: 640x480 images
  - Output: Flower bounding boxes
  - Latency: <20ms per frame
  
- **Classification**: YOLOv8-Classifier
  - Classes: bud, open, post-pollination
  - Input: 224x224 cropped flowers
  - Latency: <5ms per frame

### 2. Training Pipeline
```
Data Preparation → Model Training → Validation → Export
```

### 3. Supported Formats
- **ONNX** - Cross-platform inference
- **TensorRT** - NVIDIA GPU optimization
- **OpenVINO** - Intel CPU optimization
- **TFLite** - Mobile devices
- **CoreML** - Apple devices

### 4. Integration Points
- Standalone inference: `flower_inference.py`
- IoT device: Copy exported models to `iot-device/models/`
- Flutter app: Via IoT device API

## Quick Commands

```bash
# Setup
bash setup.sh  # or setup.bat on Windows

# Train
python scripts/train_detector.py --config configs/detector_config.yaml
python scripts/train_classifier.py --config configs/classifier_config.yaml

# Validate
python scripts/validate_models.py --detection-model models/detector/*/weights/best.pt

# Export
python scripts/export_models.py --model models/detector/*/weights/best.pt --format all

# Inference
python flower_inference.py --detector models/exported/detector.onnx \
                          --classifier models/exported/classifier.onnx \
                          --image test.jpg

# Jupyter
jupyter notebook notebooks/
```

## Expected Performance

| Model | mAP/Accuracy | Latency | FPS |
|-------|-------------|---------|-----|
| Detection (YOLOv8n) | 0.85+ | <20ms | 30+ |
| Classification | 0.90+ | <5ms | 100+ |
| Combined | - | <25ms | 25+ |

## Files Summary

| File | Purpose |
|------|---------|
| `train_detector.py` | YOLOv8 detection training |
| `train_classifier.py` | Readiness classification training |
| `validate_models.py` | Model evaluation and metrics |
| `prepare_dataset.py` | Dataset conversion and splitting |
| `export_models.py` | Export to multiple formats |
| `flower_inference.py` | Unified inference pipeline |
| `detector_config.yaml` | Detection hyperparameters |
| `classifier_config.yaml` | Classification hyperparameters |
| `eda_detection.ipynb` | Data exploration |
| `model_training.ipynb` | End-to-end training |
| `model_evaluation.ipynb` | Performance analysis |

## Integration Workflow

1. **Prepare Data**
   - Collect flower images
   - Annotate with YOLO format
   - Organize in `data/` directory

2. **Train Models**
   - Run training scripts
   - Monitor validation metrics
   - Export best models

3. **Deploy**
   - Copy models to IoT device
   - Integrate inference pipeline
   - Test on drone

4. **Monitor**
   - Log inference performance
   - Collect failure cases
   - Retrain periodically

## Next Steps

1. Read [QUICKSTART.md](QUICKSTART.md) for detailed setup
2. Review [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for IoT integration
3. Check [README.md](README.md) for feature details
4. Run `setup.bat` (Windows) or `bash setup.sh` (Linux/macOS)
5. Prepare your training dataset
6. Launch Jupyter and start training

## Support

For issues:
1. Check error messages in terminal
2. Review training logs in `models/*/results/`
3. Verify dataset format matches YOLO spec
4. Test individual scripts with `--help` flag
5. Review integration guide for deployment issues

---

**Version**: 1.0  
**Last Updated**: 2025-01-29  
**Framework**: YOLOv8 + PyTorch  
**License**: MIT
