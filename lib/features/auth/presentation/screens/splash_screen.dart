// ============================================================
// 📱 SCREEN 01 — SplashScreen
// File: lib/screens/splash_screen.dart
// Route: /
// ============================================================

import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Timer _navigationTimer;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _titleSlide;
  late final Animation<double> _indicatorOpacity;
  late final Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _controller.forward();
    _navigationTimer = Timer(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      context.go(isLoggedIn ? '/home' : '/login');
    });
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.78, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.32, curve: Curves.easeOut),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.28, 0.55, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.28, 0.58, curve: Curves.easeOutCubic),
      ),
    );

    _indicatorOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.76, curve: Curves.easeOut),
      ),
    );

    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve:
            const Interval(0.5, 0.98, curve: Curves.easeInOutCubicEmphasized),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF2F8733),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                children: [
                  SizedBox(height: screenHeight * 0.12),
                  _buildLogoCluster(),
                  SizedBox(height: screenHeight * 0.05),
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -8),
                          child: _buildTitle(),
                        ),
                        SizedBox(height: screenHeight * 0.028),
                        _buildLoadingDot(),
                        const SizedBox(height: 12),
                        _buildProgressBar(),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogoCluster() {
    final pulse =
        0.88 + (math.sin(_controller.value * math.pi * 4.0).abs() * 0.12);

    return Opacity(
      opacity: _logoOpacity.value,
      child: Transform.scale(
        scale: _logoScale.value,
        child: SizedBox(
          width: 310,
          height: 310,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: pulse,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Transform.rotate(
                angle: -0.3,
                child: Container(
                  width: 230,
                  height: 215,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(96),
                  ),
                ),
              ),
              Transform.rotate(
                angle: 0.34,
                child: Container(
                  width: 225,
                  height: 210,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(90),
                  ),
                ),
              ),
              Container(
                width: 205,
                height: 205,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.28),
                      Colors.white.withValues(alpha: 0.22),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 26,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 78,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final maxWidth = MediaQuery.sizeOf(context).width - 48;

    return Opacity(
      opacity: _titleOpacity.value,
      child: Transform.translate(
        offset: Offset(0, _titleSlide.value),
        child: SizedBox(
          width: maxWidth,
          child: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Food Lens',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFF3F7F3),
                fontSize: 50,
                fontWeight: FontWeight.w700,
                height: 1,
                letterSpacing: 0.2,
                shadows: [
                  Shadow(
                    color: Color.fromARGB(45, 0, 0, 0),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDot() {
    final glow = 0.5 + (math.sin(_controller.value * math.pi * 8).abs() * 0.5);

    return Opacity(
      opacity: _indicatorOpacity.value,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.35 * glow),
              blurRadius: 24,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEFF5EF),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.75),
              width: 1,
            ),
          ),
          child: Transform.rotate(
            angle: _controller.value * math.pi * 1.4,
            child: const Icon(
              Icons.gps_fixed_rounded,
              color: Color(0xFF74A677),
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final width = (MediaQuery.sizeOf(context).width - 72).clamp(208.0, 448.0);

    return Opacity(
      opacity: _indicatorOpacity.value,
      child: SizedBox(
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 18,
            value: _progressValue.value,
            backgroundColor: Colors.white.withValues(alpha: 0.09),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE4EBE4)),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}
