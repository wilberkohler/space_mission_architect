import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TopStatusBar extends StatelessWidget {
  const TopStatusBar({
    required this.agencyName,
    required this.year,
    required this.budget,
    required this.reputation,
    this.careerTitle,
    this.careerLevel,
    super.key,
  });

  final String agencyName;
  final int year;
  final int budget;
  final int reputation;
  final String? careerTitle;
  final int? careerLevel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentGlow,
            border: Border.all(color: AppColors.accent, width: 1),
          ),
          child: const Icon(Icons.public, size: 13, color: AppColors.accent),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            agencyName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _chip(Icons.calendar_today_outlined, 'ANO $year', AppColors.textMuted),
        const SizedBox(width: 6),
        _chip(Icons.attach_money_outlined, '${budget}M', AppColors.green),
        const SizedBox(width: 6),
        _chip(Icons.military_tech_outlined, '$reputation', AppColors.purple),
        if (careerTitle != null && careerLevel != null) ...<Widget>[
          const SizedBox(width: 6),
          _chip(Icons.workspace_premium_outlined, 'L$careerLevel ${careerTitle!}', AppColors.accent),
        ],
      ],
    );
  }

  Widget _chip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.circle),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
