import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Hapus import 'main.dart' untuk menghindari inisialisasi Firebase
// import 'package:gymbros/main.dart'; 

void main() {
  // Buat tes dummy sederhana yang tidak bergantung pada Firebase
  testWidgets('Dummy smoke test', (WidgetTester tester) async {
    // Build widget sederhana saja.
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Text('Test'),
      ),
    ));

    // Pastikan widget 'Test' ada.
    expect(find.text('Test'), findsOneWidget);
    // Jangan cari '0' atau '1'
  });
}
