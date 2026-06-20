import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GuidancePanel extends StatelessWidget {
  const GuidancePanel({
    required this.messages,
    required this.level,
    super.key,
  });

  final List<String> messages;
  final int level;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool highlight = level <= 2;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (highlight ? AppColors.accent : AppColors.panelLight).withOpacity(highlight ? 0.1 : 0.6),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: highlight ? AppColors.accent.withOpacity(0.5) : AppColors.panelBorder,
        ),
        boxShadow: highlight
            ? <BoxShadow>[BoxShadow(color: AppColors.accent.withOpacity(0.12), blurRadius: 12)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                highlight ? Icons.assistant_navigation : Icons.tips_and_updates_outlined,
                color: AppColors.accent,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Painel de orientacao',
                style: TextStyle(
                  color: highlight ? AppColors.accent : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: highlight ? 12 : 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...messages.map(
            (String msg) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('• ', style: TextStyle(color: AppColors.accent)),
                  Expanded(
                    child: Text(
                      msg,
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
      ),
    );
  }
}
