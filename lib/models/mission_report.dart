class MissionReport {
  const MissionReport({
    required this.success,
    required this.resultLabel,
    required this.budgetSpent,
    required this.reputationDelta,
    required this.unlocks,
    required this.lessonsLearned,
  });

  final bool success;
  final String resultLabel;
  final int budgetSpent;
  final int reputationDelta;
  final List<String> unlocks;
  final List<String> lessonsLearned;
}
