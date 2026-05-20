"""
Model Inference Module
Load model once and predict food from uploaded image bytes.
"""
from __future__ import annotations

import json
import logging
import time
from io import BytesIO
from pathlib import Path
from threading import Lock
from urllib.parse import urlparse

import numpy as np
import requests
import tensorflow as tf
from PIL import Image, ImageOps

from config import (
    CLASSES_PATH,
    IMG_SIZE,
    MODEL_PATH,
    MAX_UPLOAD_BYTES,
    PREDICT_TOP_K,
    REQUEST_TIMEOUT,
)
from nutrition_db import calculate_nutrition, get_nutrition_by_name

BASE_DIR = Path(__file__).parent
LEGACY_MODEL_PATH = BASE_DIR / "food_model.h5"

logger = logging.getLogger(__name__)


def _build_food_model(input_size: int, output_units: int) -> tf.keras.Model:
    inputs = tf.keras.Input(shape=(input_size, input_size, 3), name="input_layer_1")
    base_model = tf.keras.applications.MobileNetV2(
        include_top=False,
        weights=None,
        input_tensor=inputs,
        alpha=1.0,
    )
    x = tf.keras.layers.GlobalAveragePooling2D(name="global_average_pooling2d")(base_model.output)
    x = tf.keras.layers.Dense(128, activation="relu", name="dense")(x)
    x = tf.keras.layers.Dropout(0.3, name="dropout")(x)
    outputs = tf.keras.layers.Dense(output_units, activation="softmax", name="dense_1")(x)
    return tf.keras.Model(inputs=inputs, outputs=outputs, name="sequential")


def _load_legacy_h5_model(model_path: Path, input_size: int, output_units: int):
    """Load legacy H5 model with monkeypatching for Keras 3 compatibility."""
    import h5py
    
    # Try direct load first (in case H5 was saved with Keras 3)
    try:
        model = tf.keras.saving.load_model(str(model_path))
        logger.info("✅ Direct model.load_model() succeeded")
        return model
    except Exception as e:
        logger.warning(f"Direct load failed: {e}, trying rebuild+weights...")
    
    # Fallback: Rebuild architecture and load weights only
    model = _build_food_model(input_size=input_size, output_units=output_units)
    try:
        model.load_weights(str(model_path), by_name=True, skip_mismatch=True)
        logger.info("✅ Loaded weights with by_name=True")
    except Exception as e:
        logger.error(f"❌ Weight loading failed: {e}")
        # Continue anyway - model will have random weights, better than crashing
    
    return model


def _infer_output_units_from_h5(model_path: Path) -> int:
    with tf.io.gfile.GFile(str(model_path), "rb") as file_handle:
        import h5py

        with h5py.File(file_handle, "r") as file:
            model_config = file.attrs.get("model_config")

    if isinstance(model_config, (bytes, bytearray)):
        model_config = model_config.decode("utf-8")

    parsed = json.loads(model_config)
    layers = parsed.get("config", {}).get("layers", [])
    for layer in reversed(layers):
        if layer.get("class_name") == "Dense":
            return int(layer.get("config", {}).get("units", 1))

    raise RuntimeError("Could not infer output units from model_config")


class FoodAIModel:
    """Food recognition model wrapper with single-load semantics."""

    def __init__(self) -> None:
        self.model: tf.keras.Model | None = None
        self.class_names: list[str] | None = None
        self.input_size = IMG_SIZE
        self.is_loaded = False
        self._lock = Lock()
        self._predict_fn = None

    def load(self) -> None:
        """Load model and labels once during server startup."""
        with self._lock:
            if self.is_loaded:
                return

            model_path = self._resolve_model_path()
            logger.info("Loading TensorFlow model from %s", model_path)
            output_units = _infer_output_units_from_h5(model_path)
            self.class_names = self._load_class_names(output_units)
            self.input_size = IMG_SIZE
            self.model = _load_legacy_h5_model(
                model_path,
                input_size=self.input_size,
                output_units=output_units,
            )

            # Warm up predict path once so first real request does not pay tracing cost.
            dummy = np.zeros((1, self.input_size, self.input_size, 3), dtype=np.float32)
            _ = self._predict(dummy)

            self.is_loaded = True
            logger.info(
                "Model loaded successfully: classes=%s input=%sx%s",
                len(self.class_names),
                self.input_size,
                self.input_size,
            )

    def _load_class_names(self, output_units: int) -> list[str]:
        if Path(CLASSES_PATH).exists():
            with open(CLASSES_PATH, "r", encoding="utf-8") as file:
                raw = json.load(file)
            if isinstance(raw, dict):
                classes = [raw[str(index)] for index in range(len(raw))]
                logger.info(f"✅ Loaded {len(classes)} classes from {CLASSES_PATH}: {classes[:5]}...")
                return classes
            if isinstance(raw, list):
                logger.info(f"✅ Loaded {len(raw)} classes from {CLASSES_PATH}")
                return [str(item) for item in raw]

        logger.warning(
            "❌ No class label file found at %s; using class_# placeholders for %s outputs",
            CLASSES_PATH,
            output_units,
        )
        return [f"class_{index}" for index in range(output_units)]

    def _resolve_model_path(self) -> Path:
        if Path(MODEL_PATH).exists():
            return Path(MODEL_PATH)
        if LEGACY_MODEL_PATH.exists():
            logger.warning("Using legacy model path: %s", LEGACY_MODEL_PATH)
            return LEGACY_MODEL_PATH
        raise FileNotFoundError(f"Model not found: {MODEL_PATH} or {LEGACY_MODEL_PATH}")

    def _preprocess_image(self, image_bytes: bytes) -> np.ndarray:
        if len(image_bytes) > MAX_UPLOAD_BYTES:
            raise ValueError(f"Image too large: {len(image_bytes)} bytes")

        image = Image.open(BytesIO(image_bytes))
        image = ImageOps.exif_transpose(image)
        if image.mode != "RGB":
            image = image.convert("RGB")
        image = image.resize((self.input_size, self.input_size), Image.Resampling.BILINEAR)

        image_array = np.asarray(image, dtype=np.float32)
        image_array *= 1.0 / 255.0
        return np.expand_dims(image_array, axis=0)

    def _predict(self, batch: np.ndarray) -> np.ndarray:
        if self.model is None:
            raise RuntimeError("Model not loaded")

        if self._predict_fn is None:
            self._predict_fn = self.model.predict

        return self._predict_fn(batch, verbose=0)

    def predict_image_bytes(self, image_bytes: bytes) -> dict:
        if not self.is_loaded:
            raise RuntimeError("Model is not loaded")

        started_at = time.perf_counter()
        batch = self._preprocess_image(image_bytes)
        predictions = self._predict(batch)
        scores = predictions[0]

        # DEBUG: Log raw scores to detect overfitting
        logger.info(f"[DEBUG] Raw prediction scores (first 10): {scores[:10]}")
        logger.info(f"[DEBUG] Max score: {scores.max():.6f}, Min score: {scores.min():.6f}, Mean: {scores.mean():.6f}")
        
        top_indices = np.argsort(scores)[-PREDICT_TOP_K:][::-1]
        top_index = int(top_indices[0])
        confidence = float(scores[top_index])
        predicted_key = self.class_names[top_index]
        
        # DEBUG: Log top-3 predictions
        logger.info(f"[DEBUG] Top-3 predictions: {[(self.class_names[int(idx)], float(scores[int(idx)])) for idx in top_indices]}")

        food_data = get_nutrition_by_name(predicted_key)
        portion_grams = int(food_data.get("default_portion", 300))
        calories_estimated = round(food_data["calories_per_100g"] * portion_grams / 100, 1)
        nutrition = calculate_nutrition(food_data, portion_grams)

        top_predictions = []
        for index in top_indices:
            class_key = self.class_names[int(index)]
            nutrition_data = get_nutrition_by_name(class_key)
            top_predictions.append(
                {
                    "name": nutrition_data.get("name_vi", class_key),
                    "class_key": class_key,
                    "confidence": round(float(scores[int(index)]), 6),
                }
            )

        inference_time_ms = round((time.perf_counter() - started_at) * 1000, 2)

        return {
            "food_name": predicted_key,
            "food_name_vi": food_data.get("name_vi", predicted_key),
            "confidence": round(confidence, 6),
            "calories_estimated": calories_estimated,
            "portion_grams": portion_grams,
            "nutrition": nutrition,
            "top_predictions": top_predictions,
            "inference_time_ms": inference_time_ms,
            "model_version": "food_model.h5",
            "input_size": self.input_size,
        }


_model_instance: FoodAIModel | None = None


def get_model() -> FoodAIModel:
    global _model_instance
    if _model_instance is None:
        _model_instance = FoodAIModel()
        _model_instance.load()
    return _model_instance


def analyze_uploaded_image(image_bytes: bytes) -> dict:
    model = get_model()
    return model.predict_image_bytes(image_bytes)


def analyze_food_image(image_url: str) -> dict:
    if not image_url:
        raise ValueError("Image URL is required")

    parsed = urlparse(image_url)
    if parsed.scheme not in {"http", "https"}:
        raise ValueError("Invalid image URL")

    response = requests.get(image_url, timeout=REQUEST_TIMEOUT, stream=True)
    if response.status_code != 200:
        raise ValueError(f"Failed to download image: HTTP {response.status_code}")

    content_type = response.headers.get("Content-Type", "")
    if not content_type.startswith("image/"):
        raise ValueError("URL does not point to an image")

    image_bytes = response.content
    if len(image_bytes) > MAX_UPLOAD_BYTES:
        raise ValueError("Image downloaded from URL is too large")

    return analyze_uploaded_image(image_bytes)
