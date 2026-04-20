// ============================================================
// SCREEN 02 - LoginScreen
// File: lib/screens/login_screen.dart
// Route: /login
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  // Form
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _pageEnterController;
  late AnimationController _buttonController;
  late AnimationController _errorShakeController;
  late AnimationController _emailFocusController;
  late AnimationController _passwordFocusController;

  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonScale;
  late Animation<double> _errorShake;
  late Animation<Color?> _emailBorderColor;
  late Animation<Color?> _passwordBorderColor;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupFocusListeners();

    // Trigger page enter animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageEnterController.forward();
    });
  }

  void _setupAnimations() {
    // Page enter: slide from right + fade (200ms, decelerate)
    _pageEnterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageEnterController,
      curve: Curves.easeOut,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pageEnterController, curve: Curves.easeOut),
    );

    // Button press: scale 1.0 -> 0.98 (100ms)
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    // Error shake animation
    _errorShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _errorShake = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _errorShakeController, curve: Curves.elasticOut),
    );

    // Focus animations for text fields
    _emailFocusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _emailBorderColor = ColorTween(
      begin: AppColors.border,
      end: AppColors.primary,
    ).animate(CurvedAnimation(
      parent: _emailFocusController,
      curve: Curves.easeOut,
    ));

    _passwordFocusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _passwordBorderColor = ColorTween(
      begin: AppColors.border,
      end: AppColors.primary,
    ).animate(CurvedAnimation(
      parent: _passwordFocusController,
      curve: Curves.easeOut,
    ));
  }

  void _setupFocusListeners() {
    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        _emailFocusController.forward();
      } else {
        _emailFocusController.reverse();
      }
    });
    _passwordFocus.addListener(() {
      if (_passwordFocus.hasFocus) {
        _passwordFocusController.forward();
      } else {
        _passwordFocusController.reverse();
      }
    });
  }

  Future<void> _handleLogin() async {
    // Clear previous error
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      _errorShakeController.forward(from: 0);
      return;
    }

    // Button press animation
    await _buttonController.forward();
    await _buttonController.reverse();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Get AuthViewModel from provider
    final authViewModel = ref.read(authViewModelProvider.notifier);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Call login
    await authViewModel.login(email, password);

    // Wait for state update - give more time for Firebase
    await Future.delayed(const Duration(milliseconds: 500));

    // Check result using mounted check
    if (!mounted) return;

    final authState = ref.read(authViewModelProvider);

    setState(() => _isLoading = false);

    // Debug: print state
    debugPrint(
        'AuthState: isLoading=${authState.isLoading}, error=${authState.errorMessage}, user=${authState.user}');

    if (authState.errorMessage != null) {
      setState(() {
        _errorMessage = authState.errorMessage;
      });
      _errorShakeController.forward(from: 0);
    } else if (authState.user.value != null) {
      // Navigate to home on success
      if (mounted) {
        context.go('/home');
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authViewModel = ref.read(authViewModelProvider.notifier);
    await authViewModel.signInWithGoogle();

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final authState = ref.read(authViewModelProvider);
    setState(() => _isLoading = false);

    if (authState.errorMessage != null) {
      setState(() => _errorMessage = authState.errorMessage);
      _errorShakeController.forward(from: 0);
      return;
    }

    if (authState.user.value != null) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _pageEnterController.dispose();
    _buttonController.dispose();
    _errorShakeController.dispose();
    _emailFocusController.dispose();
    _passwordFocusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),

                    // Header / Logo
                    _buildHeader(),

                    const SizedBox(height: 40),

                    // Email Field
                    _buildEmailField(),

                    const SizedBox(height: 16),

                    // Password Field
                    _buildPasswordField(),

                    // Error Message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      _buildErrorMessage(),
                    ],

                    const SizedBox(height: 8),

                    // Forgot Password
                    _buildForgotPassword(),

                    const SizedBox(height: 24),

                    // Login Button
                    _buildLoginButton(),

                    const SizedBox(height: 24),

                    // Google Sign-In Button
                    _buildGoogleButton(),

                    const SizedBox(height: 24),

                    // Divider
                    _buildDivider(),

                    const SizedBox(height: 24),

                    // Register Link
                    _buildRegisterLink(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widgets

  Widget _buildHeader() {
    return Column(
      children: [
        const AppLogo(
          size: 72,
          iconSize: 36,
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),

        const SizedBox(height: 20),

        // Title
        const Text(
          'Login',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _emailFocusController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _emailBorderColor.value ?? AppColors.border,
                  width: _emailFocus.hasFocus ? 2 : 1,
                ),
              ),
              child: child,
            );
          },
          child: TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'hello@foodlens.ai',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.mail_outline,
                color: AppColors.textSecondary,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _passwordFocusController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _errorMessage != null
                      ? AppColors.error
                      : (_passwordBorderColor.value ?? AppColors.border),
                  width: _passwordFocus.hasFocus ? 2 : 1,
                ),
              ),
              child: child,
            );
          },
          child: TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: _obscurePassword,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 18,
                letterSpacing: 2,
              ),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.textSecondary,
                size: 20,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minHeight: 24,
                    minWidth: 24,
                  ),
                  splashRadius: 18,
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                minHeight: 40,
                minWidth: 40,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              if (value.length < 6) {
                return 'Mật khẩu ít nhất 6 ký tự';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return AnimatedBuilder(
      animation: _errorShakeController,
      builder: (context, child) {
        final sineValue =
            (_errorShake.value * 2 * 3.14159).isNaN ? 0.0 : _errorShake.value;
        return Transform.translate(
          offset: Offset(
            _errorShakeController.isAnimating
                ? 8 * (sineValue - sineValue.floor())
                : 0,
            0,
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          context.go('/forgot-password');
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScale.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _buttonController.forward(),
        onTapUp: (_) {
          _buttonController.reverse();
          _handleLogin();
        },
        onTapCancel: () => _buttonController.reverse(),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // Google Sign-In Button
  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleGoogleSignIn,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google Icon
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // G icon (simplified)
                        const Text(
                          'G',
                          style: TextStyle(
                            color: Color(0xFF4285F4),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Divider
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            context.go('/register');
          },
          child: const Text(
            'Register',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
