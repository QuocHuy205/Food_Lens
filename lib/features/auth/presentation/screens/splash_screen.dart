import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Auto navigate to Home after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_navigated) {
        _navigated = true;
        debugPrint('🔄 Navigating from Splash to Home screen');
        context.go('/home');
      }
    });
  }

  void _skipSplash() {
    if (!_navigated) {
      _navigated = true;
      debugPrint('⏭️ Skip splash button pressed');
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back button on splash
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Food Lens AI',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Smart Food Recognition',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              if (!_navigated)
                const CircularProgressIndicator()
              else
                const Text('Loading...'),
              const SizedBox(height: 40),
              // Skip button for testing
              if (!_navigated)
                ElevatedButton.icon(
                  onPressed: _skipSplash,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Skip'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
