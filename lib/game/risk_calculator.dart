import '../models/component_option.dart';
import '../models/mission_variable.dart';
import '../models/team_specialty.dart';
import '../utils/constants.dart';

class RiskCalculator {
  static double estimateMissionRisk({
    required List<MissionVariable> variables,
    required List<ComponentOption> components,
    required List<TeamSpecialty> team,
    required int completedTests,
    int complexityLevel = 1,
  }) {
    if (variables.isEmpty) {
      return 0.6;
    }

    double variablePenalty = 0;
    for (final MissionVariable variable in variables) {
      if (variable.value < AppConstants.planningIdealMin) {
        variablePenalty += (AppConstants.planningIdealMin - variable.value) / 100;
      } else if (variable.value > AppConstants.planningIdealMax) {
        variablePenalty += (variable.value - AppConstants.planningIdealMax) / 120;
      }
    }

    final double teamPenalty = team.fold<double>(0, (double sum, TeamSpecialty t) {
      if (t.assigned >= t.recommended) {
        return sum;
      }
      return sum + ((t.recommended - t.assigned) / t.recommended);
    });

    final double componentReliability = components.isEmpty
        ? 0.5
        : components.fold<double>(0, (double sum, ComponentOption c) => sum + c.reliabilityImpact) /
            components.length;

    final double testReduction = (completedTests * 0.04).clamp(0, 0.2);

    final double complexityPenalty = (complexityLevel - 1).clamp(0, 6) * 0.04;

    final double rawRisk = 0.25 + variablePenalty * 0.4 + teamPenalty * 0.25 +
        (1 - componentReliability) * 0.35 - testReduction;

    return (rawRisk + complexityPenalty).clamp(0.05, 0.95);
  }
}
