# SESSION HANDOFF - Compact (Updated Apr 20, 2026)

Muc tieu: File gon, de AI session sau tiep quan nhanh. Giữ chi tiet session gan nhat, tom tat day du cac session truoc.

---

## Session Gan Nhat - Session 16 (Apr 20, 2026)

### Da hoan thanh
- Register UI/UX:
  - Can giua logo + header tren man Register de dong bo voi Login.
  - Toi uu cam giac keyboard cham khi focus o nhap lieu.
  - Chuyen Register ve layout co dinh 1 trang theo yeu cau user:
    - Khong scroll.
    - Khong day giao dien len khi ban phim hien.
    - Su dung `resizeToAvoidBottomInset: false`.
- Global keyboard dismiss:
  - Tap ra ngoai input se unfocus va tat ban phim cho toan app.
  - Da gan o `MaterialApp.builder`.
- Edit Profile:
  - `BMI` va `Daily Calorie Needs (TDEE)` dat chung 1 hang de tiet kiem dien tich.
- Safe cleanup (khong doi luong chinh):
  - Xoa import/field khong dung o mot so man Auth.
  - Sua cac import path sai o ViewModel (Scan/History/Nutrition) de het compile errors.
  - Doi mot phan `withOpacity` sang `withValues` o cac file da touch.

### Files da thay doi gan nhat
- `lib/main.dart`
- `lib/features/auth/presentation/screens/register_screen.dart`
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/auth/presentation/screens/forgot_password_screen.dart`
- `lib/features/auth/presentation/screens/splash_screen.dart`
- `lib/features/profile/presentation/screens/edit_profile_screen.dart`
- `lib/features/scan/presentation/viewmodels/scan_viewmodel.dart`
- `lib/features/history/presentation/viewmodels/history_viewmodel.dart`
- `lib/features/nutrition/presentation/viewmodels/nutrition_viewmodel.dart`
- `lib/features/scan/data/datasources/ai_remote_datasource.dart`
- `test/mocks/mock_repositories.dart`

### Trang thai hien tai
- App chay duoc (`flutter run` OK trong cac lan chay gan day).
- `flutter analyze` hien con issue lint/info, nhung compile errors da duoc giam dang ke va luong chinh van on.
- Huong logo cu da duoc giu theo yeu cau user.

---

## Tom Tat Day Du Cac Session Truoc (Sessions 1-15)

### Session 15 (Apr 20, 2026)
- Dot cleanup/analyze toan du an:
  - Quet warning/error tong.
  - Don warning an toan o Auth + Splash.
  - Chot huong: giu hanh vi dang chay, chi don cac diem low-risk.

### Session 14 (Apr 19, 2026)
- Auth guard + restore session:
  - Router redirect theo auth state.
  - Startup doi auth init truoc khi quyet dinh route.
- Local auth token persistence cho server integration.
- Home header dong bo profile (ten/avatar).
- Bo xung UX nho trong Edit Profile.

### Session 13 (Apr 19, 2026)
- Profile feature wiring day du voi Firestore (`users/{uid}`):
  - Repo + datasource + viewmodel + usecases.
  - ProfileScreen hien du lieu that.
  - EditProfileScreen save/restore profile that.

### Session 12 (Apr 19, 2026)
- Google Sign-In flow that cho Login/Register.
- Sua back behavior o ScanScreen (pop hoac fallback go home).
- Upsert user document sau Google sign-in.

### Session 11 (Apr 19, 2026)
- Forgot Password route fix va verify luong dieu huong.
- Build debug OK.

### Session 10 (Apr 18, 2026)
- Them nut Google tren Login/Register.
- Tao ForgotPasswordScreen voi luong success state.
- Register fit one-screen (thoi diem do dung LayoutBuilder/IntrinsicHeight).

### Session 9 (Apr 18, 2026)
- Hoan thien cac chinh sua dieu huong Register, bo cuc auth UI.

### Session 8 (Apr 18, 2026)
- UI layer hoan thien bo man hinh chinh + routing top-level.
- Navigation flow duoc test end-to-end tren thiet bi.

### Session 7 (Apr 18, 2026)
- Redesign man hinh ScanResult/History/Stats/Profile/EditProfile.

### Session 6 (Apr 18, 2026)
- Xay auth UI (Splash/Login/Register) + Home/Scan UI.

### Sessions 1-5
- Dat nen tang architecture:
  - Clean Architecture cho Flutter app.
  - Server-client separation.
  - Datasource/model/repository groundwork.

---

## Status Hien Tai Theo Module

- Auth: Da co login/register/google/forgot-password + auth guard.
- Profile: Load/save Firestore, Edit Profile hoat dong.
- Home: Dong bo profile co ban.
- Scan/Nutrition/History:
  - UI da co, mot so usecase/repository path tiep tuc hoan thien theo phase.
- AI Server integration:
  - Co cau truc endpoint/datasource; can tiep tuc test e2e voi server that.

---

## Van De Con Ton (khong block runtime)

- Nhieu lint info con lai (chu yeu):
  - `withOpacity` deprecation -> can chuyen tiep sang `withValues` tren cac file chua touch.
  - `use_super_parameters`.
  - `avoid_print` o cloudinary service.
  - mot so style lint nho (curly braces).
- Khuyen nghi: dọn lint theo tung nhom de tranh roi regression UI.

---

## Next Step De Xuat (cho AI session sau)

1. Lint cleanup pass 2 (scope an toan):
   - Chuyen het `withOpacity` con lai.
   - Don `avoid_print` bang logger/co dieu kien debug.
2. Hoan thien usecase wiring cho Scan/History/Nutrition.
3. E2E test luong scan:
   - pick image -> upload cloudinary -> call `/analyze` -> luu firestore.
4. Them test cho auth/profile critical paths.

---

## Lenh Kiem Tra Nhanh

- `flutter run`
- `flutter analyze`
- `flutter test`

---

## Ghi Chu Ban Giao

- Uu tien giu hanh vi dang chay.
- Neu refactor man auth/register, tranh dua lai `IntrinsicHeight` de khong lap lai hien tuong keyboard cham.
- Tiep tuc cap nhat file nay sau moi session theo dung format compact.
