import 'package:flutter/material.dart';

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Food Detected',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Food Name: [Name]'),
                      const SizedBox(height: 8),
                      const Text('Calories: [Calories] kcal'),
                      const SizedBox(height: 8),
                      const Text('Confidence: [Confidence]%'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // TODO: Save to history
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
