import 'package:flutter/material.dart';
import 'package:food_lens/l10n/app_localizations.dart';

class RecentScansList extends StatelessWidget {
  final List<Map<String, String>> scans;

  const RecentScansList({
    required this.scans,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recentScans,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: scans.length,
          itemBuilder: (context, index) {
            final scan = scans[index];
            return ListTile(
              leading: const Icon(Icons.restaurant),
              title: Text(scan['name'] ?? l10n.unknown),
              subtitle: Text(scan['calories'] ?? '0 ${l10n.kcal}'),
              trailing: Text(scan['time'] ?? ''),
            );
          },
        ),
      ],
    );
  }
}
