from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import json
from datetime import datetime
from mock_data import get_mock_food_result

app = FastAPI(title="Food AI - Mock Server", version="1.0.0")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class AnalyzeRequest(BaseModel):
    image_url: str


class AnalyzeResponse(BaseModel):
    food_name: str
    calories_estimated: float
    confidence: float
    scanned_at: str


@app.get("/")
def read_root():
    return {"message": "Food AI Mock Server", "version": "1.0.0"}


@app.post("/analyze", response_model=AnalyzeResponse)
def analyze_food(request: AnalyzeRequest):
    """
    Mock AI endpoint that analyzes food from image URL.
    Returns mock data for testing.
    """
    try:
        # Get mock result (in real app, this would call actual AI model)
        mock_result = get_mock_food_result()

        return AnalyzeResponse(
            food_name=mock_result["food_name"],
            calories_estimated=mock_result["calories"],
            confidence=mock_result["confidence"],
            scanned_at=datetime.now().isoformat(),
        )
    except Exception as e:
        return {"error": str(e)}, 500


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
