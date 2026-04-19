import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Screen imports
import 'package:food_lens/features/auth/presentation/screens/splash_screen.dart';
import 'package:food_lens/features/auth/presentation/screens/login_screen.dart';
import 'package:food_lens/features/auth/presentation/screens/register_screen.dart';
import 'package:food_lens/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:food_lens/features/home/presentation/screens/home_screen.dart';
import 'package:food_lens/features/scan/presentation/screens/scan_screen.dart';
import 'package:food_lens/features/nutrition/presentation/screens/stats_screen.dart';
import 'package:food_lens/features/profile/presentation/screens/profile_screen.dart';
import 'package:food_lens/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:food_lens/features/history/presentation/screens/history_screen.dart';
import 'package:food_lens/test/cloudinary_test.dart';

// App routes
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String scan = '/scan';
  static const String stats = '/stats';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String history = '/history';
  static const String cloudinaryTest = '/cloudinary-test'; // For testing upload
}

class AuthRouterNotifier extends ChangeNotifier {
  User? currentUser;
  final StreamSubscription<User?> _subscription;

  AuthRouterNotifier(FirebaseAuth auth)
      : currentUser = auth.currentUser,
        _subscription = auth.authStateChanges().listen((user) {}) {
    _subscription.onData((user) {
      currentUser = user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════
// CUSTOM PAGE TRANSITION — Smooth Fade + Scale
// ═══════════════════════════════════════════════════════════
CustomTransitionPage<T> _buildSmoothPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    // Thời gian transition
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Sử dụng easeOutCubic cho animation mượt mà
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      // Wrap trong Container có màu nền để tránh đen khi transition
      return FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(curvedAnimation),
          child: Container(
            color: const Color(0xFFF5F5F5), // AppColors.background
            child: child,
          ),
        ),
      );
    },
  );
}

NoTransitionPage<T> _buildNoTransitionPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return NoTransitionPage<T>(
    key: state.pageKey,
    child: child,
  );
}

final appRouterProvider = Provider((ref) {
  final firebaseAuth = FirebaseAuth.instance;
  final authNotifier = AuthRouterNotifier(firebaseAuth);
  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    routes: [
      // ── Auth Routes ─────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _buildNoTransitionPage(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _buildNoTransitionPage(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => _buildNoTransitionPage(
          context: context,
          state: state,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) => _buildNoTransitionPage(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      // ── Main Routes ─────────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.scan,
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const ScanScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.history,
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const HistoryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.stats,
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const StatsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const EditProfileScreen(),
        ),
      ),
      // ── Test Route ──────────────────────────────────
      GoRoute(
        path: AppRoutes.cloudinaryTest,
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const CloudinaryTestScreen(),
        ),
      ),
    ],
    redirect: (context, state) {
      debugPrint('🔗 Router redirect - Current path: ${state.uri.path}');

      final isLoggedIn = authNotifier.currentUser != null;
      final currentPath = state.uri.path;

      // Splash is controlled by SplashScreen timer/navigation.
      if (currentPath == AppRoutes.splash) {
        return null;
      }

      final isAuthPage = currentPath == AppRoutes.login ||
          currentPath == AppRoutes.register ||
          currentPath == AppRoutes.forgotPassword;

      if (!isLoggedIn && !isAuthPage) {
        return AppRoutes.login;
      }

      if (isLoggedIn && (currentPath == AppRoutes.splash || isAuthPage)) {
        return AppRoutes.home;
      }

      return null;
    },
  );
});
