/// Opção de teste pré-lançamento (simulação, bancada, ensaio completo, etc.)
class TestOption {
  const TestOption({
    required this.id,
    required this.name,
    required this.cost,
    required this.duration,
    required this.affectedVariables,
    required this.possibleFindings,
    required this.uncertaintyReduction,
    required this.riskReduction,
  });

  final String id;
  final String name;
  final int cost;
  final int duration;
  final List<String> affectedVariables;
  final List<String> possibleFindings;
  final double uncertaintyReduction;
  final double riskReduction;

  // Backward compatibility aliases.
  String get label => name;
  String get description => possibleFindings.join(' | ');
  int get successBonus => ((uncertaintyReduction + riskReduction) * 50).round();
  String get durationLabel => '$duration min';
}
