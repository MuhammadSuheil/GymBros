
import 'package:flutter/material.dart';

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Streak'),
      ),
      body: const Center(
        child: Text(
          'Streak Coming soon!',
           style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}