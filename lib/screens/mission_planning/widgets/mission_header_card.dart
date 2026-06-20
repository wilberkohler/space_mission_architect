import 'package:flutter/material.dart';

import '../../../models/mission.dart';
import '../../../theme/app_theme.dart';

class MissionHeaderCard extends StatelessWidget {
  const MissionHeaderCard({
    required this.mission,
    super.key,
  });

  final Mission mission;

  @override
  Widget build(BuildContext context) {
    final (Color statusColor, String statusLabel) =
        _statusStyle(mission.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border:
            Border.all(color: statusColor.withValues(alpha: 0.35), width: 1.2),
        boxShadow: <BoxShadow>[
          BoxShadow(color: statusColor.withValues(alpha: 0.06), blurRadius: 14),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.35),
                  ),
                ),
                child:
                    Icon(_missionIcon(mission), size: 20, color: statusColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      mission.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${mission.era} - ${mission.type} • Complexidade ${mission.complexityLevel} • Requisito N${mission.requiredCareerLevel}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: AppDecorations.statusBadge(statusColor),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            mission.historicalReference,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  (Color, String) _statusStyle(MissionStatus status) {
    return switch (status) {
      MissionStatus.available => (AppColors.accent, 'DISPONÍVEL'),
      MissionStatus.success => (AppColors.green, 'SUCESSO'),
      MissionStatus.locked => (AppColors.locked, 'BLOQUEADA'),
      MissionStatus.inProgress => (AppColors.orange, 'EM ANDAMENTO'),
      MissionStatus.partialSuccess => (AppColors.yellow, 'SUCESSO PARCIAL'),
      MissionStatus.failure => (AppColors.red, 'FALHA'),
    };
  }

  IconData _missionIcon(Mission mission) {
    final String t = mission.type.toLowerCase();
    if (t.contains('orbita') || t.contains('orbital')) {
      return Icons.travel_explore_outlined;
    }
    if (t.contains('luna')) {
      return Icons.dark_mode_outlined;
    }
    if (t.contains('mars') || t.contains('marte')) {
      return Icons.public_outlined;
    }
    if (t.contains('satelite')) {
      return Icons.satellite_alt_outlined;
    }
    return Icons.rocket_launch_outlined;
  }
}
