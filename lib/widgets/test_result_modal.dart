import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import '../audio/sound_effect.dart';
import '../models/countdown_step.dart';
import '../theme/app_theme.dart';

/// Modal displayed after a test countdown completes.
/// Shows passed/warning status, findings, and deltas.
/// Returns true if user proceeds to planning, false to discard.
Future<void> showTestResultModal(
  BuildContext context, {
  required TestRunOutcome outcome,
}) {
  if (outcome.passed && outcome.hasWarning) {
    AudioManager.instance.play(SoundEffect.testWarning);
  } else if (outcome.passed) {
    AudioManager.instance.play(SoundEffect.testSuccess);
  } else {
    AudioManager.instance.play(SoundEffect.testFailed);
  }

  return showDialog<void>(
    context: context,
    builder: (_) => _TestResultDialog(outcome: outcome),
  );
}

class _TestResultDialog extends StatelessWidget {
  const _TestResultDialog({required this.outcome});

  final TestRunOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final Color accent =
        outcome.passed ? AppColors.green : AppColors.orange;
    final String headline =
        outcome.passed ? 'Teste aprovado' : 'Teste com alertas';
    final IconData headIcon =
        outcome.passed ? Icons.check_circle_outline : Icons.warning_amber_outlined;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Container(
        width: 460,
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: accent.withOpacity(0.4), width: 1.5),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: accent.withOpacity(0.12),
                blurRadius: 32,
                spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl)),
                border: Border(
                    bottom: BorderSide(color: accent.withOpacity(0.2))),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withOpacity(0.12),
                      border: Border.all(color: accent.withOpacity(0.4)),
                    ),
                    child: Icon(headIcon, size: 20, color: accent),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          headline.toUpperCase(),
                          style: TextStyle(
                            color: accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          outcome.testName,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Deltas row
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _deltaCard(
                          label: 'Reducao de risco',
                          value:
                              '${(outcome.riskDelta.abs() * 100).toStringAsFixed(1)}%',
                          color: AppColors.green,
                          icon: Icons.trending_down,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _deltaCard(
                          label: 'Incerteza reduzida',
                          value:
                              '${(outcome.uncertaintyDelta.abs() * 100).toStringAsFixed(1)}%',
                          color: AppColors.accent,
                          icon: Icons.visibility_outlined,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _deltaCard(
                          label: 'Custo',
                          value: '${outcome.budgetCost}M',
                          color: AppColors.yellow,
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                      ),
                    ],
                  ),
                  if (outcome.validatedItems.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'ITENS VALIDADOS',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: outcome.validatedItems
                          .map(
                            (String item) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.green.withOpacity(0.08),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.circle),
                                border: Border.all(
                                    color:
                                        AppColors.green.withOpacity(0.3)),
                              ),
                              child: Text(
                                item,
                                style: const TextStyle(
                                  color: AppColors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (outcome.findings.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'OBSERVACOES',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...outcome.findings.map(
                      (String f) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.chevron_right,
                              size: 14,
                              color: AppColors.orange.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                f,
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
                  ],
                ],
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    AudioManager.instance.play(SoundEffect.uiBack);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back_outlined, size: 16),
                  label: const Text('Voltar ao planejamento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent.withOpacity(0.12),
                    foregroundColor: accent,
                    side: BorderSide(color: accent.withOpacity(0.4)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deltaCard({
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
