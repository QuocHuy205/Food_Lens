import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Screen imports
import 'package:food_lens/features/auth/presentation/screens/splash_screen.dart';
import 'package:food_lens/features/auth/presentation/screens/login_screen.dart';
import 'package:food_lens/features/auth/presentation/screens/register_screen.dart';
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
  static const String home = '/home';
  static const String scan = '/scan';
  static const String stats = '/stats';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String history = '/history';
  static const String cloudinaryTest = '/cloudinary-test'; // For testing upload
}

final appRouterProvider = Provider((ref) {
  // TODO: Wire auth state from authViewModelProvider
  // final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: AppRoutes.home, // START: Splash screen

    routes: [
      // ── Auth Routes ─────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      // ── Main Routes ─────────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.scan,
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.stats,
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      // ── Test Route ──────────────────────────────────
      GoRoute(
        path: AppRoutes.cloudinaryTest,
        builder: (context, state) => const CloudinaryTestScreen(),
      ),
    ],
    redirect: (context, state) {
      // FOR TESTING: Log all route transitions
      debugPrint('🔗 Router redirect - Current path: ${state.uri.path}');

      // TODO: Implement auth guard
      // if (authState.isLoading) return AppRoutes.splash;
      // if (authState.user == null && state.location != AppRoutes.login && state.location != AppRoutes.register) {
      //   return AppRoutes.login;
      // }
      // if (authState.user != null && state.location == AppRoutes.login) {
      //   return AppRoutes.home;
      // }
      return null;
    },
  );
});
