# 🍜 AI Food Recognition — Entry Point for AI Agents

> **Đọc file này đầu tiên trước khi làm bất cứ điều gì.**

---

## 📌 Tổng quan hệ thống

**Tên đồ án:** Hệ thống AI nhận diện món ăn và ước tính lượng calo hỗ trợ đề xuất chế độ dinh dưỡng

**Nhóm sinh viên:**
- Vương Quốc Huy — 23IT.B085 — 23SE4
- Nguyễn Duy Thăng — 23IT.B206 — 23SE5
- Nguyễn Đức Hải — 23IT.B048 — 23SE4

**GVHD:** ThS. Trần Đình Sơn | **Trường:** VKU — Đà Nẵng

---

## 🏗️ Tech Stack

| Layer | Công nghệ |
|-------|-----------|
| Mobile App | Flutter 3.x |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| Image Storage | Cloudinary |
| AI API | FastAPI (Python) hoặc Mock JSON |
| State Management | Riverpod |

---

## 🔄 Flow chính

```
User → Chụp/Upload ảnh → Cloudinary (lưu URL) → AI API (nhận diện)
     → Kết quả: tên món + calo → Lưu Firestore → Cập nhật Daily Log
     → Hiển thị Stats → Tạo Recommendation
```

---

## 📁 Cấu trúc tài liệu

```
food-ai-docs/
├── CLAUDE.md                  ← Bạn đang đọc file này
├── SETUP_GUIDE.md             ← Hướng dẫn setup từ zero
│
├── .claude/
│   ├── RULES.md               ← Quy tắc kiến trúc (PHẢI đọc)
│   ├── CODE_QUALITY.md        ← Chuẩn code
│   ├── TESTING.md             ← Hướng dẫn test
│   └── OPERATIONS.md          ← Git flow, commit
│
├── agents/
│   ├── UI_AGENT.md            ← Danh sách màn hình + navigation
│   ├── AUTH_AGENT.md          ← Firebase Auth flow
│   ├── DATA_AGENT.md          ← Firestore schema (QUAN TRỌNG NHẤT)
│   └── AI_AGENT.md            ← AI pipeline + mock strategy
│
├── commands/
│   └── COMMANDS.md            ← Template thêm feature mới
│
└── docs/
    ├── ARCHITECTURE.md        ← Clean Architecture + MVVM
    ├── TECH_STACK.md          ← Chi tiết công nghệ
    ├── PROJECT_STRUCTURE.md   ← Cây thư mục Flutter
    ├── FEATURE_GUIDE.md       ← Hướng dẫn code từng feature
    ├── PROGRESS.md            ← Checklist tiến độ
    └── SESSION_HANDOFF.md     ← Ghi context cho AI tiếp theo
```

---

## 🚀 Lệnh quan trọng

```bash
# Tạo project Flutter
flutter create food_ai_app --org com.vku --platforms android,ios

# Chạy app
cd food_ai_app && flutter pub get && flutter run

# Build APK demo
flutter build apk --debug

# Chạy test
flutter test

# Chạy mock AI server
cd ai_server && uvicorn main:app --reload --port 8000
```

---

## 📖 Thứ tự đọc tài liệu

1. `CLAUDE.md` ← đang đọc
2. `SETUP_GUIDE.md` ← setup môi trường
3. `.claude/RULES.md` ← hiểu kiến trúc
4. `docs/PROJECT_STRUCTURE.md` ← cây thư mục
5. `agents/DATA_AGENT.md` ← hiểu database
6. `agents/UI_AGENT.md` ← hiểu màn hình
7. `agents/AI_AGENT.md` ← hiểu AI flow
8. `docs/FEATURE_GUIDE.md` ← bắt đầu code

---

## ⚠️ Quy tắc vàng

- **KHÔNG** viết logic trong Widget
- **KHÔNG** gọi Firestore trực tiếp từ UI
- **LUÔN** dùng Repository pattern
- **LUÔN** handle lỗi với `Either<Failure, Success>`
- File > 300 dòng → tách nhỏ ra
