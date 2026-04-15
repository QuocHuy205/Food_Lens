# ✅ TIẾN ĐỘ DỰ ÁN — Ứng Dụng Nhận Diện Thực Phẩm AI & Calo

> ⚠️ QUY TẮC:

- Luôn đọc file này trước khi viết code
- Chỉ làm 1 task tại 1 thời điểm (theo Phase 2, 3, 4... lần lượt)
- Sau khi xong → tick [x] + cập nhật SESSION_HANDOFF.md

---

## 🎯 STATUS SUMMARY

| Phase    | Tên             | Status      | Tiến độ              |
| -------- | --------------- | ----------- | -------------------- |
| Phase 1  | Foundation      | ✅ COMPLETE | 100%                 |
| Phase 2  | Auth (Firebase) | 🟡 NEXT     | 0% (structure ready) |
| Phase 3  | Profile & TDEE  | ⏳ TODO     | 0%                   |
| Phase 4  | Scan & Upload   | ⏳ TODO     | 0%                   |
| Phase 5  | AI Integration  | ⏳ TODO     | 0%                   |
| Phase 6  | Save History    | ⏳ TODO     | 0%                   |
| Phase 7  | Daily Tracking  | ⏳ TODO     | 0%                   |
| Phase 8  | Stats & Charts  | ⏳ TODO     | 0%                   |
| Phase 9  | Recommendation  | ⏳ TODO     | 0%                   |
| Phase 10 | UI Polish       | ⏳ TODO     | 0%                   |
| Phase 11 | Testing         | ⏳ TODO     | 0%                   |
| Phase 12 | Demo Prep       | ⏳ TODO     | 0%                   |

---

# 🧠 DEVELOPMENT FLOW (QUAN TRỌNG)

Auth → Profile → Scan → AI → Save → Stats → Recommendation → Polish

**RULE: Cannot skip phases. Must do Auth first before Profile.**

---

# ✅ PHASE 1 — SETUP & FOUNDATION (COMPLETE)

## 1. Project Setup

- [x] Tạo Flutter project
- [x] Setup Clean Architecture structure
- [x] Tạo toàn bộ file `.md` (CLAUDE, RULES, AGENTS,...)
- [x] Setup Firebase project
- [x] Kết nối Firebase vào Flutter
- [x] Setup Cloudinary
- [x] Setup environment config (.env + .env.example)
- [x] Tạo toàn bộ 45+ folder
- [x] Tạo 80+ starter files (entities, screens, viewmodels, providers)
- [x] Setup go_router with all routes
- [x] Fix pubspec.yaml (compatible versions)
- [x] Fix main.dart (proper Firebase init + .env load)
- [x] Cloudinary test screen (working + integrated)

**STATUS**: ✅ Foundation ready for Phase 2 (Auth Implementation)

---

# 🔐 PHASE 2 — AUTHENTICATION (NEXT - BẮT BUỘC LÀM TRƯỚC)

## 2.1 Auth Logic

- [ ] Tạo `UserEntity` (DONE - structure only)
- [ ] Tạo `AuthRepository` (DONE - abstract only)
- [ ] Tạo `AuthRepositoryImpl` (Firebase) — **TODO NEXT**
  - Implement `register(email, password)`
  - Implement `login(email, password)`
  - Implement `logout()`
  - Wire Firebase Auth methods
  - Return Either<Failure, UserEntity>

## 2.2 Firestore DataSource

- [ ] Tạo `FirestoreDataSource` — **TODO NEXT**
  - Implement `saveUser(UserModel)`
  - Implement `getUser(userId)`
  - Collections: `users/{userId}`

## 2.3 UseCases

- [ ] `LoginUseCase` — **TODO NEXT**
  - Call AuthRepository.login()
  - Return Either<Failure, UserEntity>
- [ ] `RegisterUseCase` — **TODO NEXT**
  - Call AuthRepository.register()
  - Call FirestoreDataSource.saveUser()
  - Return Either<Failure, UserEntity>
- [ ] `LogoutUseCase` — **TODO NEXT**
  - Call AuthRepository.logout()
- [ ] `GetCurrentUserUseCase` (optional) — **TODO LATER**
  - Get cached user or stream

## 2.4 ViewModel

- [ ] `AuthViewModel` — **TODO NEXT**
  - Inject: LoginUseCase, RegisterUseCase, LogoutUseCase
  - Implement login(email, pwd) method
  - Implement register(email, pwd, name) method
  - Implement logout() method
  - Update state on success/error

## 2.5 UI Screens

- [ ] `LoginScreen` — **TODO NEXT**
  - Wire AuthViewModel
  - Watch authViewModelProvider
  - Build form (email, password fields)
  - Call viewmodel.login() on submit
  - Show loading + error states
- [ ] `RegisterScreen` — **TODO NEXT**
  - Similar to LoginScreen
  - Call viewmodel.register()

## 2.6 Navigation

- [x] `go_router` setup (DONE)
- [ ] Auth guard — **TODO NEXT**
  - Redirect to /login if logout
  - Redirect to /home if logged in

---

# 👤 PHASE 3 — PROFILE & NUTRITION BASE (TODO - AFTER AUTH)

## 3.1 Profile Data

- [ ] UserProfile model with @freezed (height, weight, age, gender)
- [ ] Firestore datasource (saveProfile, getProfile)
- [ ] ProfileRepository + ProfileRepositoryImpl

## 3.2 Logic

- [ ] Tính BMI: `weight / (height/100)²`
- [ ] Tính TDEE (based on age, weight, activity level)

## 3.3 UI

- [ ] ProfileScreen (view profile + BMI/TDEE display)
- [ ] EditProfileScreen (form to update profile)

---

# 📸 PHASE 4 — SCAN FOOD (TODO - CORE FEATURE)

## 4.1 Image Input

- [ ] Camera (image_picker)
- [ ] Gallery picker

## 4.2 Upload

- [ ] Upload ảnh lên Cloudinary — **(already setup in test screen)**
- [ ] Lấy image_url

## 4.3 AI Integration

- [ ] AIRepository (abstract)
- [ ] Call API `/analyze`
- [ ] Parse response: food_name, calories_estimated

## 4.4 UI

- [ ] ScanScreen (camera/gallery, upload button)
- [ ] ResultScreen (show food + calories)

## 4.5 Error Handling

- [ ] Retry khi AI fail
- [ ] Fallback mock data

---

# 🤖 PHASE 5 — AI (TODO - MOCK FIRST)

## 5.1 Mock AI (ưu tiên làm trước)

- [ ] Setup FastAPI server
- [ ] Tạo mock response (10–20 món ăn VN)
- [ ] Test từ Flutter

## 5.2 (Optional) Real Model

- [ ] Train model (MobileNet/EfficientNet)
- [ ] Export API

---

# 💾 PHASE 6 — SAVE DATA & HISTORY (TODO)

## 6.1 Scan History

- [ ] Collection: `users/{userId}/scans`
- [ ] Lưu: image_url, food_name, calories, timestamp

## 6.2 UI

- [ ] HistoryScreen
- [ ] List scan items

---

# 📊 PHASE 7 — NUTRITION TRACKING (TODO)

## 7.1 Daily Log

- [ ] Collection: `daily_logs`
- [ ] Tự động cộng calories mỗi ngày

## 7.2 HomeScreen

- [ ] Hiển thị calories hôm nay
- [ ] So sánh với TDEE

---

# 📈 PHASE 8 — STATS & ANALYTICS (TODO)

## 8.1 Stats

- [ ] Chart 7 ngày (bar chart)
- [ ] Calories trend

## 8.2 Macros

- [ ] Protein / Carbs / Fat breakdown

---

# 🧠 PHASE 9 — RECOMMENDATION (TODO)

## 9.1 Logic

- [ ] Nếu thiếu calo → gợi ý ăn thêm
- [ ] Nếu dư calo → cảnh báo

## 9.2 Data

- [ ] Collection: `recommendations`

## 9.3 UI

- [ ] Hiển thị trên HomeScreen

---

# 🎨 PHASE 10 — POLISH UI/UX (TODO)

- [ ] Loading states (tất cả màn)
- [ ] Error states (retry button)
- [ ] Empty states
- [ ] Animation nhẹ

---

# 🧪 PHASE 11 — TESTING (TODO)

- [ ] Unit test Repository
- [ ] Unit test UseCase
- [ ] Test TDEE calculator

---

# 🎯 PHASE 12 — DEMO PREP (TODO)

- [ ] Seed dữ liệu demo (5–7 ngày)
- [ ] Tạo account demo
- [ ] Setup mock AI ổn định
- [ ] Build APK

---

# 🎤 DEMO FLOW (3 phút)

1. Login
2. Profile (TDEE)
3. Scan món ăn → kết quả AI
4. Lưu → xem lịch sử
5. Stats + Recommendation

---

# ❗ AI INSTRUCTIONS (QUAN TRỌNG)

👉 Khi AI đọc file này:

1. Tìm phase đầu tiên chưa hoàn toàn (hiện tại: Phase 2)
2. Làm task đầu tiên không check [x]
3. Chỉ implement 1 file/1 feature tại 1 thời điểm
4. Sau khi xong:
   - Tick [x]
   - Test bằng `flutter run`
   - Update SESSION_HANDOFF.md

👉 Không được:

- Nhảy bước (must do Phase 2 → Phase 3 → ...)
- Code nhiều feature cùng lúc (1 task/1 session)
- Bỏ qua architecture rules (xem .claude/RULES.md)
- Commit không tick ✅ PROGRESS.md
