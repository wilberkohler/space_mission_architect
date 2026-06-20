import '../models/component_option.dart';
import '../models/mission.dart';
import '../models/mission_result.dart';
import '../models/mission_variable.dart';
import '../models/team_specialty.dart';
import '../models/test_option.dart';
import 'budget_calculator.dart';
import 'risk_calculator.dart';

class TestRunResult {
  const TestRunResult({
    required this.updatedRisk,
    required this.budgetCost,
    required this.finding,
  });

  final double updatedRisk;
  final int budgetCost;
  final String finding;
}

class MockGameEngine {
  static List<MissionVariable> variablesForComplexity({
    required int complexity,
    required List<MissionVariable> source,
  }) {
    final Map<int, List<String>> map = <int, List<String>>{
      1: <String>['propulsion', 'mass', 'stability'],
      2: <String>['propulsion', 'mass', 'stability', 'communication', 'guidance'],
      3: <String>['propulsion', 'mass', 'communication', 'safety', 'thermal_control', 'bio_support'],
      4: <String>['propulsion', 'mass', 'guidance', 'communication', 'safety', 'life_support', 'reentry'],
      5: <String>['propulsion', 'guidance', 'communication', 'energy', 'thermal_control', 'safety'],
      6: <String>['propulsion', 'guidance', 'communication', 'energy', 'life_support', 'docking', 'safety'],
    };
    final List<String> allowed = map[complexity] ?? map[6]!;
    return source.where((MissionVariable v) => allowed.contains(v.id)).toList();
  }

  static List<ComponentOption> componentsForComplexity({
    required int complexity,
    required List<ComponentOption> source,
  }) {
    final Map<int, List<String>> map = <int, List<String>>{
      1: <String>['propulsion_balanced', 'structure_basic'],
      2: <String>['propulsion_balanced', 'structure_basic', 'comm_balanced', 'payload_simple'],
      3: <String>['propulsion_advanced', 'comm_balanced', 'bio_safety_basic', 'thermal_basic'],
      4: <String>['propulsion_advanced', 'comm_advanced', 'life_support_basic', 'reentry_shield'],
      5: <String>['propulsion_advanced', 'comm_long_range', 'energy_long_range', 'reentry_shield'],
      6: <String>['propulsion_advanced', 'comm_long_range', 'energy_long_range', 'docking_module', 'life_support_extended', 'logistics_module'],
    };
    final List<String> allowed = map[complexity] ?? map[6]!;
    return source.where((ComponentOption c) => allowed.contains(c.id)).toList();
  }

  static List<TestOption> testsForComplexity({
    required int complexity,
    required List<TestOption> source,
  }) {
    final Map<int, List<String>> map = <int, List<String>>{
      1: <String>['engine_test', 'stability_test'],
      2: <String>['engine_test', 'structural_test', 'comm_test', 'trajectory_sim'],
      3: <String>['engine_test', 'structural_test', 'comm_test', 'safety_test', 'thermal_test'],
      4: <String>['engine_test', 'structural_test', 'comm_test', 'trajectory_sim', 'safety_test', 'integrated_test'],
      5: <String>['engine_test', 'comm_test', 'trajectory_sim', 'thermal_test', 'integrated_test'],
      6: <String>['engine_test', 'comm_test', 'trajectory_sim', 'docking_test', 'integrated_test'],
    };
    final List<String> allowed = map[complexity] ?? map[6]!;
    return source.where((TestOption t) => allowed.contains(t.id)).toList();
  }

  static List<TeamSpecialty> teamForComplexity({
    required int complexity,
    required List<TeamSpecialty> source,
  }) {
    final Map<int, List<String>> map = <int, List<String>>{
      1: <String>['technical_general'],
      2: <String>['technical_general', 'communications'],
      3: <String>['technical_general', 'communications', 'safety_ops', 'bio_support'],
      4: <String>['propulsion', 'structures', 'guidance', 'communications', 'safety_ops', 'bio_support'],
      5: <String>['propulsion', 'structures', 'guidance', 'communications', 'safety_ops', 'bio_support'],
      6: <String>['propulsion', 'structures', 'guidance', 'communications', 'safety_ops', 'bio_support', 'docking'],
    };
    final List<String> allowed = map[complexity] ?? map[6]!;
    return source.where((TeamSpecialty t) => allowed.contains(t.id)).toList();
  }

  static double estimateMissionRisk({
    required List<MissionVariable> variables,
    required List<ComponentOption> components,
    required List<TeamSpecialty> team,
    required int completedTests,
    int complexityLevel = 1,
  }) {
    return RiskCalculator.estimateMissionRisk(
      variables: variables,
      components: components,
      team: team,
      completedTests: completedTests,
      complexityLevel: complexityLevel,
    );
  }

  static TestRunResult runTest({
    required TestOption test,
    required double currentRisk,
  }) {
    final double reduction = (test.uncertaintyReduction + test.riskReduction) / 2;
    final double updatedRisk = (currentRisk - reduction).clamp(0.03, 0.95);
    final String finding = test.possibleFindings.isEmpty
        ? 'Nenhuma anomalia relevante encontrada.'
        : test.possibleFindings.first;
    return TestRunResult(updatedRisk: updatedRisk, budgetCost: test.cost, finding: finding);
  }

  static int launchMission({
    required Mission mission,
    required List<ComponentOption> selectedComponents,
    required List<TeamSpecialty> team,
  }) {
    return BudgetCalculator.estimateMissionBudget(
      mission: mission,
      components: selectedComponents,
      team: team,
    );
  }

  static int advanceMissionPhase({
    required int phaseOrder,
    required double phaseRiskMultiplier,
    Mission? mission,
  }) {
    if (mission != null && mission.operationalCostPerPhase > 0) {
      return BudgetCalculator.scaledOperationalCost(mission, phaseOrder: phaseOrder);
    }
    return BudgetCalculator.phaseBudgetConsumption(
      phaseOrder: phaseOrder,
      phaseRiskMultiplier: phaseRiskMultiplier,
    );
  }

  static MissionResult abortMission() {
    return MissionResult(
      resultType: MissionOutcome.aborted,
      summary: 'Missao abortada',
      completedPhases: 0,
      failedPhase: 'Abortar',
      causes: <String>['Abortada por decisao do controle de voo'],
      budgetImpact: 120,
      reputationImpact: <String, int>{'public': -3, 'scientific': -1, 'technical': -2},
      unlockedMissions: <String>[],
      lessonsLearned: <String>['Reavaliar parametros antes do lancamento'],
    );
  }

  static MissionResult terminateFlight() {
    return MissionResult(
      resultType: MissionOutcome.failure,
      summary: 'Falha controlada',
      completedPhases: 0,
      failedPhase: 'Termino de voo',
      causes: <String>['Evento critico mitigado com termino de voo'],
      budgetImpact: 150,
      reputationImpact: <String, int>{'public': -2, 'scientific': 0, 'technical': -1},
      unlockedMissions: <String>[],
      lessonsLearned: <String>['Melhorar redundancia e criterios de aborto'],
    );
  }

  static MissionResult generateMissionReport({
    required bool success,
    required int completedPhases,
    required int budgetImpact,
  }) {
    return MissionResult(
      resultType: success ? MissionOutcome.fullSuccess : MissionOutcome.partialSuccess,
      summary: success ? 'Sucesso completo' : 'Sucesso parcial',
      completedPhases: completedPhases,
      failedPhase: success ? '-' : 'Operacao inicial',
      causes: success
          ? <String>['Parametros dentro da janela ideal']
          : <String>['Uma anomalia limitou desempenho final'],
      budgetImpact: budgetImpact,
      reputationImpact: success
          ? <String, int>{'public': 6, 'scientific': 8, 'technical': 5}
          : <String, int>{'public': 2, 'scientific': 4, 'technical': 1},
      unlockedMissions: success ? <String>['first_satellite'] : <String>[],
      lessonsLearned: <String>[
        'Ajustar curva de empuxo na fase de subida',
        'Expandir testes integrados antes do lancamento',
      ],
      sciencePoints: success ? 280 : 140,
      experimentsCompleted: success ? 4 : 2,
      discoveries: success ? 1 : 0,
    );
  }

  static List<Mission> unlockNextMissions({
    required List<Mission> missions,
    required String completedMissionId,
    required bool success,
    required int careerLevel,
    required int availableBudget,
  }) {
    if (!success) {
      return missions;
    }

    return missions.map((Mission mission) {
      final bool dependenciesOk = mission.requiredMissions.every(
        (String req) => req == completedMissionId ||
            missions.any((Mission m) => m.id == req && (m.status == MissionStatus.success || m.status == MissionStatus.partialSuccess)),
      );
      final bool careerOk = careerLevel >= mission.requiredCareerLevel;
      final bool budgetOk = availableBudget >= mission.minimumBudget;
      if (mission.status == MissionStatus.locked && dependenciesOk && careerOk && budgetOk) {
        return mission.copyWith(status: MissionStatus.available);
      }
      return mission;
    }).toList();
  }

  static int calculateExperienceGain({
    required Mission mission,
    required MissionResult result,
    required int testsCompleted,
    required bool underBudget,
    required bool historicalMilestone,
  }) {
    int xp = testsCompleted * 5;

    if (result.resultType == MissionOutcome.fullSuccess) {
      xp += 45 + (mission.complexityLevel * 12);
    } else if (result.resultType == MissionOutcome.partialSuccess) {
      xp += 24 + (mission.complexityLevel * 8);
    } else if (result.resultType == MissionOutcome.failure) {
      xp += 16 + (mission.complexityLevel * 5);
    } else {
      xp += 20 + (mission.complexityLevel * 4);
    }

    if (underBudget) {
      xp += 15;
    }
    if (historicalMilestone) {
      xp += 25;
    }

    return xp;
  }
}
