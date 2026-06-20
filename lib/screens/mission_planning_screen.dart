import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import '../audio/sound_effect.dart';
import '../game/budget_calculator.dart';
import '../game/game_controller.dart';
import '../models/component_option.dart';
import '../models/countdown_step.dart';
import '../models/mission.dart';
import '../models/mission_variable.dart';
import '../models/team_specialty.dart';
import '../models/test_option.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/countdown_panel.dart';
import '../widgets/game_cockpit_scaffold.dart';
import '../widgets/guidance_panel.dart';
import '../widgets/launch_readiness_modal.dart';
import '../widgets/round_action_button.dart';
import '../widgets/test_countdown_modal.dart';
import '../widgets/test_result_modal.dart';
import '../widgets/variable_slider.dart';
import 'mission_tracking_screen.dart';

class MissionPlanningScreen extends StatefulWidget {
  const MissionPlanningScreen({
    required this.controller,
    super.key,
  });

  final GameController controller;

  @override
  State<MissionPlanningScreen> createState() => _MissionPlanningScreenState();
}

class _MissionPlanningScreenState extends State<MissionPlanningScreen> {
  final ScrollController _pageScrollController = ScrollController();
  final List<TestRunOutcome> _testHistory = <TestRunOutcome>[];
  final Set<String> _selectedTestIds = <String>{};
  String? _activeTestId;
  String? _testInProgressId;
  bool _showAllVariablesDebug = false;
  bool _showMoreContentHint = false;

  @override
  void initState() {
    super.initState();
    _showAllVariablesDebug = AppConstants.showDebugIdealRanges;
    final String initial = widget.controller.selectedTestId;
    _activeTestId = initial;
    _selectedTestIds.add(initial);
    _pageScrollController.addListener(_updateMoreContentHint);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMoreContentHint();
      AudioManager.instance.startBackgroundMusic(SoundEffect.mainTheme);
    });
  }

  @override
  void dispose() {
    _pageScrollController
      ..removeListener(_updateMoreContentHint)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GameController controller = widget.controller;
    final Mission? mission = controller.selectedMission;

    if (mission == null) {
      return const Scaffold(
        body: Center(
          child: Text('Nenhuma missao selecionada.'),
        ),
      );
    }

    final List<TestOption> availableTests = controller.availableTests;
    _sanitizeTestSelection(availableTests, controller);

    return GameCockpitScaffold(
      controller: controller,
      title: 'Planejamento da Missão',
      activeTab: CockpitTab.planning,
      onTabSelected: (CockpitTab tab) {
        if (tab == CockpitTab.mission) {
          _launchFlow(controller);
        }
      },
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compactWidth = constraints.maxWidth < 980;
            final bool mobileWidth = constraints.maxWidth < 760;
            final double moduleHeight = mobileWidth ? 300 : 340;

            return Stack(
              children: <Widget>[
                SingleChildScrollView(
                  controller: _pageScrollController,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      children: <Widget>[
                        _missionHeaderCard(mission),
                        const SizedBox(height: AppSpacing.md),
                        if (compactWidth)
                          Column(
                            children: <Widget>[
                              _actionDock(controller, compact: true),
                              const SizedBox(height: AppSpacing.sm),
                              _summaryZone(controller: controller, mission: mission),
                            ],
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: 240,
                                child: _actionDock(controller, vertical: true),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _summaryZone(controller: controller, mission: mission),
                              ),
                            ],
                          ),
                        if (mission.complexityLevel <= 2) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          GuidancePanel(
                            messages: controller.guidanceMessagesForMission(mission),
                            level: mission.complexityLevel,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        _optionalSupportModules(
                          controller: controller,
                          mission: mission,
                          moduleHeight: moduleHeight,
                          mobileWidth: mobileWidth,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _calibrationWorkbench(
                          controller: controller,
                          mission: mission,
                          mobileWidth: mobileWidth,
                          moduleHeight: moduleHeight,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                  ),
                ),
                if (_showMoreContentHint)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: AppSpacing.sm,
                    child: Center(
                      child: GestureDetector(
                        onTap: _scrollToMoreContent,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.35),
                            border: Border.all(color: AppColors.textSecondary.withOpacity(0.4)),
                          ),
                          child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary, size: 24),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _updateMoreContentHint() {
    if (!_pageScrollController.hasClients || !mounted) {
      return;
    }
    final double remaining =
        _pageScrollController.position.maxScrollExtent - _pageScrollController.offset;
    final bool shouldShow = remaining > 24;
    if (shouldShow != _showMoreContentHint) {
      setState(() => _showMoreContentHint = shouldShow);
    }
  }

  Future<void> _scrollToMoreContent() async {
    if (!_pageScrollController.hasClients) {
      return;
    }
    final ScrollPosition position = _pageScrollController.position;
    final double target =
        (position.pixels + position.viewportDimension * 0.72).clamp(0.0, position.maxScrollExtent);
    await _pageScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void _sanitizeTestSelection(List<TestOption> availableTests, GameController controller) {
    if (availableTests.isEmpty) {
      _selectedTestIds.clear();
      _activeTestId = null;
      return;
    }

    final Set<String> validIds = availableTests.map((TestOption t) => t.id).toSet();
    _selectedTestIds.removeWhere((String id) => !validIds.contains(id));

    if (_activeTestId == null || !validIds.contains(_activeTestId)) {
      _activeTestId = _selectedTestIds.isNotEmpty ? _selectedTestIds.first : null;
    }

    if (_activeTestId != null) {
      controller.selectTest(_activeTestId!);
    }
  }

  Widget _optionalSupportModules({
    required GameController controller,
    required Mission mission,
    required double moduleHeight,
    required bool mobileWidth,
  }) {
    if (mission.complexityLevel <= 1) {
      return const SizedBox.shrink();
    }

    if (mission.complexityLevel == 2) {
      return SizedBox(
        width: double.infinity,
        height: moduleHeight,
        child: _componentsPanel(controller),
      );
    }

    if (mobileWidth) {
      return Column(
        children: <Widget>[
          SizedBox(height: moduleHeight, child: _componentsPanel(controller)),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(height: moduleHeight, child: _teamPanel(controller)),
        ],
      );
    }

    return Row(
      children: <Widget>[
        Expanded(child: SizedBox(height: moduleHeight, child: _componentsPanel(controller))),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: SizedBox(height: moduleHeight, child: _teamPanel(controller))),
      ],
    );
  }

  Widget _calibrationWorkbench({
    required GameController controller,
    required Mission mission,
    required bool mobileWidth,
    required double moduleHeight,
  }) {
    final Widget heading = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              'CALIBRAGEM DE TESTES E VARIAVEIS',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
          if (AppConstants.showDebugIdealRanges)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Ver todas (debug)', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                Switch.adaptive(
                  value: _showAllVariablesDebug,
                  onChanged: (bool value) => setState(() => _showAllVariablesDebug = value),
                ),
              ],
            ),
        ],
      ),
    );

    final Widget testsPane = SizedBox(height: moduleHeight, child: _testsPanel(controller));
    final Widget varsPane = SizedBox(height: moduleHeight, child: _variablesPanel(controller));

    if (mobileWidth) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          heading,
          const SizedBox(height: AppSpacing.sm),
          testsPane,
          const SizedBox(height: AppSpacing.sm),
          varsPane,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        heading,
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: testsPane),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: varsPane),
          ],
        ),
      ],
    );
  }

  Widget _actionDock(
    GameController controller, {
    bool compact = false,
    bool vertical = false,
  }) {
    final TestOption? activeTest = _activeSelectedTest(controller);
    final Mission? mission = controller.selectedMission;
    final bool launchEnabled = canLaunchMission();
    final bool blockedByTests =
        mission != null && _isLaunchBlockedByTestSpend(controller: controller, mission: mission);
    final bool firstCareerLevel = controller.playerCareer.level <= 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.panelBorder),
        boxShadow: <BoxShadow>[BoxShadow(color: AppColors.accent.withOpacity(0.04), blurRadius: 12)],
      ),
      child: Column(
        children: <Widget>[
          if (!compact) ...<Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.accent.withOpacity(0.25)),
              ),
              child: const Text(
                'Fluxo: TESTE -> AJUSTE -> LANCAMENTO. Mais testes melhoram confianca, mas custam orcamento.',
                style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ACOES PRINCIPAIS',
              style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (vertical)
            Column(
              children: <Widget>[
                RoundActionButton(
                  label: 'TESTE',
                  icon: Icons.science_outlined,
                  color: AppColors.accent,
                  size: compact ? 84 : 100,
                  onPressed: (activeTest == null || _testInProgressId != null)
                      ? null
                      : () {
                          AudioManager.instance.playUi(SoundEffect.uiClick);
                          _attemptRunTestFromDock(activeTest, controller);
                        },
                ),
                const SizedBox(height: AppSpacing.sm),
                RoundActionButton(
                  label: 'LANCAMENTO',
                  icon: Icons.rocket_launch,
                  color: launchEnabled ? AppColors.green : AppColors.red,
                  size: compact ? 84 : 100,
                  onPressed: launchEnabled
                      ? () {
                          AudioManager.instance.playUi(SoundEffect.uiConfirm);
                          _launchFlow(controller);
                        }
                      : null,
                ),
              ],
            )
          else
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                RoundActionButton(
                  label: 'TESTE',
                  icon: Icons.science_outlined,
                  color: AppColors.accent,
                  size: compact ? 84 : 100,
                  onPressed: (activeTest == null || _testInProgressId != null)
                      ? null
                      : () {
                          AudioManager.instance.playUi(SoundEffect.uiClick);
                          _attemptRunTestFromDock(activeTest, controller);
                        },
                ),
                RoundActionButton(
                  label: 'LANCAMENTO',
                  icon: Icons.rocket_launch,
                  color: launchEnabled ? AppColors.green : AppColors.red,
                  size: compact ? 84 : 100,
                  onPressed: launchEnabled
                      ? () {
                          AudioManager.instance.playUi(SoundEffect.uiConfirm);
                          _launchFlow(controller);
                        }
                      : null,
                ),
              ],
            ),
          if (!launchEnabled) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.red.withOpacity(0.3)),
              ),
              child: Text(
                blockedByTests
                    ? 'Testes consumiram a reserva de lancamento. Replaneje para recuperar margem.'
                    : 'Margem de lancamento insuficiente com a configuracao atual.',
                style: const TextStyle(color: AppColors.red, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
            if (blockedByTests) ...<Widget>[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _recoverFromBudgetLock(controller),
                  icon: Icon(
                    firstCareerLevel ? Icons.restart_alt : Icons.trending_down,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  label: Text(
                    firstCareerLevel
                        ? 'Reiniciar planejamento'
                        : 'Replanejar (reduz reputacao)',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
              ),
            ],
          ],
          if (_testHistory.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            _testHistoryRow(),
          ],
        ],
      ),
    );
  }

  Future<void> _runTestFlow(TestOption test, GameController controller) async {
    setState(() => _testInProgressId = test.id);
    await AudioManager.instance.playSfx(SoundEffect.testStart);

    final TestRunOutcome? rawOutcome = await showTestCountdown(
      context,
      test: test,
    );

    if (!mounted) {
      return;
    }

    setState(() => _testInProgressId = null);

    if (rawOutcome == null) {
      return;
    }

    final TestRunOutcome adjusted = _calibrateOutcome(rawOutcome, test, controller);
    setState(() {
      _testHistory.add(adjusted);
      _selectedTestIds.add(test.id);
      _activeTestId = test.id;
    });

    await showTestResultModal(context, outcome: adjusted);
  }

  Future<void> _attemptRunTestFromDock(TestOption test, GameController controller) async {
    final Mission? mission = controller.selectedMission;
    if (mission != null &&
        _testHistory.isNotEmpty &&
        _wouldTestBreakLaunchReserve(test: test, controller: controller, mission: mission)) {
      final bool proceed = await _confirmRiskyTestSpend(test: test, controller: controller, mission: mission);
      if (!proceed || !mounted) {
        return;
      }
    }
    await _runTestFlow(test, controller);
  }

  Future<bool> _confirmRiskyTestSpend({
    required TestOption test,
    required GameController controller,
    required Mission mission,
  }) async {
    final int reserve = _reserveMinimum(mission);
    final int launchCost = _estimatedLaunchCost(controller, mission);
    final int remainingBefore = controller.missionBudgetCap - (_accumulatedTestCost + launchCost);
    final int remainingAfter = remainingBefore - test.cost;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Aviso de orcamento de lancamento'),
          content: Text(
            'Novo teste pode eliminar a margem para lancamento.\\n\\n'
            'Reserva minima: ${reserve}M\\n'
            'Margem atual: ${remainingBefore}M\\n'
            'Margem apos este teste: ${remainingAfter}M\\n\\n'
            'Se continuar, a missao pode ficar sem recursos para lancar.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Continuar mesmo assim'),
            ),
          ],
        );
      },
    );

    return confirmed == true;
  }

  TestRunOutcome _calibrateOutcome(TestRunOutcome raw, TestOption test, GameController controller) {
    final double signal = controller.overallPlanningScore + (test.successBonus * 0.7);
    final bool partialFailure = signal < 48;
    final bool warning = raw.hasWarning || signal < 62;

    final List<String> findings = <String>[...raw.findings];
    if (partialFailure) {
      findings.insert(0, 'Falha parcial: dados inconsistentes, repetir teste apos ajustes.');
    } else if (warning) {
      findings.insert(0, 'Alerta: parametros validos, mas com margem estreita.');
    }

    return TestRunOutcome(
      testId: raw.testId,
      testName: raw.testName,
      passed: !partialFailure,
      hasWarning: warning,
      validatedItems: raw.validatedItems,
      findings: findings,
      riskDelta: partialFailure ? raw.riskDelta * 0.4 : raw.riskDelta,
      uncertaintyDelta: partialFailure ? raw.uncertaintyDelta * 0.5 : raw.uncertaintyDelta,
      budgetCost: raw.budgetCost,
      description: raw.description,
    );
  }

  Future<void> _launchFlow(GameController controller) async {
    if (!canLaunchMission()) {
      final Mission? mission = controller.selectedMission;
      if (mission != null && _isLaunchBlockedByTestSpend(controller: controller, mission: mission)) {
        await _showBudgetLockDialog(controller);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Margem de lancamento insuficiente. Ajuste componentes, equipe ou custos.'),
        ),
      );
      return;
    }

    final bool? confirmed = await showLaunchReadinessModal(
      context,
      controller: controller,
      testHistory: _testHistory,
    );
    if (confirmed != true || !mounted) {
      return;
    }

    await AudioManager.instance.playSfx(SoundEffect.launchConfirm);

    final NavigatorState mainNav = Navigator.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        final NavigatorState dialogNav = Navigator.of(ctx);
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 540,
              maxHeight: MediaQuery.of(ctx).size.height * 0.82,
            ),
            child: SingleChildScrollView(
              child: CountdownPanel(
                type: CountdownType.launch,
                title: 'Contagem de Lancamento',
                subtitle: controller.selectedMission?.name ?? '',
                durationSeconds: 10,
                steps: kLaunchCountdownSteps,
                systemStatuses: _buildSystemStatuses(controller),
                cancelActionLabel: 'Abortar lancamento',
                onCompleted: () {
                  dialogNav.pop();
                  AudioManager.instance.playSfx(SoundEffect.launchLiftoff);
                  mainNav.push(
                    MaterialPageRoute<void>(
                      builder: (_) => MissionTrackingScreen(controller: controller),
                    ),
                  );
                },
                onCancelled: dialogNav.pop,
              ),
            ),
          ),
        );
      },
    );
  }

  List<SystemGoStatus> _buildSystemStatuses(GameController controller) {
    final int chance = controller.overallPlanningScore.round();
    final bool budgetOk = canLaunchMission();
    final bool lowConfidence = _confidenceScore(controller) < 0.45;

    GoState goFor(bool ok) => ok ? GoState.go : GoState.warning;

    return <SystemGoStatus>[
      SystemGoStatus(name: 'Propulsao', goState: chance >= 60 ? GoState.go : GoState.warning),
      SystemGoStatus(name: 'Guiagem', goState: chance >= 70 ? GoState.go : GoState.warning),
      SystemGoStatus(name: 'Orcamento', goState: goFor(budgetOk)),
      SystemGoStatus(name: 'Confianca', goState: lowConfidence ? GoState.warning : GoState.go),
      SystemGoStatus(
        name: 'Seguranca',
        goState: _testHistory.any((TestRunOutcome o) => o.hasWarning || !o.passed) ? GoState.warning : GoState.go,
      ),
    ];
  }

  TestOption? _activeSelectedTest(GameController controller) {
    final List<TestOption> availableTests = controller.availableTests;
    if (availableTests.isEmpty || _selectedTestIds.isEmpty) {
      return null;
    }

    final String preferredId = (_activeTestId != null && _selectedTestIds.contains(_activeTestId))
        ? _activeTestId!
        : _selectedTestIds.first;

    return availableTests.where((TestOption t) => t.id == preferredId).firstOrNull;
  }

  Map<String, TestRunOutcome> get _latestOutcomesByTest {
    final Map<String, TestRunOutcome> map = <String, TestRunOutcome>{};
    for (final TestRunOutcome o in _testHistory) {
      map[o.testId] = o;
    }
    return map;
  }

  int get _accumulatedTestCost => _testHistory.fold<int>(0, (int sum, TestRunOutcome o) => sum + o.budgetCost);

  int _estimatedLaunchCost(GameController controller, Mission mission) {
    final List<ComponentOption> selectedComponents = controller.availableComponents
        .where((ComponentOption c) => controller.selectedComponents[c.name] ?? false)
        .toList();
    final List<TeamSpecialty> selectedTeam = controller.availableTeam;

    return BudgetCalculator.estimateMissionBudget(
      mission: mission,
      components: selectedComponents,
      team: selectedTeam,
    );
  }

  int _reserveMinimum(Mission mission) {
    if (mission.minimumBudget <= 0) {
      return 0;
    }
    return (mission.minimumBudget * 0.10).round().clamp(8, 1000000);
  }

  int _plannedTotalCost(GameController controller, Mission mission) {
    return _accumulatedTestCost + _estimatedLaunchCost(controller, mission);
  }

  int _remainingBudget(GameController controller, Mission mission) {
    return controller.missionBudgetCap - _plannedTotalCost(controller, mission);
  }

  bool canLaunchMission() {
    final GameController controller = widget.controller;
    final Mission? mission = controller.selectedMission;
    if (mission == null) {
      return false;
    }

    final int availableBudget = controller.missionBudgetCap;
    final int totalPlanned = _plannedTotalCost(controller, mission);
    final int remaining = availableBudget - totalPlanned;
    final int reserve = _reserveMinimum(mission);

    if (remaining < 0) {
      return false;
    }
    if (totalPlanned > availableBudget) {
      return false;
    }
    if (remaining < reserve) {
      return false;
    }
    return true;
  }

  bool _isLaunchBlockedByTestSpend({
    required GameController controller,
    required Mission mission,
  }) {
    if (_accumulatedTestCost <= 0) {
      return false;
    }

    final int reserve = _reserveMinimum(mission);
    final int launchCost = _estimatedLaunchCost(controller, mission);
    final int remainingWithoutTests = controller.missionBudgetCap - launchCost;
    final int remainingWithTests = remainingWithoutTests - _accumulatedTestCost;

    return remainingWithoutTests >= reserve && remainingWithTests < reserve;
  }

  bool _wouldTestBreakLaunchReserve({
    required TestOption test,
    required GameController controller,
    required Mission mission,
  }) {
    final int reserve = _reserveMinimum(mission);
    final int launchCost = _estimatedLaunchCost(controller, mission);
    final int remainingNow = controller.missionBudgetCap - (_accumulatedTestCost + launchCost);
    final int remainingAfter = remainingNow - test.cost;
    return remainingNow >= reserve && remainingAfter < reserve;
  }

  Future<void> _showBudgetLockDialog(GameController controller) async {
    final bool firstCareerLevel = controller.playerCareer.level <= 1;
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Lancamento sem margem de orcamento'),
          content: Text(
            firstCareerLevel
                ? 'Os testes executados consumiram a reserva de lancamento. Reinicie o planejamento para recuperar os recursos de testes.'
                : 'Os testes executados consumiram a reserva de lancamento. Para continuar no seu nivel atual, sera aplicada reducao de reputacao ao replanejar.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _recoverFromBudgetLock(controller);
              },
              child: Text(firstCareerLevel ? 'Reiniciar planejamento' : 'Replanejar com penalidade'),
            ),
          ],
        );
      },
    );
  }

  void _recoverFromBudgetLock(GameController controller) {
    final bool firstCareerLevel = controller.playerCareer.level <= 1;
    setState(() {
      _testHistory.clear();
      _selectedTestIds
        ..clear()
        ..add(controller.selectedTestId);
      _activeTestId = controller.selectedTestId;
    });

    if (!firstCareerLevel) {
      controller.currentReputation = controller.currentReputation.copyWith(pub: -4, sci: -3, ind: -3);
      controller.notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Replanejamento aplicado com reducao de reputacao.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Planejamento reiniciado para recuperar margem de lancamento.'),
      ),
    );
  }

  double _confidenceScore(GameController controller) {
    final List<MissionVariable> vars = controller.availableMissionVariables;
    if (vars.isEmpty) {
      return 0;
    }

    final Set<String> varIds = vars.map((MissionVariable v) => v.id).toSet();
    final Set<String> testedVarIds = <String>{};
    for (final TestRunOutcome outcome in _latestOutcomesByTest.values) {
      testedVarIds.addAll(outcome.validatedItems.where(varIds.contains));
    }

    final double variableCoverage = testedVarIds.length / math.max(varIds.length, 1);
    final double testCoverage = _latestOutcomesByTest.length / math.max(controller.availableTests.length, 1);

    return (variableCoverage * 0.65 + testCoverage * 0.35).clamp(0.0, 1.0);
  }

  Set<String> _filteredVariableIds(GameController controller) {
    final Set<String> available = controller.availableMissionVariables.map((MissionVariable v) => v.id).toSet();

    if (_showAllVariablesDebug) {
      return available;
    }

    if (_selectedTestIds.isEmpty) {
      return <String>{};
    }

    final bool integratedSelected = _selectedTestIds.contains('integrated_test');
    final bool allSelected = _selectedTestIds.length >= controller.availableTests.length && controller.availableTests.isNotEmpty;
    if (integratedSelected || allSelected) {
      return available;
    }

    final Set<String> affected = <String>{};
    for (final TestOption test in controller.availableTests) {
      if (_selectedTestIds.contains(test.id)) {
        affected.addAll(test.affectedVariables);
      }
    }

    return affected.intersection(available);
  }

  RangeValues _effectiveIdealRange(MissionVariable variable) {
    final double baseMin = variable.estimatedIdealMin;
    final double baseMax = variable.estimatedIdealMax;

    final double evidence = _testHistory
        .where((TestRunOutcome o) => o.validatedItems.contains(variable.id))
        .fold<double>(0.0, (double sum, TestRunOutcome o) => sum + o.uncertaintyDelta.abs())
        .clamp(0.0, 0.40);

    final double normalized = evidence / 0.40;
    final double shrinkFactor = normalized * 0.48;

    final double center = (baseMin + baseMax) / 2;
    final double half = ((baseMax - baseMin) / 2) * (1 - shrinkFactor);

    final double min = (center - half).clamp(variable.minValue, variable.maxValue);
    final double max = (center + half).clamp(variable.minValue, variable.maxValue);
    return RangeValues(min, max);
  }

  Widget _testHistoryRow() {
    final Map<String, TestRunOutcome> latest = _latestOutcomesByTest;
    final List<TestRunOutcome> outcomes = latest.values.toList();
    final List<String> names = outcomes.map((TestRunOutcome o) => o.testName).toList();

    final List<String> alerts = outcomes
        .where((TestRunOutcome o) => o.hasWarning || !o.passed)
        .map((TestRunOutcome o) => o.findings.isEmpty ? o.testName : '${o.testName}: ${o.findings.first}')
        .toList();

    final bool allGood = outcomes.isNotEmpty && outcomes.every((TestRunOutcome o) => o.passed && !o.hasWarning);
    final Color c = allGood ? AppColors.green : AppColors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
      decoration: BoxDecoration(
        color: c.withOpacity(0.07),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.science_outlined, size: 14, color: c),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Testes realizados: ${names.join(', ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (alerts.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              'Alertas: ${alerts.join(' | ')}',
              style: const TextStyle(color: AppColors.orange, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _missionHeaderCard(Mission mission) {
    final (Color statusColor, String statusLabel) = _statusStyle(mission.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: statusColor.withOpacity(0.35), width: 1.2),
        boxShadow: <BoxShadow>[BoxShadow(color: statusColor.withOpacity(0.06), blurRadius: 14)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: statusColor.withOpacity(0.35)),
                ),
                child: Icon(_missionIcon(mission), size: 20, color: statusColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      mission.name,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${mission.era} - ${mission.type} • Complexidade ${mission.complexityLevel} • Requisito N${mission.requiredCareerLevel}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: AppDecorations.statusBadge(statusColor),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            mission.historicalReference,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _summaryZone({
    required GameController controller,
    required Mission mission,
  }) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Widget chanceRisk = _chanceRiskCard(controller: controller, mission: mission);
        final Widget budget = _budgetPlannerCard(controller: controller, mission: mission);

        if (constraints.maxWidth < 660) {
          return Column(
            children: <Widget>[
              chanceRisk,
              const SizedBox(height: AppSpacing.sm),
              budget,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: chanceRisk),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: budget),
          ],
        );
      },
    );
  }

  Widget _budgetPlannerCard({
    required GameController controller,
    required Mission mission,
  }) {
    final int available = controller.missionBudgetCap;
    final int testCost = _accumulatedTestCost;
    final int launchCost = _estimatedLaunchCost(controller, mission);
    final int total = testCost + launchCost;
    final int remaining = available - total;
    final int reserve = _reserveMinimum(mission);
    final int remainingBeforeTests = available - launchCost;
    final bool blockedByTests = _isLaunchBlockedByTestSpend(controller: controller, mission: mission);

    final bool ok = canLaunchMission();
    final Color c = ok ? AppColors.green : AppColors.red;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.account_balance_wallet_outlined, size: 14, color: c),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'PLANO ORCAMENTARIO DA MISSAO',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _line('Orcamento disponivel', '${available}M'),
          _line('Orcamento minimo', '${mission.minimumBudget}M'),
          _line('Orcamento recomendado', '${mission.recommendedBudget}M'),
          _line('Testes selecionados/realizados', '${testCost}M'),
          _line('Lancamento estimado', '${launchCost}M'),
          _line('Total comprometido', '${total}M'),
          _line('Restante', '${remaining}M', valueColor: remaining >= reserve ? AppColors.green : AppColors.red),
          const SizedBox(height: 6),
          _beforeAfterIndicator(
            label: 'Margem para lancamento',
            before: '${remainingBeforeTests}M',
            after: '${remaining}M',
            improved: remaining >= remainingBeforeTests,
          ),
          const SizedBox(height: 6),
          Text(
            'Reserva minima: ${reserve}M',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
          if (!ok) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              blockedByTests
                  ? 'Os testes reduziram a margem abaixo da reserva de lancamento.'
                  : 'A configuracao atual esta abaixo da reserva de lancamento.',
              style: const TextStyle(color: AppColors.red, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }

  Widget _line(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(color: valueColor ?? AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _beforeAfterIndicator({
    required String label,
    required String before,
    required String after,
    required bool improved,
  }) {
    final Color tone = improved ? AppColors.green : AppColors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: tone.withOpacity(0.3)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.compare_arrows, size: 13, color: tone),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label: $before -> $after',
              style: TextStyle(color: tone, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chanceRiskCard({
    required GameController controller,
    required Mission mission,
  }) {
    final int chance = controller.overallPlanningScore.round();
    final double confidence = _confidenceScore(controller);
    final int spread = (22 - (confidence * 16)).round().clamp(4, 22);
    final int chanceLow = (chance - spread).clamp(0, 100);
    final int chanceHigh = (chance + spread).clamp(0, 100);
    final int risk = (100 - chance).clamp(0, 100);
    final int riskReductionFromTests =
      (_testHistory.fold<double>(0.0, (double sum, TestRunOutcome o) => sum + (-o.riskDelta)) * 100)
        .round();
    final int riskBeforeTests = (risk + riskReductionFromTests).clamp(0, 100);

    final Color chanceColor = chance >= 70
        ? AppColors.green
        : chance >= 50
            ? AppColors.yellow
            : AppColors.red;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: chanceColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: chanceColor, width: 2),
              boxShadow: <BoxShadow>[BoxShadow(color: chanceColor.withOpacity(0.15), blurRadius: 14)],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('$chance%', style: TextStyle(fontSize: 20, color: chanceColor, fontWeight: FontWeight.w800)),
                  const Text('chance', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Chance estimada: $chanceLow-$chanceHigh%',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Risco estimado: $risk% • Confianca ${(confidence * 100).round()}%',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                if (_testHistory.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  _beforeAfterIndicator(
                    label: 'Risco estimado',
                    before: '$riskBeforeTests%',
                    after: '$risk%',
                    improved: risk <= riskBeforeTests,
                  ),
                ],
                if (confidence < 0.45) ...<Widget>[
                  const SizedBox(height: 6),
                  const Text(
                    'Baixa confianca nos parametros da missao.',
                    style: TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ],
                const SizedBox(height: 6),
                ...mission.mainRisks.take(2).map(
                  (String riskText) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.warning_amber_outlined, size: 13, color: AppColors.orange.withOpacity(0.85)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            riskText,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _componentsPanel(GameController controller) {
    final List<ComponentOption> availableComponents = controller.availableComponents;
    return _panel(
      title: 'COMPONENTES',
      child: ListView.separated(
        itemCount: availableComponents.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final ComponentOption component = availableComponents[index];
          final bool enabled = controller.selectedComponents[component.name] ?? false;
          final Color accent = enabled ? AppColors.accent : AppColors.panelBorder;

          return InkWell(
            key: ValueKey<String>('component-${component.id}'),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: () => setState(() => controller.toggleComponent(component.name, !enabled)),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: enabled ? AppColors.accent.withOpacity(0.07) : AppColors.panelLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: accent.withOpacity(enabled ? 0.5 : 1), width: enabled ? 1.5 : 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      color: accent.withOpacity(0.13),
                    ),
                    child: Icon(_componentIcon(component.system), size: 18, color: accent),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                component.name,
                                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ),
                            Icon(
                              enabled ? Icons.check_circle : Icons.radio_button_unchecked,
                              size: 16,
                              color: enabled ? AppColors.accent : AppColors.textMuted,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${component.categoryLabel} - ${component.description}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: <Widget>[
                            _tinyIndicator('Custo ${component.cost}M', AppColors.green),
                            _tinyIndicator('Confiab. ${(component.reliabilityImpact * 100).round()}%', AppColors.accent),
                            _tinyIndicator('Risco -${(component.riskImpact.abs() * 100).round()}%', AppColors.yellow),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _teamPanel(GameController controller) {
    final List<TeamSpecialty> availableTeam = controller.availableTeam;
    return _panel(
      title: 'EQUIPE',
      child: Column(
        children: <Widget>[
          _teamSummaryCard(controller),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.separated(
              itemCount: availableTeam.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) {
                final TeamSpecialty item = availableTeam[index];
                final bool healthy = item.assigned >= item.recommended;
                final Color c = healthy ? AppColors.green : AppColors.accent;

                return Container(
                  key: ValueKey<String>('team-${item.id}'),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.panelLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: c.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(item.role, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: AppDecorations.statusBadge(c),
                            child: Text(
                              '${item.assigned}/${item.total}',
                              style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(item.impactLabel, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      const SizedBox(height: 4),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: c,
                          thumbColor: c,
                          inactiveTrackColor: AppColors.panelBorder,
                          trackHeight: 3,
                        ),
                        child: Slider(
                          min: 0,
                          max: item.total.toDouble(),
                          divisions: item.total,
                          value: item.assigned.toDouble(),
                          onChanged: (double value) {
                            setState(() => controller.adjustTeamAssignment(item.role, value.round()));
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamSummaryCard(GameController controller) {
    final List<TeamSpecialty> availableTeam = controller.availableTeam;
    final int assignedTotal = availableTeam.fold<int>(0, (int sum, TeamSpecialty t) => sum + t.assigned);
    final int recommendedTotal = availableTeam.fold<int>(0, (int sum, TeamSpecialty t) => sum + t.recommended);
    final int readiness = recommendedTotal == 0 ? 0 : ((assignedTotal / recommendedTotal) * 100).round();
    final Color c = readiness >= 90
        ? AppColors.green
        : readiness >= 70
            ? AppColors.yellow
            : AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.withOpacity(0.35)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.withOpacity(0.12),
              border: Border.all(color: c.withOpacity(0.35)),
            ),
            child: Icon(Icons.groups_2_outlined, size: 18, color: c),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Resumo da equipe', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                Text(
                  '$assignedTotal/$recommendedTotal membros alocados',
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: AppDecorations.statusBadge(c),
            child: Text('$readiness%', style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _variablesPanel(GameController controller) {
    final List<MissionVariable> availableVars = controller.availableMissionVariables;
    final Set<String> visibleIds = _filteredVariableIds(controller);
    final List<MissionVariable> filteredVars = availableVars.where((MissionVariable v) => visibleIds.contains(v.id)).toList();

    if (filteredVars.isEmpty) {
      return _panel(
        title: 'VARIAVEIS',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.tune, color: AppColors.textMuted, size: 24),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Selecione um teste para calibrar variaveis especificas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              if (AppConstants.showDebugIdealRanges) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => setState(() => _showAllVariablesDebug = true),
                  child: const Text('Ver todas as variaveis (debug)'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return _panel(
      title: 'VARIAVEIS',
      child: ListView.separated(
        itemCount: filteredVars.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final MissionVariable variable = filteredVars[index];
          final double value = controller.variableValue(variable.id, fallback: variable.defaultValue);
          final RangeValues ideal = _effectiveIdealRange(variable);
          return VariableSlider(
            key: ValueKey<String>('variable-${variable.id}'),
            label: '${variable.label} (${variable.unit})',
            value: value,
            min: variable.minValue,
            max: variable.maxValue,
            idealMin: ideal.start,
            idealMax: ideal.end,
            showDebugIdealRanges: AppConstants.showDebugIdealRanges,
            accentColor: _variableColor(index),
            onChanged: (double newValue) {
              setState(() => controller.setMissionVariable(variable.id, newValue));
            },
          );
        },
      ),
    );
  }

  Widget _testsPanel(GameController controller) {
    final List<TestOption> availableTests = controller.availableTests;
    final Map<String, TestRunOutcome> latest = _latestOutcomesByTest;

    return _panel(
      title: 'TESTES',
      child: ListView.separated(
        itemCount: availableTests.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final TestOption test = availableTests[index];
          final bool selected = _selectedTestIds.contains(test.id);
          final TestRunOutcome? outcome = latest[test.id];
          final _TestVisualState state = _testStateFor(test, selected, outcome);

          final Color borderColor = switch (state) {
            _TestVisualState.selected => AppColors.accent,
            _TestVisualState.running => AppColors.accent,
            _TestVisualState.doneSuccess => AppColors.green,
            _TestVisualState.doneWarning => AppColors.yellow,
            _TestVisualState.doneFailure => AppColors.red,
            _TestVisualState.notRun => AppColors.panelBorder,
          };

          final IconData stateIcon = switch (state) {
            _TestVisualState.selected => Icons.radio_button_checked,
            _TestVisualState.running => Icons.hourglass_bottom,
            _TestVisualState.doneSuccess => Icons.check_circle,
            _TestVisualState.doneWarning => Icons.warning_amber_outlined,
            _TestVisualState.doneFailure => Icons.error_outline,
            _TestVisualState.notRun => Icons.radio_button_unchecked,
          };

          final String stateLabel = switch (state) {
            _TestVisualState.selected => 'Selecionado',
            _TestVisualState.running => 'Em andamento',
            _TestVisualState.doneSuccess => 'Realizado',
            _TestVisualState.doneWarning => 'Realizado com alerta',
            _TestVisualState.doneFailure => 'Falha parcial',
            _TestVisualState.notRun => 'Nao realizado',
          };

          return InkWell(
            key: ValueKey<String>('test-${test.id}'),
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: () {
              setState(() {
                if (selected) {
                  _selectedTestIds.remove(test.id);
                  if (_activeTestId == test.id) {
                    _activeTestId = _selectedTestIds.isEmpty ? null : _selectedTestIds.first;
                  }
                } else {
                  _selectedTestIds.add(test.id);
                  _activeTestId = test.id;
                }
                if (_activeTestId != null) {
                  controller.selectTest(_activeTestId!);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: selected ? AppColors.accent.withOpacity(0.08) : AppColors.panelLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: borderColor.withOpacity(0.7), width: selected ? 1.5 : 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      color: borderColor.withOpacity(0.12),
                    ),
                    child: Icon(Icons.science_outlined, size: 18, color: borderColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                test.label,
                                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13),
                              ),
                            ),
                            Icon(stateIcon, size: 16, color: borderColor),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          stateLabel,
                          style: TextStyle(color: borderColor, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          test.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(height: 7),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: <Widget>[
                            _tinyIndicator('Duracao ${test.durationLabel}', AppColors.accent),
                            _tinyIndicator('Custo ${test.cost}M', AppColors.green),
                            _tinyIndicator('Afeta ${test.affectedVariables.length}', AppColors.yellow),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _TestVisualState _testStateFor(TestOption test, bool selected, TestRunOutcome? outcome) {
    if (_testInProgressId == test.id) {
      return _TestVisualState.running;
    }
    if (outcome != null) {
      if (!outcome.passed) {
        return _TestVisualState.doneFailure;
      }
      if (outcome.hasWarning) {
        return _TestVisualState.doneWarning;
      }
      return _TestVisualState.doneSuccess;
    }
    if (selected) {
      return _TestVisualState.selected;
    }
    return _TestVisualState.notRun;
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.panelBorder),
        boxShadow: <BoxShadow>[BoxShadow(color: AppColors.accent.withOpacity(0.03), blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(child: child),
        ],
      ),
    );
  }

  (Color, String) _statusStyle(MissionStatus status) {
    return switch (status) {
      MissionStatus.available => (AppColors.accent, 'DISPONIVEL'),
      MissionStatus.success => (AppColors.green, 'SUCESSO'),
      MissionStatus.locked => (AppColors.locked, 'BLOQUEADA'),
      MissionStatus.inProgress => (AppColors.orange, 'EM ANDAMENTO'),
      MissionStatus.partialSuccess => (AppColors.yellow, 'SUCESSO PARCIAL'),
      MissionStatus.failure => (AppColors.red, 'FALHA'),
    };
  }

  IconData _missionIcon(Mission mission) {
    final String t = mission.type.toLowerCase();
    if (t.contains('orbita') || t.contains('orbital')) {
      return Icons.travel_explore_outlined;
    }
    if (t.contains('luna')) {
      return Icons.dark_mode_outlined;
    }
    if (t.contains('mars') || t.contains('marte')) {
      return Icons.public_outlined;
    }
    if (t.contains('satelite')) {
      return Icons.satellite_alt_outlined;
    }
    return Icons.rocket_launch_outlined;
  }

  IconData _componentIcon(String system) {
    final String s = system.toLowerCase();
    if (s.contains('propuls')) {
      return Icons.rocket_launch_outlined;
    }
    if (s.contains('comunic')) {
      return Icons.wifi_tethering_outlined;
    }
    if (s.contains('estrutura')) {
      return Icons.shield_outlined;
    }
    if (s.contains('energia')) {
      return Icons.bolt_outlined;
    }
    return Icons.precision_manufacturing_outlined;
  }

  Widget _tinyIndicator(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.circle),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Color _variableColor(int index) {
    const List<Color> colors = <Color>[AppColors.accent, AppColors.green, AppColors.yellow, AppColors.purple];
    return colors[index % colors.length];
  }
}

enum _TestVisualState {
  notRun,
  selected,
  running,
  doneSuccess,
  doneWarning,
  doneFailure,
}
