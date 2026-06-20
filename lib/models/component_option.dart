class ComponentOption {
  const ComponentOption({
    required this.id,
    required this.system,
    required this.name,
    required this.cost,
    required this.massImpact,
    required this.reliabilityImpact,
    required this.riskImpact,
    required this.description,
  });

  final String id;
  final String system;
  final String name;
  final int cost;
  final double massImpact;
  final double reliabilityImpact;
  final double riskImpact;
  final String description;

  // Backward compatibility aliases.
  bool get isDefault => false;
  int get quality => (reliabilityImpact * 100).round().clamp(0, 100);
  String get categoryLabel {
    return system;
  }
}
