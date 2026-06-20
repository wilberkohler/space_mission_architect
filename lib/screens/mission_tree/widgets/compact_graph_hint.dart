import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class CompactGraphHint extends StatelessWidget {
  const CompactGraphHint({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bgDeep.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(AppRadius.circle),
            border: Border.all(color: AppColors.panelBorder),
          ),
          child: const Text(
            'Arraste para navegar • use zoom para aproximar',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
