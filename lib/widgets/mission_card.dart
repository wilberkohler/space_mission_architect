import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MissionCard extends StatelessWidget {
  const MissionCard({
    required this.name,
    required this.description,
    required this.status,
    super.key,
    this.onPlan,
  });

  final String name;
  final String description;
  final String status;
  final VoidCallback? onPlan;

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = _statusStyle(status);
    return Container(
      decoration: AppDecorations.glassPanel(accent: color),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: AppDecorations.statusBadge(color),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),
            if (onPlan != null) ...<Widget>[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.withOpacity(0.12),
                    foregroundColor: color,
                    side: BorderSide(color: color.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'PLANEJAR MISSÃO',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  (Color, IconData) _statusStyle(String s) {
    return switch (s.toLowerCase()) {
      'disponível' || 'available' => (AppColors.accent, Icons.rocket_launch_outlined),
      'sucesso' || 'success' => (AppColors.green, Icons.check_circle_outline),
      'em andamento' || 'inprogress' => (AppColors.orange, Icons.play_circle_outline),
      'falha' || 'failure' => (AppColors.red, Icons.cancel_outlined),
      _ => (AppColors.locked, Icons.lock_outline),
    };
  }
}
