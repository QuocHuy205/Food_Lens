// ============================================================
// 📱 SCREEN 01 — SplashScreen
// File: lib/screens/splash_screen.dart
// Route: /
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation Controllers ──────────────────────────────────
  late AnimationController _logoController;
  late AnimationController _taglineController;
  late AnimationController _fadeOutController;
  late AnimationController _loadingController;

  // ── Animations ─────────────────────────────────────────────
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _taglineScale;
  late Animation<double> _taglineOpacity;
  late Animation<double> _screenFadeOut;
  late Animation<double> _loadingOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // Logo: scale 0→1 + opacity 0→1 (0–300ms, decelerate)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    // Tagline: scale 0→1 + opacity 0→1 (100–300ms after logo)
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _taglineScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    // Loading indicator fade-in
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeOut),
    );

    // Screen fade-out (2800–3000ms)
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _screenFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn),
    );
  }

  Future<void> _startSequence() async {
    // Step 1: Logo fade-in (0ms)
    _logoController.forward();

    // Step 2: Tagline after 100ms
    await Future.delayed(const Duration(milliseconds: 100));
    _taglineController.forward();

    // Step 3: Loading indicator after 400ms
    await Future.delayed(const Duration(milliseconds: 300));
    _loadingController.forward();

    // Step 4: Hold for 2s, then fade out
    await Future.delayed(const Duration(milliseconds: 2000));
    _fadeOutController.forward();

    // Step 5: Navigate after fade-out
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      // TODO: Check auth state → redirect to /home or /login
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _fadeOutController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _screenFadeOut,
      builder: (context, child) {
        return Opacity(
          opacity: _screenFadeOut.value,
          child: child,
        );
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1B5E20), // Dark green top
                Color(0xFF2E7D32), // Primary green mid
                Color(0xFF43A047), // Light green bottom
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // ── Main Content ───────────────────────────
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Logo Icon ──────────────────────
                      _buildAnimatedLogo(),

                      const SizedBox(height: 24),

                      // ── App Name ───────────────────────
                      _buildAnimatedTitle(),

                      const SizedBox(height: 8),

                      // ── Tagline ────────────────────────
                      _buildAnimatedTagline(),

                      const SizedBox(height: 48),

                      // ── Loading Indicator ──────────────
                      _buildLoadingIndicator(),
                    ],
                  ),
                ),

                // ── Background Food Image (decorative) ────
                _buildBackgroundDecoration(),

                // ── "PREPARING YOUR KITCHEN" text ─────────
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: _buildPreparingText(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Opacity(
            opacity: _logoOpacity.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Notification badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6F00),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Fork & knife icon
            const Icon(
              Icons.restaurant,
              color: Colors.white,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: child,
        );
      },
      child: const Text(
        'Food Lens AI',
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAnimatedTagline() {
    return AnimatedBuilder(
      animation: _taglineController,
      builder: (context, child) {
        return Transform.scale(
          scale: _taglineScale.value,
          child: Opacity(
            opacity: _taglineOpacity.value,
            child: child,
          ),
        );
      },
      child: const Text(
        'Scan. Track. Thrive.',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return Opacity(
          opacity: _loadingOpacity.value,
          child: child,
        );
      },
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
        ),
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    // Semi-transparent food image card (as seen in design)
    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _logoController,
        builder: (context, child) {
          return Opacity(
            opacity: (_logoOpacity.value * 0.6).clamp(0.0, 1.0),
            child: child,
          );
        },
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Beautifully safe where',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Safe work',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The Living Laboratory',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreparingText() {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return Opacity(
          opacity: _loadingOpacity.value,
          child: child,
        );
      },
      child: const Text(
        'PREPARING YOUR KITCHEN',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white38,
          fontSize: 11,
          letterSpacing: 2.0,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
