from fastapi import APIRouter, UploadFile, File

router = APIRouter()

@router.post("/upload")
async def upload_image(file: UploadFile = File(...)):
    return {
        "filename": file.filename,
        "status": "Image received, sent for ML inference"
    }
@router.get("/status")
def image_status():
    return {"status": "Image API is operational"}
  