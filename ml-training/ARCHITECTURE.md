# Model Training Architecture & Workflow

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    POLLEN CARE ML TRAINING                      │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ INPUT LAYER                                                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Raw Flower Images           Annotated Dataset                 │
│  ├─ Bud stage               ├─ YOLO format                    │
│  ├─ Open (receptive)        ├─ Normalized coordinates         │
│  └─ Post-pollination        └─ Class labels                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│ DATA PREPARATION & AUGMENTATION                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  • Dataset splitting (80% train, 20% val)                      │
│  • YOLO format conversion                                       │
│  • Image augmentation:                                          │
│    - Mosaic (combine 4 images)                                 │
│    - Mixup (blend images)                                      │
│    - Color jitter (lighting variations)                        │
│    - Geometric (rotation, scale, translate)                    │
│  • Class balancing (for classification)                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
        │                                            │
        ▼                                            ▼
┌──────────────────────────────┐    ┌──────────────────────────────┐
│  DETECTION TRAINING          │    │ CLASSIFICATION TRAINING      │
├──────────────────────────────┤    ├──────────────────────────────┤
│                              │    │                              │
│  Model: YOLOv8n/s            │    │  Model: YOLOv8n/s-cls        │
│  Input: 640×480 images       │    │  Input: 224×224 crops        │
│                              │    │                              │
│  Loss:                       │    │  Loss:                       │
│  ├─ Box (localization)       │    │  ├─ Cross-entropy            │
│  ├─ Conf (objectness)        │    │  └─ Class probabilities      │
│  └─ Cls (classification)     │    │                              │
│                              │    │  Optimizer: Adam             │
│  Optimizer: SGD              │    │  LR: 0.001                   │
│  LR: 0.01                    │    │  Epochs: 100                 │
│  Epochs: 100-150             │    │  Batch: 32-64                │
│  Batch: 32                   │    │  Patience: 20                │
│  Patience: 20                │    │                              │
│                              │    │  Early stopping when:        │
│  Early stopping when:        │    │  - Val accuracy plateaus     │
│  - Val loss plateaus         │    │  - No improvement × 20 ep    │
│  - mAP@0.5 plateaus          │    │                              │
│  - No improvement × 20 ep    │    │                              │
│                              │    │                              │
└──────────────────────────────┘    └──────────────────────────────┘
        │                                        │
        ▼                                        ▼
┌──────────────────────────────┐    ┌──────────────────────────────┐
│  DETECTION VALIDATION        │    │ CLASSIFICATION VALIDATION    │
├──────────────────────────────┤    ├──────────────────────────────┤
│                              │    │                              │
│  Metrics:                    │    │  Metrics:                    │
│  • mAP@0.5: 0.85+            │    │  • Top-1 Accuracy: 0.90+     │
│  • mAP@0.5-0.95: 0.75+       │    │  • Top-5 Accuracy: 0.95+     │
│  • Precision: 0.92+          │    │  • F1 Score: 0.88+           │
│  • Recall: 0.88+             │    │  • Per-class metrics         │
│  • Inference: <20ms          │    │  • Inference: <5ms           │
│                              │    │                              │
│  Status:                     │    │  Status:                     │
│  ✓ PASS if all targets met   │    │  ✓ PASS if accuracy > 0.85   │
│  ⚠ REVIEW if marginal        │    │  ⚠ REVIEW if < 0.85          │
│                              │    │                              │
└──────────────────────────────┘    └──────────────────────────────┘
        │                                        │
        └────────────────────┬───────────────────┘
                             ▼
                ┌────────────────────────────┐
                │   MODEL EXPORT             │
                ├────────────────────────────┤
                │                            │
                │  Export Formats:           │
                │  ├─ ONNX (universal)       │
                │  ├─ TensorRT (NVIDIA GPU)  │
                │  ├─ OpenVINO (Intel CPU)   │
                │  ├─ TFLite (mobile)        │
                │  └─ CoreML (Apple)         │
                │                            │
                │  Optimization:             │
                │  • Model quantization      │
                │  • Pruning (optional)      │
                │  • Inference benchmarking  │
                │                            │
                └────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ DEPLOYMENT                                                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ Unified Inference Pipeline (flower_inference.py)        │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │                                                          │  │
│  │  Input: Camera frame from drone                         │  │
│  │    │                                                    │  │
│  │    ├─► Detection Model (YOLOv8)                         │  │
│  │    │     └─► Bounding boxes + confidence              │  │
│  │    │                                                    │  │
│  │    ├─► For each detection:                             │  │
│  │    │     ├─► Crop flower region                        │  │
│  │    │     └─► Classification Model                      │  │
│  │    │         └─► Readiness class + confidence          │  │
│  │    │                                                    │  │
│  │    └─► Output:                                         │  │
│  │         ├─ List of detected flowers                    │  │
│  │         ├─ Bounding boxes                              │  │
│  │         ├─ Readiness classification                    │  │
│  │         └─ Confidence scores                           │  │
│  │                                                          │  │
│  │  Performance:                                           │  │
│  │  • Detection: 20-30ms                                   │  │
│  │  • Classification: 5-10ms/flower                        │  │
│  │  • Total: 25-40ms per frame                             │  │
│  │  • FPS: 25-40 (Jetson Nano)                             │  │
│  │        30+ (Intel x86)                                  │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                             │                                   │
│                             ▼                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  IoT Device Integration (iot-device/)                   │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │                                                          │  │
│  │  • Load exported models (ONNX)                          │  │
│  │  • Integrate with flight controller                     │  │
│  │  • Real-time flower detection during flight            │  │
│  │  • Filter receptive flowers (class='open')             │  │
│  │  • Generate target GPS coordinates                      │  │
│  │  • Navigate to flowers                                  │  │
│  │  • Execute pollination mechanism                        │  │
│  │  • Log GPS + classification data                        │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                             │                                   │
│                             ▼                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Mobile Application Integration (flutter-app/)          │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │                                                          │  │
│  │  • Display real-time detection results                  │  │
│  │  • Show flower readiness assessment                     │  │
│  │  • Mission statistics & analytics                       │  │
│  │  • Historical pollination data                          │  │
│  │  • Alert on receptive flowers                           │  │
│  │  • Performance metrics dashboard                        │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Training Workflow Timeline

```
Week 1-2: Data Collection & Annotation
├─ Photograph flowers at different stages
├─ Annotate with YOLO format (x, y, w, h)
├─ Organize by class (bud, open, post-pollination)
└─ Split into train/validation sets

Week 3: Setup & Preparation
├─ Run setup script
├─ Install dependencies
├─ Prepare datasets
└─ Verify data format

Week 4: Training
├─ Day 1-2: Train detection model (1-2 hours)
├─ Day 3-4: Train classification model (30-60 min)
└─ Day 5: Validation & fine-tuning

Week 5: Evaluation & Export
├─ Review performance metrics
├─ Validate on field images
├─ Export to multiple formats
└─ Benchmark on target hardware

Week 6: Integration & Deployment
├─ Copy models to IoT device
├─ Update inference code
├─ Test on drone
└─ Collect field performance data
```

## Model Stack Details

### Detection Model (YOLOv8)
```
Input: [640, 480, 3] RGB image

Backbone: CSPDarknet (Efficient feature extraction)
├─ Conv layers
├─ C2f modules (Cross-Stage Partial)
└─ SPPF (Spatial Pyramid Pooling)

Head: Decoupled detection
├─ Detection head
├─ Box regression
└─ Objectness & class predictions

Output: [N, 6] per image
├─ 4 values: x1, y1, x2, y2 (box coordinates)
├─ 1 value: objectness score
└─ 1 value: class confidence
```

### Classification Model (YOLOv8-Classifier)
```
Input: [224, 224, 3] cropped flower image

Backbone: Efficient CNN
├─ Convolutional layers
├─ Feature extraction
└─ Pooling

Head: Classification
├─ Average pooling
├─ Linear layers
└─ Softmax (3 classes)

Output: [3] class logits
├─ bud (class 0)
├─ open (class 1)
└─ post-pollination (class 2)
```

## Performance Metrics

### Detection Metrics
```
Precision:  TP / (TP + FP)      - Accuracy of positive predictions
Recall:     TP / (TP + FN)      - Coverage of actual positives
mAP@0.5:    Mean Average Precision at IOU=0.5
mAP@0.5-0.95: mAP across multiple IOU thresholds
F1-Score:   2 * (Precision * Recall) / (Precision + Recall)
```

### Classification Metrics
```
Accuracy:   Correct predictions / Total predictions
Precision:  Per-class TP / (TP + FP)
Recall:     Per-class TP / (TP + FN)
F1-Score:   Per-class harmonic mean of precision & recall
Confusion Matrix: Predicted vs actual classes
```

### Inference Metrics
```
Latency:    Time from input to output (ms)
Throughput: Images processed per second
FPS:        Frames per second (inverse of latency)
Memory:     RAM and VRAM used during inference
```

## Deployment Checklist

```
□ Detection mAP@0.5 > 0.85
□ Detection mAP@0.5-0.95 > 0.75
□ Detection Precision > 0.92
□ Detection Recall > 0.88
□ Detection Latency < 20ms (>30 FPS)

□ Classification Accuracy > 0.90
□ Classification Latency < 5ms per image
□ Classification tested on all classes
□ Confusion matrix reviewed

□ Combined latency < 40ms (>25 FPS)
□ Memory usage < 500MB
□ GPU/CPU usage acceptable
□ Temperature monitoring enabled

□ Tested on various lighting conditions
□ Tested on various flower stages
□ Field validation completed
□ Fallback mechanism in place

□ Models exported to target formats
□ Models copied to IoT device
□ Inference pipeline integrated
□ Performance monitoring setup
```

## Next Actions

1. **Prepare Training Data**
   ```bash
   # Collect and annotate flower images
   # Organize in data/ directory structure
   ```

2. **Run Setup**
   ```bash
   # Windows
   setup.bat
   
   # Linux/macOS
   bash setup.sh
   ```

3. **Start Training**
   ```bash
   # Via Jupyter (recommended)
   jupyter notebook notebooks/model_training.ipynb
   
   # Or via command line
   python scripts/train_detector.py
   python scripts/train_classifier.py
   ```

4. **Validate & Export**
   ```bash
   python scripts/validate_models.py
   python scripts/export_models.py
   ```

5. **Deploy to Drone**
   ```bash
   cp models/exported/*.onnx ../iot-device/models/
   # Update IoT device code
   ```

---

**Framework**: YOLOv8 (Real-time Object Detection)  
**Status**: Ready for Training  
**Last Updated**: 2025-01-29
