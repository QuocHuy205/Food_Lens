import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ .env file loaded successfully');
    debugPrint(
        '   - CLOUDINARY_CLOUD_NAME: ${dotenv.env['CLOUDINARY_CLOUD_NAME']?.isNotEmpty == true ? '✓ Set' : '✗ Missing'}');
    debugPrint(
        '   - CLOUDINARY_UPLOAD_PRESET: ${dotenv.env['CLOUDINARY_UPLOAD_PRESET']?.isNotEmpty == true ? '✓ Set' : '✗ Missing'}');
  } catch (e) {
    debugPrint('⚠️ Failed to load .env: $e');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization error: $e');
    debugPrint('   This is OK for testing if Firebase is not yet configured');
  }

  debugPrint('🚀 App started - Router will handle navigation');
  debugPrint('📍 Initial route: /');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Food Lens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: goRouter,
      // Đảm bảo màu nền nhất quán
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            final currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: Container(
            color: const Color(0xFFF5F5F5),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
