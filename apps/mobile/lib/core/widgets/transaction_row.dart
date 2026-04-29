import 'package:flutter/material.dart';
import '../constants/colors.dart';

class TransactionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final bool isNegative;

  const TransactionRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    this.isNegative = true,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isNegative
                  ? (isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark)
                  : AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
