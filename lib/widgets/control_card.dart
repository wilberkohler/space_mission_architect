import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ControlCard extends StatelessWidget {
  const ControlCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.accentColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final Color border = accentColor?.withOpacity(0.3) ?? AppColors.panelBorder;
    final Color? shadow = accentColor;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: border, width: 1),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (shadow ?? AppColors.accent).withOpacity(shadow != null ? 0.06 : 0.03),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
