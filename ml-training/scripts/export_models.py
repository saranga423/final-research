"""
Model Export Utilities
Exports trained models to various formats for edge deployment
Supports: ONNX, TensorRT, OpenVINO, CoreML, TFlite
"""

import argparse
from pathlib import Path
from ultralytics import YOLO # pyright: ignore[reportPrivateImportUsage]
import torch

class ModelExporter:
    """Handles model export to different formats"""
    
    EXPORT_FORMATS = {
        'onnx': {
            'format': 'onnx',
            'suffix': '.onnx',
            'description': 'ONNX (best for cross-platform)'
        },
        'tensorrt': {
            'format': 'engine',
            'suffix': '.engine',
            'description': 'TensorRT (best for NVIDIA GPUs)'
        },
        'openvino': {
            'format': 'openvino',
            'suffix': '.xml',
            'description': 'OpenVINO (Intel optimization)'
        },
        'tflite': {
            'format': 'tflite',
            'suffix': '.tflite',
            'description': 'TFLite (mobile devices)'
        },
        'coreml': {
            'format': 'coreml',
            'suffix': '.mlmodel',
            'description': 'CoreML (Apple devices)'
        },
    }
    
    def __init__(self, model_path):
        """
        Initialize exporter
        
        Args:
            model_path: Path to YOLOv8 model (best.pt)
        """
        print(f"Loading model: {model_path}")
        self.model = YOLO(model_path)
        self.model_path = Path(model_path)
        self.output_dir = self.model_path.parent.parent / 'exported'
        self.output_dir.mkdir(parents=True, exist_ok=True)
    
    def export_onnx(self, imgsz=640, opset=12):
        """
        Export to ONNX format
        Best for inference across different platforms
        """
        print("\n=== Exporting to ONNX ===")
        output_path = self.output_dir / f"{self.model_path.stem}.onnx"
        
        try:
            self.model.export(
                format='onnx',
                imgsz=imgsz,
                opset=opset,
                device=0 if torch.cuda.is_available() else 'cpu'
            )
            print(f"✓ ONNX export successful")
            print(f"  Output: {output_path}")
            return output_path
        except Exception as e:
            print(f"✗ ONNX export failed: {e}")
            return None
    
    def export_tensorrt(self, imgsz=640, workspace=4):
        """
        Export to TensorRT format
        Optimized for NVIDIA GPUs (Jetson devices)
        """
        print("\n=== Exporting to TensorRT ===")
        
        if not torch.cuda.is_available():
            print("✗ TensorRT requires CUDA-capable GPU")
            return None
        
        output_path = self.output_dir / f"{self.model_path.stem}.engine"
        
        try:
            self.model.export(
                format='engine',
                imgsz=imgsz,
                device=0,
                workspace=workspace
            )
            print(f"✓ TensorRT export successful")
            print(f"  Output: {output_path}")
            return output_path
        except Exception as e:
            print(f"✗ TensorRT export failed: {e}")
            return None
    
    def export_openvino(self, imgsz=640):
        """
        Export to OpenVINO format
        Intel optimized inference
        """
        print("\n=== Exporting to OpenVINO ===")
        output_path = self.output_dir / f"{self.model_path.stem}_openvino"
        
        try:
            self.model.export(
                format='openvino',
                imgsz=imgsz,
                device='cpu'
            )
            print(f"✓ OpenVINO export successful")
            print(f"  Output: {output_path}")
            return output_path
        except Exception as e:
            print(f"✗ OpenVINO export failed: {e}")
            return None
    
    def export_tflite(self, imgsz=224):
        """
        Export to TFLite format
        For mobile and edge devices
        """
        print("\n=== Exporting to TFLite ===")
        output_path = self.output_dir / f"{self.model_path.stem}.tflite"
        
        try:
            self.model.export(
                format='tflite',
                imgsz=imgsz,
                device='cpu'
            )
            print(f"✓ TFLite export successful")
            print(f"  Output: {output_path}")
            return output_path
        except Exception as e:
            print(f"✗ TFLite export failed: {e}")
            return None
    
    def export_coreml(self, imgsz=640):
        """
        Export to CoreML format
        For iOS/macOS deployment
        """
        print("\n=== Exporting to CoreML ===")
        output_path = self.output_dir / f"{self.model_path.stem}.mlmodel"
        
        try:
            self.model.export(
                format='coreml',
                imgsz=imgsz,
                device='cpu'
            )
            print(f"✓ CoreML export successful")
            print(f"  Output: {output_path}")
            return output_path
        except Exception as e:
            print(f"✗ CoreML export failed: {e}")
            return None
    
    def export_all(self, imgsz=640):
        """Export to all available formats"""
        print("=== Exporting to All Formats ===\n")
        results = {}
        
        # Try each format
        results['onnx'] = self.export_onnx(imgsz)
        results['openvino'] = self.export_openvino(imgsz)
        results['tflite'] = self.export_tflite(imgsz)
        
        # GPU-specific formats
        if torch.cuda.is_available():
            results['tensorrt'] = self.export_tensorrt(imgsz)
        
        # Apple-specific
        try:
            results['coreml'] = self.export_coreml(imgsz)
        except:
            results['coreml'] = None
        
        self._print_export_summary(results)
        return results
    
    def _print_export_summary(self, results):
        """Print export summary"""
        print("\n" + "="*50)
        print("EXPORT SUMMARY")
        print("="*50)
        
        successful = sum(1 for v in results.values() if v is not None)
        total = len(results)
        
        print(f"\nSuccessful: {successful}/{total}")
        for fmt, path in results.items():
            status = "✓" if path else "✗"
            print(f"  {status} {fmt.upper():<12} {path if path else 'Failed'}")
        
        print(f"\nAll exports saved to: {self.output_dir}")

def get_export_recommendations():
    """Get deployment recommendations by target platform"""
    recommendations = {
        'NVIDIA Jetson (Orin/Nano)': ['tensorrt', 'onnx'],
        'Intel Devices': ['openvino', 'onnx'],
        'Mobile (Android)': ['tflite', 'onnx'],
        'Mobile (iOS)': ['coreml'],
        'Edge Devices (Generic)': ['onnx'],
        'Cloud/Server': ['onnx', 'tensorrt'],
    }
    
    print("\n=== Export Recommendations by Platform ===\n")
    for platform, formats in recommendations.items():
        print(f"{platform}:")
        for fmt in formats:
            print(f"  • {fmt.upper()}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Export Trained Models")
    parser.add_argument('--model', type=str, required=True,
                        help='Path to trained model (best.pt)')
    parser.add_argument('--format', type=str, default='all',
                        choices=['all', 'onnx', 'tensorrt', 'openvino', 'tflite', 'coreml'],
                        help='Export format')
    parser.add_argument('--imgsz', type=int, default=640,
                        help='Image size for export')
    parser.add_argument('--recommendations', action='store_true',
                        help='Show platform recommendations')
    parser.add_argument('--output-dir', type=str, default=None,
                        help='Output directory (optional)')
    
    args = parser.parse_args()
    
    if args.recommendations:
        get_export_recommendations()
    else:
        exporter = ModelExporter(args.model)
        
        if args.output_dir:
            exporter.output_dir = Path(args.output_dir)
            exporter.output_dir.mkdir(parents=True, exist_ok=True)
        
        if args.format == 'all':
            exporter.export_all(args.imgsz)
        else:
            getattr(exporter, f"export_{args.format}")(args.imgsz)
