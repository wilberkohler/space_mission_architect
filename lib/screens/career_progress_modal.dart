import 'package:flutter/material.dart';

import '../models/player_career.dart';
import '../theme/app_theme.dart';

Future<void> showCareerProgressModal(
  BuildContext context, {
  required PlayerCareer career,
  PlayerCareer? nextCareer,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.purple.withOpacity(0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Progresso de carreira',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Cargo atual: ${career.title}', style: const TextStyle(color: AppColors.purple)),
              Text(
                'XP: ${career.experience} / ${career.isMaxLevel ? 'MAX' : career.experienceToNextLevel}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 7,
                  value: career.progress,
                  backgroundColor: AppColors.panelBorder,
                  color: AppColors.purple,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Responsabilidades desbloqueadas',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              ...career.unlockedResponsibilities.map((String r) => Text('• $r', style: const TextStyle(color: AppColors.textSecondary))),
              if (nextCareer != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Text('Proximo cargo: ${nextCareer.title}', style: const TextStyle(color: AppColors.accent)),
              ],
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
