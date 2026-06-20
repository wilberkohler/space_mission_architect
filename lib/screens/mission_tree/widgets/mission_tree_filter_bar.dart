import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/shared/status_pill.dart';
import '../mission_tree_filter.dart';

class MissionTreeFilterBar extends StatelessWidget {
  const MissionTreeFilterBar({
    required this.controller,
    required this.filter,
    required this.resultCount,
    required this.hasActiveFilters,
    required this.onChanged,
    required this.onOpenFilters,
    required this.onClear,
    super.key,
  });

  final TextEditingController controller;
  final MissionTreeFilter filter;
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
                label: 'Filtro: ${filter.label}',
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
