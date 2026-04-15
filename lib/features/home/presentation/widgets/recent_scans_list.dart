import 'package:flutter/material.dart';

class RecentScansList extends StatelessWidget {
  final List<Map<String, String>> scans;

  const RecentScansList({
    required this.scans,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Scans',
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
              title: Text(scan['name'] ?? 'Unknown'),
              subtitle: Text(scan['calories'] ?? '0 kcal'),
              trailing: Text(scan['time'] ?? ''),
            );
          },
        ),
      ],
    );
  }
}
