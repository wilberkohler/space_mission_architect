import 'package:flutter/material.dart';

import '../../../models/countdown_step.dart';
import '../../../theme/app_theme.dart';

class TestHistoryBanner extends StatelessWidget {
  const TestHistoryBanner({
    required this.outcomes,
    super.key,
  });

  final List<TestRunOutcome> outcomes;

  @override
  Widget build(BuildContext context) {
    final List<String> names =
        outcomes.map((TestRunOutcome o) => o.testName).toList();
    final List<String> alerts = outcomes
        .where((TestRunOutcome o) => o.hasWarning || !o.passed)
        .map(
          (TestRunOutcome o) => o.findings.isEmpty
              ? o.testName
              : '${o.testName}: ${o.findings.first}',
        )
        .toList();

    final bool allGood = outcomes.isNotEmpty &&
        outcomes.every((TestRunOutcome o) => o.passed && !o.hasWarning);
    final Color c = allGood ? AppColors.green : AppColors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.science_outlined, size: 14, color: c),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Testes realizados: ${names.join(', ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (alerts.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              'Alertas: ${alerts.join(' | ')}',
              style: const TextStyle(
                color: AppColors.orange,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
