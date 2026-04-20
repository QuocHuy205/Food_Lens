import 'package:flutter/material.dart';
import 'package:food_lens/l10n/app_localizations.dart';
import 'package:food_lens/core/theme/app_colors.dart';
import 'package:food_lens/core/widgets/animated_widgets.dart';
import 'package:food_lens/core/widgets/app_bottom_nav.dart';

// HISTORY SCREEN - With animations
// Refactored: Page enter + staggered list + animated filter chips

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pageEnterController;
  late AnimationController _listItemController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // State
  String selectedFilter = 'today';
  final searchController = TextEditingController();
  final List<Map<String, dynamic>> _historyItems = [
    {
      'icon': Icons.ramen_dining,
      'name': 'Fresh Tuna Poke Bowl',
      'time': '12:30 PM',
      'calories': 340,
      'type': 'lunch'
    },
    {
      'icon': Icons.eco,
      'name': 'Avocado Salad',
      'time': '7:15 PM',
      'calories': 280,
      'type': 'dinner'
    },
    {
      'icon': Icons.egg_alt,
      'name': 'Scrambled Eggs',
      'time': '8:00 AM',
      'calories': 180,
      'type': 'breakfast'
    },
    {
      'icon': Icons.apple,
      'name': 'Apple & Almonds',
      'time': '3:30 PM',
      'calories': 120,
      'type': 'snack'
    },
    {
      'icon': Icons.lunch_dining,
      'name': 'Turkey Sandwich',
      'time': '12:00 PM',
      'calories': 320,
      'type': 'lunch'
    },
    {
      'icon': Icons.local_drink,
      'name': 'Banana Smoothie',
      'time': '7:30 AM',
      'calories': 200,
      'type': 'breakfast'
    },
    {
      'icon': Icons.outdoor_grill,
      'name': 'Grilled Chicken',
      'time': '6:45 PM',
      'calories': 250,
      'type': 'dinner'
    },
    {
      'icon': Icons.spa,
      'name': 'Carrot Sticks',
      'time': '4:00 PM',
      'calories': 35,
      'type': 'snack'
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageEnterController.forward();
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
                      decoration: InputDecoration(
                        hintText: l10n.searchHistoryPlaceholder,
                        prefixIcon: Icon(Icons.search, color: textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
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
                        {'key': 'yesterday', 'label': l10n.yesterday},
                        {'key': 'last7Days', 'label': l10n.last7Days},
                        {'key': 'last30Days', 'label': l10n.last30Days},
                      ].asMap().entries.map((entry) {
                        final filter = entry.value['key'] as String;
                        final label = entry.value['label'] as String;
                        final index = entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _AnimatedFilterChip(
                            label: label,
                            isSelected: selectedFilter == filter,
                            onTap: () =>
                                setState(() => selectedFilter = filter),
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
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _historyItems.length,
                    itemBuilder: (context, index) {
                      final item = _historyItems[index];
                      return FadeInWidget(
                        delay: Duration(milliseconds: 250 + (index * 60)),
                        child: Dismissible(
                          key: Key('scan_$index'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.scanDeleted),
                                action: SnackBarAction(
                                  label: l10n.undo,
                                  onPressed: () {},
                                ),
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
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: _HistoryListItem(
                            icon: item['icon'],
                            name: item['name'],
                            time:
                                '${_localizedMealType(context, item['type'])} • ${item['time']}',
                            calories: item['calories'],
                            type: item['type'],
                          ),
                        ),
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
    final surface = Theme.of(context).colorScheme.surface;
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.primary : surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary : borderColor,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected ? Colors.white : onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// History list item with consistent styling
class _HistoryListItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final String time;
  final int calories;
  final String type;

  const _HistoryListItem({
    required this.icon,
    required this.name,
    required this.time,
    required this.calories,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final textSecondary = onSurface.withValues(alpha: 0.72);
    final borderColor = onSurface.withValues(alpha: 0.16);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Emoji icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Center(child: Icon(icon, size: 30, color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Calories
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$calories kcal',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getTypeColor(type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: _getTypeColor(type),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'breakfast':
        return const Color(0xFFFF9800);
      case 'lunch':
        return const Color(0xFF2196F3);
      case 'dinner':
        return const Color(0xFF9C27B0);
      case 'snack':
        return const Color(0xFF4CAF50);
      default:
        return AppColors.textSecondary;
    }
  }
}

String _localizedMealType(BuildContext context, String type) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case 'breakfast':
      return l10n.breakfast;
    case 'lunch':
      return l10n.lunch;
    case 'dinner':
      return l10n.dinner;
    case 'snack':
      return l10n.snack;
    default:
      return type;
  }
}
