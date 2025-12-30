"""
Model Validation & Metrics Evaluation
Comprehensive validation of both detection and classification models
"""

import argparse
from pathlib import Path
from ultralytics.models.yolo import YOLO
import torch
import json
from datetime import datetime

class ModelValidator:
    """Validates and evaluates trained models"""
    
    def __init__(self, detection_model_path, classifier_model_path):
        """
        Initialize validator with model paths
        
        Args:
            detection_model_path: Path to detection model
            classifier_model_path: Path to classification model
        """
        print("Loading models...")
        self.detector = YOLO(detection_model_path) if detection_model_path else None
        self.classifier = YOLO(classifier_model_path) if classifier_model_path else None
        self.validation_results = {}
    
    def validate_detector(self, data_yaml_path):
        """Validate detection model"""
        if not self.detector:
            print("Detector model not loaded")
            return None
        
        print("\n=== Validating Detection Model ===")
        metrics = self.detector.val(data=data_yaml_path)
        
        # Extract and store metrics
        results = {
            'model': 'YOLOv8 Detector',
            'timestamp': datetime.now().isoformat(),
            'metrics': {
                'mAP@0.5': float(metrics.box.map50) if hasattr(metrics.box, 'map50') else 0,
                'mAP@0.5-0.95': float(metrics.box.map) if hasattr(metrics.box, 'map') else 0,
                'precision': float(metrics.box.mp) if hasattr(metrics.box, 'mp') else 0,
                'recall': float(metrics.box.mr) if hasattr(metrics.box, 'mr') else 0,
            }
        }
        
        self.validation_results['detector'] = results
        self._print_detection_metrics(results)
        
        return metrics
    
    def validate_classifier(self, data_dir):
        """Validate classification model"""
        if not self.classifier:
            print("Classifier model not loaded")
            return None
        
        print("\n=== Validating Classification Model ===")
        metrics = self.classifier.val(data=data_dir)
        
        # Extract and store metrics
        results = {
            'model': 'YOLOv8 Classifier',
            'timestamp': datetime.now().isoformat(),
            'metrics': {
                'top1_accuracy': float(metrics.top1) if hasattr(metrics, 'top1') else 0,
                'top5_accuracy': float(metrics.top5) if hasattr(metrics, 'top5') else 0,
            }
        }
        
        self.validation_results['classifier'] = results
        self._print_classification_metrics(results)
        
        return metrics
    
    def _print_detection_metrics(self, results):
        """Pretty print detection metrics"""
        metrics = results['metrics']
        print(f"\nDetection Model Performance:")
        print(f"  mAP@0.5:      {metrics['mAP@0.5']:.4f} {'✓' if metrics['mAP@0.5'] > 0.85 else '⚠'}")
        print(f"  mAP@0.5-0.95: {metrics['mAP@0.5-0.95']:.4f} {'✓' if metrics['mAP@0.5-0.95'] > 0.75 else '⚠'}")
        print(f"  Precision:    {metrics['precision']:.4f} {'✓' if metrics['precision'] > 0.85 else '⚠'}")
        print(f"  Recall:       {metrics['recall']:.4f} {'✓' if metrics['recall'] > 0.85 else '⚠'}")
    
    def _print_classification_metrics(self, results):
        """Pretty print classification metrics"""
        metrics = results['metrics']
        print(f"\nClassification Model Performance:")
        print(f"  Top-1 Accuracy: {metrics['top1_accuracy']:.4f} {'✓' if metrics['top1_accuracy'] > 0.85 else '⚠'}")
        print(f"  Top-5 Accuracy: {metrics['top5_accuracy']:.4f}")
    
    def test_inference_speed(self, test_image_path, imgsz=640):
        """
        Test inference speed for detection
        
        Args:
            test_image_path: Path to test image
            imgsz: Image size for detection
        """
        if not self.detector:
            print("Detector model not loaded")
            return
        
        print(f"\n=== Testing Detection Inference Speed ===")
        results = self.detector.predict(
            source=test_image_path,
            imgsz=imgsz,
            device=0 if torch.cuda.is_available() else 'cpu',
            verbose=False
        )
        
        # Results contain timing information
        if results:
            result = results[0]
            if hasattr(result, 'speed'):
                print(f"  Preprocess: {result.speed.get('preprocess', 0):.2f}ms")
                print(f"  Inference:  {result.speed.get('inference', 0):.2f}ms")
                print(f"  Postprocess: {result.speed.get('postprocess', 0):.2f}ms")
                total = sum(result.speed.values()) # type: ignore
                print(f"  Total:      {total:.2f}ms")
        
        return results
    
    def test_classification_speed(self, test_image_path, imgsz=224):
        """
        Test inference speed for classification
        
        Args:
            test_image_path: Path to test image
            imgsz: Image size for classification
        """
        if not self.classifier:
            print("Classifier model not loaded")
            return
        
        print(f"\n=== Testing Classification Inference Speed ===")
        results = self.classifier.predict(
            source=test_image_path,
            imgsz=imgsz,
            device=0 if torch.cuda.is_available() else 'cpu',
            verbose=False
        )
        
        if results:
            result = results[0]
            if hasattr(result, 'speed'):
                print(f"  Preprocess: {result.speed.get('preprocess', 0):.2f}ms")
                print(f"  Inference:  {result.speed.get('inference', 0):.2f}ms")
                print(f"  Postprocess: {result.speed.get('postprocess', 0):.2f}ms")
                total = sum(result.speed.values()) # type: ignore
                print(f"  Total:      {total:.2f}ms")
        
        return results
    
    def generate_validation_report(self, output_path='validation_report.json'):
        """Save validation results to JSON file"""
        print(f"\nSaving validation report to: {output_path}")
        
        with open(output_path, 'w') as f:
            json.dump(self.validation_results, f, indent=2)
        
        print("✓ Validation report saved")
    
    def print_summary(self):
        """Print summary of all validations"""
        print("\n" + "="*50)
        print("VALIDATION SUMMARY")
        print("="*50)
        
        if 'detector' in self.validation_results:
            det = self.validation_results['detector']['metrics']
            status = "✓ PASS" if (det['mAP@0.5'] > 0.85 and det['precision'] > 0.85) else "⚠ REVIEW"
            print(f"\nDetection Model: {status}")
            print(f"  Best Metric (mAP@0.5): {det['mAP@0.5']:.4f}")
        
        if 'classifier' in self.validation_results:
            clf = self.validation_results['classifier']['metrics']
            status = "✓ PASS" if clf['top1_accuracy'] > 0.85 else "⚠ REVIEW"
            print(f"\nClassification Model: {status}")
            print(f"  Top-1 Accuracy: {clf['top1_accuracy']:.4f}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Validate Trained Models")
    parser.add_argument('--detection-model', type=str, default=None,
                        help='Path to detection model')
    parser.add_argument('--classifier-model', type=str, default=None,
                        help='Path to classification model')
    parser.add_argument('--detection-data', type=str, default='data/detection/dataset.yaml',
                        help='Path to detection dataset.yaml')
    parser.add_argument('--classifier-data', type=str, default='data/classification',
                        help='Path to classification dataset directory')
    parser.add_argument('--test-image', type=str, default=None,
                        help='Path to test image for speed testing')
    parser.add_argument('--output-report', type=str, default='validation_report.json',
                        help='Output path for validation report')
    
    args = parser.parse_args()
    
    validator = ModelValidator(args.detection_model, args.classifier_model)
    
    if args.detection_model:
        validator.validate_detector(args.detection_data)
        if args.test_image:
            validator.test_inference_speed(args.test_image)
    
    if args.classifier_model:
        validator.validate_classifier(args.classifier_data)
        if args.test_image:
            validator.test_classification_speed(args.test_image)
    
    validator.print_summary()
    validator.generate_validation_report(args.output_report)
