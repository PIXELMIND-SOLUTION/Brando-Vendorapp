import 'package:flutter/material.dart';

class ToastService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFF43A047),
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  static void showError(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFFE53935),
      icon: Icons.error_outline,
      duration: duration,
    );
  }

  static void showInfo(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFF2196F3),
      icon: Icons.info_outline,
      duration: duration,
    );
  }

  static void showWarning(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showToast(
      message: message,
      backgroundColor: const Color(0xFFFF9800),
      icon: Icons.warning_amber_outlined,
      duration: duration,
    );
  }

  static void _showToast({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
  }) {
    if (messengerKey.currentState == null) {
      debugPrint(
        'ToastService: messengerKey not initialized. Make sure to set scaffoldMessengerKey in MaterialApp',
      );
      return;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: duration,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    messengerKey.currentState?.showSnackBar(snackBar);
  }

  static void clearAll() {
    messengerKey.currentState?.clearSnackBars();
  }
}
