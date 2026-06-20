import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class CalibrationWorkbench extends StatelessWidget {
  const CalibrationWorkbench({
    required this.mobileWidth,
    required this.moduleHeight,
    required this.testsPanel,
    required this.variablesPanel,
    required this.showDebugToggle,
    required this.showAllVariablesDebug,
    required this.onShowAllVariablesChanged,
    super.key,
  });

  final bool mobileWidth;
  final double moduleHeight;
  final Widget testsPanel;
  final Widget variablesPanel;
  final bool showDebugToggle;
  final bool showAllVariablesDebug;
  final ValueChanged<bool> onShowAllVariablesChanged;

  @override
  Widget build(BuildContext context) {
    final Widget heading = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              'CALIBRAGEM DE TESTES E VARIÁVEIS',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
          if (showDebugToggle)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Ver todas (debug)',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
                Switch.adaptive(
                  value: showAllVariablesDebug,
                  onChanged: onShowAllVariablesChanged,
                ),
              ],
            ),
        ],
      ),
    );

    final Widget testsPane = SizedBox(height: moduleHeight, child: testsPanel);
    final Widget varsPane =
        SizedBox(height: moduleHeight, child: variablesPanel);

    if (mobileWidth) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          heading,
          const SizedBox(height: AppSpacing.sm),
          testsPane,
          const SizedBox(height: AppSpacing.sm),
          varsPane,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        heading,
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: testsPane),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: varsPane),
          ],
        ),
      ],
    );
  }
}
