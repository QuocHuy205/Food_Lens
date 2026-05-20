import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:food_lens/l10n/app_localizations.dart';
import 'package:food_lens/core/theme/app_colors.dart';
import 'package:food_lens/core/widgets/animated_widgets.dart';
import 'package:food_lens/core/widgets/app_bottom_nav.dart';
import '../../../scan/domain/entities/scan_history.dart';
import '../providers/history_provider.dart';
import '../widgets/history_list_item.dart';

// HISTORY SCREEN - With animations + Riverpod
// Refactored: Page enter + staggered list + animated filter chips + real Firestore data

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pageEnterController;
  late AnimationController _listItemController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // State
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageEnterController.forward();
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        ref.read(historyViewModelProvider.notifier).loadHistory(userId);
      }
    });
  }

  void _setupAnimations() {
    // Page enter: fade + slide up (300ms)
    _pageEnterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageEnterController,
      curve: Curves.easeOut,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pageEnterController, curve: Curves.easeOut),
    );

    // List items: staggered fade-in
    _listItemController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _pageEnterController.dispose();
    _listItemController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textSecondary =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72);
    final borderColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.16);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Search Bar
                FadeInWidget(
                  delay: const Duration(milliseconds: 100),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        ref
                            .read(historyViewModelProvider.notifier)
                            .searchFood(value);
                      },
                      decoration: InputDecoration(
                        hintText: l10n.searchHistoryPlaceholder,
                        prefixIcon: Icon(Icons.search, color: textSecondary),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: borderColor, width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: borderColor, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        hintStyle: TextStyle(color: textSecondary),
                      ),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                ),
                // Filter Chips
                FadeInWidget(
                  delay: const Duration(milliseconds: 150),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        {'key': 'today', 'label': l10n.today},
                        {'key': 'week', 'label': l10n.last7Days},
                        {'key': 'month', 'label': l10n.last30Days},
                      ].asMap().entries.map((entry) {
                        final filter = entry.value['key'] as String;
                        final label = entry.value['label'] as String;
                        final index = entry.key;
                        final historyState =
                            ref.watch(historyViewModelProvider);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _AnimatedFilterChip(
                            label: label,
                            isSelected: historyState.currentFilter == filter,
                            onTap: () {
                              ref
                                  .read(historyViewModelProvider.notifier)
                                  .filterByDate(filter);
                            },
                            delay: Duration(milliseconds: 200 + (index * 50)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // History List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final historyState = ref.watch(historyViewModelProvider);
                      final filteredItems = historyState.filteredItems;

                      return historyState.history.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stackTrace) => Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              _localizedMessage(
                                context,
                                vi: 'Lỗi tải lịch sử: $error',
                                en: 'Failed to load history: $error',
                              ),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                        data: (data) {
                          if (filteredItems.isEmpty) {
                            return Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 32),
                                child: Text(
                                  _localizedMessage(
                                    context,
                                    vi: 'Chưa có dữ liệu',
                                    en: 'No history yet',
                                  ),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return FadeInWidget(
                                delay:
                                    Duration(milliseconds: 250 + (index * 60)),
                                child: Dismissible(
                                  key: Key('scan_${item.id}'),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (direction) {
                                    final userId =
                                        FirebaseAuth.instance.currentUser?.uid;
                                    if (userId == null) {
                                      return;
                                    }
                                    ref
                                        .read(historyViewModelProvider.notifier)
                                        .deleteHistoryItem(userId, item.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.scanDeleted),
                                      ),
                                    );
                                  },
                                  background: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                  child: HistoryListItem(
                                    imageUrl: item.imageUrl,
                                    name: item.foodName,
                                    time:
                                        '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')} • ${(item.quantity ?? 100).toStringAsFixed(0)}g',
                                    calories: item.calories.round(),
                                    type: '',
                                    onEdit: () => _editQuantity(item),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(context),
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
        l10n.historyTitle,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return AppBottomNav(
      currentIndex: 2,
      surfaceColor: Theme.of(context).colorScheme.surface,
      borderColor:
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.16),
      unselectedItemColor:
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
    );
  }

  Future<void> _editQuantity(ScanHistory item) async {
    final newQuantity = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return _QuantityEditDialog(
          initialQuantity: (item.quantity ?? 100).round(),
        );
      },
    );

    if (newQuantity == null) {
      return;
    }

    final oldQuantity = item.quantity ?? 100;
    final ratio =
        oldQuantity > 0 ? item.calories / oldQuantity : item.calories / 100;
    final updatedCalories = (ratio * newQuantity).round().toDouble();
    final updatedItem = ScanHistory(
      id: item.id,
      userId: item.userId,
      foodName: item.foodName,
      calories: updatedCalories,
      imageUrl: item.imageUrl,
      createdAt: item.createdAt,
      quantity: newQuantity.toDouble(),
    );

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return;
    }

    await ref
        .read(historyViewModelProvider.notifier)
        .updateHistoryItem(updatedItem);

    if (!mounted) return;
    final error = ref.read(historyViewModelProvider).errorMessage;
    if (error == null) {
      final caloriesText = updatedCalories.round().toString();
      final quantityText = '${newQuantity}g';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _localizedMessage(
              context,
              vi: 'Đã cập nhật lịch sử: $quantityText • $caloriesText kcal',
              en: 'History updated: $quantityText • $caloriesText kcal',
            ),
          ),
        ),
      );
    }
  }
}

class _QuantityEditDialog extends StatefulWidget {
  final int initialQuantity;

  const _QuantityEditDialog({required this.initialQuantity});

  @override
  State<_QuantityEditDialog> createState() => _QuantityEditDialogState();
}

class _QuantityEditDialogState extends State<_QuantityEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialQuantity.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = int.tryParse(_controller.text);
    if (parsed != null && parsed > 0) {
      Navigator.of(context).pop(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.quantity),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          hintText: '100',
          suffixText: 'g',
        ),
        autofocus: true,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

String _localizedMessage(
  BuildContext context, {
  required String vi,
  required String en,
}) {
  return Localizations.localeOf(context).languageCode == 'vi' ? vi : en;
}

// Helper widgets

/// Animated filter chip with scale feedback
class _AnimatedFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration delay;

  const _AnimatedFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_AnimatedFilterChip> createState() => _AnimatedFilterChipState();
}

class _AnimatedFilterChipState extends State<_AnimatedFilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start after delay
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final borderColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.16);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary
                : onSurface.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary : borderColor,
              width: 1.2,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected ? Colors.white : onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// History list item moved to shared widget for reuse
