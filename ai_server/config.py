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

# Model Configuration
MODEL_PATH = MODELS_DIR / "model_v1.h5"
TFLITE_PATH = MODELS_DIR / "model_v1.tflite"
CLASSES_PATH = MODELS_DIR / "classes.json"
NUTRITION_DB_PATH = MODELS_DIR / "nutrition_db.json"

# TensorFlow Config
IMG_SIZE = 224
BATCH_SIZE = 32
NUM_CLASSES = 50  # Vietnamese foods

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
