"""
Food AI Server - FastAPI Backend
Nhận ảnh multipart từ Flutter app, xử lý AI inference, trả về kết quả.
"""
import logging
import time
from datetime import datetime

from fastapi import FastAPI, File, HTTPException, UploadFile, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from config import ALLOWED_ORIGINS, DEBUG, HOST, PORT
from inference import analyze_food_image, analyze_uploaded_image, get_model
from schemas import AnalyzeRequest, AnalyzeResponse, HealthResponse, PredictResponse

# ===== LOGGING =====
logging.basicConfig(
    level=logging.DEBUG if DEBUG else logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ===== CREATE APP =====
app = FastAPI(
    title="Food AI Server",
    description="AI backend cho Food Lens mobile app",
    version="1.0.0",
)

# ===== CORS MIDDLEWARE =====
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ===== LIFESPAN =====
@app.on_event("startup")
async def startup_event():
    """Load model khi server start"""
    logger.info("🟢 Server starting...")
    model = get_model()
    logger.info(f"Model loaded: {model.is_loaded}")


@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup khi server shutdown"""
    logger.info("🔴 Server shutting down...")


# ===== HEALTH CHECK =====
@app.get(
    "/health",
    response_model=HealthResponse,
    tags=["Health"]
)
async def health_check():
    """
    Health check endpoint
    
    Returns:
        - status: "healthy" hoặc "degraded"
        - model_loaded: True nếu model sẵn sàng
    """
    model = get_model()
    return HealthResponse(
        status="healthy" if model.is_loaded else "degraded",
        message="Food AI server is running" if model.is_loaded else "Model not loaded",
        timestamp=datetime.now(),
        model_loaded=model.is_loaded,
    )


# ===== ROOT =====
@app.get("/", tags=["Root"])
async def root():
    """Root endpoint - info"""
    return {
        "name": "Food AI Server",
        "version": "1.0.0",
        "status": "running",
        "endpoints": {
            "health": "/health",
            "analyze": "/analyze",
            "docs": "/docs",
        },
    }


# ===== MAIN ENDPOINT: ANALYZE FOOD =====
@app.post(
    "/predict",
    response_model=PredictResponse,
    status_code=status.HTTP_200_OK,
    tags=["Inference"]
)
async def predict_food(image: UploadFile = File(...)):
    """
    Predict food from uploaded image bytes.

    Flutter sends multipart/form-data with key `image`.
    The server decodes the image in memory, resizes to model input,
    preprocesses, runs the TensorFlow model, and returns the prediction.
    """
    started_at = time.perf_counter()

    try:
        if not image.content_type or not image.content_type.startswith("image/"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Uploaded file must be an image",
            )

        image_bytes = await image.read()
        if not image_bytes:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Empty image payload",
            )

        result = analyze_uploaded_image(image_bytes)
        result["response_time_ms"] = round((time.perf_counter() - started_at) * 1000, 2)

        logger.info(
            "Prediction complete (%sms): %s @ %s",
            result["response_time_ms"],
            result["food_name"],
            result["confidence"],
        )

        return PredictResponse(success=True, data=result)

    except HTTPException:
        raise
    except ValueError as e:
        logger.warning("Validation error: %s", e)
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        logger.exception("Prediction failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Prediction failed: {e}",
        )


@app.post(
    "/analyze",
    response_model=AnalyzeResponse,
    status_code=status.HTTP_200_OK,
    tags=["Inference"]
)
async def analyze_food(request: AnalyzeRequest):
    """
    🔍 Analyze food từ image URL.

    Flow:
    1. Flutter app upload ảnh lên Cloudinary
    2. Send POST /analyze với image_url
    3. Server download ảnh, run AI inference
    4. Return: food name + calories + nutrition
    """
    started_at = time.perf_counter()

    if not request.image_url:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="image_url cannot be empty",
        )

    try:
        result = analyze_food_image(request.image_url)
        result["response_time_ms"] = round((time.perf_counter() - started_at) * 1000, 2)

        logger.info(
            "Remote prediction complete (%sms): %s @ %s",
            result["response_time_ms"],
            result["food_name"],
            result["confidence"],
        )

        return AnalyzeResponse(success=True, data=result)
    except ValueError as e:
        logger.warning("Analyze request validation failed: %s", e)
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        logger.exception("Analyze request failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Analyze failed: {e}"
        )


# ===== ERROR HANDLERS =====
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Catch-all exception handler"""
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "Internal server error"}
    )


# ===== RUN SERVER =====
if __name__ == "__main__":
    import uvicorn
    
    logger.info(f"🚀 Starting server on {HOST}:{PORT}")
    
    uvicorn.run(
        app,
        host=HOST,
        port=PORT,
        log_level="debug" if DEBUG else "info",
        reload=DEBUG,  # Reload trên file change nếu DEBUG=True
    )

