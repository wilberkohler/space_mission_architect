import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ResourceStatusPanel extends StatelessWidget {
  const ResourceStatusPanel({
    required this.fuel,
    required this.energy,
    required this.communication,
    required this.integrity,
    required this.science,
    super.key,
  });

  final double fuel;
  final double energy;
  final double communication;
  final double integrity;
  final double science;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _resourceBar('COMBUSTÍVEL', fuel, Icons.local_fire_department_outlined, AppColors.orange),
        const SizedBox(height: AppSpacing.sm),
        _resourceBar('ENERGIA', energy, Icons.bolt_outlined, AppColors.yellow),
        const SizedBox(height: AppSpacing.sm),
        _resourceBar('COMUNICAÇÃO', communication, Icons.wifi_outlined, AppColors.accent),
        const SizedBox(height: AppSpacing.sm),
        _resourceBar('INTEGRIDADE', integrity, Icons.shield_outlined, AppColors.green),
        const SizedBox(height: AppSpacing.sm),
        _resourceBar('CIÊNCIA', science, Icons.science_outlined, AppColors.purple),
      ],
    );
  }

  Widget _resourceBar(
    String label,
    double value,
    IconData icon,
    Color baseColor,
  ) {
    final double pct = (value / 100).clamp(0.0, 1.0);
    final Color barColor = pct < 0.25
        ? AppColors.red
        : pct < 0.5
            ? AppColors.yellow
            : baseColor;

    return Row(
      children: <Widget>[
        Icon(icon, size: 14, color: barColor),
        const SizedBox(width: 6),
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.panelBorder,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: barColor.withOpacity(0.4), blurRadius: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 34,
          child: Text(
            '${value.round()}%',
            style: TextStyle(
              color: barColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
