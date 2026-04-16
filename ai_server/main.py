"""
Food AI Server - FastAPI Backend
Nhận request từ Flutter app, xử lý AI inference, trả về kết quả
"""
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import logging
from datetime import datetime
import time

from config import ALLOWED_ORIGINS, DEBUG, HOST, PORT
from schemas import AnalyzeRequest, AnalyzeResponse, HealthResponse
from inference import get_model, analyze_food_image

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
        message="Food AI server is running" if model.is_loaded else "Model not loaded - using mock",
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
    "/analyze",
    response_model=AnalyzeResponse,
    status_code=status.HTTP_200_OK,
    tags=["Inference"]
)
async def analyze_food(request: AnalyzeRequest):
    """
    🔍 Analyze food từ image URL
    
    Flow:
    1. Flutter app upload ảnh lên Cloudinary
    2. Send POST /analyze với image_url
    3. Server download ảnh, run AI inference
    4. Return: food name + calories + nutrition
    
    Args:
        request: {image_url, user_id}
    
    Returns:
        {success, data: {food_name, calories, nutrition, ...}}
    
    Example:
        ```json
        POST /analyze
        {
            "image_url": "https://res.cloudinary.com/...",
            "user_id": "user123"
        }
        ```
    """
    start_time = time.time()
    
    try:
        logger.info(f"📸 Analyzing food for user {request.user_id}")
        logger.debug(f"Image URL: {request.image_url[:50]}...")
        
        # ===== RUN INFERENCE =====
        result = await analyze_food_image(request.image_url)
        
        # ===== BUILD RESPONSE =====
        response_time_ms = (time.time() - start_time) * 1000
        result["response_time_ms"] = round(response_time_ms, 2)
        
        logger.info(
            f"✅ Analysis complete ({response_time_ms:.0f}ms): "
            f"{result['food_name']} @ {result['confidence']:.0%}"
        )
        
        return AnalyzeResponse(
            success=True,
            data=result,
        )
        
    except ValueError as e:
        logger.warning(f"⚠️ Validation error: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"❌ Server error: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Inference failed: " + str(e)
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

