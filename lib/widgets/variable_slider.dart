import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class VariableSlider extends StatelessWidget {
  const VariableSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.min = 0,
    this.max = 100,
    this.idealMin,
    this.idealMax,
    this.accentColor,
    this.showDebugIdealRanges = false,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final double? idealMin;
  final double? idealMax;
  final Color? accentColor;
  final bool showDebugIdealRanges;

  @override
  Widget build(BuildContext context) {
    final Color color = accentColor ?? AppColors.accent;
    final bool hasIdeal = idealMin != null && idealMax != null;
    final bool inIdeal = hasIdeal && value >= idealMin! && value <= idealMax!;
    final double nearMargin = hasIdeal ? ((idealMax! - idealMin!) * 0.18).clamp(2.0, 10.0) : 0;
    final bool nearIdeal = hasIdeal && !inIdeal && value >= (idealMin! - nearMargin) && value <= (idealMax! + nearMargin);
    final Color activeColor = !hasIdeal
      ? color
      : inIdeal
        ? AppColors.green
        : nearIdeal
          ? AppColors.yellow
          : AppColors.red;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.panelLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: AppDecorations.statusBadge(activeColor),
                child: Text(
                  value.round().toString(),
                  style: TextStyle(
                    color: activeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          if (showDebugIdealRanges && hasIdeal)
            _idealRangeTrack(
              min: min,
              max: max,
              idealMin: idealMin!,
              idealMax: idealMax!,
              activeColor: activeColor,
            ),
          if (showDebugIdealRanges && hasIdeal) const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeColor,
              inactiveTrackColor: AppColors.panelBorder,
              thumbColor: activeColor,
              overlayColor: activeColor.withOpacity(0.2),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(min: min, max: max, value: value, onChanged: onChanged),
          ),
          if (hasIdeal)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                'Faixa ideal: ${idealMin!.round()} – ${idealMax!.round()} | Atual: ${value.round()}',
                style: TextStyle(color: activeColor.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _idealRangeTrack({
    required double min,
    required double max,
    required double idealMin,
    required double idealMax,
    required Color activeColor,
  }) {
    final double span = (max - min).abs() < 0.001 ? 1 : (max - min);
    final double start = ((idealMin - min) / span).clamp(0.0, 1.0);
    final double end = ((idealMax - min) / span).clamp(0.0, 1.0);

    return Column(
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double totalWidth = constraints.maxWidth;
            final double left = totalWidth * start;
            final double width = (totalWidth * (end - start)).clamp(2.0, totalWidth);

            return Stack(
              children: <Widget>[
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.panelBorder,
                    borderRadius: BorderRadius.circular(AppRadius.circle),
                  ),
                ),
                Positioned(
                  left: left,
                  top: 0,
                  child: Container(
                    width: width,
                    height: 6,
                    decoration: BoxDecoration(
                      color: activeColor.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(AppRadius.circle),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('min ${idealMin.round()}', style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
            Text('max ${idealMax.round()}', style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
          ],
        ),
      ],
    );
  }
}
