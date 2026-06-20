import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MissionPhaseTimeline extends StatelessWidget {
  const MissionPhaseTimeline({
    required this.phases,
    required this.activeIndex,
    super.key,
  });

  final List<String> phases;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(phases.length, (int i) {
        final bool past = i < activeIndex;
        final bool active = i == activeIndex;
        final Color color = active
            ? AppColors.accent
            : past
                ? AppColors.green
                : AppColors.textMuted;
        return Padding(
          key: ValueKey<String>('phase-row-${phases[i]}-$i'),
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.12),
                      border: Border.all(color: color, width: active ? 2 : 1),
                    ),
                    child: Icon(
                      past ? Icons.check : (active ? Icons.adjust : Icons.circle_outlined),
                      size: 12,
                      color: color,
                    ),
                  ),
                  if (i < phases.length - 1)
                    Container(width: 1, height: 20, color: AppColors.panelBorder),
                ],
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  phases[i],
                  style: TextStyle(
                    color: active
                        ? AppColors.textPrimary
                        : past
                            ? AppColors.textSecondary
                            : AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
