import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF252525),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isError
                    ? const Color(0xFFFF5252).withOpacity(0.2)
                    : const Color(0xFF4CAF50).withOpacity(0.2),
              ),
              child: Icon(
                isError ? Icons.close : Icons.check,
                color: isError ? const Color(0xFFFF5252) : const Color(0xFF4CAF50),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
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
      ),
    );
  }
}
