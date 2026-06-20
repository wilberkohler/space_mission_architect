import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import '../audio/sound_effect.dart';
import '../game/game_controller.dart';
import '../models/agency.dart';
import '../models/mission.dart';
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
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AudioManager.instance.playUi(SoundEffect.uiBack);
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Ver rivais',
            onPressed: () => _openRivals(context),
            icon: const Icon(Icons.leaderboard_outlined),
          ),
        ],
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
          child: agency == null ? _noAgencyState(context) : _campaignContent(context, agency),
        ),
      ),
    );
  }

  Widget _noAgencyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: EmptyState(
          icon: Icons.public_off_outlined,
          title: 'Nenhuma agência selecionada',
          message: 'Escolha uma agência para iniciar a campanha e liberar o painel de comando.',
          actionLabel: 'Voltar para seleção',
          onAction: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _campaignContent(BuildContext context, Agency agency) {
    final Mission? recommendedMission = _recommendedMission();
    final _MissionStats stats = _MissionStats.from(controller.missions);
    final int currentYear = controller.selectedMission?.year ??
        (controller.missions.isEmpty ? 1960 : controller.missions.first.year);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= 980;
        final Widget overview = _overviewColumn(context, agency, currentYear, recommendedMission, stats);
        final Widget side = _sideColumn(context, stats);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _heroHeader(agency, currentYear),
              const SizedBox(height: AppSpacing.lg),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(flex: 3, child: overview),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(flex: 2, child: side),
                  ],
                )
              else
                Column(
                  children: <Widget>[
                    overview,
                    const SizedBox(height: AppSpacing.lg),
                    side,
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _heroHeader(Agency agency, int currentYear) {
    return SpacePanel(
      accentColor: agency.color,
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: AppDecorations.statusBadge(agency.color),
            child: Icon(Icons.satellite_alt_outlined, color: agency.color, size: 26),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'COMANDO DA CAMPANHA',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  agency.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${agency.country} • ${agency.specialty}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          StatusPill(label: 'Ano $currentYear', icon: Icons.calendar_today_outlined, color: AppColors.yellow),
        ],
      ),
    );
  }

  Widget _overviewColumn(
    BuildContext context,
    Agency agency,
    int currentYear,
    Mission? recommendedMission,
    _MissionStats stats,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionHeader(
          title: 'Estado da campanha',
          subtitle: 'Recursos principais para decidir o próximo passo.',
          trailing: StatusPill(label: 'N${controller.playerCareer.level}', icon: Icons.workspace_premium_outlined),
        ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            SizedBox(
              width: 250,
              child: MetricTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'ORÇAMENTO',
                value: '${controller.budgetM}M',
                subtitle: 'Teto atual da campanha',
                color: AppColors.green,
              ),
            ),
            SizedBox(
              width: 250,
              child: MetricTile(
                icon: Icons.auto_awesome_outlined,
                title: 'REPUTAÇÃO PÚBLICA',
                value: controller.currentReputation.public.toString(),
                subtitle: 'Apoio e confiança externa',
                color: AppColors.purple,
              ),
            ),
            SizedBox(
              width: 250,
              child: MetricTile(
                icon: Icons.science_outlined,
                title: 'CIÊNCIA',
                value: controller.currentReputation.scientific.toString(),
                subtitle: 'Prestígio científico',
                color: AppColors.accent,
              ),
            ),
            SizedBox(
              width: 250,
              child: MetricTile(
                icon: Icons.engineering_outlined,
                title: 'TÉCNICA',
                value: controller.currentReputation.technical.toString(),
                subtitle: 'Capacidade industrial',
                color: AppColors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (recommendedMission == null)
          EmptyState(
            icon: Icons.lock_clock_outlined,
            title: 'Nenhuma missão disponível agora',
            message: 'Revise os requisitos da árvore de missões para entender o próximo desbloqueio possível.',
            actionLabel: 'Abrir árvore de missões',
            onAction: () => _openMissionTree(context),
          )
        else
          PrimaryObjectiveCard(
            title: recommendedMission.name,
            badgeLabel: 'Próxima missão',
            description: _recommendedMissionDescription(recommendedMission),
            actionLabel: 'Escolher missão',
            onAction: () => _openMissionTree(context),
            accentColor: AppColors.accent,
          ),
        const SizedBox(height: AppSpacing.lg),
        _campaignProgress(stats),
      ],
    );
  }

  Widget _sideColumn(BuildContext context, _MissionStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionHeader(
          title: 'Rivais em destaque',
          subtitle: 'A corrida espacial continua enquanto sua agência avança.',
          trailing: TextButton.icon(
            onPressed: () => _openRivals(context),
            icon: const Icon(Icons.leaderboard_outlined, size: 15),
            label: const Text('Ver todos'),
          ),
        ),
        _rivalsSummary(),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(
          title: 'Ações rápidas',
          subtitle: 'Escolha o próximo painel de comando.',
        ),
        SpacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () => _openMissionTree(context),
                icon: const Icon(Icons.account_tree_outlined),
                label: const Text('Escolher missão'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => _openRivals(context),
                icon: const Icon(Icons.leaderboard_outlined),
                label: const Text('Ver rivais'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _campaignProgress(_MissionStats stats) {
    final double progress = stats.total == 0 ? 0 : stats.completed / stats.total;

    return SpacePanel(
      accentColor: AppColors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHeader(
            title: 'Progresso da campanha',
            subtitle: 'Resumo das missões conhecidas no programa espacial.',
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.circle),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.panelBorder,
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              StatusPill(label: 'Total ${stats.total}', icon: Icons.public_outlined, color: AppColors.textSecondary),
              StatusPill(label: 'Disponíveis ${stats.available}', icon: Icons.rocket_launch_outlined, color: AppColors.accent),
              StatusPill(label: 'Sucesso ${stats.success}', icon: Icons.check_circle_outline, color: AppColors.green),
              StatusPill(label: 'Parciais ${stats.partial}', icon: Icons.star_half_outlined, color: AppColors.yellow),
              StatusPill(label: 'Falhas ${stats.failure}', icon: Icons.cancel_outlined, color: AppColors.red),
              StatusPill(label: 'Bloqueadas ${stats.locked}', icon: Icons.lock_outline, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rivalsSummary() {
    final rivals = controller.rivals..sort((a, b) => b.score.compareTo(a.score));
    final topRivals = rivals.take(3).toList();

    if (topRivals.isEmpty) {
      return const EmptyState(
        icon: Icons.leaderboard_outlined,
        title: 'Sem rivais registrados',
        message: 'Quando a campanha avançar, rivais e manchetes aparecerão aqui.',
      );
    }

    return SpacePanel(
      child: Column(
        children: <Widget>[
          for (int i = 0; i < topRivals.length; i++) ...<Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.panelLight,
                  child: Text('#${i + 1}', style: const TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        topRivals[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        topRivals[i].headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                StatusPill(label: '${topRivals[i].score}', color: AppColors.yellow),
              ],
            ),
            if (i < topRivals.length - 1) const Divider(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }

  Mission? _recommendedMission() {
    final List<Mission> available = controller.missions
        .where((Mission mission) => mission.status == MissionStatus.available)
        .toList()
      ..sort((Mission a, Mission b) {
        final int yearOrder = a.year.compareTo(b.year);
        if (yearOrder != 0) {
          return yearOrder;
        }
        final int difficultyOrder = a.difficulty.compareTo(b.difficulty);
        if (difficultyOrder != 0) {
          return difficultyOrder;
        }
        return a.name.compareTo(b.name);
      });

    if (available.isEmpty) {
      return null;
    }

    final Mission? selected = controller.selectedMission;
    if (selected != null && selected.status == MissionStatus.available) {
      return selected;
    }

    return available.first;
  }

  String _recommendedMissionDescription(Mission mission) {
    return '${mission.year} • ${mission.type} • Complexidade ${mission.complexityLevel}\n'
        'Orçamento mínimo ${mission.minimumBudget}M, recomendado ${mission.recommendedBudget}M. '
        'Planeje variáveis, equipe e testes antes de autorizar o lançamento.';
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

class _MissionStats {
  const _MissionStats({
    required this.total,
    required this.available,
    required this.locked,
    required this.success,
    required this.partial,
    required this.failure,
  });

  final int total;
  final int available;
  final int locked;
  final int success;
  final int partial;
  final int failure;

  int get completed => success + partial + failure;

  factory _MissionStats.from(List<Mission> missions) {
    return _MissionStats(
      total: missions.length,
      available: missions.where((Mission m) => m.status == MissionStatus.available).length,
      locked: missions.where((Mission m) => m.status == MissionStatus.locked).length,
      success: missions.where((Mission m) => m.status == MissionStatus.success).length,
      partial: missions.where((Mission m) => m.status == MissionStatus.partialSuccess).length,
      failure: missions.where((Mission m) => m.status == MissionStatus.failure).length,
    );
  }
}
