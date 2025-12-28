
from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

class Feedback(BaseModel):
    image_id: str
    correct_label: int

@router.post("/feedback")
def submit_feedback(feedback: Feedback):
    # Store feedback for retraining
    return {"status": "feedback_received", "data": feedback.dict()}
