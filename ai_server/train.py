"""
Training Pipeline for Food AI Model
Train từ dataset Vietnamese Food - GPU Optimized
"""
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import GlobalAveragePooling2D, Dense, Dropout, Input
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau, ModelCheckpoint
from tensorflow.keras import mixed_precision
import numpy as np
import json
from pathlib import Path
import logging

from config import (
    DATASET_DIR, MODELS_DIR, IMG_SIZE, BATCH_SIZE, EPOCHS, NUM_CLASSES,
    VALIDATION_SPLIT, MODEL_PATH, TFLITE_PATH, CLASSES_PATH,
    USE_GPU, MIXED_PRECISION
)

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

# Enable GPU + Mixed Precision
if USE_GPU:
    gpus = tf.config.list_physical_devices('GPU')
    if gpus:
        logger.info(f"🚀 {len(gpus)} GPU(s) detected: {gpus}")
        for gpu in gpus:
            tf.config.experimental.set_memory_growth(gpu, True)

if MIXED_PRECISION:
    policy = mixed_precision.Policy('mixed_float16')
    mixed_precision.set_global_policy(policy)
    logger.info("✨ Mixed Precision enabled (FP16)")


class FoodAITrainer:
    """Training Pipeline"""
    
    def __init__(self, img_size=IMG_SIZE, batch_size=BATCH_SIZE, epochs=EPOCHS, num_classes=NUM_CLASSES):
        self.img_size = img_size
        self.batch_size = batch_size
        self.epochs = epochs
        self.num_classes = num_classes
        self.model = None
        self.history = None
    
    def prepare_data(self, data_dir=DATASET_DIR):
        """
        Prepare data generators with augmentation from a single root directory.

        Expected structure:
        data/images/
        ├── pho/
        │   ├── pho_001.jpg
        │   ├── pho_002.jpg
        ├── banh_mi/
        │   ├── banh_mi_001.jpg
        └── ...
        """
        logger.info(f"Loading data from {data_dir}")

        if not data_dir.exists():
            raise ValueError(f"Training data not found: {data_dir}")

        data_gen = ImageDataGenerator(
            rescale=1.0 / 255.0,
            rotation_range=20,
            width_shift_range=0.2,
            height_shift_range=0.2,
            shear_range=0.2,
            zoom_range=0.2,
            horizontal_flip=True,
            fill_mode="nearest",
            validation_split=VALIDATION_SPLIT,
        )

        train_generator = data_gen.flow_from_directory(
            data_dir,
            target_size=(self.img_size, self.img_size),
            batch_size=self.batch_size,
            class_mode="categorical",
            subset="training",
            shuffle=True,
        )

        val_generator = data_gen.flow_from_directory(
            data_dir,
            target_size=(self.img_size, self.img_size),
            batch_size=self.batch_size,
            class_mode="categorical",
            subset="validation",
            shuffle=False,
        )

        logger.info(
            "✅ Data loaded: %s train, %s val",
            train_generator.samples,
            val_generator.samples,
        )
        logger.info("Classes: %s", train_generator.class_indices)

        return train_generator, val_generator
    
    def build_model(self):
        """Build model với Transfer Learning"""
        logger.info("Building model with MobileNetV2...")
        
        # Load base model
        base_model = MobileNetV2(
            input_shape=(self.img_size, self.img_size, 3),
            include_top=False,
            weights='imagenet'
        )
        
        # Freeze base layers
        base_model.trainable = False
        
        # Build model
        model = tf.keras.Sequential([
            base_model,
            GlobalAveragePooling2D(),
            Dense(256, activation='relu'),
            Dropout(0.3),  # Reduced from 0.5 to prevent underfitting
            Dense(128, activation='relu'),
            Dropout(0.2),  # Reduced from 0.3
            Dense(self.num_classes, activation='softmax')
        ])
        
        # Compile with optimized learning rate
        # Increased from 0.001 to 0.005 for faster convergence
        optimizer = Adam(learning_rate=0.005)
        model.compile(
            optimizer=optimizer,
            loss='categorical_crossentropy',
            metrics=[
                'accuracy',
                tf.keras.metrics.TopKCategoricalAccuracy(k=3, name='top_3_accuracy')
            ]
        )
        
        logger.info(model.summary())
        self.model = model
        return model
    
    def train(self, train_generator, val_generator):
        """Train model"""
        logger.info("Starting training...")
        
        callbacks = [
            EarlyStopping(
                monitor='val_loss',
                patience=15,  # Increased from 5 to allow model more training time
                restore_best_weights=True,
                verbose=1
            ),
            ReduceLROnPlateau(
                monitor='val_loss',
                factor=0.5,
                patience=5,  # Reduce LR if val_loss plateaus
                min_lr=1e-7,
                verbose=1
            ),
            ModelCheckpoint(
                str(MODEL_PATH),
                monitor='val_accuracy',
                save_best_only=True,
                verbose=1
            )
        ]
        
        steps_per_epoch = max(1, train_generator.samples // self.batch_size)
        validation_steps = max(1, val_generator.samples // self.batch_size)

        history = self.model.fit(
            train_generator,
            validation_data=val_generator,
            epochs=self.epochs,
            steps_per_epoch=steps_per_epoch,
            validation_steps=validation_steps,
            callbacks=callbacks,
            verbose=1
        )
        
        self.history = history
        logger.info("✅ Training complete!")
        return history
    
    def save_model(self, model_path=MODEL_PATH):
        """Save model"""
        logger.info(f"Saving model to {model_path}")
        self.model.save(str(model_path))
        logger.info("✅ Model saved!")
    
    def convert_to_tflite(self, tflite_path=TFLITE_PATH):
        """Convert model to TFLite"""
        logger.info(f"Converting to TFLite: {tflite_path}")
        
        converter = tf.lite.TFLiteConverter.from_keras_model(self.model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_ops = [
            tf.lite.OpsSet.TFLITE_BUILTINS,
            tf.lite.OpsSet.SELECT_TF_OPS
        ]
        
        tflite_model = converter.convert()
        
        with open(tflite_path, 'wb') as f:
            f.write(tflite_model)
        
        size_mb = len(tflite_model) / 1024 / 1024
        logger.info(f"✅ TFLite model saved: {size_mb:.1f} MB")
    
    def save_classes(self, train_generator, classes_path=CLASSES_PATH):
        """Save class names"""
        classes = train_generator.class_indices
        classes_dict = {str(v): k for k, v in classes.items()}

        with open(classes_path, 'w', encoding='utf-8') as f:
            json.dump(classes_dict, f, indent=2, ensure_ascii=False)

        logger.info(f"✅ Classes saved: {classes_path}")


def main():
    """Main training pipeline"""
    try:
        # Create trainer
        trainer = FoodAITrainer()
        
        # Prepare data
        train_gen, val_gen = trainer.prepare_data()
        trainer.num_classes = train_gen.num_classes

        # Build model
        trainer.build_model()

        # Train
        trainer.train(train_gen, val_gen)
        
        # Save
        trainer.save_model()
        trainer.convert_to_tflite()
        trainer.save_classes(train_gen)
        
        logger.info("✅ All done!")
        
    except Exception as e:
        logger.error(f"❌ Training failed: {e}", exc_info=True)


if __name__ == "__main__":
    main()
