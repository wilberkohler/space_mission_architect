import 'mission_phase.dart';

enum MissionStatus { available, locked, success, partialSuccess, failure, inProgress }

class Mission {
  const Mission({
    required this.id,
    required this.name,
    required this.historicalReference,
    required this.year,
    required this.era,
    required this.type,
    required this.difficulty,
    required this.recommendedBudget,
    this.minimumBudget = 0,
    this.maximumBudget = 0,
    this.budgetReward = 0,
    this.operationalCostPerPhase = 0,
    this.requiredCareerLevel = 1,
    this.complexityLevel = 1,
    required this.requiredMissions,
    required this.variables,
    required this.mainRisks,
    required this.status,
    this.phases = const <MissionPhase>[],
    this.historicalHighlights = const <String>[],
  });

  final String id;
  final String name;
  final String historicalReference;
  final int year;
  final String era;
  final String type;
  final int difficulty;
  final int recommendedBudget;
  final int minimumBudget;
  final int maximumBudget;
  final int budgetReward;
  final int operationalCostPerPhase;
  final int requiredCareerLevel;
  final int complexityLevel;
  final List<String> requiredMissions;
  final List<String> variables;
  final List<String> mainRisks;
  final MissionStatus status;
  final List<MissionPhase> phases;
  final List<String> historicalHighlights;

  bool get unlocked => status != MissionStatus.locked;

  // Backward compatibility aliases.
  String get description => historicalReference;
  int get cost => recommendedBudget;
  int get requiredReputation => (difficulty * 10).clamp(0, 100);
  List<String> get unlockRequires => requiredMissions;

  Mission copyWith({
    MissionStatus? status,
    List<MissionPhase>? phases,
    int? minimumBudget,
    int? maximumBudget,
    int? budgetReward,
    int? operationalCostPerPhase,
    int? requiredCareerLevel,
    int? complexityLevel,
  }) {
    return Mission(
      id: id,
      name: name,
      historicalReference: historicalReference,
      year: year,
      era: era,
      type: type,
      difficulty: difficulty,
      recommendedBudget: recommendedBudget,
      minimumBudget: minimumBudget ?? this.minimumBudget,
      maximumBudget: maximumBudget ?? this.maximumBudget,
      budgetReward: budgetReward ?? this.budgetReward,
      operationalCostPerPhase: operationalCostPerPhase ?? this.operationalCostPerPhase,
      requiredCareerLevel: requiredCareerLevel ?? this.requiredCareerLevel,
      complexityLevel: complexityLevel ?? this.complexityLevel,
      requiredMissions: requiredMissions,
      variables: variables,
      mainRisks: mainRisks,
      status: status ?? this.status,
      phases: phases ?? this.phases,
      historicalHighlights: historicalHighlights,
    );
  }
}
