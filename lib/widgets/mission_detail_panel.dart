import 'package:flutter/material.dart';

import '../models/mission.dart';
import '../theme/app_theme.dart';

class MissionDetailPanel extends StatelessWidget {
  const MissionDetailPanel({
    required this.mission,
    required this.canPlan,
    required this.lockReasons,
    required this.onPlan,
    super.key,
  });

  final Mission mission;
  final bool canPlan;
  final List<String> lockReasons;
  final VoidCallback onPlan;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(mission.status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: statusColor.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mission.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: AppDecorations.statusBadge(statusColor),
                child: Text(
                  _statusLabel(mission.status),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            mission.historicalReference,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _metaChip('Ano', mission.year.toString(), Icons.calendar_today_outlined),
              _metaChip('Tipo', mission.type, Icons.category_outlined),
              _metaChip('Dificuldade', mission.difficulty.toString(), Icons.speed_outlined),
              _metaChip('Orc. Recom.', '${mission.recommendedBudget}M', Icons.account_balance_wallet_outlined),
              _metaChip('Cargo', 'N${mission.requiredCareerLevel}', Icons.workspace_premium_outlined),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (mission.requiredMissions.isNotEmpty)
            Text(
              'Requisitos: ${mission.requiredMissions.join(', ')}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          if (lockReasons.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            ...lockReasons.map(
              (String reason) => Text(
                '- $reason',
                style: const TextStyle(color: AppColors.red, fontSize: 11, height: 1.3),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: canPlan ? onPlan : null,
              icon: const Icon(Icons.rocket_launch_outlined, size: 16),
              label: const Text('Planejar missao'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.panelLight,
        borderRadius: BorderRadius.circular(AppRadius.circle),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Text('$label: ', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Color _statusColor(MissionStatus status) {
    return switch (status) {
      MissionStatus.available => AppColors.available,
      MissionStatus.success => AppColors.success,
      MissionStatus.partialSuccess => AppColors.yellow,
      MissionStatus.failure => AppColors.red,
      MissionStatus.inProgress => AppColors.accent,
      MissionStatus.locked => AppColors.locked,
    };
  }

  String _statusLabel(MissionStatus status) {
    return switch (status) {
      MissionStatus.available => 'Disponivel',
      MissionStatus.success => 'Sucesso',
      MissionStatus.partialSuccess => 'Parcial',
      MissionStatus.failure => 'Falha',
      MissionStatus.inProgress => 'Em andamento',
      MissionStatus.locked => 'Bloqueada',
    };
  }
}
