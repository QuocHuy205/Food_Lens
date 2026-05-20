import 'package:flutter/material.dart';
import 'package:food_lens/core/theme/app_colors.dart';

class HistoryListItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String time;
  final int calories;
  final String type;
  final VoidCallback? onEdit;

  const HistoryListItem({
    required this.imageUrl,
    required this.name,
    required this.time,
    required this.calories,
    required this.type,
    this.onEdit,
    super.key,
  });

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

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final textSecondary = onSurface.withValues(alpha: 0.72);
    final borderColor = onSurface.withValues(alpha: 0.16);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Food image - Circular with border
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.restaurant_menu,
                          size: 28,
                          color: AppColors.primary,
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.primary.withValues(alpha: 0.5),
                              ),
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.restaurant_menu,
                        size: 28,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Info - Enhanced typography
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
              if (type.isNotEmpty && type != 'meal')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
              if (onEdit != null) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
