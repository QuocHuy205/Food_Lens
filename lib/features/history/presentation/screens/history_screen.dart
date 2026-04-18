import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:food_lens/core/theme/app_colors.dart';
import 'package:food_lens/core/widgets/animated_widgets.dart';

// ═══════════════════════════════════════════════════════════
// HISTORY SCREEN — With animations
// Refactored: Page enter + staggered list + animated filter chips
// ═══════════════════════════════════════════════════════════

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  // ── Animation Controllers ──────────────────────────────────
  late AnimationController _pageEnterController;
  late AnimationController _listItemController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // ── State ──────────────────────────────────────────────────
  String selectedFilter = 'Today';
  final searchController = TextEditingController();
  final List<Map<String, dynamic>> _historyItems = [
    {
      'emoji': '🍜',
      'name': 'Fresh Tuna Poke Bowl',
      'time': 'Lunch • 12:30 PM',
      'calories': 340,
      'type': 'Lunch'
    },
    {
      'emoji': '🥗',
      'name': 'Avocado Salad',
      'time': 'Dinner • 7:15 PM',
      'calories': 280,
      'type': 'Dinner'
    },
    {
      'emoji': '🍳',
      'name': 'Scrambled Eggs',
      'time': 'Breakfast • 8:00 AM',
      'calories': 180,
      'type': 'Breakfast'
    },
    {
      'emoji': '🍎',
      'name': 'Apple & Almonds',
      'time': 'Snack • 3:30 PM',
      'calories': 120,
      'type': 'Snack'
    },
    {
      'emoji': '🥪',
      'name': 'Turkey Sandwich',
      'time': 'Lunch • 12:00 PM',
      'calories': 320,
      'type': 'Lunch'
    },
    {
      'emoji': '🍌',
      'name': 'Banana Smoothie',
      'time': 'Breakfast • 7:30 AM',
      'calories': 200,
      'type': 'Breakfast'
    },
    {
      'emoji': '🍗',
      'name': 'Grilled Chicken',
      'time': 'Dinner • 6:45 PM',
      'calories': 250,
      'type': 'Dinner'
    },
    {
      'emoji': '🥕',
      'name': 'Carrot Sticks',
      'time': 'Snack • 4:00 PM',
      'calories': 35,
      'type': 'Snack'
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
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ── Search Bar ───────────────────────────
                FadeInWidget(
                  delay: const Duration(milliseconds: 100),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search your history...',
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                    ),
                  ),
                ),
                // ── Filter Chips ─────────────────────────
                FadeInWidget(
                  delay: const Duration(milliseconds: 150),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        'Today',
                        'Yesterday',
                        'Last 7 Days',
                        'Last 30 Days'
                      ].asMap().entries.map((entry) {
                        final filter = entry.value;
                        final index = entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _AnimatedFilterChip(
                            label: filter,
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
                // ── History List ────────────────────────
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
                                content: const Text('Scan deleted'),
                                action: SnackBarAction(
                                  label: 'UNDO',
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
                            emoji: item['emoji'],
                            name: item['name'],
                            time: item['time'],
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
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: const Text(
        'History',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(color: AppColors.border.withOpacity(0.5), width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        iconSize: 24,
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/scan');
              break;
            case 2:
              context.go('/history');
              break;
            case 3:
              context.go('/stats');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// HELPER WIDGETS — Reusable animated components
// ═══════════════════════════════════════════════════════════

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
            color: widget.isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary : AppColors.border,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected ? Colors.white : AppColors.textPrimary,
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
  final String emoji;
  final String name;
  final String time;
  final int calories;
  final String type;

  const _HistoryListItem({
    required this.emoji,
    required this.name,
    required this.time,
    required this.calories,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Emoji icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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
                  color: _getTypeColor(type).withOpacity(0.1),
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
      case 'Breakfast':
        return const Color(0xFFFF9800);
      case 'Lunch':
        return const Color(0xFF2196F3);
      case 'Dinner':
        return const Color(0xFF9C27B0);
      case 'Snack':
        return const Color(0xFF4CAF50);
      default:
        return AppColors.textSecondary;
    }
  }
}
