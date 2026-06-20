import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MissionTrajectoryView extends StatelessWidget {
  const MissionTrajectoryView({
    required this.progress,
    super.key,
    this.phaseName,
  });

  final double progress;
  final String? phaseName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.panelBorder, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: <Widget>[
            CustomPaint(
              size: const Size(double.infinity, 220),
              painter: _StarfieldPainter(),
            ),
            CustomPaint(
              size: const Size(double.infinity, 220),
              painter: _TrajectoryPainter(progress.clamp(0.0, 1.0)),
            ),
            if (phaseName != null)
              Positioned(
                bottom: 12,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: AppDecorations.statusBadge(AppColors.accent),
                  child: Text(
                    phaseName!,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 12,
              right: 14,
              child: Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  const _StarfieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint();
    final Random rng = Random(42);
    for (int i = 0; i < 70; i++) {
      final double x = rng.nextDouble() * size.width;
      final double y = rng.nextDouble() * size.height;
      final double r = rng.nextDouble() * 1.2 + 0.2;
      p.color = Colors.white.withOpacity(rng.nextDouble() * 0.35 + 0.05);
      canvas.drawCircle(Offset(x, y), r, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrajectoryPainter extends CustomPainter {
  const _TrajectoryPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(32, 24, size.width - 64, size.height - 52);

    final Paint basePaint = Paint()
      ..color = AppColors.panelBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        colors: <Color>[AppColors.accent, AppColors.green],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const double startAngle = pi;
    const double sweepFull = pi * 0.85;

    canvas.drawArc(rect, startAngle, sweepFull, false, basePaint);
    if (progress > 0) {
      canvas.drawArc(rect, startAngle, sweepFull * progress, false, fillPaint);
    }

    // Ship dot
    final double shipAngle = startAngle + sweepFull * progress;
    final Offset center = rect.center;
    final double rx = rect.width / 2;
    final double ry = rect.height / 2;
    final Offset shipPos = Offset(
      center.dx + cos(shipAngle) * rx,
      center.dy + sin(shipAngle) * ry,
    );

    canvas.drawCircle(
      shipPos,
      10,
      Paint()
        ..color = AppColors.accent.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(shipPos, 5, Paint()..color = AppColors.accent);

    // Origin planet
    final Offset origin = Offset(
      center.dx + cos(startAngle) * rx,
      center.dy + sin(startAngle) * ry,
    );
    canvas.drawCircle(origin, 9, Paint()..color = AppColors.green.withOpacity(0.25));
    canvas.drawCircle(origin, 5, Paint()..color = AppColors.green);
  }

  @override
  bool shouldRepaint(covariant _TrajectoryPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
