import '../models/rival_agency_state.dart';

class RivalSimulator {
  static List<RivalAgencyState> advanceRivals(List<RivalAgencyState> rivals) {
    return rivals.map((RivalAgencyState rival) {
      final int nextProgress = (rival.progress + 1).clamp(0, 100);
      final int nextReputation = (rival.reputationScore + (nextProgress % 2 == 0 ? 1 : 0)).clamp(0, 100);
      return RivalAgencyState(
        agencyId: rival.agencyId,
        currentEra: rival.currentEra,
        progress: nextProgress,
        lastMission: rival.lastMission,
        reputationScore: nextReputation,
        likelyNextMission: rival.likelyNextMission,
        milestonesAchieved: rival.milestonesAchieved,
      );
    }).toList();
  }
}
