"""
Integration Guide: ML Training Pipeline with IoT Device
How to integrate trained models with the autonomous pollination drone system
"""

# ============================================================================
# PART 1: MODEL TRAINING WORKFLOW
# ============================================================================

## Step 1: Prepare Training Data

### Detection Dataset
```
data/detection/
├── images/
│   ├── train/  (500+ images)
│   └── val/    (100+ images)
└── labels/
    ├── train/  (YOLO format .txt)
    └── val/
```

YOLO format:
```
<class_id> <x_center_norm> <y_center_norm> <width_norm> <height_norm>
```

### Classification Dataset
```
data/classification/
├── train/
│   ├── bud/                 (100+ samples)
│   ├── open/                (100+ samples)
│   └── post-pollination/    (100+ samples)
└── val/
    ├── bud/
    ├── open/
    └── post-pollination/
```

## Step 2: Setup Training Environment

```bash
# Windows
setup.bat

# Linux/macOS
bash setup.sh

# Verify installation
python -c "import torch; print(torch.cuda.is_available())"
```

## Step 3: Run Training

### Option A: Command Line
```bash
# Prepare data
python scripts/prepare_dataset.py \
    --detection-images /path/to/images \
    --detection-labels /path/to/labels \
    --classification-dir /path/to/classes

# Train detection
python scripts/train_detector.py \
    --config configs/detector_config.yaml \
    --data data/detection/dataset.yaml

# Train classification
python scripts/train_classifier.py \
    --config configs/classifier_config.yaml \
    --data data/classification

# Validate
python scripts/validate_models.py \
    --detection-model models/detector/flower_detector/weights/best.pt \
    --classifier-model models/classifier/flower_classifier/weights/best.pt
```

### Option B: Jupyter Notebooks
```bash
jupyter notebook notebooks/

# 1. eda_detection.ipynb       - Explore data
# 2. model_training.ipynb      - Train models
# 3. model_evaluation.ipynb    - Evaluate performance
```

## Step 4: Export Models

```bash
# Export to multiple formats
python scripts/export_models.py \
    --model models/detector/flower_detector/weights/best.pt \
    --format all

python scripts/export_models.py \
    --model models/classifier/flower_classifier/weights/best.pt \
    --format all
```

Output formats:
- **ONNX** - Universal format (recommended)
- **TensorRT** - NVIDIA GPU optimization
- **OpenVINO** - Intel optimization
- **TFLite** - Mobile devices

# ============================================================================
# PART 2: MODEL INTEGRATION WITH IOT DEVICE
# ============================================================================

## Integration Steps

### 1. Copy Trained Models
```bash
# Copy exported models to IoT device
cp models/exported/*.onnx iot-device/models/
cp models/exported/*.engine iot-device/models/  # If TensorRT
```

### 2. Update IoT Device Inference

In `iot-device/src/inference.py` or similar:

```python
from ml_training.flower_inference import FlowerDetectionPipeline

class DroneInference:
    def __init__(self, detector_model_path, classifier_model_path):
        # Initialize inference pipeline
        self.pipeline = FlowerDetectionPipeline(
            detector_path=detector_model_path,
            classifier_path=classifier_model_path,
            conf_threshold=0.5,
            device=0  # GPU device or 'cpu'
        )
    
    def detect_and_classify(self, frame):
        """
        Process drone camera frame
        
        Args:
            frame: Camera frame (numpy array)
            
        Returns:
            List of detected flowers with classifications
        """
        # Save frame temporarily
        cv2.imwrite('/tmp/drone_frame.jpg', frame)
        
        # Run inference
        flowers, annotated = self.pipeline.process_image('/tmp/drone_frame.jpg')
        
        # Filter by readiness (optional)
        receptive_flowers = [
            f for f in flowers 
            if f['classification'].class_name == 'open'
        ]
        
        return receptive_flowers, annotated
```

### 3. Integrate with Flight Controller

In main drone logic:

```python
class PollnationDrone:
    def __init__(self):
        # ... drone initialization ...
        self.inference = DroneInference(
            detector_model_path='models/detector.onnx',
            classifier_model_path='models/classifier.onnx'
        )
    
    def pollinate_mission(self):
        """Main mission loop"""
        while self.flying:
            # Get camera frame
            frame = self.camera.get_frame()
            
            # Detect flowers
            flowers, _ = self.inference.detect_and_classify(frame)
            
            # Process each flower
            for flower in flowers:
                x1, y1, x2, y2 = flower['bbox']
                
                # Get flower center in image coordinates
                flower_center = ((x1 + x2) / 2, (y1 + y2) / 2)
                
                # Convert to GPS coordinates
                gps_location = self.image_to_gps(flower_center, frame)
                
                # Check readiness
                if flower['classification'].class_name == 'open':
                    # Navigate to flower
                    self.navigate_to(gps_location)
                    
                    # Execute pollination
                    self.pollinate()
                    
                    # Log event
                    self.log_pollination(gps_location, flower['classification'])
```

# ============================================================================
# PART 3: OPTIMIZATION FOR EDGE DEVICES
# ============================================================================

## Model Optimization

### Option 1: Quantization
```python
# INT8 quantization for faster inference
python scripts/export_models.py \
    --model best.pt \
    --format onnx \
    --quantize int8
```

### Option 2: Model Pruning
```python
# Reduce model size and latency
from ultralytics import YOLO

model = YOLO('best.pt')
pruned = model.prune(amount=0.3)  # Prune 30%
pruned.export(format='onnx')
```

### Option 3: Lightweight Architecture
```yaml
# Use nano model for better edge performance
model_size: 'n'  # nano (fastest)
            # s   (balanced)
            # m   # accurate
```

## Performance Benchmarking

### On Jetson Nano
```bash
# Expected performance
Detection:    20-30ms per frame
Classification: 5-10ms per frame
Total:        25-40ms (25-40 FPS)
```

### On x86 CPU
```bash
# With OpenVINO optimization
Detection:    15-25ms per frame
Classification: 3-5ms per frame
Total:        18-30ms (30+ FPS)
```

## Memory Requirements
- Detection Model: 50-100 MB (ONNX)
- Classification Model: 20-50 MB (ONNX)
- Runtime Memory: 200-500 MB

# ============================================================================
# PART 4: VALIDATION & TESTING
# ============================================================================

## Pre-Deployment Checklist

- [ ] Detection mAP@0.5 > 0.85
- [ ] Classification accuracy > 0.85
- [ ] Inference time < 40ms total
- [ ] Tested on diverse lighting conditions
- [ ] Tested with various flower stages
- [ ] Memory usage acceptable
- [ ] CPU/GPU utilization acceptable
- [ ] Temperature monitoring enabled
- [ ] Fallback mechanism in place

## Field Testing Protocol

1. **Controlled Environment**
   - Test on pumpkin flowers in lab/greenhouse
   - Verify detection and classification accuracy
   - Measure inference performance

2. **Field Trials**
   - Test on real farm conditions
   - Various times of day (lighting)
   - Different weather conditions
   - Multiple flower varieties

3. **Performance Monitoring**
   - Log inference times
   - Monitor detection confidence
   - Track false positives/negatives
   - Collect failure cases for retraining

# ============================================================================
# PART 5: CONTINUOUS IMPROVEMENT
# ============================================================================

## Monitoring & Retraining

### Collect Hard Examples
```python
# During drone operation, save low-confidence detections
if detection_confidence < 0.7:
    save_hard_example(frame, detection)
```

### Periodic Retraining
```bash
# Every month or after 1000 flights
1. Collect new data and annotate
2. Merge with existing training dataset
3. Retrain models with increased data
4. Validate performance improvements
5. Deploy updated models
```

### Performance Tracking
```python
# Log metrics for analysis
metrics = {
    'timestamp': datetime.now(),
    'detection_confidence': avg_confidence,
    'classification_accuracy': accuracy,
    'inference_time_ms': latency,
    'flowers_processed': count,
    'receptivity_rate': receptive_pct
}
log_metrics(metrics)
```

# ============================================================================
# TROUBLESHOOTING GUIDE
# ============================================================================

## Issue: Low Detection Accuracy

**Symptoms**: Many flowers missed, false positives

**Solutions**:
1. Check data augmentation parameters
2. Increase training epochs
3. Adjust confidence threshold
4. Add more training data
5. Verify annotation quality

## Issue: Slow Inference

**Symptoms**: FPS < 20

**Solutions**:
1. Switch to smaller model (nano vs small)
2. Enable model quantization
3. Use TensorRT for GPU
4. Reduce input image resolution
5. Use CPU optimization (OpenVINO)

## Issue: Misclassification

**Symptoms**: Readiness assessment wrong

**Solutions**:
1. Review classification training data
2. Increase classification epochs
3. Add class augmentation
4. Balance class distribution
5. Verify flower crop regions

# ============================================================================
# PERFORMANCE TARGETS
# ============================================================================

| Metric | Target | Jetson Nano | Intel x86 |
|--------|--------|-------------|----------|
| Detection mAP@0.5 | >0.85 | ✓ | ✓ |
| Classification Acc | >0.85 | ✓ | ✓ |
| Inference Time | <40ms | 25-35ms | 20-30ms |
| FPS | >25 | 25-30 | 30-40 |
| Memory | <500MB | <200MB | <300MB |
| GPU VRAM | <1GB | - | - |

# ============================================================================
# REFERENCES & RESOURCES
# ============================================================================

- YOLOv8 Docs: https://docs.ultralytics.com/
- YOLO Format: https://docs.ultralytics.com/datasets/detect/
- Model Export: https://docs.ultralytics.com/modes/export/
- Jetson Setup: https://developer.nvidia.com/embedded/learn
- OpenVINO: https://docs.openvino.ai/
- PyTorch: https://pytorch.org/docs/

# ============================================================================
