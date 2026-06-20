import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'space_panel.dart';
import 'status_pill.dart';

class PrimaryObjectiveCard extends StatelessWidget {
  const PrimaryObjectiveCard({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    super.key,
    this.badgeLabel,
    this.icon = Icons.flag_outlined,
    this.accentColor = AppColors.accent,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;
  final String? badgeLabel;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SpacePanel(
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: AppDecorations.statusBadge(accentColor),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'OBJETIVO PRINCIPAL',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeLabel != null) StatusPill(label: badgeLabel!, color: accentColor),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.rocket_launch_outlined, size: 17),
              label: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
