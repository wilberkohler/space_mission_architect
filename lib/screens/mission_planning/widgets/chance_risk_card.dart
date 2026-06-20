import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class ChanceRiskCard extends StatelessWidget {
  const ChanceRiskCard({
    required this.chance,
    required this.chanceLow,
    required this.chanceHigh,
    required this.risk,
    required this.confidence,
    required this.riskBeforeTests,
    required this.hasTestHistory,
    required this.mainRisks,
    super.key,
  });

  final int chance;
  final int chanceLow;
  final int chanceHigh;
  final int risk;
  final double confidence;
  final int riskBeforeTests;
  final bool hasTestHistory;
  final Iterable<String> mainRisks;

  @override
  Widget build(BuildContext context) {
    final Color chanceColor = chance >= 70
        ? AppColors.green
        : chance >= 50
            ? AppColors.yellow
            : AppColors.red;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: chanceColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: chanceColor, width: 2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: chanceColor.withValues(alpha: 0.15),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '$chance%',
                    style: TextStyle(
                      fontSize: 20,
                      color: chanceColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'chance',
                    style: TextStyle(fontSize: 9, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Chance estimada: $chanceLow-$chanceHigh%',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Risco estimado: $risk% • Confiança ${(confidence * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                if (hasTestHistory) ...<Widget>[
                  const SizedBox(height: 6),
                  _BeforeAfterIndicator(
                    label: 'Risco estimado',
                    before: '$riskBeforeTests%',
                    after: '$risk%',
                    improved: risk <= riskBeforeTests,
                  ),
                ],
                if (confidence < 0.45) ...<Widget>[
                  const SizedBox(height: 6),
                  const Text(
                    'Baixa confiança nos parâmetros da missão.',
                    style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                ...mainRisks.take(2).map(
                      (String riskText) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.warning_amber_outlined,
                              size: 13,
                              color: AppColors.orange.withValues(alpha: 0.85),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                riskText,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BeforeAfterIndicator extends StatelessWidget {
  const _BeforeAfterIndicator({
    required this.label,
    required this.before,
    required this.after,
    required this.improved,
  });

  final String label;
  final String before;
  final String after;
  final bool improved;

  @override
  Widget build(BuildContext context) {
    final Color tone = improved ? AppColors.green : AppColors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: tone.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.compare_arrows, size: 13, color: tone),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label: $before -> $after',
              style: TextStyle(
                color: tone,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
