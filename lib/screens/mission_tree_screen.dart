import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import '../audio/sound_effect.dart';
import '../game/game_controller.dart';
import '../models/mission.dart';
import '../theme/app_theme.dart';
import '../widgets/game_cockpit_scaffold.dart';
import '../widgets/mission_detail_panel.dart';
import '../widgets/mission_legend.dart';
import '../widgets/mission_tree_graph.dart';
import '../widgets/shared/empty_state.dart';
import '../widgets/shared/status_pill.dart';
import 'mission_planning_screen.dart';
import 'rivals_screen.dart';

class MissionTreeScreen extends StatefulWidget {
  const MissionTreeScreen({
    required this.controller,
    super.key,
  });

  final GameController controller;

  @override
  State<MissionTreeScreen> createState() => _MissionTreeScreenState();
}

class _MissionTreeScreenState extends State<MissionTreeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedMissionId;
  _MissionTreeFilter _filter = _MissionTreeFilter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedMissionId = widget.controller.selectedMission?.id ??
        (widget.controller.missions.isNotEmpty
            ? widget.controller.missions.first.id
            : null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioManager.instance.startBackgroundMusic(SoundEffect.mainTheme);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Mission> get _filteredMissions {
    final String normalizedQuery = _normalize(_query);
    return widget.controller.missions.where((Mission mission) {
      final bool statusMatches = switch (_filter) {
        _MissionTreeFilter.all => true,
        _MissionTreeFilter.available =>
          mission.status == MissionStatus.available,
        _MissionTreeFilter.locked => mission.status == MissionStatus.locked,
        _MissionTreeFilter.success => mission.status == MissionStatus.success,
        _MissionTreeFilter.partial =>
          mission.status == MissionStatus.partialSuccess,
        _MissionTreeFilter.failure => mission.status == MissionStatus.failure,
      };
      if (!statusMatches) {
        return false;
      }
      if (normalizedQuery.isEmpty) {
        return true;
      }
      final String searchable = _normalize(
        '${mission.name} ${mission.type} ${mission.era} ${mission.year}',
      );
      return searchable.contains(normalizedQuery);
    }).toList();
  }

  Mission? get _selectedMission {
    final List<Mission> missions = _filteredMissions;
    if (missions.isEmpty) {
      return null;
    }
    return missions
            .where((Mission m) => m.id == _selectedMissionId)
            .firstOrNull ??
        missions.first;
  }

  void _openPlanning(Mission mission) {
    final GameController controller = widget.controller;
    AudioManager.instance.playUi(SoundEffect.uiConfirm);
    controller.selectMission(mission);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MissionPlanningScreen(controller: controller),
      ),
    );
  }

  void _clearFilters() {
    AudioManager.instance.playUi(SoundEffect.uiClick);
    setState(() {
      _filter = _MissionTreeFilter.all;
      _query = '';
      _searchController.clear();
      _selectedMissionId = widget.controller.missions.isNotEmpty
          ? widget.controller.missions.first.id
          : null;
    });
  }

  Future<void> _showFilterSheet() async {
    AudioManager.instance.playUi(SoundEffect.uiClick);
    final _MissionTreeFilter? selected =
        await showModalBottomSheet<_MissionTreeFilter>(
      context: context,
      backgroundColor: AppColors.panel,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Filtrar missões',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Escolha quais status devem aparecer no mapa da campanha.',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final _MissionTreeFilter option
                      in _MissionTreeFilter.values)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        option == _filter
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: option == _filter
                            ? AppColors.accent
                            : AppColors.textMuted,
                      ),
                      title: Text(
                        option.label,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        option.description,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                      onTap: () => Navigator.of(context).pop(option),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selected == null || selected == _filter) {
      return;
    }

    setState(() {
      _filter = selected;
      final List<Mission> missions = _filteredMissions;
      _selectedMissionId = missions.isNotEmpty ? missions.first.id : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final GameController controller = widget.controller;
    final List<Mission> filteredMissions = _filteredMissions;
    final Mission? selected = _selectedMission;
    final bool hasActiveFilters =
        _filter != _MissionTreeFilter.all || _query.trim().isNotEmpty;

    return GameCockpitScaffold(
      controller: controller,
      title: 'Árvore de Missões',
      activeTab: CockpitTab.tree,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            tooltip: 'Filtros',
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.filter_alt_outlined, size: 18),
          ),
          IconButton(
            tooltip: 'Painel de Rivais',
            onPressed: () {
              AudioManager.instance.playUi(SoundEffect.uiClick);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RivalsScreen(controller: controller),
                ),
              );
            },
            icon: const Icon(Icons.leaderboard_outlined, size: 18),
          ),
        ],
      ),
      onTabSelected: (CockpitTab tab) {
        if (tab == CockpitTab.planning && controller.selectedMission != null) {
          AudioManager.instance.playUi(SoundEffect.uiClick);
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MissionPlanningScreen(controller: controller),
            ),
          );
        }
      },
      body: Column(
        children: <Widget>[
          _MissionTreeFilterBar(
            controller: _searchController,
            filterLabel: _filter.label,
            resultCount: filteredMissions.length,
            hasActiveFilters: hasActiveFilters,
            onChanged: (String value) {
              setState(() {
                _query = value;
                final List<Mission> missions = _filteredMissions;
                _selectedMissionId =
                    missions.isNotEmpty ? missions.first.id : null;
              });
            },
            onOpenFilters: _showFilterSheet,
            onClear: _clearFilters,
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 1160;
                final Widget graph = Container(
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.panelBorder),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: filteredMissions.isEmpty
                      ? _MissionTreeEmptyState(onClear: _clearFilters)
                      : Stack(
                          children: <Widget>[
                            MissionTreeGraph(
                              missions: filteredMissions,
                              selectedMissionId: selected?.id,
                              onSelectMission: (Mission mission) {
                                AudioManager.instance
                                    .playUi(SoundEffect.tabSwitch);
                                setState(() => _selectedMissionId = mission.id);
                              },
                            ),
                            if (constraints.maxWidth < 860)
                              const Positioned(
                                left: AppSpacing.sm,
                                right: AppSpacing.sm,
                                bottom: AppSpacing.sm,
                                child: _CompactGraphHint(),
                              ),
                          ],
                        ),
                );

                if (selected == null) {
                  return graph;
                }

                final List<String> lockReasons =
                    controller.missionBlockReasons(selected);
                final bool canPlan = lockReasons.isEmpty;
                final Widget details = MissionDetailPanel(
                  key: ValueKey<String>('mission-detail-${selected.id}'),
                  mission: selected,
                  canPlan: canPlan,
                  lockReasons: lockReasons,
                  allMissions: controller.missions,
                  currentBudget: controller.budgetM,
                  currentReputation: controller.currentReputation.total,
                  currentCareerLevel: controller.playerCareer.level,
                  onPlan: () => _openPlanning(selected),
                );

                if (wide) {
                  return Row(
                    children: <Widget>[
                      Expanded(child: graph),
                      const SizedBox(width: AppSpacing.md),
                      SizedBox(width: 390, child: details),
                    ],
                  );
                }

                return Column(
                  children: <Widget>[
                    Expanded(child: graph),
                    const SizedBox(height: AppSpacing.sm),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: constraints.maxHeight * 0.46,
                      ),
                      child: SingleChildScrollView(child: details),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const MissionLegend(),
        ],
      ),
    );
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }
}

enum _MissionTreeFilter {
  all('Todas', 'Mostra todos os nós da campanha.'),
  available('Disponíveis', 'Missões prontas para avaliar e planejar.'),
  locked('Bloqueadas', 'Missões com requisitos pendentes.'),
  success('Concluídas', 'Missões finalizadas com sucesso.'),
  partial('Parciais', 'Missões com sucesso parcial.'),
  failure('Falhas', 'Missões finalizadas com falha.');

  const _MissionTreeFilter(this.label, this.description);

  final String label;
  final String description;
}

class _MissionTreeFilterBar extends StatelessWidget {
  const _MissionTreeFilterBar({
    required this.controller,
    required this.filterLabel,
    required this.resultCount,
    required this.hasActiveFilters,
    required this.onChanged,
    required this.onOpenFilters,
    required this.onClear,
  });

  final TextEditingController controller;
  final String filterLabel;
  final int resultCount;
  final bool hasActiveFilters;
  final ValueChanged<String> onChanged;
  final VoidCallback onOpenFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 680;
          final Widget search = TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpar busca',
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: onClear,
                    ),
              hintText: 'Buscar por nome, tipo, era ou ano',
              isDense: true,
            ),
          );
          final Widget actions = Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              StatusPill(
                label: 'Filtro: $filterLabel',
                icon: Icons.filter_alt_outlined,
                color:
                    hasActiveFilters ? AppColors.accent : AppColors.textMuted,
              ),
              StatusPill(
                label: '$resultCount missões',
                icon: Icons.account_tree_outlined,
                color: AppColors.yellow,
              ),
              OutlinedButton.icon(
                onPressed: onOpenFilters,
                icon: const Icon(Icons.tune, size: 16),
                label: const Text('Filtros'),
              ),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.restart_alt, size: 16),
                  label: const Text('Limpar'),
                ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                search,
                const SizedBox(height: AppSpacing.sm),
                actions,
              ],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(child: search),
              const SizedBox(width: AppSpacing.sm),
              Flexible(child: actions),
            ],
          );
        },
      ),
    );
  }
}

class _MissionTreeEmptyState extends StatelessWidget {
  const _MissionTreeEmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: EmptyState(
          icon: Icons.search_off_outlined,
          title: 'Nenhuma missão encontrada',
          message: 'Nenhuma missão encontrada para os filtros atuais.',
          action: ElevatedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Limpar busca e filtros'),
          ),
        ),
      ),
    );
  }
}

class _CompactGraphHint extends StatelessWidget {
  const _CompactGraphHint();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bgDeep.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(AppRadius.circle),
            border: Border.all(color: AppColors.panelBorder),
          ),
          child: const Text(
            'Arraste para navegar • use zoom para aproximar',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
