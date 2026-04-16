# 🎯 SETUP SERVER PYTHON — HƯỚNG DẪN TỔNG THỂ

Bạn đang ở trong folder `food_lens/ai_server`. Server Python này xử lý AI inference cho app Flutter.

---

## 📋 TÓOM TẮT

```
food_lens/
├── lib/                       ← Flutter app (UI + gọi API)
├── pubspec.yaml
│
└── ai_server/                 ← ⭐ Python server (AI xử lý)
    ├── main.py                ← FastAPI app
    ├── inference.py           ← Model inference
    ├── config.py              ← Config
    ├── schemas.py             ← Pydantic models
    ├── nutrition_db.py        ← Food DB
    ├── train.py               ← Training code
    │
    ├── models/                ← Saved models (git-lfs)
    │   ├── model_v1.h5        ← Full model (150 MB)
    │   ├── model_v1.tflite    ← Mobile model (20 MB)
    │   └── classes.json
    │
    ├── data/                  ← Training dataset
    │   └── vietnamese_food_101/
    │       ├── train/
    │       └── val/
    │
    ├── requirements.txt       ← Dependencies
    ├── .env                   ← Config (gitignored)
    ├── .env.example           ← Template
    ├── Dockerfile             ← Docker build
    ├── docker-compose.yml     ← Local dev
    └── README_SERVER.md       ← Hướng dẫn chi tiết
```

---

## 🚀 QUICK START (5 PHÚT)

### **1️⃣ Virtual Environment**

```bash
cd ai_server
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

### **2️⃣ Install Dependencies**

```bash
pip install -r requirements.txt
```

### **3️⃣ Run Server**

```bash
python main.py
```

**Output:**

```
INFO:     Uvicorn running on http://0.0.0.0:8000
Model loaded: True ✅
```

### **4️⃣ Test API**

```bash
curl -X GET http://localhost:8000/health

# Result
```

```json
{
  "status": "healthy",
  "model_loaded": true
}
```

---

## 📁 CÁC FILE QUAN TRỌNG

### **config.py** — Cấu Hình

```python
MODEL_PATH = "models/model_v1.h5"
IMG_SIZE = 224
BATCH_SIZE = 32
```

### **inference.py** — Inference Logic

```python
model = FoodAIModel()
model.load()
result = model.predict("https://cloudinary.../image.jpg")
# → {"food_name": "pho", "confidence": 0.92, "calories": 350, ...}
```

### **schemas.py** — API Models

```python
class AnalyzeRequest(BaseModel):
    image_url: str
    user_id: str

class AnalyzeResponse(BaseModel):
    success: bool
    data: dict
```

### **main.py** — FastAPI Server

```python
@app.post("/analyze")
async def analyze_food(request: AnalyzeRequest):
    # Download image → Inference → Return JSON
```

### **train.py** — Training Pipeline

```bash
python train.py
# Cần: data/vietnamese_food_101/train/{class}/images
# Output: models/model_v1.h5 + .tflite + classes.json
```

### **nutrition_db.py** — Food Database

```python
NUTRITION_DATABASE = {
    "pho": {
        "calories_per_100g": 75,
        "nutrition_per_100g": {"protein_g": 7.5, ...}
    },
    ...
}
```

---

## 🔄 FLOW: APP CALL SERVER

```
1️⃣ Flutter App
   ├─ Chụp ảnh
   ├─ Upload Cloudinary
   └─ Gửi POST /analyze + URL

2️⃣ Python Server (AI xử lý)
   ├─ Download ảnh từ URL
   ├─ Preprocess (resize 224x224)
   ├─ TensorFlow inference
   ├─ Lookup nutrition DB
   └─ Return JSON

3️⃣ Flutter App (hiển thị)
   ├─ Nhận kết quả
   ├─ Show UI: "Phở bò — 350 calo"
   └─ Save Firestore
```

**Network traffic:**

- Request: 500 bytes (URL + user_id)
- Response: 1-2 KB (JSON result)
- ✅ Siêu nhẹ!

---

## 🏗️ 2 KIẾN TRÚC DEPLOY

### **Option A: Local (Development)**

```bash
# Terminal 1: Run server
cd ai_server
python main.py
→ http://localhost:8000

# Terminal 2: Run Flutter app
cd ..
flutter run
→ Connect to http://localhost:8000
```

---

### **Option B: Docker (Production-ready)**

```bash
# Build container
docker build -t food-ai-server .

# Run container
docker run -p 8000:8000 food-ai-server

# Or use compose
docker-compose up -d
```

---

### **Option C: Cloud Deploy (Render.com)**

```bash
# 1. Push to Docker Hub
docker build -t username/food-ai-server .
docker push username/food-ai-server

# 2. Deploy to Render
# New Web Service → Docker Image → username/food-ai-server:latest

# 3. Update Flutter app
const AI_SERVER_URL = "https://food-ai-server.onrender.com"

# 4. Test
curl https://food-ai-server.onrender.com/health
```

**Cost:** $0 (free tier, rut giảm sau 15 min idle)

---

## 📊 MÔ HÌNH AI

### **Architecture**

```
Input Image (224x224x3)
    ↓
MobileNetV2 Base (ImageNet weights)  ← Transfer Learning
    ↓
GlobalAveragePooling
    ↓
Dense(256) → Dropout(0.5)
    ↓
Dense(128) → Dropout(0.3)
    ↓
Output: 50 Food Classes (softmax)
```

### **Transfer Learning = Tối ưu**

- ✅ Học nhanh (base model ImageNet ~ 1M params)
- ✅ Cần ít data (1000-5000 ảnh OK)
- ✅ Accuracy cao (80-90%)
- ✅ Model nhẹ (MobileNetV2: 15-20 MB TFLite)

### **Training Time**

- GPU: 30-60 phút
- CPU: 2-4 giờ

---

## 🧪 TEST SERVER

### **Swagger UI (Interactive)**

```
http://localhost:8000/docs
→ Try it out
→ Execute
→ Xem response
```

### **cURL**

```bash
# Health check
curl -X GET http://localhost:8000/health

# Analyze (mock)
curl -X POST http://localhost:8000/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "image_url": "https://res.cloudinary.com/test/image.jpg",
    "user_id": "user123"
  }'
```

### **Python Client**

```python
import requests

response = requests.post(
    "http://localhost:8000/analyze",
    json={
        "image_url": "https://...",
        "user_id": "user123"
    }
)

print(response.json())
# {
#   "success": true,
#   "data": {
#     "food_name": "pho",
#     "confidence": 0.92,
#     "calories_estimated": 350.0,
#     ...
#   }
# }
```

---

## ⚙️ CONFIGURATION

### **.env** (Local)

```
SERVER_HOST=0.0.0.0
SERVER_PORT=8000
DEBUG=True
CLOUDINARY_CLOUD_NAME=your_name
```

### **Environment Variables** (Cloud/Docker)

```bash
docker run \
  -e SERVER_HOST=0.0.0.0 \
  -e SERVER_PORT=8000 \
  -e DEBUG=False \
  food-ai-server
```

---

## 🎓 TRAINING YOUR OWN MODEL

### **Step 1: Chuẩn Bị Data**

```
ai_server/data/vietnamese_food_101/
├── train/
│   ├── pho/           (100 ảnh)
│   ├── banh_mi/       (100 ảnh)
│   └── ...
└── val/
    ├── pho/           (20 ảnh)
    └── ...
```

### **Step 2: Train**

```bash
python train.py
# Output: models/model_v1.h5 + .tflite + classes.json
```

### **Step 3: Deploy**

```bash
docker build -t food-ai-server .
docker run -p 8000:8000 food-ai-server
```

---

## 📦 INTEGRATION VỚI FLUTTER

### **File: lib/core/services/ai_service.dart**

```dart
class AIService {
  static const String AI_SERVER_URL = "http://localhost:8000";

  Future<Map<String, dynamic>> analyzeFoodImage(String imageUrl, String userId) async {
    final response = await Dio().post(
      "$AI_SERVER_URL/analyze",
      data: {
        "image_url": imageUrl,
        "user_id": userId,
      },
    );

    return response.data["data"];
  }
}
```

### **Change localhost → Cloud URL**

```dart
// Development
static const String AI_SERVER_URL = "http://localhost:8000";

// Production
static const String AI_SERVER_URL = "https://food-ai-server.onrender.com";

// Load từ .env
static const String AI_SERVER_URL = String.fromEnvironment('AI_SERVER_URL', defaultValue: 'http://localhost:8000');
```

---

## 🚨 TROUBLESHOOTING

| Vấn Đề                  | Fix                                |
| ----------------------- | ---------------------------------- |
| ImportError: tensorflow | `pip install tensorflow==2.15.0`   |
| Model not found         | `python train.py` để tạo model     |
| CORS error in Flutter   | Check `allow_origins` in main.py   |
| Port 8000 occupied      | `lsof -i :8000` → kill process     |
| Docker build timeout    | Tăng timeout hoặc split Dockerfile |

---

## ✅ CHECKLIST

```
✅ Virtual environment created
✅ requirements.txt installed
✅ .env configured
✅ Server running locally (http://localhost:8000)
✅ /health endpoint works
✅ /analyze endpoint works
✅ Swagger UI accessible
✅ Docker builds successfully
✅ Flutter integration ready
```

---

## 🎯 NEXT

1. **Train model** (nếu chưa):

   ```bash
   python train.py
   ```

2. **Run server 24/7**:

   ```bash
   docker-compose up -d
   ```

3. **Deploy cloud**:

   ```bash
   docker push username/food-ai-server:latest
   # Render.com: Deploy
   ```

4. **Connect Flutter** (Phase 2):
   ```dart
   const AI_SERVER_URL = "https://food-ai-server.onrender.com"
   ```

---

**Server Python sẵn sàng! 🚀**
