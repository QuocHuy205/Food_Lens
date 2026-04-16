"""
Model Inference Module
Load model + predict food từ image
"""
import tensorflow as tf
import numpy as np
from PIL import Image
import json
import time
import logging
from io import BytesIO
import requests
from pathlib import Path

from config import (
    MODEL_PATH, CLASSES_PATH, IMG_SIZE, CONFIDENCE_THRESHOLD,
    INFERENCE_TIMEOUT, MAX_IMAGE_SIZE
)
from nutrition_db import get_nutrition_by_name, calculate_nutrition

logger = logging.getLogger(__name__)


class FoodAIModel:
    """Food recognition AI model"""
    
    def __init__(self):
        self.model = None
        self.class_names = None
        self.is_loaded = False
    
    def load(self):
        """Load model từ file"""
        try:
            logger.info(f"Loading model from {MODEL_PATH}...")
            
            # Model exist check
            if not Path(MODEL_PATH).exists():
                logger.warning(f"Model not found: {MODEL_PATH}")
                logger.warning("Using mock predictions instead")
                self.is_loaded = False
                return
            
            # Load model
            self.model = tf.keras.models.load_model(str(MODEL_PATH))
            
            # Load class names
            with open(CLASSES_PATH, 'r') as f:
                classes_dict = json.load(f)
                # classes_dict có dạng: {"0": "pho", "1": "banh_mi", ...}
                self.class_names = [classes_dict[str(i)] for i in range(len(classes_dict))]
            
            self.is_loaded = True
            logger.info(f"✅ Model loaded successfully! Classes: {len(self.class_names)}")
            
        except Exception as e:
            logger.error(f"❌ Error loading model: {e}")
            self.is_loaded = False
    
    def download_image(self, image_url: str) -> Image.Image:
        """Download image từ Cloudinary URL"""
        try:
            logger.info(f"Downloading image from {image_url[:50]}...")
            
            response = requests.get(image_url, timeout=10)
            response.raise_for_status()
            
            # Check size
            if len(response.content) > MAX_IMAGE_SIZE:
                raise ValueError(f"Image too large: {len(response.content)} bytes")
            
            image = Image.open(BytesIO(response.content))
            logger.info(f"✅ Image downloaded: {image.size}")
            return image
            
        except Exception as e:
            logger.error(f"❌ Error downloading image: {e}")
            raise
    
    def preprocess_image(self, image: Image.Image) -> np.ndarray:
        """Preprocess ảnh cho model"""
        try:
            # Convert RGBA → RGB nếu cần
            if image.mode in ('RGBA', 'LA', 'P'):
                image = image.convert('RGB')
            
            # Resize to model input size
            image = image.resize((IMG_SIZE, IMG_SIZE), Image.Resampling.LANCZOS)
            
            # Convert to array + normalize
            img_array = np.array(image).astype('float32') / 255.0
            
            # Add batch dimension
            img_batch = np.expand_dims(img_array, axis=0)
            
            logger.debug(f"Preprocessed image shape: {img_batch.shape}")
            return img_batch
            
        except Exception as e:
            logger.error(f"❌ Error preprocessing image: {e}")
            raise
    
    def predict(self, image_url: str) -> dict:
        """
        Full prediction pipeline:
        1. Download image
        2. Preprocess
        3. Run inference
        4. Get nutrition
        """
        start_time = time.time()
        
        try:
            # ===== DOWNLOAD =====
            image = self.download_image(image_url)
            
            # ===== PREPROCESS =====
            img_batch = self.preprocess_image(image)
            
            # ===== INFERENCE =====
            if not self.is_loaded or self.model is None:
                logger.warning("Model not loaded, using mock prediction")
                return self._mock_prediction(food_name="Món ăn hỗn hợp")
            
            predictions = self.model.predict(img_batch, verbose=0)
            
            # Get top prediction
            top_idx = np.argmax(predictions[0])
            confidence = float(predictions[0][top_idx])
            predicted_class = self.class_names[top_idx]
            
            # ===== GET NUTRITION =====
            food_data = get_nutrition_by_name(predicted_class)
            portion = food_data.get("default_portion", 300)
            calories = food_data["calories_per_100g"] * portion / 100
            nutrition = calculate_nutrition(food_data, portion)
            
            # ===== TOP-K PREDICTIONS =====
            top_k_idx = np.argsort(predictions[0])[-3:][::-1]
            top_predictions = [
                {
                    "name": f"{self.class_names[idx]} (VI)",
                    "confidence": float(predictions[0][idx])
                }
                for idx in top_k_idx
            ]
            
            inference_time_ms = (time.time() - start_time) * 1000
            
            return {
                "food_name": predicted_class,
                "food_name_vi": food_data.get("name_vi", predicted_class),
                "confidence": confidence,
                "calories_estimated": round(calories, 1),
                "portion_grams": portion,
                "nutrition": nutrition,
                "top_predictions": top_predictions,
                "inference_time_ms": round(inference_time_ms, 2),
                "model_version": "v1.0",
            }
            
        except Exception as e:
            logger.error(f"❌ Prediction error: {e}")
            raise
    
    def _mock_prediction(self, food_name: str = "Phở bò") -> dict:
        """Mock prediction nếu model không load được"""
        food_data = get_nutrition_by_name(food_name)
        portion = food_data.get("default_portion", 300)
        calories = food_data["calories_per_100g"] * portion / 100
        nutrition = calculate_nutrition(food_data, portion)
        
        return {
            "food_name": food_name,
            "food_name_vi": food_data.get("name_vi", food_name),
            "confidence": 0.75,  # Mock confidence
            "calories_estimated": round(calories, 1),
            "portion_grams": portion,
            "nutrition": nutrition,
            "top_predictions": [
                {"name": food_name, "confidence": 0.75},
                {"name": "Phở gà", "confidence": 0.15},
                {"name": "Bún chả", "confidence": 0.10},
            ],
            "inference_time_ms": 150.0,
            "model_version": "mock",
        }


# Global model instance
_model_instance = None


def get_model() -> FoodAIModel:
    """Get or create model instance"""
    global _model_instance
    if _model_instance is None:
        _model_instance = FoodAIModel()
        _model_instance.load()
    return _model_instance


async def analyze_food_image(image_url: str) -> dict:
    """Async wrapper for prediction"""
    model = get_model()
    return model.predict(image_url)
