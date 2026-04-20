import 'package:flutter/material.dart';
import 'package:food_lens/l10n/app_localizations.dart';

class CalorieSummaryCard extends StatelessWidget {
  final double consumed;
  final double target;

  const CalorieSummaryCard({
    required this.consumed,
    required this.target,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todayCalories,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    '${consumed.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} ${l10n.kcal}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (consumed / target).clamp(0.0, 1.0),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }
}
