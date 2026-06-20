import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CriticalActionButton extends StatelessWidget {
  const CriticalActionButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    super.key,
    this.highlight = false,
  });

  final String label;
  final bool enabled;
  final bool highlight;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Color color = highlight ? AppColors.red : AppColors.textMuted;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: highlight ? AppColors.red.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: highlight ? AppColors.red.withOpacity(0.55) : AppColors.panelBorder,
          width: highlight ? 1.5 : 1,
        ),
        boxShadow: highlight ? AppShadows.criticalGlow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 1,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  highlight ? Icons.warning_amber_outlined : Icons.stop_circle_outlined,
                  size: 14,
                  color: enabled ? color : AppColors.textMuted.withOpacity(0.3),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: enabled ? color : AppColors.textMuted.withOpacity(0.3),
                    fontSize: 12,
                    fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
