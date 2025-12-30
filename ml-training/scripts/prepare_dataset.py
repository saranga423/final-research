"""
Dataset Preparation Utilities
Handles dataset conversion, splitting, and augmentation
"""

import argparse
import yaml
from pathlib import Path
import shutil
from sklearn.model_selection import train_test_split
import json

class DatasetPreparator:
    """Prepares datasets for model training"""
    
    def __init__(self, data_dir):
        """
        Initialize data preparator
        
        Args:
            data_dir: Root data directory
        """
        self.data_dir = Path(data_dir)
        self.detection_dir = self.data_dir / 'detection'
        self.classification_dir = self.data_dir / 'classification'
    
    def create_detection_dataset(self, image_dir, label_dir, split_ratio=0.8, val_split=0.1):
        """
        Create YOLO format detection dataset
        
        Args:
            image_dir: Directory with images
            label_dir: Directory with YOLO format labels
            split_ratio: Training set ratio (rest goes to test)
            val_split: Validation split from training set
        """
        print("Creating detection dataset structure...")
        
        # Create directories
        self.detection_dir.mkdir(parents=True, exist_ok=True)
        (self.detection_dir / 'images' / 'train').mkdir(parents=True, exist_ok=True)
        (self.detection_dir / 'images' / 'val').mkdir(parents=True, exist_ok=True)
        (self.detection_dir / 'labels' / 'train').mkdir(parents=True, exist_ok=True)
        (self.detection_dir / 'labels' / 'val').mkdir(parents=True, exist_ok=True)
        
        # Get all images
        image_files = list(Path(image_dir).glob('*.jpg')) + \
                      list(Path(image_dir).glob('*.png'))
        
        # Split dataset
        train_files, test_files = train_test_split(
            image_files, 
            test_size=(1 - split_ratio),
            random_state=42
        )
        
        train_files, val_files = train_test_split(
            train_files,
            test_size=val_split,
            random_state=42
        )
        
        # Copy files
        for f in train_files:
            shutil.copy2(f, self.detection_dir / 'images' / 'train')
            label_f = Path(label_dir) / f.stem / '.txt'
            if label_f.exists():
                shutil.copy2(label_f, self.detection_dir / 'labels' / 'train')
        
        for f in val_files:
            shutil.copy2(f, self.detection_dir / 'images' / 'val')
            label_f = Path(label_dir) / f.stem / '.txt'
            if label_f.exists():
                shutil.copy2(label_f, self.detection_dir / 'labels' / 'val')
        
        print(f"✓ Train: {len(train_files)}, Val: {len(val_files)}")
        
        # Create dataset.yaml
        self._create_detection_yaml(len(train_files), len(val_files))
    
    def create_classification_dataset(self, image_dir, class_names=None, split_ratio=0.8, val_split=0.1):
        """
        Create classification dataset with class subdirectories
        
        Args:
            image_dir: Directory containing class subdirectories
            class_names: List of class names (auto-detect if None)
            split_ratio: Training set ratio
            val_split: Validation split
        """
        print("Creating classification dataset structure...")
        
        # Auto-detect classes or use provided
        if class_names is None:
            class_names = [d.name for d in Path(image_dir).iterdir() 
                          if d.is_dir()]
        
        # Create directory structure
        self.classification_dir.mkdir(parents=True, exist_ok=True)
        for split in ['train', 'val']:
            for class_name in class_names:
                (self.classification_dir / split / class_name).mkdir(parents=True, exist_ok=True)
        
        # Process each class
        total_train = 0
        total_val = 0
        
        for class_name in class_names:
            class_dir = Path(image_dir) / class_name
            if not class_dir.exists():
                print(f"Warning: Class directory {class_name} not found")
                continue
            
            # Get all images in class
            images = list(class_dir.glob('*.jpg')) + list(class_dir.glob('*.png'))
            
            # Split
            train_images, test_images = train_test_split(
                images,
                test_size=(1 - split_ratio),
                random_state=42
            )
            
            train_images, val_images = train_test_split(
                train_images,
                test_size=val_split,
                random_state=42
            )
            
            # Copy files
            for img in train_images:
                shutil.copy2(img, self.classification_dir / 'train' / class_name)
            
            for img in val_images:
                shutil.copy2(img, self.classification_dir / 'val' / class_name)
            
            total_train += len(train_images)
            total_val += len(val_images)
            print(f"  {class_name}: {len(train_images)} train, {len(val_images)} val")
        
        print(f"✓ Total - Train: {total_train}, Val: {total_val}")
    
    def _create_detection_yaml(self, train_count, val_count):
        """Create dataset.yaml for detection"""
        yaml_path = self.detection_dir / 'dataset.yaml'
        
        dataset_config = {
            'path': str(self.detection_dir.absolute()),
            'train': 'images/train',
            'val': 'images/val',
            'nc': 1,  # Number of classes (flowers)
            'names': ['flower']
        }
        
        with open(yaml_path, 'w') as f:
            yaml.dump(dataset_config, f)
        
        print(f"✓ Created: {yaml_path}")
    
    def validate_dataset(self):
        """Validate dataset integrity"""
        print("\n=== Validating Dataset ===")
        
        # Check detection dataset
        det_train = list((self.detection_dir / 'images' / 'train').glob('*'))
        det_val = list((self.detection_dir / 'images' / 'val').glob('*'))
        
        print(f"\nDetection Dataset:")
        print(f"  Train images: {len(det_train)}")
        print(f"  Val images: {len(det_val)}")
        print(f"  Total: {len(det_train) + len(det_val)}")
        
        # Check classification dataset
        if (self.classification_dir / 'train').exists():
            clf_train = list((self.classification_dir / 'train').rglob('*'))
            clf_val = list((self.classification_dir / 'val').rglob('*'))
            
            print(f"\nClassification Dataset:")
            print(f"  Train images: {len([f for f in clf_train if f.is_file()])}")
            print(f"  Val images: {len([f for f in clf_val if f.is_file()])}")
    
    def generate_manifest(self):
        """Generate dataset manifest"""
        manifest = {
            'created': str(Path.cwd()),
            'detection': {
                'train': len(list((self.detection_dir / 'images' / 'train').glob('*'))),
                'val': len(list((self.detection_dir / 'images' / 'val').glob('*'))),
            },
            'classification': {
                'train': len(list((self.classification_dir / 'train').rglob('*'))),
                'val': len(list((self.classification_dir / 'val').rglob('*'))),
            }
        }
        
        with open('dataset_manifest.json', 'w') as f:
            json.dump(manifest, f, indent=2)
        
        print("✓ Manifest saved to dataset_manifest.json")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Prepare Datasets")
    parser.add_argument('--data-dir', type=str, default='data',
                        help='Root data directory')
    parser.add_argument('--detection-images', type=str, default=None,
                        help='Detection images directory')
    parser.add_argument('--detection-labels', type=str, default=None,
                        help='Detection labels directory (YOLO format)')
    parser.add_argument('--classification-dir', type=str, default=None,
                        help='Classification dataset directory')
    parser.add_argument('--split-ratio', type=float, default=0.8,
                        help='Training split ratio')
    parser.add_argument('--validate', action='store_true',
                        help='Validate dataset')
    parser.add_argument('--manifest', action='store_true',
                        help='Generate dataset manifest')
    
    args = parser.parse_args()
    
    preparator = DatasetPreparator(args.data_dir)
    
    if args.detection_images and args.detection_labels:
        preparator.create_detection_dataset(
            args.detection_images,
            args.detection_labels,
            args.split_ratio
        )
    
    if args.classification_dir:
        preparator.create_classification_dataset(
            args.classification_dir,
            args.split_ratio
        )
    
    if args.validate:
        preparator.validate_dataset()
    
    if args.manifest:
        preparator.generate_manifest()
