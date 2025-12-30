import os
import json
import cv2
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
from collections import defaultdict
import argparse
from datetime import datetime

class DatasetAnalyzer:
    """Comprehensive dataset analysis for YOLOv8 flower detection."""
    
    def __init__(self, data_dir="data"):
        self.data_dir = Path(data_dir)
        self.detection_dir = self.data_dir / "detection"
        self.classification_dir = self.data_dir / "classification"
        self.stats = defaultdict(dict)
        
    def analyze_detection_dataset(self):
        """Analyze detection dataset structure and annotations."""
        print("\n" + "="*60)
        print("DETECTION DATASET ANALYSIS")
        print("="*60)
        
        for split in ["train", "val"]:
            img_dir = self.detection_dir / "images" / split
            label_dir = self.detection_dir / "labels" / split
            
            if not img_dir.exists():
                print(f"\n⚠️  {split} images directory not found: {img_dir}")
                continue
            
            images = list(img_dir.glob("*.jpg")) + list(img_dir.glob("*.png"))
            print(f"\n📸 {split.upper()} Images: {len(images)} found")
            
            if len(images) == 0:
                print(f"   ❌ No images found in {img_dir}")
                continue
            
            # Analyze image properties
            self._analyze_images(images, split)
            
            # Analyze labels if they exist
            if label_dir.exists():
                self._analyze_labels(images, label_dir, split)
            else:
                print(f"   ⚠️  No labels directory: {label_dir}")
    
    def analyze_classification_dataset(self):
        """Analyze classification dataset structure."""
        print("\n" + "="*60)
        print("CLASSIFICATION DATASET ANALYSIS")
        print("="*60)
        
        for split in ["train", "val"]:
            split_dir = self.classification_dir / split
            
            if not split_dir.exists():
                print(f"\n⚠️  {split} directory not found: {split_dir}")
                continue
            
            print(f"\n📊 {split.upper()} Split:")
            class_counts = defaultdict(int)
            
            for class_dir in split_dir.iterdir():
                if class_dir.is_dir():
                    images = list(class_dir.glob("*.jpg")) + list(class_dir.glob("*.png"))
                    class_counts[class_dir.name] = len(images)
                    print(f"   {class_dir.name:20s}: {len(images):4d} images")
            
            self.stats[f"classification_{split}"] = class_counts
            
            # Visualize class distribution
            if class_counts:
                self._plot_class_distribution(class_counts, split)
    
    def _analyze_images(self, images, split):
        """Analyze image properties (size, format, etc)."""
        sizes = []
        formats = defaultdict(int)
        corrupted = []
        
        for img_path in images:
            try:
                img = cv2.imread(str(img_path))
                if img is None:
                    corrupted.append(img_path.name)
                    continue
                
                h, w = img.shape[:2]
                sizes.append((w, h))
                formats[img_path.suffix.lower()] += 1
            except Exception as e:
                corrupted.append(f"{img_path.name} ({str(e)})")
        
        if corrupted:
            print(f"   ⚠️  Corrupted files: {len(corrupted)}")
            for f in corrupted[:5]:
                print(f"      - {f}")
        
        if sizes:
            sizes = np.array(sizes)
            print(f"   📐 Image dimensions:")
            print(f"      Width  - Min: {sizes[:,0].min()}, Max: {sizes[:,0].max()}, Mean: {sizes[:,0].mean():.0f}")
            print(f"      Height - Min: {sizes[:,1].min()}, Max: {sizes[:,1].max()}, Mean: {sizes[:,1].mean():.0f}")
        
        print(f"   📄 Formats: {dict(formats)}")
        self.stats[f"images_{split}"] = {
            "count": len(images),
            "corrupted": len(corrupted),
            "formats": dict(formats),
            "avg_width": sizes[:,0].mean() if len(sizes) > 0 else 0, # type: ignore
            "avg_height": sizes[:,1].mean() if len(sizes) > 0 else 0, # type: ignore
        }
    
    def _analyze_labels(self, images, label_dir, split):
        """Analyze YOLO format labels."""
        labeled_count = 0
        unlabeled = []
        bbox_stats = []
        
        for img_path in images:
            label_file = label_dir / f"{img_path.stem}.txt"
            
            if not label_file.exists():
                unlabeled.append(img_path.name)
                continue
            
            labeled_count += 1
            
            try:
                with open(label_file, 'r') as f:
                    lines = f.readlines()
                    if lines:
                        for line in lines:
                            parts = line.strip().split()
                            if len(parts) >= 5:
                                x, y, w, h = map(float, parts[1:5])
                                bbox_stats.append((w, h))
            except Exception as e:
                print(f"   ⚠️  Error reading {label_file.name}: {e}")
        
        print(f"   🏷️  Labels: {labeled_count}/{len(images)} images labeled")
        
        if unlabeled:
            print(f"   ⚠️  Unlabeled images: {len(unlabeled)}")
            if len(unlabeled) <= 5:
                for f in unlabeled:
                    print(f"      - {f}")
        
        if bbox_stats:
            bbox_stats = np.array(bbox_stats)
            print(f"   📦 Bounding boxes:")
            print(f"      Count: {len(bbox_stats)}")
            print(f"      Avg width: {bbox_stats[:,0].mean():.3f}")
            print(f"      Avg height: {bbox_stats[:,1].mean():.3f}")
        
        self.stats[f"labels_{split}"] = {
            "labeled": labeled_count,
            "unlabeled": len(unlabeled),
            "total_boxes": len(bbox_stats),
        }
    
    def _plot_class_distribution(self, class_counts, split):
        """Create visualization of class distribution."""
        try:
            fig, ax = plt.subplots(figsize=(10, 6))
            classes = list(class_counts.keys())
            counts = list(class_counts.values())
            
            colors = plt.cm.Set3(np.linspace(0, 1, len(classes))) # type: ignore
            bars = ax.bar(classes, counts, color=colors, edgecolor='black', linewidth=1.5)
            
            ax.set_title(f"Classification Dataset - {split.upper()} Split", fontsize=14, fontweight='bold')
            ax.set_xlabel("Flower Class", fontsize=12)
            ax.set_ylabel("Image Count", fontsize=12)
            ax.grid(axis='y', alpha=0.3)
            
            # Add value labels on bars
            for bar in bars:
                height = bar.get_height()
                ax.text(bar.get_x() + bar.get_width()/2., height,
                       f'{int(height)}',
                       ha='center', va='bottom', fontweight='bold')
            
            plt.tight_layout()
            output_dir = Path("reports")
            output_dir.mkdir(exist_ok=True)
            plt.savefig(output_dir / f"class_distribution_{split}.png", dpi=150, bbox_inches='tight')
            print(f"   ✅ Saved: reports/class_distribution_{split}.png")
            plt.close()
        except Exception as e:
            print(f"   ⚠️  Could not create visualization: {e}")
    
    def generate_report(self):
        """Generate comprehensive dataset report."""
        print("\n" + "="*60)
        print("DATASET REPORT")
        print("="*60)
        
        # Summary
        print(f"\nGenerated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"Dataset path: {self.data_dir.absolute()}")
        
        # Detection summary
        det_train = self.stats.get("images_train", {})
        det_val = self.stats.get("images_val", {})
        print(f"\n🎯 DETECTION DATASET:")
        print(f"   Train: {det_train.get('count', 0)} images")
        print(f"   Val:   {det_val.get('count', 0)} images")
        print(f"   Total: {det_train.get('count', 0) + det_val.get('count', 0)} images")
        
        # Classification summary
        class_train = self.stats.get("classification_train", {})
        class_val = self.stats.get("classification_val", {})
        print(f"\n📊 CLASSIFICATION DATASET:")
        if class_train:
            print(f"   Train: {sum(class_train.values())} images")
            for cls, count in class_train.items():
                pct = (count / sum(class_train.values()) * 100) if class_train else 0
                print(f"      - {cls}: {count} ({pct:.1f}%)")
        if class_val:
            print(f"   Val: {sum(class_val.values())} images")
            for cls, count in class_val.items():
                pct = (count / sum(class_val.values()) * 100) if class_val else 0
                print(f"      - {cls}: {count} ({pct:.1f}%)")
        
        # Recommendations
        self._print_recommendations()
    
    def _print_recommendations(self):
        """Print recommendations based on analysis."""
        print("\n" + "="*60)
        print("RECOMMENDATIONS")
        print("="*60)
        
        det_train = self.stats.get("images_train", {})
        det_val = self.stats.get("images_val", {})
        
        train_count = det_train.get('count', 0)
        val_count = det_val.get('count', 0)
        
        if train_count == 0:
            print("❌ No training images found. Add images to data/detection/images/train/")
        elif train_count < 100:
            print(f"⚠️  Only {train_count} training images. Recommend at least 500+ for good results.")
        else:
            print(f"✅ Training images: {train_count} (good)")
        
        if val_count == 0:
            print("⚠️  No validation images found. Recommend 20% of training set.")
        else:
            ratio = val_count / train_count if train_count > 0 else 0
            if ratio < 0.1:
                print(f"⚠️  Validation ratio is {ratio:.1%}. Recommend 20%.")
            else:
                print(f"✅ Validation ratio: {ratio:.1%} (good)")
        
        class_train = self.stats.get("classification_train", {})
        if class_train and len(class_train) > 0:
            min_class = min(class_train.values())
            max_class = max(class_train.values())
            imbalance = max_class / min_class if min_class > 0 else float('inf')
            
            if imbalance > 2:
                print(f"⚠️  Class imbalance detected (ratio: {imbalance:.1f}x). Consider data augmentation.")
            else:
                print(f"✅ Class balance: {imbalance:.1f}x (acceptable)")
    
    def run(self):
        """Run complete analysis."""
        print("\n🔍 Starting Dataset Analysis...")
        
        self.analyze_detection_dataset()
        self.analyze_classification_dataset()
        self.generate_report()
        
        print("\n✅ Analysis complete!\n")


def main():
    parser = argparse.ArgumentParser(description="Analyze YOLOv8 flower dataset")
    parser.add_argument("--data-dir", default="data", help="Path to data directory")
    args = parser.parse_args()
    
    analyzer = DatasetAnalyzer(args.data_dir)
    analyzer.run()


if __name__ == "__main__":
    main()
