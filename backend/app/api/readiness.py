from fastapi import APIRouter, UploadFile, File, HTTPException
import os
import shutil

router = APIRouter()

# Absolute-safe path (recommended)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
ML_DATASET_DIR = os.path.join(
    BASE_DIR,
    "..",
    "ml-training",
    "datasets",
    "pollination"
)

@router.post("/upload-dataset")
async def upload_pollination_dataset(file: UploadFile = File(...)):
    if not file.filename.endswith(".csv"): # type: ignore
        raise HTTPException(status_code=400, detail="Only CSV files are allowed")

    os.makedirs(ML_DATASET_DIR, exist_ok=True)

    save_path = os.path.join(ML_DATASET_DIR, file.filename) # type: ignore

    with open(save_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return {
        "message": "Dataset uploaded successfully",
        "filename": file.filename,
        "saved_to": save_path
    }
