import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import '../audio/sound_effect.dart';
import '../game/game_controller.dart';
import '../models/countdown_step.dart';
import '../models/mission.dart';
import '../theme/app_theme.dart';

/// Shows a pre-launch readiness summary. Returns true when the user confirms
/// launch, false / null when they go back.
Future<bool?> showLaunchReadinessModal(
  BuildContext context, {
  required GameController controller,
  required List<TestRunOutcome> testHistory,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _LaunchReadinessDialog(
      controller: controller,
      testHistory: testHistory,
    ),
  );
}

class _LaunchReadinessDialog extends StatelessWidget {
  const _LaunchReadinessDialog({
    required this.controller,
    required this.testHistory,
  });

  final GameController controller;
  final List<TestRunOutcome> testHistory;

  @override
  Widget build(BuildContext context) {
    final Mission? mission = controller.selectedMission;
    if (mission == null) {
      return const SizedBox.shrink();
    }

    final int chance = controller.overallPlanningScore.round();
    final int risk = (100 - chance).clamp(0, 100);
    final Color chanceColor = chance >= 70
        ? AppColors.green
        : chance >= 50
            ? AppColors.yellow
            : AppColors.red;

    final bool budgetOk =
        controller.missionBudgetCap >= mission.minimumBudget;
    final int passedTests =
        testHistory.where((TestRunOutcome o) => o.passed).length;
    final bool hasPendingAlert =
        testHistory.any((TestRunOutcome o) => o.hasWarning);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        width: 540,
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.green.withOpacity(0.4), width: 1.5),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: AppColors.green.withOpacity(0.10),
                blurRadius: 32,
                spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _header(mission),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Chance + budget row
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _statusCard(
                          label: 'Chance estimada',
                          value: '$chance%',
                          color: chanceColor,
                          icon: Icons.bar_chart_outlined,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _statusCard(
                          label: 'Orcamento alocado',
                          value: '${controller.missionBudgetCap}M',
                          color: budgetOk ? AppColors.green : AppColors.red,
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _statusCard(
                          label: 'Testes realizados',
                          value: '$passedTests/${testHistory.length}',
                          color: testHistory.isEmpty
                              ? AppColors.textMuted
                              : passedTests == testHistory.length
                                  ? AppColors.green
                                  : AppColors.orange,
                          icon: Icons.science_outlined,
                        ),
                      ),
                    ],
                  ),
                  if (hasPendingAlert) ...<Widget>[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                            color: AppColors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.warning_amber_outlined,
                              size: 14, color: AppColors.orange),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Algum teste apontou alertas — verifique antes de lancamento.',
                              style: TextStyle(
                                  color: AppColors.orange, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  // Top risks
                  const Text(
                    'PRINCIPAIS RISCOS',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...mission.mainRisks.take(3).map(
                    (String riskText) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.warning_amber_outlined,
                            size: 13,
                            color: AppColors.orange.withOpacity(0.85),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              riskText,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Risk indicator
                  Row(
                    children: <Widget>[
                      const Text(
                        'Risco total: ',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                      Text(
                        '$risk%',
                        style: TextStyle(
                          color: chanceColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Footer buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        AudioManager.instance.play(SoundEffect.uiBack);
                        Navigator.of(context).pop(false);
                      },
                      icon: const Icon(Icons.arrow_back_outlined, size: 16),
                      label: const Text('Voltar ao planejamento'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.accent.withOpacity(0.10),
                        foregroundColor: AppColors.accent,
                        side: BorderSide(
                            color: AppColors.accent.withOpacity(0.35)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        AudioManager.instance.play(SoundEffect.uiConfirm);
                        Navigator.of(context).pop(true);
                      },
                      icon: const Icon(Icons.rocket_launch_outlined,
                          size: 16),
                      label: const Text('Confirmar lancamento'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.green.withOpacity(0.12),
                        foregroundColor: AppColors.green,
                        side: BorderSide(
                            color: AppColors.green.withOpacity(0.4)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(Mission mission) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.07),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl)),
        border: Border(
            bottom: BorderSide(color: AppColors.green.withOpacity(0.2))),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.green.withOpacity(0.12),
              border: Border.all(color: AppColors.green.withOpacity(0.4)),
            ),
            child: const Icon(Icons.rocket_launch_outlined,
                size: 22, color: AppColors.green),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'PRONTIDAO PARA LANCAMENTO',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
                Text(
                  mission.name,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                color: color, fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
