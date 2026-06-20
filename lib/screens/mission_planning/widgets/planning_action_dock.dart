import 'package:flutter/material.dart';

import '../../../models/test_option.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/round_action_button.dart';

class PlanningActionDock extends StatelessWidget {
  const PlanningActionDock({
    required this.activeTest,
    required this.testInProgress,
    required this.launchEnabled,
    required this.blockedByTests,
    required this.firstCareerLevel,
    required this.onRunTest,
    required this.onLaunch,
    required this.onRecoverFromBudgetLock,
    required this.testHistory,
    super.key,
    this.compact = false,
    this.vertical = false,
  });

  final TestOption? activeTest;
  final bool testInProgress;
  final bool launchEnabled;
  final bool blockedByTests;
  final bool firstCareerLevel;
  final VoidCallback? onRunTest;
  final VoidCallback onLaunch;
  final VoidCallback onRecoverFromBudgetLock;
  final Widget? testHistory;
  final bool compact;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.panelBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          if (!compact) ...<Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.25),
                ),
              ),
              child: const Text(
                'Fluxo: TESTE -> AJUSTE -> LANÇAMENTO. Mais testes melhoram confiança, mas custam orçamento.',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'AÇÕES PRINCIPAIS',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (vertical) _verticalActions() else _wrappedActions(),
          if (!launchEnabled) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
              ),
              child: Text(
                blockedByTests
                    ? 'Testes consumiram a reserva de lançamento. Replaneje para recuperar margem.'
                    : 'Margem de lançamento insuficiente com a configuração atual.',
                style: const TextStyle(
                  color: AppColors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (blockedByTests) ...<Widget>[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onRecoverFromBudgetLock,
                  icon: Icon(
                    firstCareerLevel ? Icons.restart_alt : Icons.trending_down,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  label: Text(
                    firstCareerLevel
                        ? 'Reiniciar planejamento'
                        : 'Replanejar (reduz reputação)',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ],
          if (testHistory != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            testHistory!,
          ],
        ],
      ),
    );
  }

  Widget _verticalActions() {
    return Column(
      children: <Widget>[
        _testButton(),
        const SizedBox(height: AppSpacing.sm),
        _launchButton(),
      ],
    );
  }

  Widget _wrappedActions() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        _testButton(),
        _launchButton(),
      ],
    );
  }

  Widget _testButton() {
    return RoundActionButton(
      label: 'TESTE',
      icon: Icons.science_outlined,
      color: AppColors.accent,
      size: compact ? 84 : 100,
      onPressed: (activeTest == null || testInProgress) ? null : onRunTest,
    );
  }

  Widget _launchButton() {
    return RoundActionButton(
      label: 'LANÇAMENTO',
      icon: Icons.rocket_launch,
      color: launchEnabled ? AppColors.green : AppColors.red,
      size: compact ? 84 : 100,
      onPressed: launchEnabled ? onLaunch : null,
    );
  }
}
