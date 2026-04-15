import 'package:flutter/material.dart';

class CalorieProgressBar extends StatelessWidget {
  final double consumed;
  final double target;
  final String? label;

  const CalorieProgressBar({
    required this.consumed,
    required this.target,
    this.label,
    Key? key,
  }) : super(key: key);

  Color get _color {
    final percentage = consumed / target;
    if (percentage < 0.8) return Colors.blue;
    if (percentage <= 1.1) return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (consumed / target).clamp(0.0, 1.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage > 1.0 ? 1.0 : percentage,
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${consumed.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} kcal',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
