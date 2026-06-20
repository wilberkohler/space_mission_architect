import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RivalAgencyPanel extends StatelessWidget {
  const RivalAgencyPanel({
    required this.name,
    required this.score,
    required this.lastMission,
    super.key,
    this.rank,
    this.isPlayer = false,
  });

  final String name;
  final int score;
  final String lastMission;
  final int? rank;
  final bool isPlayer;

  @override
  Widget build(BuildContext context) {
    final Color color = isPlayer ? AppColors.accent : AppColors.textSecondary;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isPlayer ? AppColors.accent.withOpacity(0.07) : AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isPlayer ? AppColors.accent.withOpacity(0.4) : AppColors.panelBorder,
          width: isPlayer ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          if (rank != null)
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _rankColor(rank!).withOpacity(0.15),
                border: Border.all(color: _rankColor(rank!).withOpacity(0.4)),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    color: _rankColor(rank!),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Última: $lastMission',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '$score pts',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Color _rankColor(int rank) {
    return switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => AppColors.textMuted,
    };
  }
}
