# train_pollination_readiness.py

import os
import random
import numpy as np
import pandas as pd
import joblib

from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix
)

# ============================================================
# Reproducibility
# ============================================================
SEED = 42
np.random.seed(SEED)
random.seed(SEED)

# ============================================================
# Resolve base directory safely
# ============================================================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

DATASET_DIR = os.path.join(
    BASE_DIR,
    "datasets",
    "pollination"
)

TRAIN_PATH = os.path.join(DATASET_DIR, "pollination_readiness_train.csv")
VAL_PATH   = os.path.join(DATASET_DIR, "pollination_readiness_val.csv")
TEST_PATH  = os.path.join(DATASET_DIR, "pollination_readiness_test.csv")

print("Training data path:", TRAIN_PATH)
print("Validation data path:", VAL_PATH)
print("Testing data path:", TEST_PATH)

# ============================================================
# Load datasets
# ============================================================
train_df = pd.read_csv(TRAIN_PATH)
val_df   = pd.read_csv(VAL_PATH)
test_df  = pd.read_csv(TEST_PATH)

print("\nDataset sizes:")
print("Train samples:", len(train_df))
print("Validation samples:", len(val_df))
print("Test samples:", len(test_df))

# ============================================================
# Basic EDA
# ============================================================
print("\nSample data:")
print(train_df.head())

print("\nData description:")
print(train_df.describe())

print("\nChecking for missing values:")
print(train_df.isnull().sum())

print("\nClass distribution:")
print(train_df["flower_stage"].value_counts())

print("\nColumns:")
print(train_df.columns.tolist())

# ============================================================
# Feature correlation (numeric only)
# ============================================================
feature_cols = ["temperature", "humidity", "light_lux", "soil_moisture"]

print("\nFeature correlations:")
print(train_df[feature_cols].corr())

# ============================================================
# Feature / label split
# ============================================================
X_train = train_df[feature_cols]
X_val   = val_df[feature_cols]
X_test  = test_df[feature_cols]

# Encode target labels
# Encode target labels
le = LabelEncoder()
y_train = le.fit_transform(train_df["flower_stage"])
y_val   = le.transform(val_df["flower_stage"])
y_test  = le.transform(test_df["flower_stage"])

label_mapping = {label: idx for idx, label in enumerate(le.classes_)}
print("Label mapping:", label_mapping)


# ============================================================
# Model training
# ============================================================
model = RandomForestClassifier(
    n_estimators=300,
    max_depth=None,
    random_state=SEED,
    class_weight="balanced",
    n_jobs=-1
)

print("\nTraining model...")
model.fit(X_train, y_train)

# ============================================================
# Validation evaluation
# ============================================================
val_preds = model.predict(X_val)

print("\nValidation Accuracy:", accuracy_score(y_val, val_preds))
print("\nValidation Classification Report:")
print(classification_report(y_val, val_preds, target_names=le.classes_))

# ============================================================
# Test evaluation
# ============================================================
test_preds = model.predict(X_test)

print("\nTest Accuracy:", accuracy_score(y_test, test_preds))
print("\nTest Classification Report:")
print(classification_report(y_test, test_preds, target_names=le.classes_))

print("\nConfusion Matrix:")
print(confusion_matrix(y_test, test_preds))

# ============================================================
# Feature importance (for research & explainability)
# ============================================================
feature_importance = pd.Series(
    model.feature_importances_,
    index=feature_cols
).sort_values(ascending=False)

print("\nFeature importance:")
print(feature_importance)

# ============================================================
# Save artifacts
# ============================================================
ARTIFACT_DIR = os.path.join(BASE_DIR, "artifacts")
os.makedirs(ARTIFACT_DIR, exist_ok=True)

MODEL_PATH = os.path.join(ARTIFACT_DIR, "pollination_readiness_model.joblib")
ENCODER_PATH = os.path.join(ARTIFACT_DIR, "pollination_readiness_label_encoder.joblib")

joblib.dump(model, MODEL_PATH)
joblib.dump(le, ENCODER_PATH)

print("\nArtifacts saved:")
print("Model:", MODEL_PATH)
print("Label encoder:", ENCODER_PATH)

print("\nTraining pipeline completed successfully.")
