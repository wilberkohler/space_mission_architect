import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MissionLegend extends StatelessWidget {
  const MissionLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: const <Widget>[
          _LegendItem(label: 'Disponivel', color: AppColors.available),
          _LegendItem(label: 'Sucesso', color: AppColors.success),
          _LegendItem(label: 'Sucesso parcial', color: AppColors.yellow),
          _LegendItem(label: 'Falha', color: AppColors.red),
          _LegendItem(label: 'Bloqueada', color: AppColors.locked),
          _LegendItem(label: 'Em andamento', color: AppColors.accent),
          _LegendLineItem(label: 'Dependencia principal', dashed: false),
          _LegendLineItem(label: 'Ramificacao futura', dashed: true),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _LegendLineItem extends StatelessWidget {
  const _LegendLineItem({required this.label, required this.dashed});

  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 24,
          height: 10,
          child: CustomPaint(
            painter: _LegendLinePainter(dashed: dashed),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _LegendLinePainter extends CustomPainter {
  _LegendLinePainter({required this.dashed});

  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = dashed ? AppColors.textMuted : AppColors.panelBorder
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    if (!dashed) {
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), p);
      return;
    }

    double x = 0;
    const double dash = 5;
    const double gap = 3;
    while (x < size.width) {
      final double end = (x + dash).clamp(0, size.width);
      canvas.drawLine(Offset(x, size.height / 2), Offset(end, size.height / 2), p);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _LegendLinePainter oldDelegate) {
    return oldDelegate.dashed != dashed;
  }
}
