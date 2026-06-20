import 'package:flutter/material.dart';

import '../models/mission.dart';
import '../theme/app_theme.dart';
import 'shared/section_header.dart';
import 'shared/status_pill.dart';

class MissionDetailPanel extends StatelessWidget {
  const MissionDetailPanel({
    required this.mission,
    required this.canPlan,
    required this.lockReasons,
    required this.allMissions,
    required this.currentBudget,
    required this.currentReputation,
    required this.currentCareerLevel,
    required this.onPlan,
    super.key,
  });

  final Mission mission;
  final bool canPlan;
  final List<String> lockReasons;
  final List<Mission> allMissions;
  final int currentBudget;
  final int currentReputation;
  final int currentCareerLevel;
  final VoidCallback onPlan;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(mission.status);
    final bool locked =
        mission.status == MissionStatus.locked || lockReasons.isNotEmpty;
    final bool available = mission.status == MissionStatus.available && canPlan;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
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
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: statusColor),
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
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            mission.historicalReference,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _metaChip('Ano', mission.year.toString(),
                  Icons.calendar_today_outlined),
              _metaChip('Tipo', mission.type, Icons.category_outlined),
              _metaChip('Dificuldade', mission.difficulty.toString(),
                  Icons.speed_outlined),
              _metaChip('Complexidade', mission.complexityLevel.toString(),
                  Icons.hub_outlined),
              _metaChip('Orc. mínimo', '${mission.minimumBudget}M',
                  Icons.savings_outlined),
              _metaChip('Orc. Recom.', '${mission.recommendedBudget}M',
                  Icons.account_balance_wallet_outlined),
              _metaChip('Cargo', 'N${mission.requiredCareerLevel}',
                  Icons.workspace_premium_outlined),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (available) _availableCallout(),
          if (locked) _lockedCallout(),
          if (mission.requiredMissions.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _requirementsList(),
          ],
          if (mission.mainRisks.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _riskList(),
          ],
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: canPlan ? onPlan : null,
              icon: const Icon(Icons.rocket_launch_outlined, size: 16),
              label: const Text('Planejar missão'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _availableCallout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.35)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.check_circle_outline, color: AppColors.green, size: 18),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Missão disponível para planejamento agora. Revise custos, riscos e requisitos antes de avançar.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lockedCallout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHeader(
            title: 'Como desbloquear',
            subtitle: 'Resolva os requisitos abaixo para liberar esta missão.',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (lockReasons.isEmpty)
            const Text(
              'Esta missão ainda depende de progresso na campanha.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            )
          else
            ...lockReasons.map(
              (String reason) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(Icons.block_outlined,
                        color: AppColors.red, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        reason,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              StatusPill(
                label: currentBudget >= mission.minimumBudget
                    ? 'Orçamento suficiente'
                    : 'Precisa de ${mission.minimumBudget}M',
                icon: Icons.account_balance_wallet_outlined,
                color: currentBudget >= mission.minimumBudget
                    ? AppColors.green
                    : AppColors.red,
              ),
              StatusPill(
                label: currentReputation >= mission.requiredReputation
                    ? 'Reputação suficiente'
                    : 'Reputação ${mission.requiredReputation}+',
                icon: Icons.auto_awesome_outlined,
                color: currentReputation >= mission.requiredReputation
                    ? AppColors.green
                    : AppColors.red,
              ),
              StatusPill(
                label: currentCareerLevel >= mission.requiredCareerLevel
                    ? 'Cargo suficiente'
                    : 'Cargo N${mission.requiredCareerLevel}',
                icon: Icons.workspace_premium_outlined,
                color: currentCareerLevel >= mission.requiredCareerLevel
                    ? AppColors.green
                    : AppColors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _requirementsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Missões necessárias',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: mission.requiredMissions
              .map(
                (String id) => StatusPill(
                  label: _missionNameForId(id),
                  icon: Icons.account_tree_outlined,
                  color: AppColors.textSecondary,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _riskList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Principais riscos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: mission.mainRisks
              .map(
                (String risk) => StatusPill(
                  label: risk,
                  icon: Icons.warning_amber_outlined,
                  color: AppColors.yellow,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _metaChip(String label, String value, IconData icon) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Container(
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
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: '$label: ',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    TextSpan(
                      text: value,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _missionNameForId(String id) {
    for (final Mission item in allMissions) {
      if (item.id == id) {
        return item.name;
      }
    }
    return id;
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
      MissionStatus.available => 'Disponível',
      MissionStatus.success => 'Sucesso',
      MissionStatus.partialSuccess => 'Parcial',
      MissionStatus.failure => 'Falha',
      MissionStatus.inProgress => 'Em andamento',
      MissionStatus.locked => 'Bloqueada',
    };
  }
}
