import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import '../audio/sound_effect.dart';
import '../game/game_controller.dart';
import '../models/mission_result.dart';
import '../theme/app_theme.dart';
import '../widgets/game_cockpit_scaffold.dart';
import '../widgets/mission_report_card.dart';
import 'home_screen.dart';
import 'mission_tree_screen.dart';
import 'rivals_screen.dart';

class MissionReportScreen extends StatefulWidget {
  const MissionReportScreen({
    required this.controller,
    super.key,
  });

  final GameController controller;

  @override
  State<MissionReportScreen> createState() => _MissionReportScreenState();
}

class _MissionReportScreenState extends State<MissionReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioManager.instance.stopAmbient();
      AudioManager.instance.startBackgroundMusic(SoundEffect.mainTheme);

      final MissionResult? result = widget.controller.latestResult;
      final String resultType = result?.resultType.name ?? result?.summary ?? '';
      AudioManager.instance.playSuccessByResult(resultType);

      final bool hasUnlocks =
          (widget.controller.latestResult?.unlocks ?? widget.controller.latestReport?.unlocks ?? <String>[])
              .isNotEmpty;
      if (hasUnlocks) {
        AudioManager.instance.playSfx(SoundEffect.missionUnlocked);
        AudioManager.instance.playMilestoneAchieved();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final MissionResult? result = widget.controller.latestResult;
    final report = widget.controller.latestReport;
    final mission = widget.controller.selectedMission;

    if ((report == null && result == null) || mission == null) {
      return const Scaffold(body: Center(child: Text('Relatorio indisponivel.')));
    }

    final String resultLabel = result?.outcomeLabel ?? report!.resultLabel;
    final String resultDetail = result?.outcomeDetail ?? 'Resumo indisponível.';
    final _OutcomeVisual visual = _resolveOutcomeVisual(result, report!.success);

    final List<String> costLines = <String>[
      'Orcamento total: \$ ${result?.budgetTotal ?? report.budgetSpent}.0M',
      'Gasto da missao: \$ ${result?.budgetSpent ?? report.budgetSpent}.0M',
      'Economia final: \$ ${result?.budgetSaved ?? 0}.0M',
    ];

    final List<String> reputationLines = <String>[
      'Publica: ${_delta(result?.reputationPublicDelta ?? report.reputationDelta)}',
      'Cientifica: ${_delta(result?.reputationScientificDelta ?? 0)}',
      'Tecnica: ${_delta(result?.reputationIndustrialDelta ?? 0)}',
    ];

    final List<String> scienceLines = <String>[
      'Pontos cientificos: ${result?.sciencePoints ?? 0}',
      'Experimentos concluidos: ${result?.experimentsCompleted ?? 0}',
      'Descobertas relevantes: ${result?.discoveries ?? 0}',
    ];

    final List<String> unlockLines = (result?.unlocks ?? report.unlocks).isEmpty
        ? <String>['Nenhum desbloqueio adicional nesta missao.']
        : (result?.unlocks ?? report.unlocks);

    final List<String> lessonLines = (result?.lessonsLearned ?? report.lessonsLearned).isEmpty
        ? <String>['Sem licoes registradas.']
        : (result?.lessonsLearned ?? report.lessonsLearned);

    return GameCockpitScaffold(
      controller: widget.controller,
      title: 'Relatorio da Missao',
      activeTab: CockpitTab.reports,
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        children: <Widget>[
          _heroResultCard(
            missionName: mission.name,
            resultLabel: resultLabel,
            resultDetail: resultDetail,
            visual: visual,
          ),
          const SizedBox(height: AppSpacing.md),
          MissionReportCard(
            title: 'CUSTOS',
            accentColor: AppColors.green,
            icon: Icons.account_balance_wallet_outlined,
            lines: costLines,
          ),
          const SizedBox(height: AppSpacing.md),
          MissionReportCard(
            title: 'REPUTACAO',
            accentColor: AppColors.purple,
            icon: Icons.auto_awesome_outlined,
            lines: reputationLines,
          ),
          const SizedBox(height: AppSpacing.md),
          MissionReportCard(
            title: 'CIENCIA',
            accentColor: AppColors.accent,
            icon: Icons.science_outlined,
            lines: scienceLines,
          ),
          const SizedBox(height: AppSpacing.md),
          MissionReportCard(
            title: 'DESBLOQUEIOS',
            accentColor: AppColors.yellow,
            icon: Icons.lock_open_outlined,
            lines: unlockLines,
          ),
          const SizedBox(height: AppSpacing.md),
          MissionReportCard(
            title: 'LICOES APRENDIDAS',
            accentColor: AppColors.orange,
            icon: Icons.menu_book_outlined,
            lines: lessonLines,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                AudioManager.instance.playUi(SoundEffect.uiBack);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MissionTreeScreen(controller: widget.controller),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: visual.color.withOpacity(0.12),
                foregroundColor: visual.color,
                side: BorderSide(color: visual.color.withOpacity(0.55), width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.0),
              ),
              icon: const Icon(Icons.account_tree_outlined),
              label: const Text('VOLTAR PARA ARVORE'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    AudioManager.instance.playUi(SoundEffect.uiClick);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RivalsScreen(controller: widget.controller),
                      ),
                    );
                  },
                  icon: const Icon(Icons.leaderboard),
                  label: const Text('RIVAIS'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    AudioManager.instance.playUi(SoundEffect.uiBack);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => HomeScreen(controller: widget.controller),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('INÍCIO'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _heroResultCard({
    required String missionName,
    required String resultLabel,
    required String resultDetail,
    required _OutcomeVisual visual,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: visual.color.withOpacity(0.35), width: 1.2),
        boxShadow: <BoxShadow>[
          BoxShadow(color: visual.color.withOpacity(0.08), blurRadius: 18),
        ],
      ),
      child: Column(
        children: <Widget>[
          const Text(
            'RESULTADO FINAL',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[visual.color.withOpacity(0.22), visual.color.withOpacity(0.04)],
              ),
              border: Border.all(color: visual.color, width: 3),
              boxShadow: <BoxShadow>[
                BoxShadow(color: visual.color.withOpacity(0.25), blurRadius: 20, spreadRadius: 1),
              ],
            ),
            child: Icon(visual.icon, size: 58, color: visual.color),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            resultLabel.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: visual.color,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            missionName,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            resultDetail,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.45, fontSize: 13),
          ),
        ],
      ),
    );
  }

  _OutcomeVisual _resolveOutcomeVisual(MissionResult? result, bool reportSuccess) {
    if (result == null) {
      return reportSuccess
          ? const _OutcomeVisual(AppColors.green, Icons.workspace_premium_outlined)
          : const _OutcomeVisual(AppColors.red, Icons.error_outline);
    }

    return switch (result.resultType) {
      MissionOutcome.fullSuccess => const _OutcomeVisual(AppColors.green, Icons.workspace_premium_outlined),
      MissionOutcome.partialSuccess => const _OutcomeVisual(AppColors.yellow, Icons.star_half_outlined),
      MissionOutcome.failure => const _OutcomeVisual(AppColors.red, Icons.cancel_outlined),
      MissionOutcome.aborted => const _OutcomeVisual(AppColors.orange, Icons.shield_outlined),
    };
  }

  String _delta(int value) => value >= 0 ? '+$value' : '$value';
}

class _OutcomeVisual {
  const _OutcomeVisual(this.color, this.icon);

  final Color color;
  final IconData icon;
}
