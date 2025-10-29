import 'package:flutter/material.dart';
import 'package:gymbros/core/constants/app_colors.dart'; 

Future<bool?> showInfoPopup(
  BuildContext context,
  String title,
  String message,
  // --- HAPUS onOkPressed DARI SINI ---
) async {
  // ---------------------------------
  return showDialog<bool>( // <-- Tambahkan <bool>
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(color: AppColors.onPrimary))),
          ],
        ),
        content: Text(message, style: const TextStyle(color: AppColors.onPrimary)),
        backgroundColor: AppColors.background, // Asumsi background gelap
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('OK', style: TextStyle(color: AppColors.onPrimary)),
            onPressed: () {
              // --- PERUBAHAN: Pop dengan nilai true ---
              Navigator.of(dialogContext).pop(true);
              // ------------------------------------
            },
          ),
        ],
      );
    },
  );
}

Future<void> showErrorPopup(BuildContext context, String title, String message) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Row(
           children: [
             const Icon(Icons.error_outline, color: AppColors.error),
             const SizedBox(width: 8),
             Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.onPrimary),),
           ],
        ),
        content: Text(message, style: TextStyle(color: AppColors.onPrimary),),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.onPrimary,        
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
            ),
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}
