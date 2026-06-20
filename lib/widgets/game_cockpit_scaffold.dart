import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import '../audio/sound_effect.dart';
import '../game/game_controller.dart';
import '../theme/app_theme.dart';
import 'compact_mission_header.dart';

enum CockpitTab { tree, planning, mission, reports, menu }

class GameCockpitScaffold extends StatelessWidget {
  const GameCockpitScaffold({
    required this.controller,
    required this.title,
    required this.activeTab,
    required this.body,
    super.key,
    this.onTabSelected,
    this.trailing,
  });

  final GameController controller;
  final String title;
  final CockpitTab activeTab;
  final Widget body;
  final ValueChanged<CockpitTab>? onTabSelected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final agency = controller.selectedAgency;
    final int year = controller.selectedMission?.year ?? (controller.missions.isEmpty ? 1960 : controller.missions.first.year);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppColors.bg, AppColors.bgDeep],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: <Widget>[
                CompactMissionHeader(
                  pageTitle: title,
                  selectedAgency: agency,
                  currentYear: year,
                  budget: controller.budgetM,
                  careerTitle: 'N${controller.playerCareer.level} ${controller.playerCareer.title}',
                  scienceScore: controller.currentReputation.scientific,
                  industryScore: controller.currentReputation.technical,
                  reputationScore: controller.currentReputation.public,
                  trailing: trailing,
                ),
                const SizedBox(height: 8),
                Expanded(child: body),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.panelBorder),
                    boxShadow: <BoxShadow>[
                      BoxShadow(color: AppColors.accent.withOpacity(0.04), blurRadius: 12),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _navItem(CockpitTab.tree, Icons.account_tree_outlined, 'Árvore'),
                      _navItem(CockpitTab.planning, Icons.assignment_outlined, 'Planejamento'),
                      _navItem(CockpitTab.mission, Icons.rocket_launch_outlined, 'Missão'),
                      _navItem(CockpitTab.reports, Icons.insert_chart_outlined, 'Relatórios'),
                      _navItem(CockpitTab.menu, Icons.menu, 'Menu'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(CockpitTab tab, IconData icon, String label) {
    final bool selected = activeTab == tab;
    final Color iconColor = selected ? AppColors.accent : AppColors.textSecondary;
    return InkWell(
      onTap: onTabSelected == null
          ? null
          : () {
              AudioManager.instance.play(SoundEffect.tabSwitch);
              onTabSelected!(tab);
            },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: selected
              ? Border.all(color: AppColors.accent.withOpacity(0.4), width: 1)
              : null,
          boxShadow: selected
              ? <BoxShadow>[BoxShadow(color: AppColors.accent.withOpacity(0.14), blurRadius: 10)]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
