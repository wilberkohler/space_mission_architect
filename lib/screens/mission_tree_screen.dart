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
  String? _selectedMissionId;

  @override
  void initState() {
    super.initState();
    _selectedMissionId = widget.controller.selectedMission?.id ??
        (widget.controller.missions.isNotEmpty ? widget.controller.missions.first.id : null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioManager.instance.startBackgroundMusic(SoundEffect.mainTheme);
    });
  }

  Mission? get _selectedMission {
    final List<Mission> missions = widget.controller.missions;
    if (missions.isEmpty) {
      return null;
    }
    return missions.where((Mission m) => m.id == _selectedMissionId).firstOrNull ?? missions.first;
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

  @override
  Widget build(BuildContext context) {
    final GameController controller = widget.controller;
    final Mission? selected = _selectedMission;

    return GameCockpitScaffold(
      controller: controller,
      title: 'Árvore de Missões',
      activeTab: CockpitTab.tree,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            tooltip: 'Filtros',
            onPressed: () {},
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
                  child: MissionTreeGraph(
                    missions: controller.missions,
                    selectedMissionId: selected?.id,
                    onSelectMission: (Mission mission) {
                      AudioManager.instance.playUi(SoundEffect.tabSwitch);
                      setState(() => _selectedMissionId = mission.id);
                    },
                  ),
                );

                if (selected == null) {
                  return graph;
                }

                final List<String> lockReasons = controller.missionBlockReasons(selected);
                final bool canPlan = lockReasons.isEmpty;
                final Widget details = MissionDetailPanel(
                  key: ValueKey<String>('mission-detail-${selected.id}'),
                  mission: selected,
                  canPlan: canPlan,
                  lockReasons: lockReasons,
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
                    details,
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
}
