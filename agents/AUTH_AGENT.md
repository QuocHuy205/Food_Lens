# 🔐 AUTH AGENT — Firebase Authentication

---

## Flow xác thực

```
App Start
  └── StreamBuilder(FirebaseAuth.authStateChanges)
        ├── null (chưa login) → LoginScreen
        └── User (đã login) → HomeScreen
```

---

## Firestore User Structure

Sau khi đăng ký thành công, tạo doc trong Firestore:

```dart
// Trong register usecase
await FirebaseFirestore.instance.doc('users/${user.uid}').set({
  'uid': user.uid,
  'fullName': fullName,
  'email': email,
  'avatarUrl': null,
  'createdAt': FieldValue.serverTimestamp(),
  // Profile fields — null ban đầu, user điền sau
  'weightKg': null,
  'heightCm': null,
  'age': null,
  'gender': null,
  'activityLevel': 'moderate',
  'tdeeCalories': null,
  'goal': 'maintain',
  'calorieGoal': 2000,
});
```

---

## Auth Repository

```dart
// features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(String fullName, String email, String password);
  Future<Either<Failure, void>> logout();
  Stream<UserEntity?> get authStateChanges;
}
```

```dart
// features/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc = await _db.doc('users/${credential.user!.uid}').get();
      return Right(UserModel.fromFirestore(doc).toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code)));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
    String fullName, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Tạo profile trong Firestore
      await _db.doc('users/${credential.user!.uid}').set({
        'uid': credential.user!.uid,
        'fullName': fullName,
        'email': email,
        'avatarUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'weightKg': null, 'heightCm': null, 'age': null,
        'gender': null, 'activityLevel': 'moderate',
        'tdeeCalories': null, 'goal': 'maintain', 'calorieGoal': 2000,
      });
      final doc = await _db.doc('users/${credential.user!.uid}').get();
      return Right(UserModel.fromFirestore(doc).toEntity());
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code)));
    }
  }

  String _mapFirebaseError(String code) => switch (code) {
    'user-not-found' => 'Email không tồn tại',
    'wrong-password' => 'Mật khẩu không đúng',
    'email-already-in-use' => 'Email đã được sử dụng',
    'weak-password' => 'Mật khẩu phải có ít nhất 6 ký tự',
    'invalid-email' => 'Email không hợp lệ',
    _ => 'Lỗi xác thực: $code',
  };
}
```

---

## Validation Rules

```dart
// core/utils/validators.dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập email';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Email không hợp lệ';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu ít nhất 6 ký tự';
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập họ tên';
    if (value.trim().length < 2) return 'Họ tên quá ngắn';
    return null;
  }
}
```

---

## Auth State Provider

```dart
// features/auth/presentation/providers/auth_provider.dart
@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  LoginState build() => const LoginState.initial();

  Future<void> login(String email, String password) async {
    state = const LoginState.loading();
    final result = await ref.read(authRepositoryProvider).login(email, password);
    result.fold(
      (failure) => state = LoginState.error(failure.message),
      (user) => state = LoginState.success(user),
    );
  }
}
```

---

## Login Screen

```dart
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginViewModelProvider);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Listen for success → navigate
    ref.listen(loginViewModelProvider, (_, next) {
      if (next is LoginSuccess) context.go('/home');
      if (next is LoginError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant, size: 80, color: AppColors.primary),
                const SizedBox(height: 8),
                Text('Food AI', style: AppTextStyles.headline1),
                const SizedBox(height: 40),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Mật khẩu', prefixIcon: Icon(Icons.lock)),
                  validator: Validators.validatePassword,
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is LoginLoading ? null : () {
                      if (formKey.currentState!.validate()) {
                        ref.read(loginViewModelProvider.notifier)
                            .login(emailController.text, passwordController.text);
                      }
                    },
                    child: state is LoginLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Đăng nhập'),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text('Chưa có tài khoản? Đăng ký'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```
