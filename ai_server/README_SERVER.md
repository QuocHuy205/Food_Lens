# 🔧 AI SERVER SETUP — Food Lens

---

## 📁 Cấu Trúc Folder

```
food_lens/ai_server/
├── main.py                    ← FastAPI app (entry point)
├── config.py                  ← Config (paths, model settings)
├── schemas.py                 ← Pydantic models
├── inference.py               ← Model inference logic
├── nutrition_db.py            ← Food nutrition database
├── train.py                   ← Training pipeline
│
├── requirements.txt           ← Python dependencies
├── Dockerfile                 ← Docker image
├── docker-compose.yml         ← Local dev
├── .dockerignore
├── .env.example               ← Environment template
│
├── models/                    ← Saved models (git-lfs)
│   ├── model_v1.h5           ← Full model (150 MB)
│   ├── model_v1.tflite       ← Mobile model (15-20 MB)
│   ├── classes.json          ← Class names
│   └── nutrition_db.json     ← Nutrition DB
│
├── data/                      ← Training dataset
│   ├── vietnamese_food_101/
│   │   ├── train/
│   │   │   ├── pho/          ← 50-100 ảnh
│   │   │   ├── banh_mi/
│   │   │   └── ...
│   │   └── val/
│   └── raw/                   ← Original data
│
└── logs/                      ← Server logs
```

---

## 🚀 QUY TRÌNH SETUP

### **STEP 1: Tạo Virtual Environment**

```bash
# Đặt tại thư mục ai_server
cd ai_server

# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

**Kết quả:** `(venv) C:\...\ai_server>`

---

### **STEP 2: Cài Dependencies**

```bash
pip install -r requirements.txt
```

**Thời gian:** 5-10 phút (TensorFlow nặng)

---

### **STEP 3: Setup .env**

```bash
# Copy template
cp .env.example .env

# Edit .env
# SERVER_HOST=0.0.0.0
# SERVER_PORT=8000
# DEBUG=True
```

---

### **STEP 4: Chuẩn Bị Dataset (Nếu train)**

```
data/vietnamese_food_101/
├── train/
│   ├── pho/              ← 100 ảnh phở
│   ├── banh_mi/          ← 100 ảnh bánh mì
│   ├── com_tam/
│   ├── bun_bo/
│   └── ... (50 loại = 5000 ảnh)
└── val/
    ├── pho/              ← 20 ảnh phở
    ├── banh_mi/
    └── ...
```

**Cấu trúc từng folder:**

```
data/vietnamese_food_101/train/pho/
├── pho_001.jpg
├── pho_002.jpg
├── pho_hanoi_001.jpg
└── ... (100+ ảnh)
```

---

### **STEP 5: Train Model (LẦN ĐẦU)**

```bash
python train.py
```

**Output:**

```
Loading data from data/vietnamese_food_101...
✅ Data loaded: 4500 train, 1000 val
Classes: {'pho': 0, 'banh_mi': 1, ...}
Building model with MobileNetV2...
Starting training...
Epoch 1/50
320/320 [==============================] - 45s - loss: 2.1 - accuracy: 0.45
...
Epoch 50/50
✅ Training complete!
Saving model to models/model_v1.h5
✅ Model saved!
Converting to TFLite: models/model_v1.tflite
✅ TFLite model saved: 18.5 MB
✅ Classes saved: models/classes.json
✅ All done!
```

**Output Files:**

- ✅ `models/model_v1.h5` (80-150 MB)
- ✅ `models/model_v1.tflite` (15-20 MB)
- ✅ `models/classes.json` (tên class)

---

### **STEP 6: Chạy Server Local**

```bash
# Run server
python main.py

# Hoặc dùng uvicorn trực tiếp
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Output:**

```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete
✅ Model loaded: True
🟢 Server starting...
```

**Truy cập:**

- 🌐 http://localhost:8000/health
- 📚 http://localhost:8000/docs (Swagger UI)
- 🎯 http://localhost:8000/analyze (POST)

---

## 🧪 TEST API LOCAL

### **Test 1: Health Check**

```bash
curl -X GET http://localhost:8000/health
```

**Response:**

```json
{
  "status": "healthy",
  "message": "Food AI server is running",
  "timestamp": "2026-04-16T10:30:00",
  "model_loaded": true
}
```

---

### **Test 2: Analyze Food (Mock)**

```bash
curl -X POST http://localhost:8000/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "image_url": "https://res.cloudinary.com/demo/image/upload/pho.jpg",
    "user_id": "user123"
  }'
```

**Response:**

```json
{
  "success": true,
  "data": {
    "food_name": "pho",
    "food_name_vi": "Phở bò",
    "confidence": 0.92,
    "calories_estimated": 350.0,
    "portion_grams": 400,
    "nutrition": {
      "protein_g": 28.0,
      "carbs_g": 36.0,
      "fat_g": 6.0,
      "fiber_g": 2.0
    },
    "top_predictions": [...],
    "inference_time_ms": 234.5,
    "response_time_ms": 1245.3
  }
}
```

---

### **Test 3: Swagger UI**

Truy cập: http://localhost:8000/docs

- ✅ Try it out
- ✅ Execute request
- ✅ Xem response

---

## 🐳 DEPLOY VỚI DOCKER

### **Local Docker**

```bash
# Build image
docker build -t food-ai-server .

# Run container
docker run \
  -p 8000:8000 \
  -v $(pwd)/models:/app/models \
  -e DEBUG=True \
  food-ai-server
```

---

### **Docker Compose (Recommended)**

```bash
# Start
docker-compose up -d

# Logs
docker-compose logs -f

# Stop
docker-compose down
```

**Output:**

```
Creating food_lens_ai_server ... done
food_lens_ai_server | INFO:     Uvicorn running on http://0.0.0.0:8000
```

---

## ☁️ DEPLOY LÊN CLOUD (Render.com)

### **Step 1: Push Docker Image**

```bash
# Build docker image
docker build -t food-ai-server .

# Tag image
docker tag food-ai-server username/food-ai-server:latest

# Push to Docker Hub
docker push username/food-ai-server:latest
```

---

### **Step 2: Deploy to Render**

1. Đăng nhập: https://render.com
2. New → Web Service
3. Docker (Container Image Registry)
4. Image URL: `username/food-ai-server:latest`
5. Port: 8000
6. Deploy

**Result:** https://food-ai-server.onrender.com

---

### **Step 3: Test Cloud URL**

```bash
curl -X GET https://food-ai-server.onrender.com/health

# Update Flutter app:
AI_SERVER_URL=https://food-ai-server.onrender.com
```

---

## 📊 MONITORING

### **Server Logs**

```bash
# Real-time logs
docker-compose logs -f

# Save logs
docker-compose logs > server.log
```

---

### **Performance**

```bash
# CPU/Memory usage
docker stats food_lens_ai_server

# Model metrics (Swagger)
http://localhost:8000/docs
```

---

## 🐛 TROUBLESHOOTING

| Vấn Đề                  | Nguyên Nhân         | Fix                                   |
| ----------------------- | ------------------- | ------------------------------------- |
| **Model not found**     | Không train model   | Chạy `python train.py`                |
| **Import error**        | Dependencies thiếu  | `pip install -r requirements.txt`     |
| **CORS error**          | Flutter gọi sai URL | Check `AI_SERVER_URL` in app          |
| **Timeout**             | Server chậm         | Optimize model được transfer learning |
| **Port already in use** | Port 8000 bị cấp    | `lsof -i :8000` → kill process        |

---

## 🎯 NEXT STEPS

1. **Train model thật** (1-2 tuần):
   - Thu thập 5000-10000 ảnh 50 loại thực phẩm
   - Chạy `python train.py`
   - Optimize accuracy → 85-90%

2. **Deploy to production**:
   - Push Docker to Docker Hub
   - Deploy to Render/Railway
   - Monitor performance

3. **Connect Flutter app**:
   - Update `AI_SERVER_URL`
   - Test end-to-end
   - Add error handling

---

**Xong! Server đã sẵn sàng! 🚀**
