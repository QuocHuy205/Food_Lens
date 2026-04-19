// ============================================================
// 📱 SCREEN 01 — SplashScreen
// File: lib/screens/splash_screen.dart
// Route: /
// ============================================================

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ── Animation Controller ───────────────────────────────────
  late final AnimationController _controller;
  late final Timer _navigationTimer;

  // ── Animations ─────────────────────────────────────────────
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _taglineScale;
  late Animation<double> _taglineOpacity;
  late Animation<double> _loadingOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _controller.forward();
    _navigationTimer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      context.go(isLoggedIn ? '/home' : '/login');
    });
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    final logoCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.18, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(logoCurve);
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(logoCurve);

    final taglineCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.10, 0.26, curve: Curves.easeOut),
    );
    _taglineScale = Tween<double>(begin: 0.0, end: 1.0).animate(taglineCurve);
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(taglineCurve);

    final loadingCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 0.34, curve: Curves.easeOut),
    );
    _loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(loadingCurve);
  }

  @override
  void dispose() {
    _navigationTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Opacity(
            opacity: _logoOpacity.value,
            child: child,
          ),
        );
      },
      child: const AppLogo(
        size: 80,
        iconSize: 40,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: child,
        );
      },
      child: const Text(
        'Food Lens',
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
      animation: _controller,
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
      animation: _controller,
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
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: (_logoOpacity.value * 0.6).clamp(0.0, 1.0),
            child: child,
          );
        },
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
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
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Safe work',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The Living Laboratory',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
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
      animation: _controller,
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
