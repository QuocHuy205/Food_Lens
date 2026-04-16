"""
Pydantic models for API requests/responses
"""
from pydantic import BaseModel
from typing import List, Optional, Dict
from datetime import datetime


class AnalyzeRequest(BaseModel):
    """Request to analyze food from image URL"""
    image_url: str
    user_id: str


class NutritionInfo(BaseModel):
    """Nutrition information"""
    protein_g: float
    carbs_g: float
    fat_g: float
    fiber_g: float


class FoodPrediction(BaseModel):
    """Single food prediction"""
    name: str
    confidence: float


class AnalyzeResponse(BaseModel):
    """Response from AI analysis"""
    success: bool
    data: Optional[Dict] = None
    error: Optional[str] = None
    
    model_config = {
        "json_schema_extra": {
            "example": {
                "success": True,
                "data": {
                    "food_name": "Pho Bo",
                    "food_name_vi": "Phở bò",
                    "confidence": 0.92,
                    "calories_estimated": 350.0,
                    "portion_grams": 400.0,
                    "nutrition": {
                        "protein_g": 28.0,
                        "carbs_g": 36.0,
                        "fat_g": 6.0,
                        "fiber_g": 2.0
                    },
                    "top_predictions": [
                        {"name": "Phở bò", "confidence": 0.92},
                        {"name": "Bún bò Huế", "confidence": 0.05},
                        {"name": "Hủ tiếu", "confidence": 0.03}
                    ],
                    "inference_time_ms": 234.5
                }
            }
        }
    }


class HealthResponse(BaseModel):
    """Health check response"""
    status: str
    message: str
    timestamp: datetime
    model_loaded: bool
