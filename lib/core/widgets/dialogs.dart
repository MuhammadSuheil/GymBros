import 'package:flutter/material.dart';
import 'package:gymbros/core/constants/app_colors.dart'; 

Future<void> showInfoPopup(BuildContext context, String title, String message, {VoidCallback? onOkPressed}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.onPrimary),),
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
