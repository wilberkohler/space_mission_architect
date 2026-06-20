import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RoundActionButton extends StatelessWidget {
  const RoundActionButton({
    required this.label,
    required this.icon,
    super.key,
    this.onPressed,
    this.color,
    this.size = 76,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.accent;
    final bool disabled = onPressed == null;
    final Color effectiveColor = disabled ? c.withOpacity(0.35) : c;
    return GestureDetector(
      onTap: onPressed,
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    effectiveColor.withOpacity(0.28),
                    effectiveColor.withOpacity(0.04)
                  ],
                ),
                border: Border.all(color: effectiveColor, width: 2),
                boxShadow: disabled
                    ? null
                    : <BoxShadow>[
                        BoxShadow(
                            color: c.withOpacity(0.4),
                            blurRadius: 22,
                            spreadRadius: 2),
                        BoxShadow(
                            color: c.withOpacity(0.15),
                            blurRadius: 42,
                            spreadRadius: 5),
                      ],
              ),
              child: Icon(icon, color: effectiveColor, size: size * 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: effectiveColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
