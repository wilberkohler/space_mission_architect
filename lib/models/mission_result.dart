enum MissionOutcome { fullSuccess, partialSuccess, failure, aborted }

class MissionResult {
  const MissionResult({
    required this.resultType,
    required this.summary,
    required this.completedPhases,
    required this.failedPhase,
    required this.causes,
    required this.budgetImpact,
    required this.reputationImpact,
    required this.unlockedMissions,
    required this.lessonsLearned,
    this.sciencePoints = 0,
    this.experimentsCompleted = 0,
    this.discoveries = 0,
  });

  final MissionOutcome resultType;
  final String summary;
  final int completedPhases;
  final String failedPhase;
  final List<String> causes;
  final int budgetImpact;
  final Map<String, int> reputationImpact;
  final List<String> unlockedMissions;
  final List<String> lessonsLearned;

  final int sciencePoints;
  final int experimentsCompleted;
  final int discoveries;

  // Backward compatibility aliases.
  MissionOutcome get outcome => resultType;
  String get outcomeLabel => summary;
  String get outcomeDetail => causes.join(', ');
  int get budgetTotal => budgetImpact < 0 ? -budgetImpact : budgetImpact;
  int get budgetSpent => budgetImpact.abs();
  int get budgetSaved => 0;

  int get reputationPublicDelta => reputationImpact['public'] ?? 0;
  int get reputationScientificDelta => reputationImpact['scientific'] ?? 0;
  int get reputationIndustrialDelta => reputationImpact['technical'] ?? 0;

  List<String> get unlocks => unlockedMissions;

  bool get isSuccess =>
      resultType == MissionOutcome.fullSuccess ||
      resultType == MissionOutcome.partialSuccess;
}
