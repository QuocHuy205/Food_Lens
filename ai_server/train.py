"""
Training Pipeline for Food AI Model
Train từ dataset Vietnamese Food
"""
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import GlobalAveragePooling2D, Dense, Dropout, Input
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau, ModelCheckpoint
import numpy as np
import json
from pathlib import Path
import logging

from config import (
    DATA_DIR, MODELS_DIR, IMG_SIZE, BATCH_SIZE, EPOCHS, NUM_CLASSES,
    MODEL_PATH, TFLITE_PATH, CLASSES_PATH
)

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)


class FoodAITrainer:
    """Training Pipeline"""
    
    def __init__(self, img_size=IMG_SIZE, batch_size=BATCH_SIZE, epochs=EPOCHS, num_classes=NUM_CLASSES):
        self.img_size = img_size
        self.batch_size = batch_size
        self.epochs = epochs
        self.num_classes = num_classes
        self.model = None
        self.history = None
    
    def prepare_data(self, data_dir=DATA_DIR / "vietnamese_food_101"):
        """
        Prepare data generators với augmentation
        
        Expected structure:
        data/vietnamese_food_101/
        ├── train/
        │   ├── pho/       (ảnh)
        │   ├── banh_mi/   (ảnh)
        │   └── ...
        └── val/
            ├── pho/
            ├── banh_mi/
            └── ...
        """
        logger.info(f"Loading data from {data_dir}")
        
        train_dir = data_dir / "train"
        val_dir = data_dir / "val"
        
        if not train_dir.exists():
            raise ValueError(f"Training data not found: {train_dir}")
        
        # Data Augmentation
        train_datagen = ImageDataGenerator(
            rescale=1./255,
            rotation_range=20,
            width_shift_range=0.2,
            height_shift_range=0.2,
            shear_range=0.2,
            zoom_range=0.2,
            horizontal_flip=True,
            fill_mode='nearest'
        )
        
        val_datagen = ImageDataGenerator(rescale=1./255)
        
        # Load generators
        train_generator = train_datagen.flow_from_directory(
            train_dir,
            target_size=(self.img_size, self.img_size),
            batch_size=self.batch_size,
            class_mode='categorical',
            shuffle=True
        )
        
        val_generator = val_datagen.flow_from_directory(
            val_dir,
            target_size=(self.img_size, self.img_size),
            batch_size=self.batch_size,
            class_mode='categorical',
            shuffle=False
        )
        
        logger.info(f"✅ Data loaded: {train_generator.samples} train, {val_generator.samples} val")
        logger.info(f"Classes: {train_generator.class_indices}")
        
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
            Dropout(0.5),
            Dense(128, activation='relu'),
            Dropout(0.3),
            Dense(self.num_classes, activation='softmax')
        ])
        
        # Compile
        optimizer = Adam(learning_rate=0.001)
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
                patience=5,
                restore_best_weights=True,
                verbose=1
            ),
            ReduceLROnPlateau(
                monitor='val_loss',
                factor=0.5,
                patience=3,
                min_lr=1e-7,
                verbose=1
            ),
            ModelCheckpoint(
                str(MODELS_DIR / "best_model.h5"),
                monitor='val_accuracy',
                save_best_only=True,
                verbose=1
            )
        ]
        
        history = self.model.fit(
            train_generator,
            validation_data=val_generator,
            epochs=self.epochs,
            steps_per_epoch=train_generator.samples // self.batch_size,
            validation_steps=val_generator.samples // self.batch_size,
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
        # Reverse: {"pho": 0} → {"0": "pho"}
        classes_dict = {str(v): k for k, v in classes.items()}
        
        with open(classes_path, 'w') as f:
            json.dump(classes_dict, f, indent=2)
        
        logger.info(f"✅ Classes saved: {classes_path}")


def main():
    """Main training pipeline"""
    try:
        # Create trainer
        trainer = FoodAITrainer()
        
        # Prepare data
        train_gen, val_gen = trainer.prepare_data()
        
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
