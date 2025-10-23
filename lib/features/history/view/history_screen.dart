// lib/features/history/view/history_screen.dart
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Latihan'),
      ),
      body: const Center(
        child: Text(
          'Riwayat latihan akan muncul di sini.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
      // TODO: Tambahkan ListView untuk menampilkan data sesi
    );
  }
}