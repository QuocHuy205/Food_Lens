import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('📱 HomeScreen initialized');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 HomeScreen building');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Lens AI'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Intake',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: const [
                          Text(
                            '1500 / 2500',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text('kcal'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(value: 0.6),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Scans',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            // TODO: Add recent scans list
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to scan
              },
              child: const SizedBox(
                width: double.infinity,
                child: Text('Scan Food', textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(height: 16),
            // Test button - testing Cloudinary upload
            OutlinedButton.icon(
              onPressed: () {
                debugPrint('🧪 Navigating to Cloudinary Test Screen');
                context.go('/cloudinary-test');
              },
              icon: const Icon(Icons.cloud_upload),
              label: const Text('📸 Test Upload (Cloudinary)'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use this to test image upload & Cloudinary integration',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
