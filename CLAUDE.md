# 🍜 AI Food Recognition — Entry Point for AI Agents

> **Đọc file này đầu tiên trước khi làm bất cứ điều gì.**

---

## 📌 Tổng quan hệ thống (UPDATED)

**Tên đồ án:** Hệ thống AI nhận diện món ăn và ước tính lượng calo hỗ trợ đề xuất chế độ dinh dưỡng

**Kiến trúc:** **Server-Client Separation** ✅

- Server (FastAPI) xử lý AI inference, tính toán
- App (Flutter) chỉ gọi API, hiển thị UI, lưu Firestore

**Nhóm sinh viên:**

- Vương Quốc Huy — 23IT.B085 — 23SE4
- Nguyễn Duy Thăng — 23IT.B206 — 23SE5
- Nguyễn Đức Hải — 23IT.B048 — 23SE4

**GVHD:** ThS. Trần Đình Sơn | **Trường:** VKU — Đà Nẵng

---

## 🏗️ Tech Stack

| Layer            | Công nghệ                         |
| ---------------- | --------------------------------- |
| Mobile App       | Flutter 3.x + Clean Architecture  |
| State Management | Riverpod (StateNotifier)          |
| Auth             | Firebase Authentication           |
| Database         | Cloud Firestore                   |
| Image Storage    | Cloudinary                        |
| AI Server        | FastAPI (Python) + TensorFlow     |
| Networking       | Dio (HTTP client)                 |
| Error Handling   | Either<Failure, Success> (fpdart) |

---

## 🔄 Flow chính (UPDATED)

```
USER → Chụp/Upload ảnh
     ↓
App upload → Cloudinary → nhận imageUrl
     ↓
App POST /analyze (imageUrl) → FastAPI Server
     ↓
Server: Load TensorFlow model → inference → tính nutrition
     ↓
Server response: {food_name, calories, nutrition, confidence}
     ↓
App parse kết quả → hiển thị ScanResultScreen
     ↓
User confirm → App lưu vào Firestore (users/{uid}/scans)
     ↓
App cập nhật Daily Log → hiển thị Stats
     ↓
App tạo Recommendation (dư/thiếu calo)
```

**KEY: Server nặng (AI), App nhẹ (UI + API call)**

---

## 📁 Cấu trúc tài liệu

```
food_lens/
├── CLAUDE.md                  ← Bạn đang đọc (updated)
├── SETUP_GUIDE.md             ← Hướng dẫn setup từ zero
├── README.md                  ← Project overview
│
├── docs/
│   ├── ARCHITECTURE.md        ← Clean Architecture + MVVM
│   ├── PROJECT_STRUCTURE.md   ← Cây thư mục Flutter
│   ├── PROGRESS.md            ← Checklist tiến độ (UPDATED)
│   ├── SESSION_HANDOFF.md     ← Ghi context cho AI tiếp theo (UPDATED)
│   ├── FEATURE_GUIDE.md       ← Hướng dẫn code từng feature
│   ├── SERVER_ARCHITECTURE.md ← FastAPI setup chi tiết (NEW)
│   ├── APP_API_INTEGRATION.md ← Dio + HTTP config (NEW)
│   ├── ENV_CONFIG_GUIDE.md    ← Environment variables
│   ├── UI_DESIGN_GUIDE.md     ← 10 screens + components
│   └── TECH_STACK.md          ← Chi tiết công nghệ
│
├── agents/
│   ├── UI_AGENT.md            ← Danh sách màn hình + navigation
│   ├── AUTH_AGENT.md          ← Firebase Auth flow
│   ├── DATA_AGENT.md          ← Firestore schema (QUAN TRỌNG)
│   └── AI_AGENT.md            ← AI pipeline + mock strategy
│
├── commands/
│   └── COMMANDS.md            ← Template thêm feature mới
│
├── ai_server/                 ← Python FastAPI server
│   ├── main.py                ← Entry point (updated)
│   ├── config.py              ← Config (updated)
│   ├── schemas.py             ← Pydantic models (updated)
│   ├── inference.py           ← TensorFlow inference
│   ├── mock_data.py           ← Mock foods (10-20 items)
│   ├── nutrition_db.py        ← Nutrition database
│   ├── train.py               ← Training script (optional)
│   ├── requirements.txt       ← Dependencies
│   ├── docker-compose.yml     ← Optional containerization
│   ├── Dockerfile             ← Optional containerization
│   └── README_SERVER.md       ← Setup hướng dẫn
│
├── lib/                       ← Flutter app (Clean Architecture)
│   ├── main.dart              ← Entry point + Firebase init
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart (UPDATED - load .env)
│   │   ├── errors/
│   │   │   └── failure.dart   (UPDATED - more failure types)
│   │   ├── extensions/
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   ├── services/
│   │   │   └── cloudinary.dart
│   │   ├── theme/
│   │   ├── utils/
│   │   └── widgets/
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── domain/ (entities, repos, usecases)
│   │   │   ├── data/ (models, datasources, repoimpl - UPDATED)
│   │   │   └── presentation/ (screens, providers - skeleton)
│   │   │
│   │   ├── scan/ (UPDATED - added Firestore datasource)
│   │   │   ├── domain/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── ai_remote_datasource.dart (UPDATED - Dio HTTP)
│   │   │   │   │   ├── cloudinary_datasource.dart (UPDATED - Dio HTTP)
│   │   │   │   │   └── firestore_datasource.dart (NEW)
│   │   │   │   ├── models/ (UPDATED - better JSON parsing)
│   │   │   │   └── repositories/ (UPDATED - wire Firestore)
│   │   │   └── presentation/ (screens skeleton)
│   │   │
│   │   ├── profile/ (skeleton)
│   │   ├── nutrition/ (skeleton)
│   │   ├── history/ (skeleton)
│   │   └── home/ (skeleton)
│   │
│   └── test/
│
└── .env (gitignored)          ← Credentials (load from .env)
```

---

## 🚀 Lệnh quan trọng

```bash
# === FLUTTER APP ===

# Chuẩn bị
flutter pub get
flutter pub upgrade

# Chạy app (dev)
flutter run

# Build APK
flutter build apk --debug

# Run tests
flutter test

# === AI SERVER ===

cd ai_server

# Cài dependencies
pip install -r requirements.txt

# Chạy mock server (dev)
python -m uvicorn main:app --reload --port 8000

# Chạy với Docker (optional)
docker-compose up

# === LINTING & FORMATTING ===

# Analyze Dart code
flutter analyze

# Format code
dart format lib/ -l 100
```

---

## 📖 Thứ tự đọc tài liệu

1. ✅ `CLAUDE.md` ← đang đọc
2. ✅ `docs/PROGRESS.md` ← xem tiến độ
3. ✅ `docs/SESSION_HANDOFF.md` ← xem context
4. 📖 `docs/ARCHITECTURE.md` ← hiểu kiến trúc
5. 📖 `docs/SERVER_ARCHITECTURE.md` ← hiểu FastAPI setup
6. 📖 `agents/DATA_AGENT.md` ← hiểu Firestore schema
7. 📖 `docs/UI_DESIGN_GUIDE.md` ← hiểu UI spec
8. 💻 `docs/FEATURE_GUIDE.md` ← bắt đầu code

---

## ⚠️ Quy tắc vàng (UPDATED)

### Architecture Rules

- ✅ **Server xử lý AI** — Load model, inference, tính toán
- ✅ **App chỉ gọi API** — POST imageUrl → nhận food + calories
- ✅ **Separation of concerns** — Server ≠ App
- ✅ **No business logic in UI** — KHÔNG viết logic trong Widget

### Code Quality

- ✅ **Repository pattern** — Data layer riêng, UI không access Firestore trực tiếp
- ✅ **Either<Failure, Success>** — All usecases return Either, không throw
- ✅ **File size ≤ 300 dòng** — File lớn → tách nhỏ
- ✅ **@freezed models** — Immutable, auto toString/copyWith
- ✅ **Const constructors** — Best practice
- ✅ **Clean Dart code** — Follow Google Dart style guide

### Error Handling

- ✅ **Custom Failures** — AuthFailure, ServerFailure, DatabaseFailure, etc.
- ✅ **Exception → Failure** — Datasources throw Exceptions, Repos catch → Failures
- ✅ **Meaningful messages** — "Lỗi: [chi tiết]" (tiếng Việt)

### API Integration

- ✅ **Dio client** — HTTP requests with timeout, error handling
- ✅ **.env for secrets** — API_URL, CLOUD_NAME, UPLOAD_PRESET from .env
- ✅ **Fallback strategy** — If server down, use mock / cached data
- ✅ **Request/Response models** — Pydantic on server, models in app

### Testing

- ✅ **Unit test usecases** — Pure Dart, no Flutter imports
- ✅ **Mock repositories** — For UI tests
- ✅ **Integration tests** — End-to-end (optional v2)

### Git & Versioning

- ✅ **.gitignore .env** — Never commit secrets
- ✅ **.env.example** — Template for setup
- ✅ **Commit messages** — Vietnamese, clear
- ✅ **Feature branches** — feat/auth, feat/scan, etc.

---

## 🎯 Workflow cho Developer

### Khi thêm feature mới:

1. **Read PROGRESS.md** → Xác nhận đang ở phase nào
2. **Read SESSION_HANDOFF.md** → Xem context hiện tại
3. **Read FEATURE_GUIDE.md** → Xem hướng dẫn chi tiết
4. **Implement layer by layer:**
   - Domain: Entity + Repository abstract + UseCase
   - Data: Model + DataSource + Repository impl
   - Presentation: Provider/ViewModel + Screen UI
5. **Test**: `flutter run` hoặc unit tests
6. **Update SESSION_HANDOFF.md** → Ghi lại context cho AI tiếp theo
7. **Tick checklist** → Update PROGRESS.md

---

## 📱 UI Screens (10 total)

| #   | Route           | Tên               | Tình Trạng  |
| --- | --------------- | ----------------- | ----------- |
| 1   | `/`             | SplashScreen      | ✅ Có       |
| 2   | `/login`        | LoginScreen       | 🟡 Skeleton |
| 3   | `/register`     | RegisterScreen    | 🟡 Skeleton |
| 4   | `/home`         | HomeScreen        | 🟡 Skeleton |
| 5   | `/scan`         | ScanScreen        | 🟡 Skeleton |
| 6   | `/scan/result`  | ScanResultScreen  | 🟡 Skeleton |
| 7   | `/history`      | HistoryScreen     | 🟡 Skeleton |
| 8   | `/stats`        | StatsScreen       | 🟡 Skeleton |
| 9   | `/profile`      | ProfileScreen     | 🟡 Skeleton |
| 10  | `/profile/edit` | EditProfileScreen | 🟡 Skeleton |

Skeleton files chứa TODO comments — sẵn sàng chờ UI implementation.

---

## 🔧 Troubleshooting

### App không chạy?

```
flutter clean
flutter pub get
flutter run
```

### Firebase not configured?

→ See `SETUP_GUIDE.md` → Firebase Console setup

### AI server connection error?

→ Check `.env` → AI_SERVER_URL = http://10.0.2.2:8000 (emulator)
→ Check server running: `python -m uvicorn main:app --reload`

### Cloudinary upload fail?

→ Check `.env` → CLOUDINARY_CLOUD_NAME, CLOUDINARY_UPLOAD_PRESET
→ See `ENV_CONFIG_GUIDE.md`

---

## 🎬 NEXT PHASE

**Phase 2 (Auth Implementation):**

- Implement Firebase login/register
- Connect AuthViewModel to screens
- Add auth guard navigation

**Phase 3-4 (Scan Core):**

- Wire AI API integration
- Implement image upload + analyze
- Test mock server responses

Xem `PROGRESS.md` chi tiết.
