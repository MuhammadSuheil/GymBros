// lib/features/streak/view/streak_screen.dart
import 'package:flutter/material.dart';

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak Latihan'),
      ),
      body: const Center(
        child: Text(
          'Fitur streak akan segera hadir!',
           style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
       // TODO: Implementasi logika & UI streak
    );
  }
}