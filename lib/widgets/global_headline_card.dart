import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum HeadlineType { success, warning, critical, neutral }

class GlobalHeadlineCard extends StatelessWidget {
  const GlobalHeadlineCard({
    required this.headline,
    super.key,
    this.type = HeadlineType.neutral,
  });

  final String headline;
  final HeadlineType type;

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (type) {
      HeadlineType.success => (AppColors.green, Icons.check_circle_outline),
      HeadlineType.warning => (AppColors.yellow, Icons.warning_amber_outlined),
      HeadlineType.critical => (AppColors.red, Icons.error_outline),
      HeadlineType.neutral => (AppColors.accent, Icons.public_outlined),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              headline,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
