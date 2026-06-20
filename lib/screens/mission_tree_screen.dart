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
import 'mission_tree/mission_tree_filter.dart';
import 'mission_tree/widgets/compact_graph_hint.dart';
import 'mission_tree/widgets/mission_tree_empty_state.dart';
import 'mission_tree/widgets/mission_tree_filter_bar.dart';
import 'mission_tree/widgets/mission_tree_filter_sheet.dart';
import 'mission_tree/widgets/recommended_mission_banner.dart';
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
  MissionTreeFilter _filter = MissionTreeFilter.all;
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
      if (!_filter.matches(mission)) {
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

  Mission? get _recommendedMission {
    final List<Mission> available = widget.controller.missions
        .where((Mission mission) => mission.status == MissionStatus.available)
        .toList()
      ..sort((Mission a, Mission b) {
        final int yearCompare = a.year.compareTo(b.year);
        if (yearCompare != 0) {
          return yearCompare;
        }
        final int difficultyCompare = a.difficulty.compareTo(b.difficulty);
        if (difficultyCompare != 0) {
          return difficultyCompare;
        }
        return a.complexityLevel.compareTo(b.complexityLevel);
      });

    return available.firstOrNull;
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
      _filter = MissionTreeFilter.all;
      _query = '';
      _searchController.clear();
      _selectedMissionId = widget.controller.missions.isNotEmpty
          ? widget.controller.missions.first.id
          : null;
    });
  }

  Future<void> _showFilterSheet() async {
    AudioManager.instance.playUi(SoundEffect.uiClick);
    final MissionTreeFilter? selected =
        await showModalBottomSheet<MissionTreeFilter>(
      context: context,
      backgroundColor: AppColors.panel,
      showDragHandle: true,
      builder: (BuildContext context) =>
          MissionTreeFilterSheet(currentFilter: _filter),
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

  void _selectRecommendedMission(Mission mission) {
    AudioManager.instance.playUi(SoundEffect.uiConfirm);
    setState(() => _selectedMissionId = mission.id);
  }

  void _showAvailableMissions(Mission mission) {
    AudioManager.instance.playUi(SoundEffect.uiClick);
    setState(() {
      _filter = MissionTreeFilter.available;
      _query = '';
      _searchController.clear();
      _selectedMissionId = mission.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final GameController controller = widget.controller;
    final List<Mission> filteredMissions = _filteredMissions;
    final Mission? selected = _selectedMission;
    final Mission? recommended = _recommendedMission;
    final bool recommendedVisible = recommended != null &&
        filteredMissions.any((Mission mission) => mission.id == recommended.id);
    final bool hasActiveFilters =
        _filter != MissionTreeFilter.all || _query.trim().isNotEmpty;

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
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints screenConstraints) {
          const double shortScreenContentHeight = 560;
          final Widget content = Column(
            children: <Widget>[
              MissionTreeFilterBar(
                controller: _searchController,
                filter: _filter,
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
              RecommendedMissionBanner(
                mission: recommended,
                missionVisible: recommendedVisible,
                onSelect: recommended == null
                    ? null
                    : () => _selectRecommendedMission(recommended),
                onShowAvailable: recommended == null
                    ? null
                    : () => _showAvailableMissions(recommended),
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
                          ? MissionTreeEmptyState(onClear: _clearFilters)
                          : Stack(
                              children: <Widget>[
                                MissionTreeGraph(
                                  missions: filteredMissions,
                                  selectedMissionId: selected?.id,
                                  onSelectMission: (Mission mission) {
                                    AudioManager.instance
                                        .playUi(SoundEffect.tabSwitch);
                                    setState(
                                        () => _selectedMissionId = mission.id);
                                  },
                                ),
                                if (constraints.maxWidth < 860)
                                  const Positioned(
                                    left: AppSpacing.sm,
                                    right: AppSpacing.sm,
                                    bottom: AppSpacing.sm,
                                    child: CompactGraphHint(),
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
          );

          if (screenConstraints.maxHeight >= shortScreenContentHeight) {
            return content;
          }

          return SingleChildScrollView(
            child: SizedBox(
              height: shortScreenContentHeight,
              child: content,
            ),
          );
        },
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
