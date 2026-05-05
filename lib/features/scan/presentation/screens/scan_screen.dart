import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:food_lens/l10n/app_localizations.dart';
import 'package:food_lens/core/theme/app_colors.dart';
import 'package:food_lens/core/services/cloudinary_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  late AnimationController _pageEnterController;
  late AnimationController _iconController;
  late AnimationController _scanLineController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _iconScale;
  late Animation<double> _scanLinePosition;

  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageEnterController.forward();
    });
  }

  void _setupAnimations() {
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

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _iconController.forward();
      }
    });

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat(reverse: true);

    _scanLinePosition = Tween<double>(begin: -0.86, end: 0.86).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageEnterController.dispose();
    _iconController.dispose();
    _scanLineController.dispose();
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
          appBar: _buildAppBar(),
          body: SafeArea(
            child: _selectedImage != null
                ? _buildImagePreviewScreen()
                : _buildCameraPickerScreen(),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        l10n.scanTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        onPressed: _handleBack,
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildCameraPickerScreen() {
    final l10n = AppLocalizations.of(context)!;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final mutedText = onSurface.withValues(alpha: 0.72);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 20),
          Column(
            children: [
              ScaleTransition(
                scale: _iconScale,
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.30),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.center_focus_strong,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.scanYourFood,
                style: TextStyle(
                  color: onSurface,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.scanSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mutedText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              _buildScannerHero(),
            ],
          ),
          Column(
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              _buildActionButton(
                icon: Icons.camera_alt,
                label: l10n.takePhoto,
                onPressed: _pickImageFromCamera,
                isPrimary: true,
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                icon: Icons.image,
                label: l10n.chooseFromGallery,
                onPressed: _pickImageFromGallery,
                isPrimary: false,
              ),
              const SizedBox(height: 26),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreviewScreen() {
    final l10n = AppLocalizations.of(context)!;
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.16);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Image Preview
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      height: 320,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.imageSelected,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nhấn "Phân tích" để bắt đầu nhận diện',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Action Buttons
          Column(
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style:
                              TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              // Analyze Button
              _buildActionButton(
                icon: _isLoading ? Icons.hourglass_bottom : Icons.check_circle,
                label: _isLoading ? 'Đang phân tích...' : 'Phân tích ảnh',
                onPressed: (_isLoading || _isUploading) ? () {} : _analyzeImage,
                isPrimary: true,
              ),
              const SizedBox(height: 16),
              // Reset Button
              _buildActionButton(
                icon: Icons.refresh,
                label: 'Chọn ảnh khác',
                onPressed: (_isLoading || _isUploading) ? () {} : _resetImage,
                isPrimary: false,
              ),
              const SizedBox(height: 26),
            ],
          ),
        ],
      ),
    );
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }

    context.go('/home');
  }

  Future<void> _pickImageFromCamera() async {
    try {
      setState(() => _errorMessage = null);

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _handleSelectedImage(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Không thể truy cập camera: $e');
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      setState(() => _errorMessage = null);

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _handleSelectedImage(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Không thể truy cập thư viện: $e');
      }
    }
  }

  Future<void> _handleSelectedImage(File imageFile) async {
    setState(() {
      _selectedImage = imageFile;
      _uploadedImageUrl = null;
      _isUploading = true;
      _errorMessage = null;
    });

    final uploadedUrl = await CloudinaryService.uploadImage(imageFile);

    if (!mounted) return;

    setState(() {
      _isUploading = false;
      _uploadedImageUrl = uploadedUrl;
      if (uploadedUrl == null) {
        _errorMessage = 'Không thể tải ảnh lên Cloudinary. Vui lòng thử lại.';
      }
    });
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      if (_uploadedImageUrl == null) {
        final uploadedUrl =
            await CloudinaryService.uploadImage(_selectedImage!);
        if (uploadedUrl == null) {
          throw Exception('Upload Cloudinary thất bại');
        }
        _uploadedImageUrl = uploadedUrl;
      }

      // TODO: Wire với ScanViewModel để gọi API analyze thật bằng _uploadedImageUrl
      await Future.delayed(const Duration(milliseconds: 700));

      if (mounted) {
        context.push('/scan/result', extra: _uploadedImageUrl);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Lỗi phân tích: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetImage() {
    setState(() {
      _selectedImage = null;
      _uploadedImageUrl = null;
      _errorMessage = null;
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.16);

    return _PressableActionButton(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1B5E20),
                    Color(0xFF2E7D32),
                    Color(0xFF43A047),
                  ],
                )
              : null,
          color: isPrimary ? null : surface,
          borderRadius: BorderRadius.circular(16),
          border:
              !isPrimary ? Border.all(color: borderColor, width: 1.2) : null,
          boxShadow: [
            if (isPrimary)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.34),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerHero() {
    final borderColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.16);

    return Container(
      width: double.infinity,
      height: 252,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.primary.withValues(alpha: 0.03),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor, width: 1.1),
            color:
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.62),
          ),
          child: Stack(
            children: [
              _buildScannerCorners(),
              AnimatedBuilder(
                animation: _scanLineController,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment(0, _scanLinePosition.value),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.0),
                            AppColors.primary.withValues(alpha: 0.92),
                            AppColors.primary.withValues(alpha: 0.0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.38),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Center(
                child: Icon(
                  Icons.restaurant_menu,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerCorners() {
    Widget corner(Alignment alignment) {
      return Align(
        alignment: alignment,
        child: Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.primary,
                width: alignment.y < 0 ? 3 : 0,
              ),
              bottom: BorderSide(
                color: AppColors.primary,
                width: alignment.y > 0 ? 3 : 0,
              ),
              left: BorderSide(
                color: AppColors.primary,
                width: alignment.x < 0 ? 3 : 0,
              ),
              right: BorderSide(
                color: AppColors.primary,
                width: alignment.x > 0 ? 3 : 0,
              ),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }

    return Stack(
      children: [
        corner(Alignment.topLeft),
        corner(Alignment.topRight),
        corner(Alignment.bottomLeft),
        corner(Alignment.bottomRight),
      ],
    );
  }
}

class _PressableActionButton extends StatefulWidget {
  const _PressableActionButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressableActionButton> createState() => _PressableActionButtonState();
}

class _PressableActionButtonState extends State<_PressableActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
