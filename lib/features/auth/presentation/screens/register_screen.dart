// ============================================================
// SCREEN 03 - RegisterScreen
// File: lib/screens/register_screen.dart
// Route: /register
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  // Form
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _termsAccepted = false;
  bool _isLoading = false;
  int _passwordStrength = 0; // 0-4

  // Animation Controllers
  late AnimationController _pageEnterController;
  late AnimationController _buttonController;
  late AnimationController _strengthController;
  late AnimationController _checkboxController;
  late AnimationController _nameFocusController;
  late AnimationController _emailFocusController;
  late AnimationController _passwordFocusController;
  late AnimationController _confirmFocusController;

  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonScale;
  late Animation<double> _checkboxScale;
  late Animation<Color?> _nameBorderColor;
  late Animation<Color?> _emailBorderColor;
  late Animation<Color?> _passwordBorderColor;
  late Animation<Color?> _confirmBorderColor;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupFocusListeners();
    _passwordController.addListener(_onPasswordChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageEnterController.forward();
    });
  }

  void _setupAnimations() {
    // Page enter: 200ms slide + fade
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

    // Button press: scale 0.98
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    // Password strength bar: 800ms ease-out
    _strengthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Checkbox animation: scale pop
    _checkboxController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _checkboxScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _checkboxController, curve: Curves.easeInOut),
    );

    // Focus border animations
    _nameFocusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _nameBorderColor = ColorTween(
      begin: AppColors.border,
      end: AppColors.primary,
    ).animate(CurvedAnimation(
      parent: _nameFocusController,
      curve: Curves.easeOut,
    ));

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

    _confirmFocusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _confirmBorderColor = ColorTween(
      begin: AppColors.border,
      end: AppColors.primary,
    ).animate(CurvedAnimation(
      parent: _confirmFocusController,
      curve: Curves.easeOut,
    ));
  }

  void _setupFocusListeners() {
    _nameFocus.addListener(() {
      _nameFocus.hasFocus
          ? _nameFocusController.forward()
          : _nameFocusController.reverse();
    });
    _emailFocus.addListener(() {
      _emailFocus.hasFocus
          ? _emailFocusController.forward()
          : _emailFocusController.reverse();
    });
    _passwordFocus.addListener(() {
      _passwordFocus.hasFocus
          ? _passwordFocusController.forward()
          : _passwordFocusController.reverse();
    });
    _confirmFocus.addListener(() {
      _confirmFocus.hasFocus
          ? _confirmFocusController.forward()
          : _confirmFocusController.reverse();
    });
  }

  void _onPasswordChanged() {
    final password = _passwordController.text;
    int strength = 0;
    if (password.length >= 6) {
      strength++;
    }
    if (password.length >= 10) {
      strength++;
    }
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password)) {
      strength++;
    }
    if (RegExp(r'[!@#\$%^&*]').hasMatch(password)) {
      strength++;
    }

    if (strength != _passwordStrength) {
      setState(() => _passwordStrength = strength);
      _strengthController.animateTo(
        strength / 4.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      _showSnackBar('Bạn phải đồng ý điều khoản sử dụng', isError: true);
      return;
    }

    await _buttonController.forward();
    await _buttonController.reverse();

    setState(() {
      _isLoading = true;
    });

    // Get AuthViewModel from provider
    final authViewModel = ref.read(authViewModelProvider.notifier);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    // Call register
    await authViewModel.register(email, password, name);

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
      _showSnackBar(authState.errorMessage!, isError: true);
    } else if (authState.user.value != null) {
      // Show loading first, then success, then auto navigate to login
      _showLoadingAndSuccess();
    } else {
      // If no error and no user, still loading - wait more
      _showSnackBar('Vui lòng chờ...', isError: false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    final authViewModel = ref.read(authViewModelProvider.notifier);
    await authViewModel.signInWithGoogle();

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final authState = ref.read(authViewModelProvider);
    setState(() => _isLoading = false);

    if (authState.errorMessage != null) {
      _showSnackBar(authState.errorMessage!, isError: true);
      return;
    }

    if (authState.user.value != null) {
      _showSnackBar('Đăng nhập Google thành công', isError: false);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          context.go('/home');
        }
      });
    }
  }

  void _showLoadingAndSuccess() {
    // Show success snackbar first
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Đăng ký thành công!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1000),
      ),
    );

    // Auto navigate to login after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(milliseconds: 3000),
      ),
    );
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
      case 0:
        return AppColors.error;
      case 1:
        return AppColors.warning;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.primary;
      case 4:
        return AppColors.success;
      default:
        return AppColors.border;
    }
  }

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 0:
        return '';
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _pageEnterController.dispose();
    _buttonController.dispose();
    _strengthController.dispose();
    _checkboxController.dispose();
    _nameFocusController.dispose();
    _emailFocusController.dispose();
    _passwordFocusController.dispose();
    _confirmFocusController.dispose();
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
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(),
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'FULL NAME',
                      hint: 'John Doe',
                      controller: _nameController,
                      focusNode: _nameFocus,
                      borderColor: _nameBorderColor,
                      focusController: _nameFocusController,
                      prefixIcon: Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Nhập họ tên';
                        }
                        if (v.length < 3) {
                          return 'Ít nhất 3 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'EMAIL ADDRESS',
                      hint: 'john@example.com',
                      controller: _emailController,
                      focusNode: _emailFocus,
                      borderColor: _emailBorderColor,
                      focusController: _emailFocusController,
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Nhập email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(v)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildPasswordFieldWithStrength(),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'CONFIRM PASSWORD',
                      hint: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                      controller: _confirmPasswordController,
                      focusNode: _confirmFocus,
                      borderColor: _confirmBorderColor,
                      focusController: _confirmFocusController,
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureConfirm,
                      hintFontSize: 18,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minHeight: 24,
                            minWidth: 24,
                          ),
                          splashRadius: 18,
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Xác nhận mật khẩu';
                        }
                        if (v != _passwordController.text) {
                          return 'Mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildTermsCheckbox(),
                    const SizedBox(height: 16),
                    _buildRegisterButton(),
                    const SizedBox(height: 12),
                    _buildDivider(),
                    const SizedBox(height: 12),
                    _buildGoogleButton(),
                    const SizedBox(height: 12),
                    _buildLoginLink(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // App Bar

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Register',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      automaticallyImplyLeading: false,
    );
  }

  // Header

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AppLogo(
          size: 72,
          iconSize: 36,
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        const SizedBox(height: 20),
        const Text(
          'Start your journey',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Join Food Lens to unlock personalized nutrition.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // Generic Text Field

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Animation<Color?> borderColor,
    required AnimationController focusController,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    double hintFontSize = 14,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: focusController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor.value ?? AppColors.border,
                  width: focusNode.hasFocus ? 2 : 1,
                ),
              ),
              child: child,
            );
          },
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: hintFontSize,
                letterSpacing: hintFontSize > 14 ? 2 : 0,
              ),
              prefixIcon:
                  Icon(prefixIcon, color: AppColors.textSecondary, size: 20),
              suffixIcon: suffixIcon,
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
            validator: validator,
          ),
        ),
      ],
    );
  }

  // Password Field with Strength Indicator

  Widget _buildPasswordFieldWithStrength() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PASSWORD',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
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
                  color: _passwordBorderColor.value ?? AppColors.border,
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
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 18,
                letterSpacing: 2,
              ),
              prefixIcon: const Icon(Icons.lock_outline,
                  color: AppColors.textSecondary, size: 20),
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
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Nhập mật khẩu';
              }
              if (v.length < 6) {
                return 'Ít nhất 6 ký tự';
              }
              return null;
            },
          ),
        ),

        // Password Strength Bar
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildStrengthIndicator(),
        ],
      ],
    );
  }

  Widget _buildStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              // Background
              Container(
                height: 4,
                width: double.infinity,
                color: AppColors.border,
              ),
              // Filled
              AnimatedBuilder(
                animation: _strengthController,
                builder: (context, _) {
                  return FractionallySizedBox(
                    widthFactor: _strengthController.value,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: _strengthColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Label
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _passwordStrength > 0
              ? Text(
                  _strengthLabel,
                  key: ValueKey(_strengthLabel),
                  style: TextStyle(
                    color: _strengthColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // Terms Checkbox

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () async {
        await _checkboxController.forward();
        await _checkboxController.reverse();
        setState(() => _termsAccepted = !_termsAccepted);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _checkboxController,
            builder: (context, child) {
              return Transform.scale(
                scale: _checkboxScale.value,
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _termsAccepted ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _termsAccepted ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: _termsAccepted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: 'I agree to the ',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Register Button

  Widget _buildRegisterButton() {
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
          _handleRegister();
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
                color: AppColors.primary.withValues(alpha: 0.35),
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
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
          ),
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
                    child: const Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFF4285F4),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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

  // Login Link

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: const Text(
            'Sign In',
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
