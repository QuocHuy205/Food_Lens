"""
Configuration for Food AI Server
"""
import os
from pathlib import Path
from dotenv import load_dotenv

# Load .env
load_dotenv()

# Paths
BASE_DIR = Path(__file__).parent
MODELS_DIR = BASE_DIR / "models"
DATA_DIR = BASE_DIR / "data"
LOGS_DIR = BASE_DIR / "logs"

# Create directories if not exist
MODELS_DIR.mkdir(exist_ok=True)
DATA_DIR.mkdir(exist_ok=True)
LOGS_DIR.mkdir(exist_ok=True)

# Dataset and model paths
DATASET_DIR = DATA_DIR / "images"
MODEL_FILENAME = os.getenv("MODEL_FILENAME", "model_v1.h5")
MODEL_PATH = MODELS_DIR / MODEL_FILENAME
TFLITE_PATH = MODELS_DIR / os.getenv("TFLITE_FILENAME", "model_v1.tflite")
CLASSES_PATH = MODELS_DIR / os.getenv("CLASSES_FILENAME", "classes.json")
NUTRITION_DB_PATH = MODELS_DIR / os.getenv("NUTRITION_DB_FILENAME", "nutrition_db.json")

# TensorFlow Config
IMG_SIZE = int(os.getenv("IMG_SIZE", "224"))
BATCH_SIZE = int(os.getenv("BATCH_SIZE", "96"))  # Tăng lên vì có GPU
EPOCHS = int(os.getenv("EPOCHS", "15"))  # 15 epochs cho tất cả 100 classes
VALIDATION_SPLIT = float(os.getenv("VALIDATION_SPLIT", "0.15"))
NUM_CLASSES = int(os.getenv("NUM_CLASSES", "100"))

# GPU Config
USE_GPU = True
MIXED_PRECISION = True  # Enable FP16 + FP32 cho tốc độ nhanh hơn

# Inference tuning
PREDICT_TOP_K = int(os.getenv("PREDICT_TOP_K", "3"))
MAX_UPLOAD_BYTES = int(os.getenv("MAX_UPLOAD_BYTES", str(10 * 1024 * 1024)))
PREDICT_TIMEOUT = float(os.getenv("PREDICT_TIMEOUT", "15"))
REQUEST_TIMEOUT = float(os.getenv("REQUEST_TIMEOUT", "15"))  # Timeout for downloading images from URL

# Server Config
HOST = os.getenv("SERVER_HOST", "0.0.0.0")
PORT = int(os.getenv("SERVER_PORT", 8000))
DEBUG = os.getenv("DEBUG", "False").lower() == "true"

# CORS
ALLOWED_ORIGINS = [
    "http://localhost:8080",
    "http://localhost:3000",
    "http://192.168.1.*",  # Local network
    "*",  # Development (remove in production)
]

# Inference Config
CONFIDENCE_THRESHOLD = 0.5
INFERENCE_TIMEOUT = 30  # seconds
MAX_IMAGE_SIZE = 10 * 1024 * 1024  # 10 MB

# Cloudinary (for image download)
CLOUDINARY_CLOUD_NAME = os.getenv("CLOUDINARY_CLOUD_NAME")
REQUEST_TIMEOUT = 10  # seconds

print(f"✅ Config loaded: {BASE_DIR}")
