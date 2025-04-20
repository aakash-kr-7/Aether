import 'package:flutter/material.dart';

class InsightDetailScreen extends StatelessWidget {
  final Map<String, dynamic> insight;

  InsightDetailScreen({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 4, 18, 39),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text('Insight'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            insight['text'] ?? '',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
