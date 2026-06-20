import 'package:flutter/material.dart';

import '../models/player_career.dart';
import '../theme/app_theme.dart';

class CareerBadge extends StatelessWidget {
  const CareerBadge({required this.career, super.key, this.compact = false});

  final PlayerCareer career;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? 6 : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.purple.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.workspace_premium_outlined, size: 13, color: AppColors.purple),
              const SizedBox(width: 4),
              Text(
                'Cargo: ${career.title}',
                style: const TextStyle(
                  color: AppColors.purple,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'XP: ${career.experience} / ${career.isMaxLevel ? 'MAX' : career.experienceToNextLevel}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
          if (!career.isMaxLevel) ...<Widget>[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 5,
                value: career.progress,
                backgroundColor: AppColors.panelBorder,
                color: AppColors.purple,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
