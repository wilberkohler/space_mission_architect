import 'package:flutter/material.dart';

import '../../../models/mission.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/shared/status_pill.dart';

class RecommendedMissionBanner extends StatelessWidget {
  const RecommendedMissionBanner({
    required this.mission,
    required this.missionVisible,
    required this.onSelect,
    required this.onShowAvailable,
    super.key,
  });

  final Mission? mission;
  final bool missionVisible;
  final VoidCallback? onSelect;
  final VoidCallback? onShowAvailable;

  @override
  Widget build(BuildContext context) {
    final Mission? recommended = mission;

    if (recommended == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.panelBorder),
        ),
        child: const Row(
          children: <Widget>[
            Icon(Icons.info_outline, color: AppColors.textMuted, size: 16),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Nenhuma missão disponível no momento',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.38)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.05),
            blurRadius: 14,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 700;
          final Widget missionSummary = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Próxima missão recomendada',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                recommended.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  StatusPill(
                    label: '${recommended.year}',
                    icon: Icons.calendar_month_outlined,
                    color: AppColors.yellow,
                  ),
                  StatusPill(
                    label: recommended.type,
                    icon: Icons.rocket_launch_outlined,
                    color: AppColors.accent,
                  ),
                  StatusPill(
                    label:
                        'Dif. ${recommended.difficulty} / Comp. ${recommended.complexityLevel}',
                    icon: Icons.speed_outlined,
                    color: AppColors.orange,
                  ),
                ],
              ),
              if (!missionVisible) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                const Row(
                  children: <Widget>[
                    Icon(
                      Icons.visibility_off_outlined,
                      color: AppColors.yellow,
                      size: 16,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'A missão recomendada está fora do filtro atual',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
          final Widget action = missionVisible
              ? ElevatedButton.icon(
                  onPressed: onSelect,
                  icon: const Icon(Icons.my_location_outlined, size: 16),
                  label: const Text('Selecionar'),
                )
              : OutlinedButton.icon(
                  onPressed: onShowAvailable,
                  icon: const Icon(Icons.filter_alt_outlined, size: 16),
                  label: const Text('Mostrar disponíveis'),
                );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                missionSummary,
                const SizedBox(height: AppSpacing.sm),
                Align(alignment: Alignment.centerRight, child: action),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(child: missionSummary),
              const SizedBox(width: AppSpacing.md),
              action,
            ],
          );
        },
      ),
    );
  }
}
