# 🤖 AI AGENT — Pipeline & Mock Strategy

---

## Pipeline tổng quan

```
User chọn ảnh (camera/gallery)
    ↓
Upload lên Cloudinary
    ↓ (nhận được imageUrl)
Gửi POST /analyze với imageUrl
    ↓ (AI xử lý)
Nhận response: { food_name, food_name_vi, confidence, calories_estimated, nutrition }
    ↓
Hiển thị kết quả cho user
    ↓ (user confirm)
Lưu vào Firestore SCAN_HISTORY
    ↓
Cập nhật DAILY_NUTRITION_LOG
```

---

## API Response Format

```json
{
  "success": true,
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
      { "name": "Phở bò", "confidence": 0.92 },
      { "name": "Bún bò Huế", "confidence": 0.05 },
      { "name": "Hủ tiếu", "confidence": 0.03 }
    ],
    "model_version": "v1.0",
    "inference_time_ms": 234.5
  }
}
```

---

## Mock AI Server (FastAPI)

Tạo folder `ai_server/` ngoài Flutter project:

```
ai_server/
├── main.py
├── mock_data.py
├── requirements.txt
└── README.md
```

**`requirements.txt`:**
```
fastapi==0.111.0
uvicorn==0.29.0
python-multipart==0.0.9
```

**`mock_data.py`:**
```python
FOOD_DATABASE = {
    "pho": {
        "food_name": "Pho Bo",
        "food_name_vi": "Phở bò",
        "calories_per_100g": 75,
        "default_portion": 400,
        "nutrition_per_100g": {"protein_g": 7.5, "carbs_g": 9, "fat_g": 1.5, "fiber_g": 0.5}
    },
    "com_tam": {
        "food_name": "Com Tam",
        "food_name_vi": "Cơm tấm",
        "calories_per_100g": 160,
        "default_portion": 300,
        "nutrition_per_100g": {"protein_g": 8, "carbs_g": 30, "fat_g": 4, "fiber_g": 1}
    },
    "banh_mi": {
        "food_name": "Banh Mi",
        "food_name_vi": "Bánh mì",
        "calories_per_100g": 265,
        "default_portion": 150,
        "nutrition_per_100g": {"protein_g": 9, "carbs_g": 50, "fat_g": 5, "fiber_g": 2}
    },
    "bun_bo": {
        "food_name": "Bun Bo Hue",
        "food_name_vi": "Bún bò Huế",
        "calories_per_100g": 68,
        "default_portion": 450,
        "nutrition_per_100g": {"protein_g": 6, "carbs_g": 8, "fat_g": 2, "fiber_g": 0.5}
    },
    "goi_cuon": {
        "food_name": "Goi Cuon",
        "food_name_vi": "Gỏi cuốn",
        "calories_per_100g": 89,
        "default_portion": 200,
        "nutrition_per_100g": {"protein_g": 5, "carbs_g": 12, "fat_g": 1.5, "fiber_g": 1}
    },
    "salad": {
        "food_name": "Salad",
        "food_name_vi": "Salad",
        "calories_per_100g": 15,
        "default_portion": 200,
        "nutrition_per_100g": {"protein_g": 1, "carbs_g": 2, "fat_g": 0.2, "fiber_g": 2}
    },
}

# Fallback khi không nhận diện được
DEFAULT_FOOD = {
    "food_name": "Mixed Dish",
    "food_name_vi": "Món ăn hỗn hợp",
    "calories_per_100g": 120,
    "default_portion": 300,
    "nutrition_per_100g": {"protein_g": 6, "carbs_g": 15, "fat_g": 4, "fiber_g": 1}
}
```

**`main.py`:**
```python
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import random
import time
from mock_data import FOOD_DATABASE, DEFAULT_FOOD

app = FastAPI(title="Food AI Mock API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class AnalyzeRequest(BaseModel):
    image_url: str

def calculate_nutrition(food_data: dict) -> dict:
    portion = food_data["default_portion"]
    per_100g = food_data["nutrition_per_100g"]
    multiplier = portion / 100
    return {
        "protein_g": round(per_100g["protein_g"] * multiplier, 1),
        "carbs_g": round(per_100g["carbs_g"] * multiplier, 1),
        "fat_g": round(per_100g["fat_g"] * multiplier, 1),
        "fiber_g": round(per_100g["fiber_g"] * multiplier, 1),
    }

@app.get("/health")
def health_check():
    return {"status": "ok", "message": "Mock AI server running"}

@app.post("/analyze")
def analyze_food(request: AnalyzeRequest):
    # Simulate inference time
    time.sleep(random.uniform(0.5, 1.5))

    # Rule-based: kiểm tra keyword trong URL
    url_lower = request.image_url.lower()
    matched_food = None
    for key in FOOD_DATABASE:
        if key in url_lower or key.replace("_", "") in url_lower:
            matched_food = FOOD_DATABASE[key]
            break

    # Random pick nếu không match (simulate AI)
    if matched_food is None:
        matched_food = random.choice(list(FOOD_DATABASE.values()))

    confidence = round(random.uniform(0.75, 0.97), 2)
    portion = matched_food["default_portion"]
    calories = round(matched_food["calories_per_100g"] * portion / 100, 1)

    # Tạo top_predictions giả
    other_foods = [f for f in FOOD_DATABASE.values() if f != matched_food]
    random.shuffle(other_foods)
    top_predictions = [
        {"name": matched_food["food_name_vi"], "confidence": confidence},
        {"name": other_foods[0]["food_name_vi"], "confidence": round((1 - confidence) * 0.6, 2)},
        {"name": other_foods[1]["food_name_vi"], "confidence": round((1 - confidence) * 0.4, 2)},
    ]

    return {
        "success": True,
        "data": {
            "food_name": matched_food["food_name"],
            "food_name_vi": matched_food["food_name_vi"],
            "confidence": confidence,
            "calories_estimated": calories,
            "portion_grams": portion,
            "nutrition": calculate_nutrition(matched_food),
            "top_predictions": top_predictions,
            "model_version": "mock-v1.0",
            "inference_time_ms": random.uniform(200, 800),
        }
    }

# Chạy: uvicorn main:app --reload --port 8000
```

---

## Flutter — AI DataSource

```dart
// features/scan/data/datasources/ai_remote_datasource.dart
class AiRemoteDataSource {
  final Dio _dio;

  AiRemoteDataSource(this._dio);

  Future<ScanResultModel> analyzeFood(String imageUrl) async {
    final response = await _dio.post(
      '${AppConfig.aiApiBaseUrl}/analyze',
      data: {'image_url': imageUrl},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return ScanResultModel.fromJson(response.data['data']);
    }
    throw ServerException('AI API trả về lỗi');
  }
}
```

---

## Flutter — Cloudinary Upload

```dart
// features/scan/data/datasources/cloudinary_datasource.dart
class CloudinaryDataSource {
  final Dio _dio;

  CloudinaryDataSource(this._dio);

  Future<String> uploadImage(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path),
      'upload_preset': AppConfig.cloudinaryUploadPreset,
    });

    final response = await _dio.post(AppConfig.cloudinaryBaseUrl, data: formData);

    if (response.statusCode == 200) {
      return response.data['secure_url'] as String;
    }
    throw ServerException('Upload ảnh thất bại');
  }
}
```

---

## Fallback khi AI fail

```dart
// Trong ScanRepositoryImpl
Future<Either<Failure, ScanResult>> analyzeFoodImage(String imageUrl) async {
  try {
    final result = await _aiDataSource.analyzeFood(imageUrl);
    return Right(result.toDomain());
  } on DioException catch (e) {
    // Fallback: trả về kết quả mặc định
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return Right(_getFallbackResult());
    }
    return Left(NetworkFailure('Không kết nối được AI server'));
  }
}

ScanResult _getFallbackResult() => const ScanResult(
  foodName: 'Món ăn',
  foodNameVi: 'Món ăn không xác định',
  caloriesEstimated: 200.0,
  confidence: 0.0, // 0% = user biết đây là fallback
  isFallback: true,
);
```

---

## Chạy mock server

```bash
cd ai_server
pip install -r requirements.txt
uvicorn main:app --reload --port 8000

# Test
curl -X POST http://localhost:8000/analyze \
  -H "Content-Type: application/json" \
  -d '{"image_url": "https://example.com/pho.jpg"}'
```

> **Android Emulator:** Dùng `http://10.0.2.2:8000` thay vì `http://localhost:8000`
