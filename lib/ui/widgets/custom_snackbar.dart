import 'package:flutter/material.dart';
import 'package:app_asistencias/ui/theme/app_spacing.dart';
import 'package:app_asistencias/ui/theme/app_colors.dart';

class CustomSnackBar {
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(AppSpacing.lg),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isError
                    ? AppColors.danger.withOpacity(0.2)
                    : AppColors.success.withOpacity(0.2),
              ),
              child: Icon(
                isError ? Icons.close : Icons.check,
                color: isError ? AppColors.danger : AppColors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
