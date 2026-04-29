import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomAlerts {
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      AppColors.primaryContainer,
      AppColors.primary,
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      const Color(0xFFFDECEA), // Light coral background
      AppColors.error,
    );
  }

  static void _showSnackbar(
    BuildContext context,
    String message,
    Color backgroundColor,
    Color indicatorColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: indicatorColor.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.textPrimaryLight
                        : AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
