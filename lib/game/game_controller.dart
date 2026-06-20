import 'dart:math';

import 'package:flutter/foundation.dart';

import '../audio/audio_manager.dart';
import '../audio/sound_effect.dart';
import '../data/mock_careers.dart';
import '../data/mock_data.dart';
import '../models/agency.dart';
import '../models/component_option.dart';
import '../models/mission.dart';
import '../models/mission_event.dart';
import '../models/mission_report.dart';
import '../models/mission_result.dart';
import '../models/mission_variable.dart';
import '../models/player_career.dart';
import '../models/reputation.dart';
import '../models/rival.dart';
import '../models/rival_agency_state.dart';
import '../models/team_specialty.dart';
import '../models/test_option.dart';
import 'budget_calculator.dart';
import 'mock_game_engine.dart';

class GameController extends ChangeNotifier {
  GameController()
      : agencies = MockData.agencies,
        missions = List<Mission>.from(MockData.missions),
        missionVariables = MockData.missionVariables,
        components = MockData.components,
        team = List<TeamSpecialty>.from(MockData.defaultTeam),
        testOptions = MockData.testOptions,
        rivalStates = MockData.rivals,
        playerCareer = mockCareers.first {
    for (final MissionVariable variable in missionVariables) {
      variableValues[variable.id] = variable.defaultValue;
    }

    for (final ComponentOption component in components) {
      selectedComponents[component.name] = component.isDefault;
    }
  }

  final List<Agency> agencies;
  List<Mission> missions;
  final List<MissionVariable> missionVariables;
  final List<ComponentOption> components;
  List<TeamSpecialty> team;
  final List<TestOption> testOptions;
  final List<RivalAgencyState> rivalStates;

  final Map<String, double> variableValues = <String, double>{};
  String selectedTestId = 'engine_test';

  // Legacy shape retained for current screen compatibility.
  final Map<String, bool> selectedComponents = <String, bool>{};

  Agency? selectedAgency;
  Mission? selectedMission;
  Reputation currentReputation =
      const Reputation(political: 0, technical: 0, scientific: 0, public: 0, safety: 0);
  int budgetM = 0;
  int missionBudgetCap = 0;

  PlayerCareer playerCareer;
  bool careerLeveledUp = false;
  int totalExperience = 0;
  int completedTestsCount = 0;
  int consecutiveSuccesses = 0;
  bool lastMissionSuccess = false;

  MissionResult? latestResult;
  MissionReport? latestReport;
  final List<MissionEvent> latestEvents = <MissionEvent>[];

  // Legacy slider aliases for old planning screen.
  double payloadQuality = 70;
  double crewTraining = 65;
  double fuelReserve = 72;

  List<Rival> get rivals => rivalStates
      .map(
        (RivalAgencyState r) => Rival(
          name: r.name,
          score: r.score,
          headline: r.headline,
          milestone: r.milestone,
        ),
      )
      .toList();

  PlayerCareer? get nextCareer {
    if (playerCareer.isMaxLevel) {
      return null;
    }
    return mockCareers.where((PlayerCareer c) => c.level == playerCareer.level + 1).firstOrNull;
  }

  CampaignBudgetState get _campaignBudgetState => CampaignBudgetState(
        currentBudget: budgetM,
        currentYear: selectedMission?.year ?? 1960,
        reputationTotal: currentReputation.total,
        lastMissionSuccess: lastMissionSuccess,
        consecutiveSuccesses: consecutiveSuccesses,
        careerInfluenceBonus: playerCareer.salaryOrInfluenceBonus,
      );

  List<MissionVariable> get availableMissionVariables {
    final Mission? mission = selectedMission;
    if (mission == null) {
      return missionVariables;
    }
    return MockGameEngine.variablesForComplexity(
      complexity: mission.complexityLevel,
      source: missionVariables,
    );
  }

  List<ComponentOption> get availableComponents {
    final Mission? mission = selectedMission;
    if (mission == null) {
      return components;
    }
    return MockGameEngine.componentsForComplexity(
      complexity: mission.complexityLevel,
      source: components,
    );
  }

  List<TestOption> get availableTests {
    final Mission? mission = selectedMission;
    if (mission == null) {
      return testOptions;
    }
    return MockGameEngine.testsForComplexity(
      complexity: mission.complexityLevel,
      source: testOptions,
    );
  }

  List<TeamSpecialty> get availableTeam {
    final Mission? mission = selectedMission;
    if (mission == null) {
      return team;
    }
    return MockGameEngine.teamForComplexity(
      complexity: mission.complexityLevel,
      source: team,
    );
  }

  void selectAgency(Agency agency) {
    selectedAgency = agency;
    budgetM = agency.baseBudget;
    currentReputation = agency.reputation;
    missionBudgetCap = 0;
    notifyListeners();
  }

  void selectMission(Mission mission) {
    selectedMission = mission;
    missionBudgetCap = BudgetCalculator.calculateMissionBudget(
      agency: selectedAgency ?? agencies.first,
      mission: mission,
      campaignState: _campaignBudgetState,
    );

    final List<TestOption> tests = availableTests;
    if (tests.isNotEmpty && !tests.any((TestOption t) => t.id == selectedTestId)) {
      selectedTestId = tests.first.id;
    }

    _syncLegacySlidersFromVariables();
    notifyListeners();
  }

  void selectTest(String testId) {
    selectedTestId = testId;
    notifyListeners();
  }

  void setMissionVariable(String id, double value) {
    variableValues[id] = value;
    _syncLegacySlidersFromVariables();
    notifyListeners();
  }

  double variableValue(String id, {double fallback = 0}) {
    return variableValues[id] ?? fallback;
  }

  void adjustTeamAssignment(String role, int assigned) {
    final int index = team.indexWhere((TeamSpecialty t) => t.role == role);
    if (index == -1) {
      return;
    }
    final TeamSpecialty old = team[index];
    team[index] = old.copyWith(assigned: assigned.clamp(0, old.total));
    notifyListeners();
  }

  void toggleComponentOption(String componentId, bool enabled) {
    final ComponentOption? option =
        components.where((ComponentOption c) => c.id == componentId).firstOrNull;
    if (option == null) {
      return;
    }
    selectedComponents[option.name] = enabled;
    notifyListeners();
  }

  void setSliderValues({
    double? payload,
    double? training,
    double? reserve,
  }) {
    payloadQuality = payload ?? payloadQuality;
    crewTraining = training ?? crewTraining;
    fuelReserve = reserve ?? fuelReserve;
    variableValues['propulsion'] = payloadQuality;
    variableValues['stability'] = crewTraining;
    variableValues['communication'] = fuelReserve;
    notifyListeners();
  }

  void toggleComponent(String component, bool enabled) {
    selectedComponents[component] = enabled;
    notifyListeners();
  }

  List<String> guidanceMessagesForMission(Mission mission) {
    final List<String> msgs = <String>[];
    if (mission.complexityLevel <= 2) {
      msgs.add('Foque em manter variaveis basicas entre 65% e 80%.');
      msgs.add('Priorize testes antes do lancamento para reduzir risco inicial.');
    }
    if (mission.complexityLevel >= 3) {
      msgs.add('Missoes mais complexas exigem cobertura de seguranca e equipe especializada.');
    }
    if (missionBudgetCap < mission.minimumBudget) {
      msgs.add('Seu teto de orcamento atual esta abaixo do minimo recomendado.');
    }
    if (playerCareer.level < mission.requiredCareerLevel) {
      msgs.add('Avance na carreira para liberar este nivel de responsabilidade.');
    }
    return msgs;
  }

  List<String> missionBlockReasons(Mission mission) {
    final List<String> reasons = <String>[];
    final bool prerequisitesComplete = mission.requiredMissions.every(
      (String req) => missions.any(
        (Mission m) => m.id == req && (m.status == MissionStatus.success || m.status == MissionStatus.partialSuccess),
      ),
    );
    if (!prerequisitesComplete) {
      reasons.add('Missao anterior nao concluida.');
    }
    if (budgetM < mission.minimumBudget) {
      reasons.add('Orcamento insuficiente (min ${mission.minimumBudget}M).');
    }
    if (currentReputation.total < mission.requiredReputation) {
      reasons.add('Reputacao insuficiente (${mission.requiredReputation}+).');
    }
    if (playerCareer.level < mission.requiredCareerLevel) {
      reasons.add('Cargo minimo: nivel ${mission.requiredCareerLevel}.');
    }
    return reasons;
  }

  bool canAccessMission(Mission mission) => missionBlockReasons(mission).isEmpty;

  MockTestResult runMockTest() {
    final int quality = payloadQuality.round();
    final int training = crewTraining.round();
    final int reserve = fuelReserve.round();
    final int componentScore = selectedComponents.entries
        .where((MapEntry<String, bool> e) => e.value)
        .where((MapEntry<String, bool> e) => availableComponents.any((ComponentOption c) => c.name == e.key))
        .length *
        8;
    final List<TeamSpecialty> missionTeam = availableTeam;
    final double teamScore = missionTeam.isEmpty
        ? 0
        : missionTeam.fold<double>(0, (double sum, TeamSpecialty t) => sum + t.efficiency) /
            missionTeam.length;
    final int testBonus =
        availableTests.firstWhere((TestOption t) => t.id == selectedTestId, orElse: () => availableTests.first).successBonus;
    final int score =
        (quality + training + reserve + componentScore + (teamScore * 100).round() + testBonus) ~/
            5;

    completedTestsCount += 1;
    gainExperience(5);

    if (score >= 75) {
      return MockTestResult(
        score: score,
        passed: true,
        notes: 'Teste de bancada aprovado. Todos os subsistemas responderam dentro da margem.',
      );
    }

    return MockTestResult(
      score: score,
      passed: false,
      notes:
          'Oscilacao detectada em telemetria. Recomenda-se revisar treinamento e reserva de combustivel.',
    );
  }

  void registerMissionEvent(MissionEvent event) {
    latestEvents.insert(0, event);
    notifyListeners();
  }

  void gainExperience(int xp) {
    if (xp <= 0) {
      return;
    }
    totalExperience += xp;
    int carry = xp;
    PlayerCareer current = playerCareer;
    bool leveled = false;

    while (!current.isMaxLevel && carry > 0) {
      final int remaining = current.experienceToNextLevel - current.experience;
      if (carry >= remaining) {
        carry -= remaining;
        final PlayerCareer? next = mockCareers.where((PlayerCareer c) => c.level == current.level + 1).firstOrNull;
        if (next == null) {
          current = current.copyWith(experience: current.experienceToNextLevel);
          break;
        }
        current = next.copyWith(experience: 0);
        leveled = true;
      } else {
        current = current.copyWith(experience: current.experience + carry);
        carry = 0;
      }
    }

    if (current.isMaxLevel) {
      current = current.copyWith(experience: current.experienceToNextLevel);
    }

    playerCareer = current;
    careerLeveledUp = leveled;
  }

  void buildMissionReport({
    required bool success,
    required bool criticalFailure,
  }) {
    final Mission mission = selectedMission!;
    final Random random = Random();
    final int budgetFactor = random.nextInt(35);
    final int spent = mission.cost + budgetFactor;
    final int reputationDelta = success ? 8 + random.nextInt(7) : -(5 + random.nextInt(6));

    final MissionOutcome outcome = criticalFailure
        ? MissionOutcome.failure
        : success
            ? MissionOutcome.fullSuccess
            : MissionOutcome.aborted;

    latestResult = MissionResult(
      resultType: outcome,
      summary: criticalFailure
          ? 'Falha Critica'
          : success
              ? 'Sucesso Completo'
              : 'Missao Abortada',
      completedPhases: success ? mission.phases.length : (mission.phases.length / 2).round(),
      failedPhase: criticalFailure && mission.phases.isNotEmpty ? mission.phases.last.name : '-',
      causes: success
          ? <String>['Missao nominal com pequena oscilacao de telemetria']
          : <String>['Evento critico em fase de voo'],
      budgetImpact: spent,
      reputationImpact: <String, int>{
        'public': reputationDelta,
        'scientific': success ? 8 : -3,
        'technical': success ? 6 : -2,
      },
      unlockedMissions: <String>[],
      sciencePoints: success ? 320 : 90,
      experimentsCompleted: success ? 5 : 1,
      discoveries: success ? 1 : 0,
      lessonsLearned: success
          ? <String>[
              'Revisar amortecedores de guinada.',
              'Reforcar testes de comunicacao em vacuo.',
            ]
          : <String>[
              'Aumentar redundancia em sensores de navegacao.',
              'Executar simulacao adicional de contingencias.',
            ],
    );

    final int xpGained = MockGameEngine.calculateExperienceGain(
      mission: mission,
      result: latestResult!,
      testsCompleted: completedTestsCount,
      underBudget: spent <= mission.recommendedBudget,
      historicalMilestone: success,
    );
    gainExperience(xpGained);

    latestReport = MissionReport(
      success: success,
      resultLabel: criticalFailure
          ? 'Falha Critica em Fase de Voo'
          : success
              ? 'Missao Concluida com Sucesso'
              : 'Termino Antecipado de Voo',
      budgetSpent: spent,
      reputationDelta: reputationDelta,
      unlocks: success
          ? <String>['Janela de lancamento avancada', 'Laboratorio de propulsao Mk-II']
          : <String>['Checklist de seguranca reforcado'],
      lessonsLearned: success
          ? <String>[
              'Padrao de treinamento da tripulacao foi eficaz.',
              'A reserva de combustivel manteve margem operacional segura.',
            ]
          : <String>[
              'Aumentar redundancia em sensores de navegacao.',
              'Executar simulacao adicional de contingencias.',
            ],
    );

    budgetM = max(0, budgetM - spent + (success ? mission.budgetReward : 0));
    currentReputation = currentReputation.copyWith(
      pub: latestResult!.reputationPublicDelta,
      sci: latestResult!.reputationScientificDelta,
      ind: latestResult!.reputationIndustrialDelta,
    );

    // Mark mission result in tree state.
    final int missionIndex = missions.indexWhere((Mission m) => m.id == mission.id);
    if (missionIndex != -1) {
      missions[missionIndex] = missions[missionIndex].copyWith(
        status: success
            ? MissionStatus.success
            : criticalFailure
                ? MissionStatus.failure
                : MissionStatus.partialSuccess,
      );
    }

    final List<Mission> beforeUnlock = List<Mission>.from(missions);
    missions = MockGameEngine.unlockNextMissions(
      missions: missions,
      completedMissionId: mission.id,
      success: success,
      careerLevel: playerCareer.level,
      availableBudget: budgetM,
    );

    final int unlockedNow = missions.where((Mission m) => m.status == MissionStatus.available).length;
    final int unlockedBefore = beforeUnlock.where((Mission m) => m.status == MissionStatus.available).length;
    if (unlockedNow > unlockedBefore) {
      AudioManager.instance.play(SoundEffect.missionUnlocked);
    }

    consecutiveSuccesses = success ? consecutiveSuccesses + 1 : 0;
    lastMissionSuccess = success;
    completedTestsCount = 0;

    notifyListeners();
  }

  int get availableComponentsCount => selectedComponents.entries
      .where((MapEntry<String, bool> e) => e.value)
      .where((MapEntry<String, bool> e) => availableComponents.any((ComponentOption c) => c.name == e.key))
      .length;

  double get overallPlanningScore {
    final List<MissionVariable> vars = availableMissionVariables;
    if (vars.isEmpty) {
      return 0;
    }

    final List<double> values = vars
        .map((MissionVariable v) => variableValues[v.id] ?? v.defaultValue)
        .toList();
    final double varAvg = values.reduce((double a, double b) => a + b) / values.length;

    final List<TeamSpecialty> missionTeam = availableTeam;
    final double teamAvg = missionTeam.isEmpty
        ? 0
        : missionTeam.fold<double>(0, (double sum, TeamSpecialty t) => sum + t.efficiency) /
            missionTeam.length;

    final double componentFactor =
        (availableComponentsCount / max(availableComponents.length, 1)) * 100;
    return ((varAvg * 0.5) + (teamAvg * 100 * 0.3) + (componentFactor * 0.2))
        .clamp(0, 100);
  }

  void _syncLegacySlidersFromVariables() {
    payloadQuality = variableValues['propulsion'] ?? payloadQuality;
    crewTraining = variableValues['stability'] ?? crewTraining;
    fuelReserve = variableValues['communication'] ?? fuelReserve;
  }
}

class MockTestResult {
  const MockTestResult({
    required this.score,
    required this.passed,
    required this.notes,
  });

  final int score;
  final bool passed;
  final String notes;
}
