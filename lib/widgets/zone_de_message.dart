// widgets/snackbar_helper.dart
import 'package:flutter/material.dart';

class SnackBarHelper {
  static void showSnackBar(
    BuildContext context,
    String message,
    Color color, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Succès
  static void success(BuildContext context, String message) {
    showSnackBar(context, "✅ $message", Colors.green);
  }

  //  Erreur
  static void error(BuildContext context, String message) {
    showSnackBar(context, "❌ $message", Colors.red);
  }

  //  Avertissement
  static void warning(BuildContext context, String message) {
    showSnackBar(context, "⚠️ $message", Colors.orange);
  }

  // ℹInformation
  static void info(BuildContext context, String message) {
    showSnackBar(context, "ℹ️ $message", Colors.blue);
  }
}