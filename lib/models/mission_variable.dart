/// Slider variável de missão (propulsão, massa, estabilidade, comunicação, etc.)
class MissionVariable {
  const MissionVariable({
    required this.id,
    required this.name,
    required this.value,
    required this.min,
    required this.max,
    required this.estimatedIdealMin,
    required this.estimatedIdealMax,
    required this.confidence,
    required this.weight,
  });

  final String id;
  final String name;
  final double value;
  final double min;
  final double max;
  final double estimatedIdealMin;
  final double estimatedIdealMax;
  final double confidence;
  final double weight;

  // Backward compatibility aliases.
  String get label => name;
  double get minValue => min;
  double get maxValue => max;
  double get defaultValue => value;
  String get unit => '%';
  bool get impactsSuccess => true;

  @override
  String toString() => '$name: $value$unit';
}
