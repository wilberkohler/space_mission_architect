class RivalAgencyState {
  const RivalAgencyState({
    required this.agencyId,
    required this.currentEra,
    required this.progress,
    required this.lastMission,
    required this.reputationScore,
    required this.likelyNextMission,
    required this.milestonesAchieved,
  });

  final String agencyId;
  final String currentEra;
  final int progress;
  final String lastMission;
  final int reputationScore;
  final String likelyNextMission;
  final List<String> milestonesAchieved;

  // Backward compatibility aliases.
  String get id => agencyId;
  String get name => agencyId.toUpperCase();
  String get country => '-';
  int get score => reputationScore;
  String get headline => '$agencyId concluiu $lastMission';
  String get milestone => milestonesAchieved.isEmpty ? 'Sem marcos' : milestonesAchieved.first;
  int get completedMissions => progress;
  int get budget => 0;
  String get trend => 'stable';
}
