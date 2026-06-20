import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import '../audio/sound_effect.dart';
import '../game/game_controller.dart';
import '../models/agency.dart';
import '../models/mission.dart';
import '../models/reputation.dart';
import '../models/rival.dart';
import '../theme/app_theme.dart';
import '../widgets/shared/empty_state.dart';
import '../widgets/shared/metric_tile.dart';
import '../widgets/shared/primary_objective_card.dart';
import '../widgets/shared/section_header.dart';
import '../widgets/shared/space_panel.dart';
import '../widgets/shared/status_pill.dart';
import 'mission_tree_screen.dart';
import 'rivals_screen.dart';

class CampaignHubScreen extends StatelessWidget {
  const CampaignHubScreen({
    required this.controller,
    super.key,
  });

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final Agency? agency = controller.selectedAgency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Central da Campanha'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: () {
            AudioManager.instance.playUi(SoundEffect.uiBack);
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppColors.bg, AppColors.bgDeep],
          ),
        ),
        child: SafeArea(
          top: false,
          child: agency == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: EmptyState(
                        icon: Icons.business_outlined,
                        title: 'Selecione uma agência',
                        message:
                            'A campanha precisa de uma agência ativa antes de mostrar missões, orçamento e rivais.',
                        action: ElevatedButton.icon(
                          onPressed: () {
                            AudioManager.instance.playUi(SoundEffect.uiBack);
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Voltar'),
                        ),
                      ),
                    ),
                  ),
                )
              : _CampaignHubContent(controller: controller, agency: agency),
        ),
      ),
    );
  }
}

class _CampaignHubContent extends StatelessWidget {
  const _CampaignHubContent({
    required this.controller,
    required this.agency,
  });

  final GameController controller;
  final Agency agency;

  @override
  Widget build(BuildContext context) {
    final Mission? recommendedMission = _recommendedMission;
    final int year = recommendedMission?.year ??
        controller.selectedMission?.year ??
        (controller.missions.isEmpty ? 1960 : controller.missions.first.year);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= 980;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            _campaignHeader(year),
            const SizedBox(height: AppSpacing.lg),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      flex: 7,
                      child: _objectiveSection(context, recommendedMission)),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(flex: 5, child: _sideColumn(context)),
                ],
              )
            else ...<Widget>[
              _objectiveSection(context, recommendedMission),
              const SizedBox(height: AppSpacing.lg),
              _sideColumn(context),
            ],
          ],
        );
      },
    );
  }

  Mission? get _recommendedMission {
    for (final Mission mission in controller.missions) {
      if (mission.status == MissionStatus.available &&
          controller.canAccessMission(mission)) {
        return mission;
      }
    }
    return null;
  }

  Widget _campaignHeader(int year) {
    final Reputation reputation = controller.currentReputation;

    return SpacePanel(
      accentColor: agency.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              StatusPill(
                label: agency.country,
                icon: Icons.public_outlined,
                color: agency.color,
              ),
              StatusPill(
                label: 'Ano $year',
                icon: Icons.calendar_month_outlined,
                color: AppColors.yellow,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            agency.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            agency.specialty,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _metricWrap(<Widget>[
            MetricTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Orçamento',
              value: '${controller.budgetM}M',
              subtitle: 'Disponível',
              color: AppColors.green,
            ),
            MetricTile(
              icon: Icons.badge_outlined,
              title: 'Cargo',
              value: 'N${controller.playerCareer.level}',
              subtitle: controller.playerCareer.title,
              color: AppColors.purple,
            ),
            MetricTile(
              icon: Icons.groups_outlined,
              title: 'Pública',
              value: '${reputation.public}',
              subtitle: 'Reputação',
              color: AppColors.accent,
            ),
            MetricTile(
              icon: Icons.science_outlined,
              title: 'Científica',
              value: '${reputation.scientific}',
              subtitle: 'Reputação',
              color: AppColors.yellow,
            ),
            MetricTile(
              icon: Icons.engineering_outlined,
              title: 'Técnica',
              value: '${reputation.technical}',
              subtitle: 'Reputação',
              color: AppColors.orange,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _objectiveSection(BuildContext context, Mission? mission) {
    if (mission == null) {
      return EmptyState(
        icon: Icons.lock_clock_outlined,
        title: 'Nenhuma missão disponível',
        message:
            'No momento não há uma missão liberada para esta campanha. Revise a árvore para entender bloqueios e próximos requisitos.',
        action: ElevatedButton.icon(
          onPressed: () => _openMissionTree(context),
          icon: const Icon(Icons.account_tree_outlined),
          label: const Text('Abrir árvore'),
        ),
      );
    }

    return PrimaryObjectiveCard(
      title: mission.name,
      description:
          'Esta é a próxima missão recomendada para continuar a campanha. Revise o briefing na árvore, confirme os requisitos e avance para o planejamento quando estiver pronto.',
      buttonLabel: 'Escolher missão',
      onPressed: () => _openMissionTree(context),
      accentColor: AppColors.accent,
      details: <Widget>[
        StatusPill(
          label: '${mission.year}',
          icon: Icons.calendar_month_outlined,
          color: AppColors.yellow,
        ),
        StatusPill(
          label: mission.type,
          icon: Icons.rocket_launch_outlined,
          color: AppColors.accent,
        ),
        StatusPill(
          label: 'Dificuldade ${mission.difficulty}',
          icon: Icons.speed_outlined,
          color: AppColors.orange,
        ),
        StatusPill(
          label: 'Complexidade ${mission.complexityLevel}',
          icon: Icons.hub_outlined,
          color: AppColors.purple,
        ),
        StatusPill(
          label: 'Mín. ${mission.minimumBudget}M',
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.green,
        ),
        StatusPill(
          label: 'Rec. ${mission.recommendedBudget}M',
          icon: Icons.check_circle_outline,
          color: AppColors.green,
        ),
      ],
    );
  }

  Widget _sideColumn(BuildContext context) {
    return Column(
      children: <Widget>[
        _progressSection(),
        const SizedBox(height: AppSpacing.lg),
        _rivalsSection(context),
        const SizedBox(height: AppSpacing.lg),
        _quickActions(context),
      ],
    );
  }

  Widget _progressSection() {
    final List<Mission> missions = controller.missions;
    final int success = _count(MissionStatus.success);
    final int partial = _count(MissionStatus.partialSuccess);
    final int failure = _count(MissionStatus.failure);
    final int available = _count(MissionStatus.available);
    final int locked = _count(MissionStatus.locked);

    return SpacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHeader(
            title: 'Progresso da campanha',
            subtitle: 'Estado atual da árvore de missões.',
          ),
          const SizedBox(height: AppSpacing.md),
          _metricWrap(<Widget>[
            MetricTile(
              icon: Icons.account_tree_outlined,
              title: 'Total',
              value: '${missions.length}',
              subtitle: 'Missões',
              color: AppColors.accent,
            ),
            MetricTile(
              icon: Icons.verified_outlined,
              title: 'Sucesso',
              value: '$success',
              subtitle: 'Concluídas',
              color: AppColors.green,
            ),
            MetricTile(
              icon: Icons.star_half_outlined,
              title: 'Parcial',
              value: '$partial',
              subtitle: 'Sucesso parcial',
              color: AppColors.yellow,
            ),
            MetricTile(
              icon: Icons.error_outline,
              title: 'Falhas',
              value: '$failure',
              subtitle: 'Missões falhas',
              color: AppColors.red,
            ),
            MetricTile(
              icon: Icons.play_circle_outline,
              title: 'Disponíveis',
              value: '$available',
              subtitle: 'Prontas para avaliar',
              color: AppColors.accent,
            ),
            MetricTile(
              icon: Icons.lock_outline,
              title: 'Bloqueadas',
              value: '$locked',
              subtitle: 'Com requisitos',
              color: AppColors.textMuted,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _rivalsSection(BuildContext context) {
    final List<Rival> rivals = <Rival>[...controller.rivals]
      ..sort((Rival a, Rival b) => b.score.compareTo(a.score));
    final List<Rival> topRivals = rivals.take(3).toList();

    return SpacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionHeader(
            title: 'Rivais',
            subtitle: 'Ranking resumido das agências concorrentes.',
            action: TextButton.icon(
              onPressed: () => _openRivals(context),
              icon: const Icon(Icons.leaderboard_outlined, size: 16),
              label: const Text('Ver rivais'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (topRivals.isEmpty)
            const EmptyState(
              icon: Icons.leaderboard_outlined,
              title: 'Sem dados de rivais',
              message:
                  'Ainda não há ranking suficiente para comparar a campanha.',
            )
          else
            Column(
              children: <Widget>[
                for (int i = 0; i < topRivals.length; i++) ...<Widget>[
                  _rivalRow(i + 1, topRivals[i]),
                  if (i != topRivals.length - 1)
                    const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return SpacePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHeader(
            title: 'Ações rápidas',
            subtitle: 'Continue a campanha pelo caminho principal.',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () => _openMissionTree(context),
                icon: const Icon(Icons.account_tree_outlined),
                label: const Text('Escolher missão'),
              ),
              OutlinedButton.icon(
                onPressed: () => _openRivals(context),
                icon: const Icon(Icons.leaderboard_outlined),
                label: const Text('Ver rivais'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  AudioManager.instance.playUi(SoundEffect.uiBack);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rivalRow(int rank, Rival rival) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.panelBorderSubtle),
      ),
      child: Row(
        children: <Widget>[
          StatusPill(
            label: '#$rank',
            color: rank == 1 ? AppColors.yellow : AppColors.accent,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  rival.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rival.milestone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${rival.score} pts',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricWrap(List<Widget> children) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 640;
        final double width = compact
            ? constraints.maxWidth
            : ((constraints.maxWidth - AppSpacing.md) / 2).clamp(220.0, 420.0);

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: children
              .map(
                (Widget child) => SizedBox(
                  width: width,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }

  int _count(MissionStatus status) {
    return controller.missions
        .where((Mission mission) => mission.status == status)
        .length;
  }

  void _openMissionTree(BuildContext context) {
    AudioManager.instance.playUi(SoundEffect.uiConfirm);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MissionTreeScreen(controller: controller),
      ),
    );
  }

  void _openRivals(BuildContext context) {
    AudioManager.instance.playUi(SoundEffect.uiClick);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RivalsScreen(controller: controller),
      ),
    );
  }
}
