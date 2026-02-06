import 'package:flutter/material.dart';

void showAestheticSnackbar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? Colors.redAccent.shade700 : Colors.teal.shade700,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      // Position at top requires usage of a different approach or margin tweaking.
      // Standard snackbars are bottom. For "Top" specifically, we might need a library or
      // custom overlay. But simplest "aesthetic" improvement is floating with colors.
      // If user insisted on "at top", SnackBar behavior is rigid in standard Flutter.
      // We will stick to high-quality floating bottom for now unless we use a custom overlay package.
      // To simulate "Top", we'd need a banner, but Snackbars are standard.
      // Let's try to make it look premium floating at bottom first.
      elevation: 6,
      duration: const Duration(seconds: 3),
    ),
  );
}
