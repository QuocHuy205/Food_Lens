# ⚙️ OPERATIONS — Git Flow & Commit Convention

---

## Git Flow

```
main
├── develop          ← branch chính để phát triển
│   ├── feature/auth-login
│   ├── feature/scan-food
│   ├── feature/ai-integration
│   ├── feature/nutrition-stats
│   └── feature/recommendation
└── fix/firebase-config-error
```

### Quy trình làm feature mới:

```bash
# 1. Từ develop, tạo branch mới
git checkout develop
git pull origin develop
git checkout -b feature/scan-food

# 2. Code...

# 3. Commit
git add .
git commit -m "feat(scan): add image picker and upload to cloudinary"

# 4. Push và tạo PR vào develop
git push origin feature/scan-food

# 5. Merge develop vào main khi xong sprint
```

---

## Commit Convention

Format: `type(scope): mô tả ngắn gọn`

| Type | Khi nào dùng |
|------|-------------|
| `feat` | Thêm tính năng mới |
| `fix` | Sửa bug |
| `refactor` | Sửa code, không đổi hành vi |
| `test` | Thêm/sửa test |
| `docs` | Sửa tài liệu |
| `chore` | Setup, config, dependencies |
| `style` | Sửa UI/layout |

### Ví dụ commit tốt:
```bash
feat(auth): add email/password login with firebase
feat(scan): integrate cloudinary image upload
fix(scan): handle null response from AI API
refactor(nutrition): extract calorie calculation to usecase
test(auth): add unit tests for login usecase
chore: add riverpod and dio dependencies
style(home): update bottom navigation bar colors
```

---

## Quy trình khi demo

```bash
# Trước khi demo, build APK release
flutter build apk --debug

# Cài lên điện thoại
adb install build/app/outputs/flutter-apk/app-debug.apk

# Nếu demo trên emulator, đảm bảo mock AI server chạy
cd ai_server
python -m uvicorn main:app --reload --port 8000
```
