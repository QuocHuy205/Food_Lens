# ✅ SYSTEM CHECKLIST — Bạn Cần Làm Gì Tiếp Theo

> Hướng dẫn sau Phase 1 (Setup) completion

---

## 🎯 BẠN ĐANG Ở ĐÂU?

```
📍 Current: Phase 1 ✅ (App + Router + Cloudinary test) — XONG

Phase 1: Setup
  ✅ Flutter project
  ✅ Clean Architecture
  ✅ Firebase setup
  ✅ Router + Navigation
  ✅ Cloudinary test

Phase 2: Auth
  - [ ] AuthRepositoryImpl
  - [ ] Firebase login/register
  - [ ] LoginScreen UI

Phase 3️⃣ ← YOU ARE ABOUT TO DO THIS
  🟡 AI Server Setup (Python)
  - [ ] Virtual environment
  - [ ] Install dependencies
  - [ ] Run server locally
  - [ ] Test API
  - [ ] (Optional) Train model

Phase 4: Integration
  - [ ] Wire app to server
  - [ ] ScanScreen → API call
  - [ ] Show results

Phase 5+: Others
  - [ ] Profile, Nutrition, Stats...
```

---

## 🆘 DECISION POINT: Server Strategy

### **3 Lựa Chọn:**

#### **❌ Option 1: Embed Model in App (NOT RECOMMENDED)**

```
Pros: Offline, no server needed
Cons: ❌ App 200+ MB, slow, drain battery

Result: ❌ Bad UX
```

#### **✅ Option 2: Cloud API Server (RECOMMENDED) ← CHOOSE THIS**

```
Pros:
  ✅ App nhẹ 80 MB
  ✅ Server mạnh (GPU)
  ✅ Inference nhanh 0.5-2s
  ✅ Easy update model
  ✅ Scale horizontally

Cons: Cần network, startup cost

Result: ✅ Production-ready
```

#### **⚡ Option 3: Hybrid (Future)**

```
Pros: Best of both (offline + accuracy)
Cons: Dev phức tạp, require TFLite

Result: ⭐ Ultimate but later
```

**→ CHOOSE OPTION 2 FOR NOW**

---

## 📋 SERVER SETUP CHECKLIST

### **STEP 1: Understanding (20 min)**

- [ ] Read: `CLAUDE.md`
- [ ] Read: `ARCHITECTURE_OVERVIEW.md`
- [ ] Read: `ai_server/SETUP_SERVER.md`

### **STEP 2: Environment Setup (10 min)**

- [ ] Open `ai_server/` folder
- [ ] Create Python venv
- [ ] Activate venv
- [ ] Install requirements.txt

### **STEP 3: Configuration (5 min)**

- [ ] Create `.env` file
- [ ] Set `SERVER_PORT=8000`
- [ ] Set `DEBUG=True`

### **STEP 4: Run Server (5 min)**

- [ ] `python main.py`
- [ ] Check: http://localhost:8000/health ✅

### **STEP 5: Test API (5 min)**

- [ ] Visit: http://localhost:8000/docs
- [ ] Try POST /analyze
- [ ] Verify response

### **STEP 6: (Optional) Docker Setup (10 min)**

- [ ] `docker build -t food-ai-server .`
- [ ] `docker-compose up -d`
- [ ] Test same as STEP 5

---

## 🖥️ SETUP COMMANDS (COPY-PASTE)

### **Windows PowerShell**

```powershell
# Step 1: Go to server
cd ai_server

# Step 2: Create venv
python -m venv venv

# Step 3: Activate
.\venv\Scripts\Activate.ps1

# Step 4: Install deps
pip install -r requirements.txt

# Step 5: Run server
python main.py

# Expected output:
# INFO:     Uvicorn running on http://0.0.0.0:8000
# Keep this terminal OPEN!
```

### **Linux/Mac Bash**

```bash
cd ai_server
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py
```

---

## 🧪 TESTING

### **Test 1: Health Check**

```bash
# Terminal 3 (new)
curl -X GET http://localhost:8000/health

# Expected
# {
#   "status": "healthy",
#   "model_loaded": false,  ← mock mode OK for now
#   "message": "Food AI server is running"
# }
```

### **Test 2: Swagger Interactive**

```
http://localhost:8000/docs

Click: POST /analyze
Click: Try it out
Click: Execute

Response:
{
  "success": true,
  "data": {
    "food_name": "...",
    "confidence": 0.75,
    "calories_estimated": 350.0,
    ...
  }
}
```

---

## 📁 FILE STRUCTURE (Before & After)

### **BEFORE (Phase 1)**

```
ai_server/
├── main.py              ← OLD (mock only)
├── mock_data.py
└── requirements.txt     ← OLD (minimal)
```

### **AFTER (Phase 3)**

```
ai_server/
├── main.py              ✨ NEW (full FastAPI)
├── inference.py         ✨ NEW (Model loading)
├── config.py            ✨ NEW (Config)
├── schemas.py           ✨ NEW (API models)
├── nutrition_db.py      ✨ NEW (Food DB)
├── train.py             ✨ NEW (Training pipeline)
├── requirements.txt     ✨ NEW (all deps)
├── .env                 ✨ NEW (config)
├── .env.example         ✨ NEW (template)
├── Dockerfile           ✨ NEW (deploy)
├── docker-compose.yml   ✨ NEW (local dev)
├── .dockerignore
├── models/              ✨ CREATED (models)
│   ├── model_v1.h5
│   ├── model_v1.tflite
│   └── classes.json
├── data/                ✨ CREATED (dataset)
│   └── vietnamese_food_101/
├── logs/                ✨ CREATED (logs)
└── README_SERVER.md     ✨ NEW (docs)
```

---

## 🎯 WHAT'S NEW IN PHASE 3

| File                 | Purpose                               | Status   |
| -------------------- | ------------------------------------- | -------- |
| `config.py`          | Configuration management              | ✅ Ready |
| `schemas.py`         | Pydantic request/response models      | ✅ Ready |
| `nutrition_db.py`    | Vietnamese food database (50 items)   | ✅ Ready |
| `inference.py`       | Model loading + inference logic       | ✅ Ready |
| `main.py`            | FastAPI server with /analyze endpoint | ✅ Ready |
| `train.py`           | Training pipeline (for future)        | ✅ Ready |
| `requirements.txt`   | Updated with TensorFlow + FastAPI     | ✅ Ready |
| `.env`               | Local configuration                   | ✅ Ready |
| `Dockerfile`         | Production Docker image               | ✅ Ready |
| `docker-compose.yml` | Local development with Docker         | ✅ Ready |
| `README_SERVER.md`   | Detailed server documentation         | ✅ Ready |
| `SETUP_SERVER.md`    | Quick setup guide                     | ✅ Ready |

---

## 🚀 EXPECTED OUTCOME

After completing Phase 3:

```
✅ Server running on http://localhost:8000
✅ /health endpoint: returns server status
✅ /analyze endpoint: accepts image_url, returns food prediction
✅ Swagger UI: interactive API testing
✅ All files ready for production deployment
✅ Documentation complete
```

---

## 🔗 NEXT PHASE (Phase 4)

After server running:

1. **Connect Flutter to Server**
   - Create: `lib/core/services/ai_service.dart`
   - Create: `lib/features/scan/domain/repositories/scan_repository.dart`
   - Implement: HTTP POST call to `/analyze`

2. **Wire UI to API**
   - Create: `ScanScreen` + `ScanViewModel`
   - Test: Upload image → Get response

3. **Full Flow**
   - Chụp ảnh → Upload Cloudinary → Call /analyze → Show result

---

## 💡 PRO TIPS

### **Tip 1: Keep Terminals Separate**

```
Terminal 1: Server (python main.py)  ← Keep OPEN
Terminal 2: App (flutter run)         ← Keep OPEN
Terminal 3: Testing (curl, other)     ← Use for testing
```

### **Tip 2: Use Swagger for Testing**

```
Instead of remembering curl commands,
visit: http://localhost:8000/docs
Use interactive UI: Try it out → Execute
```

### **Tip 3: Mock Mode is Okay for Now**

```
If model not loading:
- It's OK, server returns mock data (confidence: 0.75)
- Perfect for testing without real model
- Later: python train.py to train real model
```

### **Tip 4: .env File is Ignored**

```
✅ .env — YOUR LOCAL CONFIG (gitignored)
✅ .env.example — TEMPLATE for others
Never commit .env to git!
```

### **Tip 5: Start Small**

```
1. Get server running ✅
2. Test /health ✅
3. Test /analyze (mock) ✅
4. Then: train real model (later)
```

---

## 🐛 DEBUGGING

### **Problem: Import Error (tensorflow)**

```
Error: ModuleNotFoundError: No module named 'tensorflow'

Fix:
1. Activate venv: .\venv\Scripts\Activate.ps1
2. Install: pip install tensorflow==2.15.0
3. Retry: python main.py
```

### **Problem: Port 8000 Already in Use**

```
Error: Address already in use

Fix:
# Find process
lsof -i :8000

# Kill it
kill -9 <PID>

# Or change port in .env
SERVER_PORT=8001
```

### **Problem: CORS Error (Flutter)**

```
Error: No 'Access-Control-Allow-Origin' header

Fix in ai_server/main.py:
- CORS is already configured
- Check Flutter app .env: AI_SERVER_URL
- Must match server URL exactly
```

### **Problem: Model Not Found**

```
Warning: Model not loaded, using mock

This is OK! You can:
1. Train model: python train.py
2. Or deploy mock server first, train later

For now, mock is fine for testing.
```

---

## ✅ VALIDATION CHECKLIST

Before moving to Phase 4, verify:

- [ ] `python main.py` runs without error
- [ ] `http://localhost:8000/health` returns 200 OK
- [ ] `http://localhost:8000/docs` opens Swagger UI
- [ ] POST /analyze works (try in Swagger)
- [ ] Response has: food_name, confidence, calories
- [ ] All 12 new files present in ai_server/
- [ ] .env file created and configured
- [ ] No errors in terminal

---

## 🎯 TIME ESTIMATE

| Task              | Time        |
| ----------------- | ----------- |
| Read docs         | 20 min      |
| Setup venv        | 10 min      |
| Install deps      | 5 min       |
| Run server        | 5 min       |
| Test API          | 10 min      |
| Docker (optional) | 15 min      |
| **Total**         | **~65 min** |

---

## 📞 NEED HELP?

1. Check error message carefully
2. Read: `ai_server/README_SERVER.md`
3. Search: Google + Stack Overflow
4. Check: ARCHITECTURE_OVERVIEW.md

---

## 🎊 SUCCESS CRITERIA

You'll know Phase 3 is complete when:

```
✅ Server running
✅ /health endpoint ✓
✅ /analyze endpoint ✓
✅ Swagger UI working
✅ Mock predictions working
✅ All files present
✅ Documentation complete
```

---

**Ready to setup server? 🚀**

**Next command:**

```bash
cd ai_server
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
python main.py
```

**See you in ~/docs after this! 💪**
