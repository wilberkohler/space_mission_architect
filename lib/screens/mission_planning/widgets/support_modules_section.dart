import 'package:flutter/material.dart';

import '../../../models/mission.dart';
import '../../../theme/app_theme.dart';

class SupportModulesSection extends StatelessWidget {
  const SupportModulesSection({
    required this.mission,
    required this.moduleHeight,
    required this.mobileWidth,
    required this.componentsPanel,
    required this.teamPanel,
    super.key,
  });

  final Mission mission;
  final double moduleHeight;
  final bool mobileWidth;
  final Widget componentsPanel;
  final Widget teamPanel;

  @override
  Widget build(BuildContext context) {
    if (mission.complexityLevel <= 1) {
      return const SizedBox.shrink();
    }

    if (mission.complexityLevel == 2) {
      return SizedBox(
        width: double.infinity,
        height: moduleHeight,
        child: componentsPanel,
      );
    }

    if (mobileWidth) {
      return Column(
        children: <Widget>[
          SizedBox(height: moduleHeight, child: componentsPanel),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(height: moduleHeight, child: teamPanel),
        ],
      );
    }

    return Row(
      children: <Widget>[
        Expanded(child: SizedBox(height: moduleHeight, child: componentsPanel)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: SizedBox(height: moduleHeight, child: teamPanel)),
      ],
    );
  }
}
