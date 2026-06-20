class MissionPhase {
  const MissionPhase({
    required this.id,
    required this.name,
    required this.order,
    required this.targetAltitude,
    required this.targetVelocity,
    required this.durationSeconds,
    this.riskFactors = const <String>[],
  });

  final String id;
  final String name;
  final int order;
  final double targetAltitude;
  final double targetVelocity;
  final int durationSeconds;
  final List<String> riskFactors;

  // Backward compatibility aliases.
  int get durationSec => durationSeconds;
  double get targetAltitudeKm => targetAltitude;
  double get targetVelocityKmh => targetVelocity;
  double get fuelConsumptionRate => 1.0;
  int get riskLevel => riskFactors.isEmpty ? 1 : 2;
}
