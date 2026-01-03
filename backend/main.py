from fastapi import FastAPI, UploadFile, File
import pandas as pd
import numpy as np
import joblib
import os

# ============================================================
# Create app
# ============================================================
app = FastAPI(title="Pollination Readiness API")

# ============================================================
# Load ML artifacts
# ============================================================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

MODEL_PATH = os.path.join(
    BASE_DIR, "..", "ml-training", "artifacts",
    "pollination_readiness_model.joblib"
)

ENCODER_PATH = os.path.join(
    BASE_DIR, "..", "ml-training", "artifacts",
    "pollination_readiness_label_encoder.joblib"
)

model = joblib.load(MODEL_PATH)
encoder = joblib.load(ENCODER_PATH)

# ============================================================
# Health check (VERY IMPORTANT)
# ============================================================
@app.get("/")
def root():
    return {"status": "API running"}

# ============================================================
# CSV prediction endpoint
# ============================================================
@app.post("/predict/csv")
async def predict_csv(file: UploadFile = File(...)):
    df = pd.read_csv(file.file)

    feature_cols = [
        "temperature",
        "humidity",
        "light_lux",
        "soil_moisture"
    ]

    missing = set(feature_cols) - set(df.columns)
    if missing:
        return {
            "error": "Missing required columns",
            "missing_columns": list(missing)
        }

    X = df[feature_cols].values
    preds = model.predict(X)
    probs = model.predict_proba(X)

    results = []
    for i, pred in enumerate(preds):
        results.append({
            "row": i,
            "prediction": encoder.inverse_transform([pred])[0],
            "confidence": float(np.max(probs[i]))
        })

    return {
        "rows_processed": len(results),
        "results": results
    }
