import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MissionNode extends StatelessWidget {
  const MissionNode({
    required this.title,
    required this.status,
    required this.onTap,
    super.key,
    this.icon = Icons.rocket_launch_outlined,
    this.subtitle,
    this.lockReasons = const <String>[],
  });

  final String title;
  final String status;
  final VoidCallback? onTap;
  final IconData icon;
  final String? subtitle;
  final List<String> lockReasons;

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = _statusStyle(status);
    final bool blocked = lockReasons.isNotEmpty;
    return GestureDetector(
      onTap: blocked ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: blocked ? AppColors.panelLight : AppColors.panel,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withOpacity(0.35), width: 1.5),
          boxShadow: <BoxShadow>[
            BoxShadow(color: color.withOpacity(0.07), blurRadius: 14, spreadRadius: 0),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.12),
                border: Border.all(color: color.withOpacity(0.45), width: 1.5),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: AppDecorations.statusBadge(color),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  if (blocked) ...<Widget>[
                    const SizedBox(height: 6),
                    ...lockReasons.map(
                      (String reason) => KeyedSubtree(
                        key: ValueKey<String>('lock-$title-$reason'),
                        child: Text(
                          '• $reason',
                          style: const TextStyle(color: AppColors.red, fontSize: 10, height: 1.25),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5), size: 18),
          ],
        ),
      ),
    );
  }

  (Color, String) _statusStyle(String s) {
    return switch (s.toLowerCase()) {
      'disponível' || 'available' => (AppColors.accent, 'DISPONÍVEL'),
      'sucesso' || 'success' => (AppColors.green, 'SUCESSO'),
      'em andamento' || 'inprogress' => (AppColors.orange, 'EM ANDAMENTO'),
      'falha' || 'failure' => (AppColors.red, 'FALHA'),
      _ => (AppColors.locked, 'BLOQUEADA'),
    };
  }
}
