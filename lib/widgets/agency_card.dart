import 'package:flutter/material.dart';

import '../models/agency.dart';

import '../theme/app_theme.dart';

class AgencyCard extends StatelessWidget {
  const AgencyCard({
    required this.agency,
    required this.onTap,
    super.key,
  });

  final Agency agency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _difficultyColor(agency.difficulty);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: AppDecorations.glassPanel(accent: accentColor),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg + 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      color: accentColor.withOpacity(0.12),
                      border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
                    ),
                    child: Icon(Icons.rocket_launch_outlined, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          agency.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          agency.country,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: AppDecorations.statusBadge(accentColor),
                    child: Text(
                      agency.difficulty.toUpperCase(),
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.panelBorder, height: 1),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  _stat(Icons.science_outlined, agency.specialty, AppColors.accent),
                  const SizedBox(width: AppSpacing.md),
                  _stat(Icons.attach_money_outlined, '${agency.initialBudget}M inicial', AppColors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Color _difficultyColor(String diff) {
    return switch (diff.toLowerCase()) {
      'fácil' || 'facil' || 'easy' => AppColors.green,
      'médio' || 'medio' || 'medium' => AppColors.yellow,
      'difícil' || 'dificil' || 'hard' => AppColors.red,
      _ => AppColors.accent,
    };
  }
}
