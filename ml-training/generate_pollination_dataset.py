import pandas as pd
import numpy as np
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(BASE_DIR, "datasets", "pollination")
os.makedirs(OUT_DIR, exist_ok=True)

np.random.seed(42)

N = 5000

data = {
    "temperature": np.random.uniform(24, 32, N).round(2),
    "humidity": np.random.uniform(60, 90, N).round(2),
    "light_lux": np.random.uniform(8000, 15000, N).round(0),
    "soil_moisture": np.random.uniform(30, 55, N).round(2),
}

df = pd.DataFrame(data)

def label_stage(row):
    if row["light_lux"] > 12000 and row["humidity"] > 70:
        return "ready"
    elif row["light_lux"] > 10000:
        return "open"
    else:
        return "closed"

df["flower_stage"] = df.apply(label_stage, axis=1)

# Shuffle
df = df.sample(frac=1).reset_index(drop=True)

# Split
train = df.iloc[:3500]
val   = df.iloc[3500:4250]
test  = df.iloc[4250:]

# Save files
df.to_csv(os.path.join(OUT_DIR, "pollination_readiness_5000.csv"), index=False)
train.to_csv(os.path.join(OUT_DIR, "pollination_readiness_train.csv"), index=False)
val.to_csv(os.path.join(OUT_DIR, "pollination_readiness_val.csv"), index=False)
test.to_csv(os.path.join(OUT_DIR, "pollination_readiness_test.csv"), index=False)

# Metadata
metadata = {
    "samples_total": N,
    "features": ["temperature", "humidity", "light_lux", "soil_moisture"],
    "target": "flower_stage",
    "classes": ["closed", "open", "ready"]
}

pd.DataFrame([metadata]).to_csv(
    os.path.join(OUT_DIR, "metadata.csv"),
    index=False
)

print("Dataset generated successfully in:", OUT_DIR)
print("Metadata:")
print(metadata)
