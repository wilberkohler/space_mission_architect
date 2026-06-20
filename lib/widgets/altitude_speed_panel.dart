import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AltitudeSpeedPanel extends StatelessWidget {
  const AltitudeSpeedPanel({
    required this.altitude,
    required this.speed,
    super.key,
    this.missionTime,
  });

  final double altitude;
  final double speed;
  final int? missionTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _instrument(
            'ALTITUDE',
            altitude.toStringAsFixed(1),
            'km',
            Icons.arrow_upward_outlined,
            AppColors.accent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _instrument(
            'VELOCIDADE',
            speed.toStringAsFixed(0),
            'km/h',
            Icons.speed_outlined,
            AppColors.green,
          ),
        ),
        if (missionTime != null) ...<Widget>[
          const SizedBox(width: 8),
          Expanded(
            child: _instrument(
              'T+',
              '$missionTime',
              's',
              Icons.timer_outlined,
              AppColors.yellow,
            ),
          ),
        ],
      ],
    );
  }

  Widget _instrument(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: <BoxShadow>[
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 11, color: color.withOpacity(0.7)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    color: color.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
