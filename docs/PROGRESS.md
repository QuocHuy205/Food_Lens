# ✅ TIẾN ĐỘ DỰ ÁN — Food Lens AI (UPDATED — Server-Client Separation)

> 🎯 **QUY TẮC CHÍNH**:
>
> 1. Server xử lý AI (FastAPI)
> 2. App chỉ gọi API + hiển thị UI
> 3. Làm 1 Phase lần, 1 task tại 1 thời điểm

---

## 📊 TỔNG QUÁT

| Phase | Tên               | Trạng Thái  | % Xong | Server  | App |
| ----- | ----------------- | ----------- | ------ | ------- | --- |
| 1     | Setup & Core      | ✅ XONG     | 100%   | ✅      | ✅  |
| 2     | Auth Firebase     | 🟡 LÀM TIẾP | 30%    | —       | 🟡  |
| 3     | Profile & TDEE    | ⏳ CHƯA     | 0%     | —       | ⏳  |
| 4     | Scan Food (Core)  | ⏳ CHƯA     | 0%     | ⏳ SDK  | ⏳  |
| 5     | AI Server (Mock)  | ⏳ CHƯA     | 0%     | ⏳ Mock | —   |
| 6     | Lịch Sử Scan      | ⏳ CHƯA     | 0%     | —       | ⏳  |
| 7     | Daily Log & Stats | ⏳ CHƯA     | 0%     | —       | ⏳  |
| 8     | UI/UX Polish      | ✅ XONG     | 100%   | —       | ✅  |
| 9     | Testing           | ⏳ CHƯA     | 0%     | ⏳      | ⏳  |
| 10    | Demo Build APK    | ⏳ CHƯA     | 0%     | —       | ⏳  |

---

## ✅ PHASE 1 — SETUP (XONG)

### Server Setup ✅

- [x] FastAPI skeleton (main.py)
- [x] Config + environment variables (config.py)
- [x] Pydantic schemas (schemas.py)
- [x] CORS middleware configured
- [x] Health check endpoint (/health)

### App Setup ✅

- [x] Flutter project + Clean Architecture
- [x] 45+ folders + 80+ files structure
- [x] Firebase setup + pubspec.yaml
- [x] .env + Cloudinary config loading
- [x] go_router + all routes defined
- [x] Splash screen auto-navigate

### Core Implementations ✅

- [x] AppConfig.dart (load from .env) — **UPDATED**
- [x] Failure.dart (more types) — **UPDATED**
- [x] AiRemoteDatasource (Dio HTTP) — **NEW UPDATED**
- [x] CloudinaryDatasource (Dio HTTP) — **NEW UPDATED**
- [x] FirestoreDatasource (CRUD) — **NEW**
- [x] ScanResultModel + ScanHistoryModel — **UPDATED**
- [x] ScanRepositoryImpl (wired Firestore) — **UPDATED**
- [x] ScanRepository abstract (all methods) — **UPDATED**

---

## 🔐 PHASE 2 — AUTH (LÀM TIẾP — 30%)

### 2.1 Firebase Auth Setup ✅

- [x] Firebase initialized in main.dart
- [x] firebase_auth: ^5.3.1 added to pubspec.yaml

### 2.2 Firestore User Collection ⭐ CHƯA

- [ ] Create `/users/{userId}` collection schema
- [ ] Fields: uid, email, fullName, createdAt, etc.
- [ ] Security rules configured

### 2.3 AuthDataSource ⭐ CHƯA

- [ ] File: `lib/features/auth/data/datasources/firebase_datasource.dart`
- [ ] Methods:
  - `registerUser(email, password, name)` → Firebase Auth + Firestore
  - `loginUser(email, password)` → Firebase Auth
  - `logoutUser()` → Firebase logout
  - `getUserProfile(userId)` → Firestore read

### 2.4 AuthRepositoryImpl ⭐ CHƯA

- [ ] File: `lib/features/auth/data/repositories/auth_repository_impl.dart`
- [ ] Wires FirebaseDataSource
- [ ] Returns Either<Failure, UserEntity>

### 2.5 UseCases ⭐ CHƯA

- [ ] `RegisterUseCase` → calls repo.register()
- [ ] `LoginUseCase` → calls repo.login()
- [ ] `LogoutUseCase` → calls repo.logout()
- [ ] `GetUserProfileUseCase` → calls repo.getUserProfile()

### 2.6 AuthViewModel ⭐ CHƯA

- [ ] File: `lib/features/auth/presentation/providers/auth_provider.dart`
- [ ] StateNotifier managing auth state
- [ ] Methods: register(), login(), logout()
- [ ] States: idle, loading, authenticated, error

### 2.7 LoginScreen UI ⭐ CHƯA

- [ ] Form: Email + Password fields
- [ ] Wire AuthViewModel
- [ ] Show loading/error states
- [ ] Link to /register

### 2.8 RegisterScreen UI ⭐ CHƯA

- [ ] Form: Name + Email + Password + Confirm
- [ ] Wire AuthViewModel
- [ ] Show loading/error states
- [ ] Link to /login

### 2.9 Auth Guard (Navigation) ⭐ CHƯA

- [ ] Check auth state on app startup
- [ ] Redirect: not auth → /login, auth → /home
- [ ] Persist auth state across app restarts

---

## 👤 PHASE 3 — PROFILE (Sau Auth)

### 3.1 ProfileDataSource ⏳ CHƯA

- [ ] Firestore CRUD: save/get/update profile

### 3.2 ProfileModel + Entity ⏳ CHƯA

- [ ] Fields: age, gender, height, weight, goal, TDEE

### 3.3 ProfileRepositoryImpl + Repo ⏳ CHƯA

- [ ] Wire ProfileDataSource

### 3.4 UseCases ⏳ CHƯA

- [ ] GetProfileUseCase
- [ ] UpdateProfileUseCase
- [ ] CalculateBmiUseCase
- [ ] CalculateTdeeUseCase

### 3.5 ProfileViewModel ⏳ CHƯA

- [ ] State management for profile edit

### 3.6 ProfileScreen + EditProfileScreen ⏳ CHƯA

- [ ] Display user bio
- [ ] Show BMI + TDEE
- [ ] Editable form

---

## 📸 PHASE 4 — SCAN FOOD (Core) — 0%

### 4.1 AI Server Mock ⏳ CHƯA

- [ ] Implement `/analyze` endpoint (mock inference)
- [ ] Add 10-20 Vietnamese foods mock data
- [ ] Test: POST /analyze → returns food + calories

### 4.2 Upload + Analyze Flow ⏳ CHƯA

- [ ] ScanScreen: pick image → upload Cloudinary
- [ ] Call AI API: POST /analyze with imageUrl
- [ ] ScanResultScreen: display result

### 4.3 ScanViewModel ⏳ CHƯA

- [ ] Orchestrate upload + analyze flow
- [ ] Handle loading states

### 4.4 ScanScreen UI ⏳ CHƯA

- [ ] Camera/Gallery picker
- [ ] Image preview
- [ ] Analyze button

### 4.5 ScanResultScreen UI ⏳ CHƯA

- [ ] Show food name + calories
- [ ] Nutrition breakdown
- [ ] Top predictions
- [ ] Save/Retake buttons

---

## 💾 PHASE 5-6 — HISTORY + DAILY LOG

### 5.1 Save Scan to Firestore ⏳ CHƯA

- [ ] After user confirms → save to `/users/{uid}/scans/{scanId}`

### 5.2 HistoryScreen ⏳ CHƯA

- [ ] List all scans (paginated)
- [ ] Filter by date/meal type
- [ ] Swipe to delete

### 6.1 Daily Log Calculation ⏳ CHƯA

- [ ] Auto-calculate daily nutrition
- [ ] Save to `/users/{uid}/daily_logs/{date}`

---

## 📊 PHASE 7 — STATS + RECOMMENDATION

### 7.1 StatsScreen ⏳ CHƯA

- [ ] 7/30/90-day charts
- [ ] Calorie trend line
- [ ] Macro breakdown

### 7.2 Recommendation Engine ⏳ CHƯA

- [ ] Calc dư/thiếu calo
- [ ] Suggest meals

---

## 🎨 PHASE 8 — UI/UX POLISH

### 8.1 Design System ⏳ CHƯA

---

## 🎨 PHASE 8 — UI/UX DESIGN (XONG — 100%) ✅

**All 10 Screens Fully Designed with Material Design 3 + Animations**

### 8.1 Design System ✅

- [x] Colors, typography (Material 3 spec)
- [x] Animations (400ms slide, 300ms cascade, 100ms press)
- [x] Spacing (16px base, 12px radius, proper padding)
- [x] Icons, shadows, borders (consistent style)

### 8.2 Bottom Navigation ✅

- [x] 5 tabs: Home | Scan | History | Stats | Profile
- [x] Working go_router navigation on all screens
- [x] Smooth stateless transitions

### 8.3 HomeScreen ✅

- [x] ✅ **COMPLETED** — Material Design 3 full implementation
- [x] Greeting card with animation
- [x] Calorie progress bar (animated 800ms width fill)
- [x] Recent scans list (3 items with emoji)
- [x] Floating Action Button (orange, /scan navigation)
- [x] Bottom navigation bar with working links

### 8.4 ScanScreen ✅

- [x] ✅ **COMPLETED** — Beautiful camera UI
- [x] Large camera icon with elastic animation (600ms)
- [x] Two action buttons: Take Photo (green) + Choose Gallery (outlined)
- [x] Page enter animation (400ms slide + fade)
- [x] AppBar with green background
- [x] Bottom navigation bar

### 8.5 ScanResultScreen ✅

- [x] ✅ **COMPLETELY REWRITTEN** — Full nutrition interface
- [x] Food image placeholder with emoji (🥗) + confidence badge (92%)
- [x] Food info card with total calories (350 kcal) + portion (200g)
- [x] Quantity selector (+/- buttons, stateful)
- [x] Nutrition facts table (Protein/Carbs/Fat/Fiber with colored bullets)
- [x] Save to History button with green gradient + loading spinner
- [x] Success snackbar feedback
- [x] Bottom navigation bar with working routes

### 8.6 HistoryScreen ✅

- [x] ✅ **COMPLETE REDESIGN** — Professional history interface
- [x] Search bar for filtering
- [x] Filter chips (Today, Yesterday, Last 7/30 Days) — stateful
- [x] Scan list items: emoji, name, time, calories, meal type badge
- [x] Swipe-to-delete gesture with undo snackbar
- [x] Material Design 3 cards with borders
- [x] Bottom navigation bar with working links

### 8.7 StatsScreen ✅

- [x] ✅ **COMPLETE ANALYTICS DASHBOARD**
- [x] Period selector (7/30/90/365 Days) — stateful
- [x] Summary cards: Average Daily (2,180 kcal) + Goal Remaining (+520 kcal)
- [x] Calorie trend chart: 7-day bar chart with gradient fills (scaled bars)
- [x] Macro breakdown: 3 color-coded segments (Blue/Orange/Red) + legend
- [x] Macro info display: Protein 145g, Carbs 298g, Fat 66g with colors
- [x] Bottom navigation bar

### 8.8 ProfileScreen ✅

- [x] ✅ **USER PROFILE COMPLETE**
- [x] Avatar with initials (88px, green background)
- [x] Name & email display (John Doe, john.doe@example.com)
- [x] Stat cards: BMI (24.5) + TDEE (2,700 kcal/day) with subtitles
- [x] Settings menu: 5 items with icons (Edit, Notifications, Units, Privacy, Help)
- [x] Each item with `onTap` navigation (Edit → /profile/edit)
- [x] Logout button (red styling) + confirmation dialog
- [x] Bottom navigation bar with working links

### 8.9 EditProfileScreen ✅

- [x] ✅ **ADVANCED PROFILE EDITOR**
- [x] Back button to return to /profile
- [x] Personal info: Name, Age (text fields with focus animations)
- [x] Gender dropdown (Male, Female)
- [x] Physical measurements: Height (cm), Weight (kg) in row
- [x] **REAL-TIME BMI CALCULATION** ✅
  - Formula: weight / (height/100)²
  - Display: BMI value + status (Underweight/Normal/Overweight/Obese)
  - Color-coded: Blue/Green/Orange/Red
  - Updates on field change
- [x] **REAL-TIME TDEE CALCULATION** ✅
  - Mifflin-St Jeor equation for BMR
  - Activity multiplier: Sedentary (1.2) → Very Active (1.9)
  - Display: Daily calorie needs based on all inputs
  - Updates reactively
- [x] Activity Level dropdown (Sedentary/Light/Moderate/Active/Very Active)
- [x] Goal dropdown (Lose Weight/Maintain/Gain Weight)
- [x] Action buttons: Discard (outlined) + Save Changes (green gradient)
- [x] Save button with loading spinner
- [x] Success snackbar + auto-redirect to /profile
- [x] Form validation & error handling

### 8.10 LoginScreen ✅

- [x] ✅ **FIREBASE AUTH UI** (Session 6)
- [x] Email + Password fields with focus animations
- [x] Form validation (email format, password 6+ chars)
- [x] Error message display with shake animation
- [x] Login button with scale press animation + loading spinner
- [x] "Register" link to /register
- [x] Proper Material Design 3 styling

### 8.11 RegisterScreen ✅

- [x] ✅ **USER SIGNUP UI** (Session 6)
- [x] 4 input fields: Name, Email, Password, Confirm Password
- [x] Password strength indicator (0-4 levels with color feedback)
- [x] Terms & conditions checkbox with scale animation
- [x] Focus border animations for all fields
- [x] Back button to return to /login
- [x] Register button with loading state
- [x] Full Material Design 3 implementation

### 8.12 SplashScreen ✅

- [x] ✅ **APP INTRO** (Session 6)
- [x] Logo scale animation (0→1)
- [x] Tagline scale animation (100ms delay)
- [x] Loading spinner
- [x] Fade-out at 2.8s + auto-navigate to /login
- [x] Working go_router navigation

---

## 🧪 PHASE 9 — TESTING

- [ ] Unit tests (usecases)
- [ ] Widget tests (screens)
- [ ] Integration tests (optional)

---

## 📦 PHASE 10 — BUILD DEMO APK

- [ ] `flutter build apk --release`
- [ ] Test on real device

---

## 🎤 NEXT IMMEDIATE STEPS

### Cho AI Session Tiếp Theo (Phase 2 — Auth Implementation):

1. **Firebase Setup** (Firestore `/users` collection schema)
2. **AuthDataSource** (Firebase Auth + Firestore CRUD)
3. **AuthRepositoryImpl + UseCases** (Register, Login, Logout, GetProfile)
4. **AuthViewModel** + state management (StateNotifier)
5. **LoginScreen + RegisterScreen** UI (wire ViewModel, handle states)
6. **Auth Guard** (redirect logic on app startup)
7. **Test**: Manual login/register flow on device

---

## 📝 Change Log

**Session 7 (Today - Apr 17):**

- ✅ Updated ScanResultScreen (complete redesign with nutrition facts)
- ✅ Updated HistoryScreen (search, filters, swipe-to-delete)
- ✅ Updated StatsScreen (period selector, trend chart, macro breakdown)
- ✅ Updated ProfileScreen (avatar, stat cards, settings menu, logout)
- ✅ Updated EditProfileScreen (real-time BMI + TDEE calculation)
- ✅ Updated SESSION_HANDOFF.md (comprehensive UI redesign details)
- ✅ Updated PROGRESS.md (Phase 8 UI/UX marked COMPLETE)

**Session 6 (Apr 16):**

- ✅ Fixed navigation (SplashScreen → LoginScreen, context.go working)
- ✅ Deleted 8 duplicate `_ui.dart` files (cleanup)
- ✅ Verified app runs on real Android device
- ✅ Updated CLAUDE.md + SESSION_HANDOFF.md

**Session 5 (Apr 16):**

- ✅ Updated CLAUDE.md (Server-Client explanation)
- ✅ Updated AppConfig (load .env)
- ✅ Implemented ai_remote_datasource (Dio HTTP)
- ✅ Implemented cloudinary_datasource (Dio HTTP)
- ✅ Created firestore_datasource (CRUD)
- ✅ Updated ScanResultModel (better JSON parsing)
- ✅ Updated ScanRepositoryImpl (wired Firestore)
- ✅ Updated Failure.dart (more types)
- ✅ Created UI skeleton files (9 screens)
- ✅ Updated SESSION_HANDOFF.md
- ✅ Updated PROGRESS.md
