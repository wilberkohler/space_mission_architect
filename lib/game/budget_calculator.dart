import '../models/component_option.dart';
import '../models/agency.dart';
import '../models/mission.dart';
import '../models/team_specialty.dart';
import '../utils/constants.dart';

class CampaignBudgetState {
  const CampaignBudgetState({
    required this.currentBudget,
    required this.currentYear,
    required this.reputationTotal,
    this.lastMissionSuccess = false,
    this.consecutiveSuccesses = 0,
    this.careerInfluenceBonus = 0,
  });

  final int currentBudget;
  final int currentYear;
  final int reputationTotal;
  final bool lastMissionSuccess;
  final int consecutiveSuccesses;
  final double careerInfluenceBonus;
}

class BudgetCalculator {
  static int estimateMissionBudget({
    required Mission mission,
    required List<ComponentOption> components,
    required List<TeamSpecialty> team,
  }) {
    final int componentCost = components.fold<int>(0, (int sum, ComponentOption c) => sum + c.cost);
    final int teamCost = team.fold<int>(0, (int sum, TeamSpecialty t) => sum + (t.assigned * t.costPerMember));
    return mission.recommendedBudget + componentCost + teamCost;
  }

  static int phaseBudgetConsumption({required int phaseOrder, required double phaseRiskMultiplier}) {
    final double spent = AppConstants.phaseBaseBudgetConsumption *
        (1 + (phaseOrder * 0.12)) *
        phaseRiskMultiplier;
    return spent.round();
  }

  static int calculateMissionBudget({
    required Agency agency,
    required Mission mission,
    required CampaignBudgetState campaignState,
  }) {
    final double missionScale = missionCostMultiplier(mission);
    final double agencyScale = (agency.budgetFactor / agency.costFactor).clamp(0.7, 1.6);
    final double reputationScale = 1 + ((campaignState.reputationTotal - 220) / 2200);
    final double streakScale = 1 + (campaignState.consecutiveSuccesses.clamp(0, 4) * 0.03);
    final double successMomentum = campaignState.lastMissionSuccess ? 1.02 : 0.98;
    final double careerScale = 1 + campaignState.careerInfluenceBonus.clamp(0, 0.3);

    final int target = (mission.recommendedBudget *
            missionScale *
            agencyScale *
            reputationScale *
            streakScale *
            successMomentum *
            careerScale)
        .round();

    final int boundedTarget = target.clamp(mission.minimumBudget, mission.maximumBudget);
    return boundedTarget.clamp(0, campaignState.currentBudget);
  }

  static double missionCostMultiplier(Mission mission) {
    return 1 + ((mission.complexityLevel - 1) * 0.14) + ((mission.difficulty - 1) * 0.06);
  }

  static int scaledOperationalCost(Mission mission, {required int phaseOrder}) {
    final double growth = 1 + (phaseOrder * 0.1);
    return (mission.operationalCostPerPhase * growth * missionCostMultiplier(mission)).round();
  }
}
