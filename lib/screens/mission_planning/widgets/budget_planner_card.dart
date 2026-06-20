import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class BudgetPlannerCard extends StatelessWidget {
  const BudgetPlannerCard({
    required this.available,
    required this.minimumBudget,
    required this.recommendedBudget,
    required this.testCost,
    required this.launchCost,
    required this.total,
    required this.remaining,
    required this.reserve,
    required this.remainingBeforeTests,
    required this.blockedByTests,
    required this.ok,
    super.key,
  });

  final int available;
  final int minimumBudget;
  final int recommendedBudget;
  final int testCost;
  final int launchCost;
  final int total;
  final int remaining;
  final int reserve;
  final int remainingBeforeTests;
  final bool blockedByTests;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final Color c = ok ? AppColors.green : AppColors.red;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.account_balance_wallet_outlined, size: 14, color: c),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'PLANO ORÇAMENTÁRIO DA MISSÃO',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _line('Orçamento disponível', '${available}M'),
          _line('Orçamento mínimo', '${minimumBudget}M'),
          _line('Orçamento recomendado', '${recommendedBudget}M'),
          _line('Testes selecionados/realizados', '${testCost}M'),
          _line('Lançamento estimado', '${launchCost}M'),
          _line('Total comprometido', '${total}M'),
          _line(
            'Restante',
            '${remaining}M',
            valueColor: remaining >= reserve ? AppColors.green : AppColors.red,
          ),
          const SizedBox(height: 6),
          _BeforeAfterIndicator(
            label: 'Margem para lançamento',
            before: '${remainingBeforeTests}M',
            after: '${remaining}M',
            improved: remaining >= remainingBeforeTests,
          ),
          const SizedBox(height: 6),
          Text(
            'Reserva mínima: ${reserve}M',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
          if (!ok) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              blockedByTests
                  ? 'Os testes reduziram a margem abaixo da reserva de lançamento.'
                  : 'A configuração atual está abaixo da reserva de lançamento.',
              style: const TextStyle(
                color: AppColors.red,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _line(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
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
