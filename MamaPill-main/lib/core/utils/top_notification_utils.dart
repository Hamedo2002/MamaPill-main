import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:mama_pill/core/resources/colors.dart';

class TopNotificationUtils {
  static void showMedicineAddedNotification(
    BuildContext context, {
    required String medicineName,
    required VoidCallback onEdit,
  }) {
    Future.delayed(const Duration(milliseconds: 500), () {
      Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: AppColors.primary,
        flushbarPosition: FlushbarPosition.TOP,
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 32),
        titleText: const Text(
          'Medicine Added',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        messageText: Row(
          children: [
            Expanded(
              child: Text(
                '$medicineName has been added successfully!',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: onEdit,
              child: const Text('Edit', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.accent.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 6),
      ).show(context);
    });
  }

  static void showSuccessNotification(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    Future.delayed(const Duration(milliseconds: 500), () {
      Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: AppColors.primary,
        flushbarPosition: FlushbarPosition.TOP,
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 32),
        titleText: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        messageText: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        duration: const Duration(seconds: 6),
      ).show(context);
    });
  }

  static void showErrorNotification(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    Future.delayed(const Duration(milliseconds: 500), () {
      Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(12),
        backgroundColor: Colors.red,
        flushbarPosition: FlushbarPosition.TOP,
        icon: const Icon(Icons.error_outline, color: Colors.white, size: 32),
        titleText: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        messageText: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        duration: const Duration(seconds: 6),
      ).show(context);
    });
  }
}
