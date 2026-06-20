import 'dart:math';

import '../models/mission.dart';
import '../models/mission_event.dart';
import '../models/mission_phase.dart';

class MissionRuntimeState {
  MissionRuntimeState({
    required this.mission,
    required this.phases,
    this.currentPhaseIndex = 0,
    this.altitude = 0,
    this.velocity = 0,
    this.budgetRemaining = 0,
    this.fuel = 100,
    this.energy = 100,
    this.communication = 100,
    this.integrity = 100,
    this.science = 0,
    this.paused = false,
    this.critical = false,
  });

  final Mission mission;
  final List<MissionPhase> phases;
  int currentPhaseIndex;
  double altitude;
  double velocity;
  int budgetRemaining;
  double fuel;
  double energy;
  double communication;
  double integrity;
  double science;
  bool paused;
  bool critical;

  MissionPhase get currentPhase => phases[currentPhaseIndex];
}

class MissionSimulator {
  static MissionRuntimeState launchMission({
    required Mission mission,
    required List<MissionPhase> phases,
    required int initialBudget,
  }) {
    return MissionRuntimeState(
      mission: mission,
      phases: phases,
      budgetRemaining: initialBudget,
    );
  }

  static MissionEvent? advanceMissionPhase(MissionRuntimeState state) {
    if (state.currentPhaseIndex >= state.phases.length) {
      return null;
    }

    final MissionPhase phase = state.currentPhase;
    state.altitude = max(state.altitude, phase.targetAltitude * (0.75 + Random().nextDouble() * 0.3));
    state.velocity = max(state.velocity, phase.targetVelocity * (0.7 + Random().nextDouble() * 0.35));

    state.fuel = max(0, state.fuel - (8 + phase.order * 1.5));
    state.energy = max(0, state.energy - (3 + phase.order * 1.1));
    state.communication = max(0, state.communication - (2 + Random().nextDouble() * 4));
    state.integrity = max(0, state.integrity - (1 + Random().nextDouble() * 3));
    state.science += 5 + Random().nextInt(12);

    MissionEvent? event;
    if (Random().nextDouble() < 0.28) {
      final bool critical = Random().nextDouble() < 0.35;
      state.critical = critical;
      event = MissionEvent(
        id: 'evt_${phase.id}_${state.currentPhaseIndex}',
        phaseId: phase.id,
        title: critical ? 'Alerta Critico' : 'Evento de Voo',
        description: critical
            ? 'Trajetoria fora da zona segura detectada.'
            : 'Oscilacao de telemetria dentro da tolerancia.',
        severity: critical ? 'critical' : 'warning',
        options: critical
            ? <String>['Abortar', 'Termino de voo', 'Continuar com risco']
            : <String>['Aplicar correcao', 'Monitorar'],
        canAbort: true,
        canTerminateFlight: critical,
        type: critical ? MissionEventType.critical : MissionEventType.warning,
        phaseIndex: state.currentPhaseIndex,
      );
    }

    if (state.currentPhaseIndex < state.phases.length - 1) {
      state.currentPhaseIndex += 1;
    }

    return event;
  }

  static String abortMission({required bool critical}) {
    return critical ? 'falha controlada' : 'missao abortada';
  }

  static String terminateFlight() {
    return 'falha controlada';
  }
}
