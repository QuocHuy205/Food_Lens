import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan History')),
      body: ListView.builder(
        itemCount: 5, // TODO: Replace with actual data
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.restaurant),
              title: const Text('Food Name [#]'),
              subtitle: const Text('Date • Calories'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // TODO: Delete item
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
