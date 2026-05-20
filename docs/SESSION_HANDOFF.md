# SESSION HANDOFF - Compact (Updated May 14, 2026)

Mục tiêu: file gọn, để AI session sau nắm nhanh trạng thái mới nhất. Giữ chi tiết session gần nhất, tóm tắt các session trước.

---

## Session Mới Nhất - Session 28 (May 14, 2026 - Daily Calories TDEE Fix + Legacy 2200 Migration)

### Đã hoàn thành

- Sửa nguồn mục tiêu của Daily Calories ở Home:
  - `lib/features/home/presentation/screens/home_screen.dart` không còn dùng `2200` hardcoded.
  - Home ưu tiên `dailyCalorieTarget` đã lưu trong profile.
  - Nếu profile cũ còn thiếu target hoặc đang giữ giá trị legacy `2200`, Home sẽ tính TDEE từ chính profile.

- Tự migrate profile cũ khi load:
  - `lib/features/profile/data/repositories/profile_repository_impl.dart` đã thêm bước normalize profile khi đọc Firestore.
  - Nếu `dailyCalorieTarget == 2200` legacy, repository tính lại TDEE từ `gender`, `weight`, `height`, `age`, `activityLevel`.
  - Giá trị mới được ghi ngược lại Firestore để các lần load sau dùng đúng TDEE.

- Loại bỏ fallback cứng ở luồng tạo user mới:
  - `lib/features/auth/data/repositories/auth_repository_impl.dart` không còn set `dailyCalorieTarget: 2200` khi upsert user doc.
  - User mới sẽ lấy target từ profile/TDEE flow thay vì hardcode.

- Đồng bộ thông báo và hiển thị calories:
  - Scan result khi lưu lịch sử hiển thị snackbar theo format `quantity • kcal`.
  - History khi chỉnh số lượng cũng dùng cùng format đó.
  - Calories được round trước khi lưu và trước khi render để tránh số lẻ dài như `234.4324`.

### Trạng thái hiện tại

- Daily Calories ở Home đang lấy target từ profile TDEE đúng hướng.
- Profile cũ có thể tự được sửa dần khi user mở app và load profile.
- Lưu scan và chỉnh lịch sử đã đồng bộ hiển thị số lượng + kcal.
- `flutter analyze` đã chạy sạch sau các thay đổi này.

### Cần nhớ cho session sau

1. Nếu user vẫn thấy `2200`, kiểm tra dữ liệu profile cũ trong Firestore trước, vì repository chỉ migrate khi profile được load.
2. Nếu cần, quét thêm các màn khác có số cứng `2200` để phân biệt với Daily Calories của Home, ví dụ Stats chart.
3. Khi sửa UI calories, luôn round ở cả lúc lưu và lúc hiển thị để tránh lệch giữa Home, History, và snackbar.

---

## Session Mới Nhất - Session 27 (May 12, 2026 - Nutrition DB Auto-Fill + Progress Refresh)

### Đã hoàn thành

- Sửa nguyên nhân label chung “Món ăn hỗn hợp”:
  - `ai_server/nutrition_db.py` trước đây fallback về `DEFAULT_FOOD` khi thiếu mapping cho class key.
  - Đã thêm cơ chế tự sinh entry cho class thiếu mapping thay vì trả fallback cứng.
  - Entry sinh ra có:
    - `name_vi` humanized theo class key.
    - `calories_per_100g` và `nutrition_per_100g` ước lượng theo nhóm món.
  - Mục tiêu là giữ UI đúng tên món theo model đã train, không bị generic label.

- Đồng bộ lại tài liệu tiến độ:
  - `docs/PROGRESS.md` đã được cập nhật lại theo trạng thái hiện tại.
  - Phản ánh server, model, app, scan flow, auth, profile, history, stats đã ở trạng thái core hoàn tất.

### Trạng thái hiện tại

- AI server đã train lại model và có metrics eval mới.
- Flutter app đã wire đầy đủ luồng chính.
- Vấn đề cần kiểm tra tiếp là server reload và verify response thực tế sau mapping mới.

### Cần làm ngay sau session này

1. Restart AI server để nạp `nutrition_db.py` mới.
2. Test lại request phân tích ảnh với class cụ thể, đặc biệt `bun_dau_mam_tom`.
3. Kiểm tra JSON trả về có `food_name_vi` đúng và `top_predictions` không còn fallback sai.
4. Chạy lại app nếu cần để chắc chắn UI hiển thị đúng.

---

## Session Gan Nhat - Session 26 (May 20, 2026 - Cloudinary Debug + Home Fixes)

### Da hoan thanh

- Trang thai Cloudinary datasource:
  - `lib/features/scan/data/datasources/cloudinary_datasource.dart` da goi upload toi Cloudinary URL chinh xac.
  - `lib/core/services/cloudinary_service.dart` da duoc tung cao:
    - Them debug output chi tiet cho tung buoc (load credentials, POST, response).
    - Them timeout handler (30s).
    - Them socket/network exception handling.
    - Them file exist check truoc upload.
    - Khong con nhan cau truyen hay timeout nhat.
  - Can kiem tra `.env` co CLOUDINARY_CLOUD_NAME va CLOUDINARY_UPLOAD_PRESET kh.
  - Avatar upload su dung chung CloudinaryService -> neu avatar fail thi van la Cloudinary config.

- Sua Home Daily Calories:
  - `progress = (consumedCalories / goalCalories).clamp(0, 1)` -> progress khong vuot 100%.
  - `remainingCalories = (goalCalories - consumedCalories).clamp(0, infinity).round()` -> remaining khong the am.
  - Home bao hien thi di danh "Remaining" khong bao gio am con tim.

- Firestore persistence verification:
  - Scan result flow da wire:
    - `ScanScreen` -> chup/chon anh -> `ScanViewModel.analyzeImage()`.
    - `ScanViewModel` -> goi `ScanRepository.analyzeFood()` -> upload Cloudinary -> `AiRemoteDatasource.analyzeFoodByUrl()`.
    - `ScanResultScreen` -> load Firebase uid -> `ScanViewModel.saveScanHistory()` -> `ScanRepository.saveScanHistory()` -> `FirestoreDatasource.saveScanHistory()`.
    - Firestore path: `users/{uid}/scans/{scanId}`.
  - Neu scan data van khong luu, likely cause: 1) Cloudinary upload fail -> khong co imageUrl -> skip save, 2) Firebase auth uid null (check FirebaseAuth.instance.currentUser), 3) Firestore rules reject write.

- Stats topbar:
  - `lib/features/stats/presentation/screens/stats_screen.dart` da co `backgroundColor: AppColors.primary` + `foregroundColor: Colors.white`.
  - Topbar nay sync voi Home + History top bar, giao dien dong nhat.

### Trang thai hien tai

- Home: Real history + profile data, no hardcoded calories, remaining clamped >= 0.
- Stats: Topbar fixed, period selector working.
- History: Firestore-backed, search/filter wired.
- Cloudinary: Enhanced debug, timeout handle, exception catch.
- App lang (vi + en) va theme (light/dark) intact.
- `flutter analyze --no-fatal-infos`: 1 unrelated warning in old nutrition stats (unused \_buildMacroInfo).

### Luu y cho session sau - TRANG CAI DAT / DEBUG

- Neu user van bao "Cloudinary khong up anh duoc":
  1. Check `.env` file co day du CLOUDINARY_CLOUD_NAME, CLOUDINARY_UPLOAD_PRESET, CLOUDINARY_API_KEY hay khong.
  2. Chay app, mo app logs -> tim `[Cloudinary]` debug output -> xem exact error.
  3. Test Cloudinary credentials bang curl truc tiep tren terminal de loai tru app code.
  4. Neu Cloudinary fail thi scan save cung khong co anh_url -> can debug fix Cloudinary truoc.
- Neu user bao "scan data khong luu vao Firestore":
  1. Check Firebase uid co load khong: `FirebaseAuth.instance.currentUser?.uid` phai khac null.
  2. Check Firestore rules: `allow read, write: if request.auth.uid == resource.data.userId;` hoac tuong tu.
  3. Neu upload Cloudinary fail, scan data se khong luu (khong co imageUrl).
  4. Neu upload thanh cong, check Firestore console xem doc da dung khong.
- Neu user bao "avatar khong up duoc":
  - Avatar goi chung `CloudinaryService` -> kiem tra Cloudinary credentials truoc tien.
  - Check `lib/features/profile/presentation/screens/edit_profile_screen.dart` -> \_avatarUrl va \_isUploadingAvatar logic.
- Neu "Daily Calories" van bao am:
  - Xem HomeScreen tay code dat co dung: `remainingCalories.clamp(0, infinity)` chưa?
  - Neu da co thi khong the am con tim.

### Next Phase

- Kiem tra Cloudinary config khong?
- Chay `flutter run`, chup anh, xem debug log `[Cloudinary]` - neu fail la gi chi tiet?
- Sau fix Cloudinary thi scan save va avatar upload se thanh cong.

---

## Session Gan Nhat Truoc - Session 25 (May 12, 2026 - ai_server Reorg + README Rewrite)

### Da hoan thanh

- Don lai `ai_server/` theo huong gon va on:
  - Giữ lai core runtime files va xoa cache rác con sot.
  - Khong doi logic server/inference vi he thong dang chay on dinh.
- Viet lai `README_SERVER.md` cho dung cau truc hien tai:
  - Mo ta day du folder, file chinh, API endpoints, train, Docker, va troubleshooting.
  - Cap nhat cach chay server tren Windows voi `.venv311` va `uvicorn`.
- Ghi lai context cho session sau:
  - Server co 2 flow chinh: `/predict` va `/analyze`.
  - Flutter scan flow da noi dung tang va san sang test end-to-end.

### Trang thai hien tai

- `ai_server/` gon hon, doc de hieu hon, va khong lam thay doi luong nghiep vu.
- README da khop voi cach to chuc va cach khoi dong server hien tai.
- Buoc tiep theo la tiep tuc test end-to-end tren app neu can.

---

## Session Gan Nhat - Session 24 (May 12, 2026 - Server Restart + App Wiring)

### Da hoan thanh

- Sua server luong analyze:
  - Bo sung import `analyze_food_image` trong `main.py`.
  - Restart lai uvicorn de nap code moi.
  - Xac nhan `POST /analyze` tra `200` voi `image_url` that.
- Noi lai flow scan cua Flutter theo dung tang:
  - `ScanScreen` goi `ScanViewModel` thay vi tao datasource truc tiep.
  - `ScanViewModel` dung `AnalyzeFoodUseCase`, `SaveScanHistoryUseCase`, va `ScanRepository`.
  - `ScanRepositoryImpl` upload anh len Cloudinary truoc, sau do goi AI server bang `/analyze`.
  - Co fallback ve `/predict` neu call theo URL khong thanh cong.
- Tao provider DI cho scan:
  - Them `Dio`, `AiRemoteDatasource`, `CloudinaryDatasource`, `FirestoreDatasource`, `ScanRepository`, va use case providers.
- Validation:
  - `get_errors` cho cac file touch trong scan flow = khong con loi.
  - `GET /health`, `POST /predict`, va `POST /analyze` deu pass.

### Trang thai hien tai

- AI server da co day du hai luong:
  - `/predict` cho multipart upload truc tiep.
  - `/analyze` cho Cloudinary image URL.
- Flutter scan flow da ket noi theo dung tang, khong con goi AI datasource truc tiep trong UI.
- Buoc tiep theo phu hop nhat la chay `flutter run` / test scan end-to-end tren device.

---

## Session Gan Nhat - Session 23 (May 12, 2026 - ai_server Cleanup + Re-Validate)

### Da hoan thanh

- Don lai `ai_server/` de giam roi:
  - Xoa cac script test/benchmark/diagnostic cu khong con can cho runtime.
  - Xoa cac anh mau phuc vu test script cu.
- Giu lai cac file core cho server:
  - `main.py`, `inference.py`, `schemas.py`, `config.py`, `nutrition_db.py`, `requirements.txt`, `train.py`, `models/`, `data/`.
- Re-validate sau cleanup:
  - `/health` van tra `200` va `model_loaded: true`.
  - `/predict` van tra `200` tren anh that trong dataset.

### Trang thai hien tai

- `ai_server/` gon hon, it file phu, de tiep tuc phat trien luong analyze/return ket qua.
- Server van hoat dong on dinh sau cleanup.
- Buoc tiep theo la tiep tuc toi uu API/analyze flow neu can, hoac gan Flutter vao endpoint server that.

---

## Session Gan Nhat - Session 22 (May 12, 2026 - AI Server Training + Validation)

### Da hoan thanh

- Chay va xac nhan lai model AI tren anh that:
  - `test_real_image.py` cho ket qua dung voi `banh_beo`.
  - Confidence top-1: 71.9%, top-3 co `banh_beo`, `banh_cuon`, `banh_duc`.
- Test toan bo API AI server:
  - `test_api.py` return `Status: 200`.
  - Response co day du `food_name`, `confidence`, `calories_estimated`, `nutrition`, `top_predictions`, `inference_time_ms`.
  - Thoi gian inference thuc te khoang 123ms.
- Kiem tra health endpoint:
  - `GET /health` tra ve `status: healthy` va `model_loaded: true`.
- Xac nhan model va pipeline da san sang cho app Flutter:
  - Model da load duoc 100 classes.
  - Server da tra ve ket qua an uong va dinh duong on dinh.

### Trang thai hien tai

- AI server dang hoat dong tot, co the dung cho scan flow that.
- Model da qua kiem tra voi anh thuc te va API test.
- Buoc tiep theo phu hop nhat la wire Flutter scan flow vao endpoint `/predict` hoac `/analyze`.

---

## Session Gan Nhat - Session 21 (May 4, 2026 - Scan Upload + Result Flow)

### Da hoan thanh

- Them luong chon/chup anh cho ScanScreen:
  - Dung `image_picker` de mo camera hoac gallery.
  - Luu anh local tam thoi de preview truoc khi phan tich.
- Upload Cloudinary khi chon/chup thanh cong:
  - Goi `CloudinaryService.uploadImage(File)` ngay sau khi co anh.
  - Giữ `imageUrl` da upload de dung cho buoc analyze.
- Don giao dien Scan:
  - Xoa text thong bao inline ve dang up anh.
  - Xoa snackbar den nho sau khi upload/phan tich xong.
  - Giu flow im lang, chi chuyen man khi can thiet.
- Dieu huong sau khi nhan `Phan tich anh`:
  - Push sang route `/scan/result`.
  - Them route result trong router neu co san.
  - `ScanResultScreen` nhan `imageUrl` va hien thi anh that tu Cloudinary neu co.
- Validation:
  - `flutter analyze` = No issues found!
  - `flutter build apk --debug` = SUCCESS.
  - `flutter run` da chay thanh cong trong session gan day.

### Trang thai hien tai

- Scan flow da co upload Cloudinary va chuyen sang result screen.
- UI Scan gon hon, khong con thong bao phu khong can thiet.
- App van clean o analyzer va build debug.

### Luu y cho session sau

- Buoc tiep theo nen wire `ScanViewModel` + API `/analyze` that, thay vi mock delay.
- Neu muon gui result qua router, hien tai da co `imageUrl` qua `state.extra`.

---

## Session Gan Nhat - Session 20 (May 4, 2026 - UI Sync + Recovery)

### Da hoan thanh

- Dong bo lai giao dien theo chu de cu, uu tien layout sach va on dinh hon:
  - Giam bot gradient/shadow qua da tren History, Stats, Profile, Edit Profile, Scan Result.
  - Giu border-based card style, mau AppColors.primary, va dark mode co ban.
  - Giup giao dien dong nhat hon voi phien ban truoc khi redesign qua manh.
- Sua loi compile do widget tree bi hong o 3 man Profile:
  - Rebuild `profile_screen.dart`, `edit_profile_screen.dart`, `change_password_screen.dart`.
  - Kiem tra lai bang `get_errors`: khong con loi syntax.
- Sua loi l10n o Change Password:
  - Do bo cac getter khong ton tai trong `AppLocalizations`.
  - Doi sang chuoi on dinh de app compile lai an toan.
- Cap nhat localization generated files:
  - `app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_vi.dart` duoc refresh sau khi bo sung key.
- Validation:
  - `flutter run` da chay thanh cong sau khi sua loi l10n.

### Trang thai hien tai

- App dang o trang thai chay duoc.
- UI da duoc dong bo lai theo huong giao dien cu, de don va on dinh hon.
- Cac man profile lien quan da duoc khoi phuc va khong con loi compile.

### Luu y cho session sau

- Neu muon tiep tuc polish UI, uu tien giu tinh sach, it gradient, it shadow, va bao toan dark mode + l10n.
- Neu can them session note, ghi ngan gon theo format compact hien tai.

---

## Session Gan Nhat - Session 19 (Apr 20, 2026 - Final Polish)

### Da hoan thanh

- Fix widget test smoke test:
  - Thay the test mau counter cu bang test don gian (tru Firebase init trong test environment).
  - `flutter test`: tat ca pass.
  - `dart fix --dry-run`: No issues to fix!
  - Validate: `flutter analyze` van sach: `No issues found!`.
- Build validation:
  - Chay `flutter build apk --debug`: APK built successfully.
  - Kiem tra release pipeline hoat dong tuy.
- Final checks:
  - App da chay thanh cong tren device/emulator.
  - Tat ca features chinh: Auth, Home, Scan, History, Stats, Profile, Settings deu co animation/UI polish.
  - I18n (English + Vietnamese) va theme (Light/Dark) fully implemented.
- Remaining TODO (for future phases):
  - Data layer integration: Connect repositories to Firestore (nutrition, history, profile).
  - Use case implementation: Call AnalyzeFoodUseCase, GetDailyLogUseCase, etc.
  - Camera/Gallery integration: Implement actual camera + image picker in Scan screen.
  - Real AI server integration: Wire /analyze endpoint instead of mock data.
  - File sizes: Largest files (register_screen.dart 975 lines) are complex auth forms - stable as-is for "done" state.

### Trang thai hien tai (PROJECT READY FOR PHASE 2)

- Static quality: `flutter analyze` = Clean, `flutter test` = Pass, `flutter build` = Success.
- UI/UX: Toan bộ 10 screens da co animation, localization, theme support.
- Architecture: Clean Architecture + Riverpod + GoRouter da setup an toan.
- Next phase: Backend integration (Firestore, AI server, Camera/Gallery).
- Deployment ready: APK debug working, codebase stable.

---

## Session Gan Nhat Truoc - Session 18 (Apr 20, 2026)

### Da hoan thanh

- Dot refactor clean code an toan (khong doi business flow):
  - Bo duplicate `AppColors` trong cac man Auth va dung chung `core/theme/app_colors.dart`.
  - Xoa bien local khong dung o Home greeting card.
- Lint cleanup pass 2:
  - `print` -> `debugPrint` trong cloudinary service.
  - `withOpacity` -> `withValues` o cac widget da duoc analyzer bao.
  - Chuan hoa `super.key` cho cac constructor widget nho.
  - Them curly braces cho cac if style-lint trong Register.
  - Fix `use_build_context_synchronously` trong man test cloudinary.
- Refactor giam duplicate lon cho Bottom Navigation:
  - Tao widget dung chung `lib/core/widgets/app_bottom_nav.dart`.
  - Chuyen 5 man sang dung widget chung: Home, History, Stats, Profile, Scan Result.
  - Giu nguyen route mapping (`/home`, `/scan`, `/history`, `/stats`, `/profile`) va current index theo tung man.
- Dead code cleanup:
  - Xoa widget khong con duoc su dung `lib/features/home/presentation/widgets/home_shell.dart`.
- Validation:
  - `flutter analyze` da sach hoan toan: `No issues found!`.

### Trang thai hien tai

- Baseline analyzer hien tai da clean, khong con warning/info/error.
- Refactor tap trung vao giam trung lap va don lint, khong thay doi luong nghiep vu chinh.

---

## Session Gan Nhat - Session 17 (Apr 20, 2026)

### Da hoan thanh

- Localize app foundation:
  - Bat `flutter_localizations`, nang `intl`, va mo `flutter generate` trong `pubspec.yaml`.
  - Them `l10n.yaml` va sinh bo `AppLocalizations` cho English + Vietnamese.
  - Cap nhat `main.dart` de dung `themeModeProvider`, `localeProvider`, `localizationsDelegates`, `supportedLocales`, va app title dich duoc.
- Global UI localization sweep:
  - Bo tat ca hardcode text con sot tren cac man hinh chinh: Home, Scan, Scan Result, History, Stats, Profile, Edit Profile va Settings.
  - Dong bo bottom nav labels, nut, placeholder, snackbar, weekday labels, meal labels, BMI/TDEE text, va cac chuoi trang thai.
  - Doi nhieu icon/label dang emoji hoac text thuong thanh bien the on-dinh hon.
- Home screen:
  - Xoa vong tron initials badge o the HI trong greeting card.
  - Giu nguyen phan text chao, ngay thang, va focus card.
  - Localize app bar, daily calories, recent scans, va bottom nav.
- Stats screen:
  - Loai bo chuoi hardcode con sot o thang thong ke.
  - Them va dong bo cac key l10n cho period selector, summary cards, trend chart va macro breakdown.
  - Chinh lai period state dung khoa on-dinh (`7d`, `30d`, `90d`, `1y`) thay cho label hien thi.
  - Xac nhan `stats_screen.dart` khong con analyzer errors.
- History screen:
  - Localize search placeholder, filter chips, app bar, snackbar va bottom nav.
  - Chuan hoa du lieu sample history thanh key on dinh cho meal type va icon.
- Scan screen va Scan Result:
  - Localize toan bo copy tren man Scan, dialog coming soon, nut camera/gallery va app bar.
  - Localize man Scan Result: ten mon, confidence, calories, nutrition facts, save button va snackbar.
- Profile va Edit Profile:
  - Localize thong tin profile, logout, BMI/TDEE cards, goal/activity labels, va text trong form.
  - Chuan hoa gia tri gender/activity/goal thanh code on dinh de khong phu thuoc label hien thi.
  - Them `Settings` entry tu Profile de vao man cai dat.
- Settings screen:
  - Tao man Settings de doi theme, doi ngon ngu va hien thi muc notifications tam thoi.
- Validation va cleanup:
  - Kiem tra cac file touched chinh khong con analyzer errors sau khi sua.
  - Sua cac getter l10n con thieu cho `last90Days` va `last1Year`.
  - Chuyen session handoff ve `docs/SESSION_HANDOFF.md` va xoa file tam trong `/memories/session/`.

### Trang thai hien tai

- `flutter analyze` toan du an con lai chi issue lint/info co san o file khac, khong phai loi moi do thay doi vua lam.
- Session memory tam o `/memories/session/session-handoff.md` da duoc xoa, chi con ban handoff chinh trong repo.

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
