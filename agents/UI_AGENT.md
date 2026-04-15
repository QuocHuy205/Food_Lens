# 📱 UI AGENT — Màn hình & Navigation

---

## Danh sách màn hình

| Route | Tên màn | Mô tả |
|-------|---------|-------|
| `/` | SplashScreen | Logo + kiểm tra auth |
| `/login` | LoginScreen | Đăng nhập email/password |
| `/register` | RegisterScreen | Đăng ký tài khoản |
| `/home` | HomeScreen | Dashboard + bottom nav |
| `/scan` | ScanScreen | Chụp / chọn ảnh |
| `/scan/result` | ScanResultScreen | Kết quả nhận diện |
| `/history` | HistoryScreen | Lịch sử scan |
| `/stats` | StatsScreen | Thống kê calo theo ngày/tuần |
| `/profile` | ProfileScreen | Hồ sơ cá nhân |
| `/profile/edit` | EditProfileScreen | Chỉnh sửa BMI, mục tiêu |

---

## Navigation Flow

```
SplashScreen
    ├── (chưa đăng nhập) → LoginScreen
    │       └── RegisterScreen ↔ LoginScreen
    │
    └── (đã đăng nhập) → HomeScreen
            ├── Bottom Nav: Home | Scan | History | Stats | Profile
            │
            ├── HomeScreen
            │   └── Quick Scan button → ScanScreen
            │
            ├── ScanScreen
            │   └── Sau khi chụp/chọn ảnh → ScanResultScreen
            │           ├── Save → quay về HomeScreen (cập nhật stats)
            │           └── Retake → quay về ScanScreen
            │
            ├── HistoryScreen
            │   └── Tap 1 item → ScanResultScreen (view only)
            │
            ├── StatsScreen
            │   └── (không navigate ra ngoài)
            │
            └── ProfileScreen
                └── Edit button → EditProfileScreen
```

---

## Setup go_router

```dart
// core/router/app_router.dart
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && isAuthRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    ShellRoute(
      builder: (context, state, child) => HomeShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/scan', builder: (_, __) => const ScanScreen()),
        GoRoute(
          path: '/scan/result',
          builder: (context, state) {
            final result = state.extra as ScanResult;
            return ScanResultScreen(result: result);
          },
        ),
        GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
        GoRoute(path: '/stats', builder: (_, __) => const StatsScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),
      ],
    ),
  ],
);
```

---

## Design System

### Colors
```dart
// core/theme/app_colors.dart
class AppColors {
  // Primary — xanh lá (healthy/food vibe)
  static const primary = Color(0xFF2E7D32);
  static const primaryLight = Color(0xFF60AD5E);
  static const primaryDark = Color(0xFF005005);

  // Accent — cam
  static const accent = Color(0xFFFF6F00);

  // Neutral
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);

  // Semantic
  static const success = Color(0xFF43A047);
  static const warning = Color(0xFFFFA000);
  static const error = Color(0xFFD32F2F);

  // Meal types
  static const breakfast = Color(0xFFFFB300);
  static const lunch = Color(0xFF1976D2);
  static const dinner = Color(0xFF7B1FA2);
  static const snack = Color(0xFF00897B);
}
```

### Text Styles
```dart
// core/theme/app_text_styles.dart
class AppTextStyles {
  static const headline1 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
  static const headline2 = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const title = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const body = TextStyle(fontSize: 14);
  static const caption = TextStyle(fontSize: 12, color: AppColors.textSecondary);
  static const calorieNumber = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
}
```

### ThemeData
```dart
// core/theme/app_theme.dart
ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  fontFamily: 'Roboto',
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    ),
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
```

---

## Bottom Navigation

```dart
// features/home/presentation/home_shell.dart
class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexFromRoute(location),
        onDestinationSelected: (index) => _navigate(context, index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.camera_alt_outlined), selectedIcon: Icon(Icons.camera_alt), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Lịch sử'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Thống kê'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
```

---

## Màn hình ScanScreen (chi tiết)

```dart
// features/scan/presentation/screens/scan_screen.dart
class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nhận diện món ăn')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Preview ảnh đã chọn
            if (state.selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(state.selectedImage!, height: 250, fit: BoxFit.cover),
              )
            else
              Container(
                height: 250,
                width: double.infinity,
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
                ),
                child: const Icon(Icons.restaurant, size: 64, color: Colors.grey),
              ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Chụp ảnh'),
                  onPressed: () => ref.read(scanViewModelProvider.notifier).pickFromCamera(),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Thư viện'),
                  onPressed: () => ref.read(scanViewModelProvider.notifier).pickFromGallery(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (state.selectedImage != null)
              ElevatedButton(
                onPressed: state.isLoading ? null : () async {
                  await ref.read(scanViewModelProvider.notifier).analyzeImage();
                  if (context.mounted && ref.read(scanViewModelProvider).result != null) {
                    context.push('/scan/result', extra: ref.read(scanViewModelProvider).result);
                  }
                },
                child: state.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Nhận diện ngay'),
              ),
          ],
        ),
      ),
    );
  }
}
```
