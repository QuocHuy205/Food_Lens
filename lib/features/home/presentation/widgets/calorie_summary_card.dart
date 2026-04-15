import 'package:flutter/material.dart';

class CalorieSummaryCard extends StatelessWidget {
  final double consumed;
  final double target;

  const CalorieSummaryCard({
    required this.consumed,
    required this.target,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Calories',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    '${consumed.toStringAsFixed(0)} / ${target.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text('kcal'),
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
