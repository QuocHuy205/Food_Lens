# 🏗️ KIẾN TRÚC TOÀN BỘ PROJECT — App + Server

---

## 📦 TỔNG QUAN

```
CaloriesAI/food_lens/                    ← Tất cả ở đây
├── lib/                                 ← Flutter App (UI)
│   ├── main.dart
│   ├── core/
│   │   ├── services/
│   │   │   ├── cloudinary_service.dart  (upload ảnh)
│   │   │   ├── ai_service.dart          ⭐ (gọi server)
│   │   │   └── ...
│   │   └── router/
│   │       └── app_router.dart
│   │
│   └── features/
│       ├── auth/
│       │   ├── domain/
│       │   ├── data/
│       │   └── presentation/
│       ├── scan/                        ⭐ (gọi AI server)
│       │   ├── domain/
│       │   │   └── repositories/
│       │   │       └── scan_repository.dart
│       │   ├── data/
│       │   │   └── repositories/
│       │   │       └── scan_repository_impl.dart
│       │   │           └── calls AI_SERVER_URL
│       │   └── presentation/
│       │       ├── screens/
│       │       │   └── scan_screen.dart
│       │       └── viewmodels/
│       │           └── scan_viewmodel.dart
│       │
│       └── nutrition/
├── pubspec.yaml                         ← Flutter dependencies
├── .env                                 ← App config
│   └── AI_SERVER_URL=http://localhost:8000
│
└── ai_server/                           ← Python Server (AI xử lý) ⭐
    ├── main.py                          ← FastAPI app
    │   @app.post("/analyze")
    │   │ • Nhận image_url từ Flutter
    │   │ • Load model AI
    │   │ • Run inference
    │   │ • Lookup nutrition DB
    │   │ • Return JSON
    │   └─────────────────────────────────────────
    │
    ├── inference.py                     ← Model xử lý
    │   class FoodAIModel:
    │   • download_image(url)
    │   • preprocess_image(img)
    │   • predict(url)
    │
    ├── config.py                        ← Cấu hình
    │   MODEL_PATH = "models/model_v1.h5"
    │   IMG_SIZE = 224
    │
    ├── schemas.py                       ← Pydantic models
    │   class AnalyzeRequest:
    │     image_url: str
    │     user_id: str
    │
    ├── nutrition_db.py                  ← Food database
    │   NUTRITION_DATABASE = {
    │     "pho": {...},
    │     "banh_mi": {...}
    │   }
    │
    ├── train.py                         ← Training code
    │   class FoodAITrainer:
    │   • prepare_data()
    │   • build_model()
    │   • train()
    │   • save_model()
    │
    ├── models/                          ← Saved models (git-lfs)
    │   ├── model_v1.h5                  (150 MB on server)
    │   ├── model_v1.tflite              (20 MB for mobile)
    │   └── classes.json
    │
    ├── data/                            ← Training dataset
    │   └── vietnamese_food_101/
    │       ├── train/
    │       │   ├── pho/              (100 ảnh)
    │       │   ├── banh_mi/          (100 ảnh)
    │       │   └── ...
    │       └── val/
    │
    ├── requirements.txt                 ← Python dependencies
    ├── .env                             ← Server config
    ├── Dockerfile                       ← Docker image
    ├── docker-compose.yml               ← Local dev
    └── README_SERVER.md                 ← Hướng dẫn


```

---

## 🔄 FLOW: App gọi Server

```
┌─────────────────────────────────────┐
│     Flutter App (lib/)              │
│                                     │
│  User chụp ảnh → Upload Cloudinary │
│      ↓                              │
│  ScanScreen                         │
│      │                              │
│      ▼                              │
│  ScanViewModel.analyzeFoodImage()  │
│      │                              │
│      ▼                              │
│  ScanRepository.analyzeFoodImage() │
│      │                              │
│      ▼                              │
│  AIService.analyzeFoodImage()      │  ⭐ (gọi HTTP POST)
│      │                              │
└──────┼──────────────────────────────┘
       │ HTTP POST /analyze
       │ {"image_url": "...", "user_id": "..."}
       │
       ▼
┌──────────────────────────────────────┐
│  Python Server (ai_server/)         │
│                                     │
│  FastAPI: main.app.post("/analyze")│
│      ├─ Download ảnh từ URL
│      ├─ Preprocess (224x224)
│      ├─ Load Model (TensorFlow)
│      ├─ Inference
│      ├─ Lookup Nutrition DB
│      └─ Return JSON
│          {
│            "food_name": "pho",
│            "confidence": 0.92,
│            "calories": 350,
│            "nutrition": {...}
│          }
│                                     │
└──────┬──────────────────────────────┘
       │ Response (1-2 KB JSON)
       │
       ▼
┌──────────────────────────────────────┐
│  Flutter App (show result)          │
│      ↓                              │
│  ResultScreen                        │
│  • Phở bò                           │
│  • 350 calo                         │
│  • Protein: 28g ...                 │
│      │                              │
│      ▼                              │
│  User ✓ Confirm                     │
│      ▼                              │
│  Save to Firestore                  │
│  Update Daily Log                   │
│      ▼                              │
│  ✅ Done                            │
└──────────────────────────────────────┘
```

---

## 📊 DATA FLOW

### **Path 1: Training (1 lần)**

```
raw dataset (5000+ ảnh)
    ↓
python train.py
    ├─ Augmentation
    ├─ MobileNetV2 (transfer learning)
    ├─ Training 50 epochs
    └─ Evaluate (val set)
    ↓
Output:
├─ models/model_v1.h5      (server — lớn, accurate)
├─ models/model_v1.tflite  (mobile — nhẹ)
└─ models/classes.json     (class labels)
```

### **Path 2: Inference (mỗi lần scan)**

```
User chụp ảnh
    ↓
Upload → Cloudinary
    ↓ (nhận URL)
APP HTTP POST /analyze + URL
    ↓
SERVER:
├─ Download ảnh từ URL
├─ Preprocess
├─ Model.predict()
├─ Lookup Nutrition DB
└─ Return JSON
    ↓
APP:
├─ Receive JSON
├─ Show UI
├─ User confirm
└─ Save Firestore
```

---

## 🛠️ TECH STACK DETAIL

### **App Layer (Flutter)**

| Component        | Technology    | Mục Đích          |
| ---------------- | ------------- | ----------------- |
| Framework        | Flutter 3.x   | Cross-platform UI |
| State Management | Riverpod      | Global state      |
| Router           | go_router     | Navigation        |
| HTTP Client      | Dio + http    | Call API          |
| Database         | Firestore     | Cloud DB          |
| File Storage     | Cloudinary    | Image CDN         |
| Auth             | Firebase Auth | User login        |

### **Server Layer (Python)**

| Component     | Technology      | Mục Đích         |
| ------------- | --------------- | ---------------- |
| Framework     | FastAPI         | REST API         |
| Runtime       | Uvicorn         | ASGI server      |
| ML            | TensorFlow 2.15 | Deep Learning    |
| Model         | MobileNetV2     | CNN backbone     |
| Format        | TFLite          | Mobile-optimized |
| Serialization | Pydantic        | Data validation  |
| Deployment    | Docker          | Containerization |

### **Infrastructure**

| Service    | Purpose          | Cost              |
| ---------- | ---------------- | ----------------- |
| Firebase   | Auth + Firestore | Free (Spark)      |
| Cloudinary | Image hosting    | Free (25GB)       |
| Render.com | Server deploy    | Free (with sleep) |
| Docker Hub | Image registry   | Free              |

---

## 💡 KEY FEATURES

### **1️⃣ Separation of Concerns**

```
App = UI + State Management
Server = AI Logic + Processing

✅ App nhẹ (80-120 MB)
✅ Server mạnh (có GPU)
✅ Dễ maintain (độc lập)
```

### **2️⃣ Scalability**

```
1 Server → 1000 Users
Network = ~2-3 KB per request

Nếu cần:
├─ Scale horizontally → thêm servers
├─ Load balancer → distribute requests
└─ Cache → store results
```

### **3️⃣ Offline Support**

```
Option A: Cache last results
├─ User offline?
└─ Show cached scans

Option B: On-device model (future)
├─ App có TFLite model
├─ Offline inference
└─ Sync when online
```

---

## 🚀 DEPLOYMENT STAGES

### **Stage 1: LOCAL DEV (Now)**

```bash
# Terminal 1: Server
cd ai_server
python main.py
→ http://localhost:8000

# Terminal 2: App
cd ..
flutter run
→ http://localhost:8000
```

### **Stage 2: DOCKER (Next)**

```bash
cd ai_server
docker-compose up -d
→ http://localhost:8000 (inside container)
```

### **Stage 3: CLOUD (Production)**

```bash
# Push to Render
docker build -t username/food-ai-server .
docker push username/food-ai-server

# Deploy
# → https://food-ai-server.onrender.com

# Update app
AI_SERVER_URL = "https://food-ai-server.onrender.com"
```

---

## 📈 PERFORMANCE TARGETS

### **Server**

| Metric         | Target      |
| -------------- | ----------- |
| Inference Time | < 1 second  |
| Response Time  | < 2 seconds |
| Memory         | < 500 MB    |
| CPU            | 1 core      |
| Requests/sec   | 10 req/s    |

### **App**

| Metric    | Target             |
| --------- | ------------------ |
| App Size  | < 150 MB           |
| RAM       | < 300 MB           |
| Scan Time | < 3 seconds        |
| Network   | < 5 KB per request |

### **Database (Firestore)**

| Metric       | Target       |
| ------------ | ------------ |
| Scan History | 1000 records |
| Query        | < 100 ms     |
| Storage      | < 100 MB     |

---

## 🔐 SECURITY

### **App → Server**

```
✅ HTTPS (enforce in production)
✅ CORS (allow only app domain)
✅ Rate limiting (10 req/user/min)
✅ Input validation (Pydantic)
✅ Error handling (don't expose code)
```

### **Image Handling**

```
✅ Download timeout (10 sec)
✅ Size limit (10 MB)
✅ Format validation (JPG, PNG)
✅ Virus scan (optional)
```

### **Database**

```
✅ Firebase Security Rules
✅ User isolation (query by user_id)
✅ No direct file access
✅ Encrypted transmission
```

---

## 📋 FILE CHECKLIST

### **App (Flutter)**

```
✅ lib/core/services/ai_service.dart
   └─ class AIService
   └─ method analyzeFoodImage(url, userId)

✅ lib/features/scan/domain/repositories/scan_repository.dart
   └─ abstract analyzeFoodImage()

✅ lib/features/scan/data/repositories/scan_repository_impl.dart
   └─ calls AIService.analyzeFoodImage()

✅ lib/features/scan/presentation/viewmodels/scan_viewmodel.dart
   └─ calls repository.analyzeFoodImage()

✅ lib/features/scan/presentation/screens/scan_screen.dart
   └─ UI + wire ViewModel

✅ .env + .env.example
   └─ AI_SERVER_URL=...

✅ pubspec.yaml
   └─ dio, http packages
```

### **Server (Python)**

```
✅ ai_server/main.py
   └─ @app.post("/analyze")

✅ ai_server/inference.py
   └─ class FoodAIModel

✅ ai_server/config.py
   └─ configuration

✅ ai_server/schemas.py
   └─ Pydantic models

✅ ai_server/nutrition_db.py
   └─ Food database

✅ ai_server/train.py
   └─ Training pipeline

✅ ai_server/requirements.txt
   └─ Python dependencies

✅ ai_server/Dockerfile
   └─ Docker image

✅ ai_server/.env + .env.example
   └─ Configuration
```

---

## ✅ NEXT STEPS

### **Phase 2: AUTH (Current)**

- [ ] Implement AuthRepositoryImpl
- [ ] Implement LoginScreen
- [ ] Wire Firebase Auth

### **Phase 3: AI Server Setup** ⭐

- [ ] Setup virtual environment
- [ ] Install dependencies
- [ ] Run server locally
- [ ] Test /health endpoint
- [ ] Test /analyze (mock)

### **Phase 4: Wire App to Server**

- [ ] Create AIService
- [ ] Implement ScanRepository
- [ ] Create ScanViewModel
- [ ] Create ScanScreen

### **Phase 5: Training (nếu có data)**

- [ ] Chuẩn Bị dataset
- [ ] Chạy python train.py
- [ ] Evaluate model
- [ ] Deploy to server

---

## 🎯 SUMMARY

```
🎯 Goal: App nhẹ (80 MB) + Server mạnh (AI xử lý)

📱 App (Flutter)
   • Chụp ảnh
   • Upload Cloudinary
   • Gửi HTTP POST /analyze
   • Hiển thị kết quả
   • Save to Firestore

🖥️ Server (Python)
   • Load model AI
   • Download ảnh từ URL
   • Run inference
   • Lookup nutrition
   • Return JSON (1-2 KB)

✅ Result
   • App: 80 MB (nhẹ)
   • Network: 2-3 KB/request (siêu nhẹ)
   • Speed: 0.5-2 sec (nhanh)
   • Maintenance: Easy (độc lập)
   • Scale: Easy (Docker)
```

---

**Kiến trúc hoàn hảo cho production! 🚀**
