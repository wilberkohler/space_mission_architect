import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import '../audio/sound_effect.dart';
import '../game/game_controller.dart';
import '../models/mission_log_entry.dart';
import '../models/mission_phase.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/critical_action_button.dart';
import '../widgets/game_cockpit_scaffold.dart';
import '../widgets/mission_event_log.dart';
import '../widgets/mission_phase_timeline.dart';
import '../widgets/mission_trajectory_view.dart';
import '../widgets/stability_balance_control.dart';
import 'mission_report_screen.dart';

class MissionTrackingScreen extends StatefulWidget {
  const MissionTrackingScreen({
    required this.controller,
    super.key,
  });

  final GameController controller;

  @override
  State<MissionTrackingScreen> createState() => _MissionTrackingScreenState();
}

class _MissionTrackingScreenState extends State<MissionTrackingScreen> {
  late final List<MissionPhase> _phases;
  final List<MissionLogEntry> _logs = <MissionLogEntry>[];
  final ValueNotifier<int> _liveFrame = ValueNotifier<int>(0);
  final ValueNotifier<int> _logVersion = ValueNotifier<int>(0);

  Timer? _timer;
  int _elapsedSec = 0;
  int _activePhase = 0;
  double _altitudeKm = 0;
  double _velocityKmh = 0;
  double _resources = 100;
  double _budgetRemainingM = 0;
  double _missionRisk = 18;
  bool _criticalActive = false;
  bool _finished = false;
  bool _telemetryLogged = false;
  bool _criticalResolvedByUser = false;
  bool _abortRecommended = false;
  final Set<int> _instabilityPhaseChecks = <int>{};
  int _criticalStartSec = -1;
  int _timeScale = 1;
  int _scienceActions = 0;
  int _stabilityActions = 0;
  String? _activeInstabilityMessage;
  StabilityBalanceState _stabilityState = StabilityBalanceState.idle;
  StabilityDriftDirection _stabilityDriftDirection = StabilityDriftDirection.right;
  double _stabilityDriftSpeed = 0.07;
  double _stabilityCurrentPosition = 0.5;
  final double _stabilitySafeZoneMin = 0.42;
  final double _stabilitySafeZoneMax = 0.58;
  int _stabilityTimeLimitSeconds = 12;

  @override
  void initState() {
    super.initState();
    _phases = widget.controller.selectedMission?.phases ?? <MissionPhase>[];
    _budgetRemainingM = widget.controller.budgetM.toDouble();
    _appendLog('Sequencia automatica iniciada.');
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    AudioManager.instance.fadeOutBackgroundMusic(duration: const Duration(milliseconds: 500));
    _startAmbientForMission();
  }

  void _startAmbientForMission() {
    final String type = (widget.controller.selectedMission?.type ?? '').toLowerCase();
    final bool isDeepSpace = type.contains('lunar') ||
        type.contains('luna') ||
        type.contains('mart') ||
        type.contains('profund') ||
        type.contains('interplanet');
    final bool isSpaceFlight = type.contains('orbital') || type.contains('orbita');
    final SoundEffect ambient = isDeepSpace
      ? SoundEffect.deepSpaceAmbient
      : isSpaceFlight
        ? SoundEffect.missionAmbient
        : SoundEffect.missionAmbient;
    AudioManager.instance.startAmbient(ambient);
  }

  @override
  void dispose() {
    AudioManager.instance.stopCriticalAlert();
    AudioManager.instance.stopAmbient();
    _timer?.cancel();
    _liveFrame.dispose();
    _logVersion.dispose();
    super.dispose();
  }

  void _notifyLiveFrame() {
    if (!_liveFrame.hasListeners) {
      return;
    }
    _liveFrame.value = _liveFrame.value + 1;
  }

  void _tick() {
    if (_finished || _phases.isEmpty) {
      return;
    }
    // NOTE: Windows may still log occasional AXTree warnings from Flutter's
    // accessibility bridge, but avoiding full-screen setState per tick helps
    // keep semantic node churn low and improves stability.
    for (int i = 0; i < _timeScale; i++) {
      if (_finished) {
        break;
      }
      _advanceOneSecond();
    }
    _notifyLiveFrame();
  }

  void _advanceOneSecond() {
    _elapsedSec += 1;

    int cumulative = 0;
    int phaseIndex = 0;
    for (int i = 0; i < _phases.length; i++) {
      cumulative += _phases[i].durationSec;
      if (_elapsedSec <= cumulative) {
        phaseIndex = i;
        break;
      }
      phaseIndex = i;
    }

    if (phaseIndex != _activePhase && phaseIndex < _phases.length) {
      final int previousPhase = _activePhase;
      _activePhase = phaseIndex;
      _appendLog('Transicao para fase: ${_phases[_activePhase].name}');
      if (_criticalActive || _resources < 30) {
        AudioManager.instance.playSfx(SoundEffect.missionPhaseWarning);
      } else {
        AudioManager.instance.playSfx(SoundEffect.missionPhaseSuccess);
      }
      // Quindar beep for communications on phase transitions.
      AudioManager.instance.playVoice(SoundEffect.quindarStart);
      // Max-Q / main engine throttle — second phase of any mission.
      if (previousPhase == 0 && _activePhase == 1) {
        AudioManager.instance.playVoice(SoundEffect.goThrottleUp);
      }
      // MECO — entering the last phase (engine cutoff before coast/orbit).
      if (_activePhase == _phases.length - 1 && _phases.length > 1) {
        AudioManager.instance.playVoice(SoundEffect.meco);
      }
    }

    final int phaseEndSec = cumulative;
    final int phaseStartSec = phaseEndSec - _phases[phaseIndex].durationSec;
    final int elapsedInPhase = (_elapsedSec - phaseStartSec).clamp(0, _phases[phaseIndex].durationSec).toInt();

    final MissionPhase phase = _phases[_activePhase];
    _altitudeKm = min(
      phase.targetAltitudeKm,
      _altitudeKm + (phase.targetAltitudeKm / max(phase.durationSec / 3, 1)),
    );
    _velocityKmh = min(
      phase.targetVelocityKmh,
      _velocityKmh + (phase.targetVelocityKmh / max(phase.durationSec / 2.5, 1)),
    );
    _resources = max(0, _resources - (0.35 + (_activePhase * 0.08)));
    _budgetRemainingM = max(0, _budgetRemainingM - (0.04 + (_activePhase * 0.02)));
    _missionRisk = (_missionRisk + (_criticalActive ? 0.75 : 0.08)).clamp(0, 100);

    if (!_telemetryLogged && _elapsedSec >= 18) {
      _telemetryLogged = true;
      _appendLog('Telemetria nominal em todos os canais.');
    }

    _maybeTriggerInstabilityForPhase(phase: phase, phaseIndex: _activePhase, elapsedInPhase: elapsedInPhase);

    if (_criticalActive && _missionRisk >= 72 && !_abortRecommended) {
      _abortRecommended = true;
      _appendLog('Risco elevado na fase atual. Aborto passa a ser recomendado.', critical: true);
    }

    if (_criticalActive && _missionRisk >= 96) {
      _appendLog('Perda de controle do veiculo. Encerramento automatico da missao.', critical: true);
      AudioManager.instance.playSfx(SoundEffect.missionPhaseFailed);
      AudioManager.instance.stopCriticalAlert();
      _completeMission(success: false);
      return;
    }

    final int total = _phases.fold<int>(0, (int acc, MissionPhase p) => acc + p.durationSec);
    if (_elapsedSec >= total) {
      final bool enoughResources = _resources >= 18 && _integrityLevel >= 30;
      final bool stableOps = _stabilityActions >= 1;
      final bool scienceBonus = _scienceActions >= 1;
      final bool success =
          !_criticalActive &&
          enoughResources &&
          _missionRisk < 72 &&
          (stableOps || scienceBonus || _criticalResolvedByUser);
      if (success) {
        AudioManager.instance.playVoice(SoundEffect.niceToBeInOrbit);
      }
      _completeMission(success: success);
    }
  }

  void _setTimeScale(int value) {
    if (_finished) {
      return;
    }
    _timeScale = value;
    _appendLog('Aceleracao ajustada para ${value}x.');
    _notifyLiveFrame();
    AudioManager.instance.playUi(SoundEffect.uiClick);
  }

  void _collectScienceSample() {
    if (_finished || _criticalActive) {
      return;
    }
    AudioManager.instance.playUi(SoundEffect.uiClick);
    _scienceActions += 1;
    _resources = max(0, _resources - 3.5);
    _budgetRemainingM = max(0, _budgetRemainingM - 1.5);
    _missionRisk = max(0, _missionRisk - 1.6);
    _appendLog('Amostra cientifica coletada com sucesso.');
    _notifyLiveFrame();
  }

  void _maybeTriggerInstabilityForPhase({
    required MissionPhase phase,
    required int phaseIndex,
    required int elapsedInPhase,
  }) {
    if (_criticalActive || _finished || _instabilityPhaseChecks.contains(phaseIndex)) {
      return;
    }

    if (!_phaseSupportsInstability(phase)) {
      return;
    }

    final int cueSecond = (phase.durationSec * 0.55).round().clamp(2, max(2, phase.durationSec - 1));
    if (elapsedInPhase < cueSecond) {
      return;
    }

    _instabilityPhaseChecks.add(phaseIndex);
    final mission = widget.controller.selectedMission;
    final int missionDifficulty = mission?.difficulty ?? 1;
    final double difficultyFactor = ((missionDifficulty - 1) * 0.04).clamp(0.0, 0.28);
    final double riskFactor = (_missionRisk * 0.0032).clamp(0.0, 0.24);
    final double phasePressureFactor = (phaseIndex * 0.02).clamp(0.0, 0.1);
    final double chance = (
      0.14 +
      (phase.riskFactors.length * 0.07) +
      difficultyFactor +
      riskFactor +
      phasePressureFactor
    ).clamp(0.16, 0.88);

    if (Random().nextDouble() > chance) {
      _appendLog('Turbulencia em ${phase.name} compensada automaticamente.');
      return;
    }

    _triggerInstabilityEvent(phase: phase);
  }

  bool _phaseSupportsInstability(MissionPhase phase) {
    final String phaseContext = '${phase.id} ${phase.name} ${phase.riskFactors.join(' ')}'.toLowerCase();
    const List<String> keys = <String>[
      'instabil',
      'oscil',
      'vibr',
      'guiag',
      'guid',
      'max-q',
      'maxq',
      'subida',
      'ascent',
      'separ',
      'stress',
    ];
    return keys.any(phaseContext.contains);
  }

  void _triggerInstabilityEvent({required MissionPhase phase}) {
    final String phaseContext = '${phase.id} ${phase.name} ${phase.riskFactors.join(' ')}'.toLowerCase();
    final bool guidanceLike = phaseContext.contains('guiag') || phaseContext.contains('guid');

    _activeInstabilityMessage = guidanceLike
        ? 'Oscilacao detectada no eixo de guiagem'
        : 'Vibracao elevada';
    _criticalActive = true;
    _criticalStartSec = _elapsedSec;
    _stabilityState = StabilityBalanceState.active;
    _stabilityDriftDirection = Random().nextBool() ? StabilityDriftDirection.left : StabilityDriftDirection.right;
    _stabilityDriftSpeed = 0.05 + (Random().nextDouble() * 0.08);
    _stabilityCurrentPosition = 0.32 + (Random().nextDouble() * 0.36);
    _stabilityTimeLimitSeconds = 10 + Random().nextInt(5);
    _appendLog('Evento tecnico: $_activeInstabilityMessage.', critical: true);
    AudioManager.instance.playSfx(SoundEffect.spaceDanger);
    AudioManager.instance.playNoGoAlert();
    AudioManager.instance.playCriticalAlert();
    _notifyLiveFrame();
  }

  void _handleStabilityStabilized() {
    if (!_criticalActive || _finished) {
      return;
    }

    AudioManager.instance.stopCriticalAlert();
    AudioManager.instance.playSfx(SoundEffect.missionPhaseSuccess);
    _stabilityActions += 1;
    _criticalActive = false;
    _criticalResolvedByUser = true;
    _abortRecommended = false;
    _stabilityState = StabilityBalanceState.stabilized;
    _resources = max(0, _resources - 2.0);
    _missionRisk = max(0, _missionRisk - 14);
    _appendLog('Estabilidade corrigida manualmente.');
    _notifyLiveFrame();
  }

  void _handleStabilityFailed() {
    if (!_criticalActive || _finished) {
      return;
    }

    AudioManager.instance.playSfx(SoundEffect.missionPhaseFailed);
    _stabilityState = StabilityBalanceState.failed;
    _resources = max(0, _resources - 8.0);
    _budgetRemainingM = max(0, _budgetRemainingM - 3.0);
    _missionRisk = min(100, _missionRisk + 18);
    _appendLog('Falha parcial na correcao de estabilidade. Risco da fase ampliado.', critical: true);
    if (_missionRisk >= 72) {
      _abortRecommended = true;
    }
    _notifyLiveFrame();
  }

  void _continueAfterFailure() {
    if (!_criticalActive || _finished || _stabilityState != StabilityBalanceState.failed) {
      return;
    }

    AudioManager.instance.playUi(SoundEffect.uiClick);
    _missionRisk = min(100, _missionRisk + 4.0);
    _appendLog('Comando manteve curso com instabilidade residual.', critical: true);
    _notifyLiveFrame();
  }

  void _abortMission() {
    AudioManager.instance.stopCriticalAlert();
    AudioManager.instance.playSfx(SoundEffect.abortMission);
    _completeMission(success: false, aborted: true);
  }

  void _terminateFlight() {
    AudioManager.instance.stopCriticalAlert();
    AudioManager.instance.playSfx(SoundEffect.flightTermination);
    _completeMission(success: false, aborted: true);
  }

  void _appendLog(String message, {bool critical = false}) {
    _logs.add(MissionLogEntry(tSec: _elapsedSec, message: message, isCritical: critical));
    _logVersion.value = _logVersion.value + 1;
  }

  void _completeMission({required bool success, bool aborted = false}) {
    if (_finished) {
      return;
    }
    _finished = true;
    AudioManager.instance.stopCriticalAlert();
    _timer?.cancel();

    widget.controller.buildMissionReport(
      success: success,
      criticalFailure: _criticalActive && !aborted,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => MissionReportScreen(controller: widget.controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.controller.selectedMission;
    if (mission == null) {
      return const Scaffold(body: Center(child: Text('Missao nao definida.')));
    }

    return GameCockpitScaffold(
      controller: widget.controller,
      title: 'Centro de Missao',
      activeTab: CockpitTab.mission,
      trailing: _liveIndicator(),
      body: ValueListenableBuilder<int>(
        valueListenable: _liveFrame,
        builder: (BuildContext context, int _, Widget? child) {
          final int totalDuration = _phases.fold<int>(0, (int acc, MissionPhase p) => acc + p.durationSec);
          final double progress = totalDuration == 0 ? 0 : (_elapsedSec / totalDuration).clamp(0, 1);
          final String activePhaseName = _phases.isEmpty ? '-' : _phases[_activePhase].name;
          final bool pulseOn = _criticalActive && _elapsedSec.isEven;

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool wideLayout = constraints.maxWidth >= 1120;
              final Widget primaryColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _missionOverviewCard(
                    missionName: mission.name,
                    phaseName: activePhaseName,
                    progress: progress,
                    pulseOn: pulseOn,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _technicalTelemetryPanel(phaseName: activePhaseName),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: AppDecorations.panel(accent: AppColors.accent),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        MissionTrajectoryView(
                          progress: progress,
                          phaseName: activePhaseName,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        MissionPhaseTimeline(
                          phases: _phases.map((MissionPhase p) => p.name).toList(),
                          activeIndex: _activePhase,
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final Widget secondaryColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _eventLogPanel(),
                  const SizedBox(height: AppSpacing.md),
                  _stabilityResponseCard(),
                  const SizedBox(height: AppSpacing.md),
                  _missionControls(pulseOn),
                ],
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: wideLayout
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(flex: 7, child: primaryColumn),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(flex: 5, child: secondaryColumn),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          primaryColumn,
                          const SizedBox(height: AppSpacing.md),
                          secondaryColumn,
                        ],
                      ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _liveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: AppDecorations.statusBadge(AppColors.green),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.circle, size: 8, color: AppColors.green),
          SizedBox(width: 4),
          Text(
            'AO VIVO',
            style: TextStyle(fontSize: 11, color: AppColors.green, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  double get _fuelLevel => _resources.clamp(0, 100);

  double get _communicationLevel => (_resources - (_missionRisk * 0.24) - (_criticalActive ? 8 : 2)).clamp(0, 100);

  double get _integrityLevel => (_resources - (_missionRisk * 0.38) - (_criticalActive ? 12 : 4)).clamp(0, 100);

  String get _missionClock {
    final int hours = _elapsedSec ~/ 3600;
    final int minutes = (_elapsedSec % 3600) ~/ 60;
    final int seconds = _elapsedSec % 60;
    return 'T+${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _missionOverviewCard({
    required String missionName,
    required String phaseName,
    required double progress,
    required bool pulseOn,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: _criticalActive ? AppColors.red.withOpacity(0.55) : AppColors.panelBorder,
          width: _criticalActive ? 1.4 : 1,
        ),
        boxShadow: _criticalActive && pulseOn
            ? <BoxShadow>[
                BoxShadow(color: AppColors.red.withOpacity(0.18), blurRadius: 18, spreadRadius: 1),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  color: AppColors.accent.withOpacity(0.12),
                  border: Border.all(color: AppColors.accent.withOpacity(0.45)),
                ),
                child: const Icon(Icons.rocket_launch_outlined, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      missionName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Monitoramento tecnico em tempo real • $phaseName',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _statusChip(
                label: _criticalActive ? 'ALERTA TECNICO' : 'NOMINAL',
                color: _criticalActive ? AppColors.red : AppColors.green,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.circle),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              color: _criticalActive ? AppColors.red : AppColors.accent,
              backgroundColor: AppColors.panelBorder,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _inlineMetric(label: 'Tempo', value: _missionClock),
              _inlineMetric(label: 'Risco da fase', value: '${_missionRisk.round()}%'),
              _inlineMetric(label: 'Progresso', value: '${(progress * 100).round()}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _technicalTelemetryPanel({required String phaseName}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Painel tecnico de voo',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _primaryTelemetryCard(
                label: 'Altitude',
                value: '${_altitudeKm.toStringAsFixed(0)} km',
                subtitle: 'Altitude atual',
                icon: Icons.vertical_align_top,
                color: AppColors.accent,
              ),
              _primaryTelemetryCard(
                label: 'Velocidade',
                value: '${(_velocityKmh / 3600).toStringAsFixed(2)} km/s',
                subtitle: '${_velocityKmh.toStringAsFixed(0)} km/h',
                icon: Icons.speed_outlined,
                color: AppColors.green,
              ),
              _primaryTelemetryCard(
                label: 'Tempo',
                value: _missionClock,
                subtitle: 'Tempo de missao',
                icon: Icons.timer_outlined,
                color: AppColors.yellow,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _secondaryTelemetryCard('Fase atual', phaseName, Icons.route_outlined, AppColors.accent),
              _secondaryTelemetryCard('Combustivel', '${_fuelLevel.round()}%', Icons.local_fire_department_outlined, AppColors.orange),
              _secondaryTelemetryCard('Integridade', '${_integrityLevel.round()}%', Icons.shield_outlined, AppColors.green),
              _secondaryTelemetryCard('Comunicacao', '${_communicationLevel.round()}%', Icons.wifi_outlined, AppColors.accent),
              _secondaryTelemetryCard(
                'Orcamento restante',
                '${_budgetRemainingM.toStringAsFixed(1)} M',
                Icons.account_balance_wallet_outlined,
                AppColors.yellow,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _primaryTelemetryCard({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withOpacity(0.28)),
        boxShadow: <BoxShadow>[BoxShadow(color: color.withOpacity(0.08), blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _secondaryTelemetryCard(String label, String value, IconData icon, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 220),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.panelBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _eventLogPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.feed_outlined, color: AppColors.accent, size: 15),
              SizedBox(width: 6),
              Text(
                'Registro de eventos',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ValueListenableBuilder<int>(
            valueListenable: _logVersion,
            builder: (BuildContext context, int _, Widget? child) {
              final List<String> events = _logs
                  .map((MissionLogEntry e) => '${formatDuration(e.tSec)}  ${e.message}')
                  .toList(growable: false);
              return MissionEventLog(events: events.reversed.take(8).toList());
            },
          ),
        ],
      ),
    );
  }

  Widget _stabilityResponseCard() {
    final bool showControl = _criticalActive || _stabilityState == StabilityBalanceState.stabilized;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: _criticalActive ? AppColors.red.withOpacity(0.5) : AppColors.panelBorder,
          width: _criticalActive ? 1.3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Stability Balance Control',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            _criticalActive
                ? (_activeInstabilityMessage ?? 'Instabilidade detectada em voo.')
                : _stabilityState == StabilityBalanceState.stabilized
                    ? 'Sistema estabilizado. A missao voltou para faixa segura.'
                    : 'Nenhuma instabilidade ativa no momento.',
            style: TextStyle(
              color: _criticalActive ? AppColors.red : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: _criticalActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_criticalActive)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.red.withOpacity(0.35)),
              ),
              child: const Text(
                'Arraste o ponteiro para a zona segura central antes do tempo acabar.',
                style: TextStyle(color: AppColors.red, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          if (showControl)
            StabilityBalanceControl(
              key: ValueKey<String>('${_criticalStartSec}_${_activeInstabilityMessage}_${_stabilityState.name}'),
              state: _stabilityState,
              driftDirection: _stabilityDriftDirection,
              driftSpeed: _stabilityDriftSpeed,
              safeZoneMin: _stabilitySafeZoneMin,
              safeZoneMax: _stabilitySafeZoneMax,
              currentPosition: _stabilityCurrentPosition,
              timeLimitSeconds: _stabilityTimeLimitSeconds,
              onStabilized: _handleStabilityStabilized,
              onFailed: _handleStabilityFailed,
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.panelLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.panelBorderSubtle),
              ),
              child: const Text(
                'O controle dinamico sera exibido automaticamente quando houver vibracao elevada ou oscilacao no eixo de guiagem.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _inlineMetric(label: 'Estado', value: _stabilityState.name.toUpperCase()),
              _inlineMetric(label: 'Deriva', value: _stabilityDriftDirection == StabilityDriftDirection.left ? 'Esquerda' : 'Direita'),
              _inlineMetric(label: 'Tempo limite', value: '${_stabilityTimeLimitSeconds}s'),
            ],
          ),
          if (_abortRecommended) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Abortar recomendado: risco acumulado acima da faixa segura.',
              style: TextStyle(color: AppColors.red, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }

  Widget _missionControls(bool pulseOn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'CONTROLES DE MISSAO',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _speedChip(1),
              _speedChip(2),
              _speedChip(4),
              _speedChip(10),
              _speedChip(50),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_criticalActive) ...<Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.red.withOpacity(0.45)),
                boxShadow: pulseOn
                    ? <BoxShadow>[BoxShadow(color: AppColors.red.withOpacity(0.2), blurRadius: 10)]
                    : null,
              ),
              child: const Text(
                'Instabilidade ativa. Use o medidor para recentrar o veiculo e conter o risco.',
                style: TextStyle(color: AppColors.red, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                if (_stabilityState == StabilityBalanceState.failed)
                  ElevatedButton.icon(
                    onPressed: _continueAfterFailure,
                    icon: const Icon(Icons.trending_flat, size: 16),
                    label: const Text('Manter curso'),
                  ),
                if (_abortRecommended || _stabilityState == StabilityBalanceState.failed)
                  CriticalActionButton(
                    label: 'Abortar',
                    enabled: !_finished,
                    highlight: true,
                    onPressed: _abortMission,
                  ),
                OutlinedButton.icon(
                  onPressed: _finished ? null : _terminateFlight,
                  icon: const Icon(Icons.stop_circle_outlined, size: 16),
                  label: const Text('Termino de voo'),
                ),
              ],
            ),
          ] else ...<Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: _collectScienceSample,
                  icon: const Icon(Icons.biotech_outlined, size: 16),
                  label: const Text('Coletar dados'),
                ),
                OutlinedButton.icon(
                  onPressed: _finished ? null : _terminateFlight,
                  icon: const Icon(Icons.stop_circle_outlined, size: 16),
                  label: const Text('Termino de voo'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _speedChip(int speed) {
    final bool selected = _timeScale == speed;
    return ChoiceChip(
      selected: selected,
      label: Text('${speed}x'),
      onSelected: _finished ? null : (_) => _setTimeScale(speed),
    );
  }

  Widget _inlineMetric({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.panelLight,
        borderRadius: BorderRadius.circular(AppRadius.circle),
        border: Border.all(color: AppColors.panelBorderSubtle),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _statusChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.circle),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6),
      ),
    );
  }
}
