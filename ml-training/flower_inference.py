"""
Unified Model Inference Pipeline
Handles both detection and classification with easy integration
"""

from pathlib import Path
from typing import List, Dict, Tuple, Optional
from ultralytics import YOLO
import numpy as np
import cv2
from dataclasses import dataclass
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class DetectionResult:
    """Detection result data class"""
    boxes: np.ndarray  # Bounding boxes [x1, y1, x2, y2]
    confidences: np.ndarray  # Confidence scores
    class_ids: np.ndarray  # Class IDs
    image: np.ndarray  # Annotated image

@dataclass
class ClassificationResult:
    """Classification result data class"""
    class_name: str  # Predicted class
    confidence: float  # Confidence score
    class_probs: Dict[str, float]  # Per-class probabilities

class FlowerDetectionPipeline:
    """
    Unified pipeline for flower detection and readiness classification
    
    Usage:
        pipeline = FlowerDetectionPipeline(
            detector_path='models/detector.pt',
            classifier_path='models/classifier.pt'
        )
        
        results = pipeline.process_image('image.jpg')
        print(results)
    """
    
    # Class names for classification
    FLOWER_CLASSES = {
        0: 'bud',
        1: 'open',
        2: 'post-pollination'
    }
    
    def __init__(self, 
                 detector_path: str,
                 classifier_path: str,
                 conf_threshold: float = 0.5,
                 device: int = 0):
        """
        Initialize the pipeline
        
        Args:
            detector_path: Path to detection model
            classifier_path: Path to classification model
            conf_threshold: Confidence threshold for detections
            device: GPU device ID (0) or 'cpu'
        """
        self.conf_threshold = conf_threshold
        self.device = device
        
        logger.info("Loading detection model...")
        self.detector = YOLO(detector_path)
        
        logger.info("Loading classification model...")
        self.classifier = YOLO(classifier_path)
        
        logger.info("✓ Models loaded successfully")
    
    def process_image(self, image_path: str) -> Tuple[List[Dict], np.ndarray]:
        """
        Process image with detection and classification
        
        Args:
            image_path: Path to input image
            
        Returns:
            List of flower detections with classifications, annotated image
        """
        # Read image
        image = cv2.imread(str(image_path))
        if image is None:
            raise ValueError(f"Failed to load image: {image_path}")
        
        # Run detection
        det_results = self.detector.predict(
            source=image_path,
            conf=self.conf_threshold,
            device=self.device,
            verbose=False
        )
        
        flowers = []
        annotated_image = image.copy()
        
        if len(det_results) > 0:
            result = det_results[0]
            
            # Process each detection
            for box, conf in zip(result.boxes.xyxy.cpu().numpy(),
                                result.boxes.conf.cpu().numpy()):
                x1, y1, x2, y2 = map(int, box)
                
                # Crop flower region
                flower_crop = image[y1:y2, x1:x2]
                
                # Classify flower readiness
                classification = self._classify_flower(flower_crop)
                
                flowers.append({
                    'bbox': (x1, y1, x2, y2),
                    'confidence': float(conf),
                    'classification': classification,
                    'crop': flower_crop
                })
                
                # Draw on annotated image
                annotated_image = self._draw_detection(
                    annotated_image, x1, y1, x2, y2,
                    classification['class_name'],
                    conf,
                    classification['confidence']
                )
        
        return flowers, annotated_image
    
    def _classify_flower(self, flower_crop: np.ndarray) -> ClassificationResult:
        """
        Classify flower readiness from cropped region
        
        Args:
            flower_crop: Cropped flower image
            
        Returns:
            Classification result
        """
        # Save temp crop for inference
        temp_path = '/tmp/flower_crop.jpg'
        cv2.imwrite(temp_path, flower_crop)
        
        # Run classification
        clf_results = self.classifier.predict(
            source=temp_path,
            device=self.device,
            verbose=False
        )
        
        if len(clf_results) > 0:
            result = clf_results[0]
            class_idx = result.probs.top1.item()
            class_name = self.FLOWER_CLASSES.get(class_idx, 'unknown')
            confidence = result.probs.top1conf.item()
            
            # Get all class probabilities
            probs = result.probs.data.cpu().numpy()
            class_probs = {
                self.FLOWER_CLASSES[i]: float(probs[i])
                for i in range(len(self.FLOWER_CLASSES))
            }
            
            return ClassificationResult(
                class_name=class_name,
                confidence=confidence,
                class_probs=class_probs
            )
        
        return ClassificationResult(
            class_name='unknown',
            confidence=0.0,
            class_probs={}
        )
    
    def _draw_detection(self, 
                       image: np.ndarray,
                       x1: int, y1: int, x2: int, y2: int,
                       class_name: str,
                       det_conf: float,
                       clf_conf: float) -> np.ndarray:
        """
        Draw detection box and classification label
        
        Args:
            image: Image to annotate
            x1, y1, x2, y2: Bounding box coordinates
            class_name: Flower readiness class
            det_conf: Detection confidence
            clf_conf: Classification confidence
            
        Returns:
            Annotated image
        """
        # Color coding by class
        colors = {
            'bud': (0, 165, 255),          # Orange
            'open': (0, 255, 0),            # Green
            'post-pollination': (0, 0, 255) # Red
        }
        color = colors.get(class_name, (255, 255, 255))
        
        # Draw bounding box
        cv2.rectangle(image, (x1, y1), (x2, y2), color, 2)
        
        # Prepare label
        label = f'{class_name} {clf_conf:.2f} (det: {det_conf:.2f})'
        
        # Put text
        cv2.putText(image, label, (x1, y1 - 5),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)
        
        return image
    
    def process_batch(self, image_dir: str) -> List[Dict]:
        """
        Process multiple images
        
        Args:
            image_dir: Directory containing images
            
        Returns:
            List of results for all images
        """
        results = []
        image_dir = Path(image_dir)
        
        for image_path in image_dir.glob('*.jpg') + image_dir.glob('*.png'):
            logger.info(f"Processing {image_path.name}...")
            
            flowers, _ = self.process_image(str(image_path))
            
            results.append({
                'image': str(image_path),
                'flowers': flowers,
                'flower_count': len(flowers)
            })
        
        return results
    
    def get_statistics(self, results: List[Dict]) -> Dict:
        """
        Generate statistics from batch results
        
        Args:
            results: List of batch processing results
            
        Returns:
            Statistics dictionary
        """
        class_counts = {'bud': 0, 'open': 0, 'post-pollination': 0}
        total_flowers = 0
        avg_det_conf = []
        avg_clf_conf = []
        
        for result in results:
            for flower in result['flowers']:
                total_flowers += 1
                class_name = flower['classification'].class_name
                class_counts[class_name] = class_counts.get(class_name, 0) + 1
                avg_det_conf.append(flower['confidence'])
                avg_clf_conf.append(flower['classification'].confidence)
        
        return {
            'total_flowers': total_flowers,
            'class_distribution': class_counts,
            'avg_detection_confidence': np.mean(avg_det_conf) if avg_det_conf else 0,
            'avg_classification_confidence': np.mean(avg_clf_conf) if avg_clf_conf else 0,
            'receptive_flowers': class_counts.get('open', 0),
            'receptivity_rate': (class_counts.get('open', 0) / total_flowers * 100) if total_flowers > 0 else 0
        }

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='Flower Detection & Classification Pipeline')
    parser.add_argument('--detector', required=True, help='Detection model path')
    parser.add_argument('--classifier', required=True, help='Classification model path')
    parser.add_argument('--image', type=str, help='Single image path')
    parser.add_argument('--batch', type=str, help='Batch image directory')
    parser.add_argument('--output', type=str, default='results.json', help='Output JSON path')
    parser.add_argument('--conf', type=float, default=0.5, help='Confidence threshold')
    
    args = parser.parse_args()
    
    # Initialize pipeline
    pipeline = FlowerDetectionPipeline(
        args.detector,
        args.classifier,
        conf_threshold=args.conf
    )
    
    # Process image or batch
    if args.image:
        flowers, annotated = pipeline.process_image(args.image)
        print(f"Detected {len(flowers)} flowers")
        for i, flower in enumerate(flowers):
            print(f"  Flower {i+1}: {flower['classification'].class_name} "
                  f"({flower['classification'].confidence:.2f})")
        cv2.imwrite('annotated_output.jpg', annotated)
    
    elif args.batch:
        results = pipeline.process_batch(args.batch)
        stats = pipeline.get_statistics(results)
        
        print(f"\\nBatch Results:")
        print(f"  Total flowers: {stats['total_flowers']}")
        print(f"  Class distribution: {stats['class_distribution']}")
        print(f"  Receptivity rate: {stats['receptivity_rate']:.1f}%")
