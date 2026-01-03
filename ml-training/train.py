import pandas as pd

BASE_PATH = "datasets/pollination"

train_df = pd.read_csv(f"{BASE_PATH}/pollination_readiness_train.csv")
val_df   = pd.read_csv(f"{BASE_PATH}/pollination_readiness_val.csv")
test_df  = pd.read_csv(f"{BASE_PATH}/pollination_readiness_test.csv")

print("Train samples:", len(train_df))
print("Validation samples:", len(val_df))
print("Test samples:", len(test_df))
print("\nSample data:")
print(train_df.head())
print("\nData description:")
print(train_df.describe())
print("\nChecking for missing values:")
print(train_df.isnull().sum())
print("\nClass distribution:")
print(train_df['readiness'].value_counts())
# Further data preprocessing and model training code would go here
print("\nFeature correlations:")
print(train_df.corr())
