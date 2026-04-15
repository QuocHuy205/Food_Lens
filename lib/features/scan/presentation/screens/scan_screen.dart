import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Food')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 64),
            const SizedBox(height: 16),
            const Text('Take a photo of your food'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Open camera
              },
              child: const Text('Open Camera'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Pick from gallery
              },
              child: const Text('Choose from Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}
