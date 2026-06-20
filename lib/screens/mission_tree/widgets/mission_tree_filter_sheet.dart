import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../mission_tree_filter.dart';

class MissionTreeFilterSheet extends StatelessWidget {
  const MissionTreeFilterSheet({
    required this.currentFilter,
    super.key,
  });

  final MissionTreeFilter currentFilter;

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final MissionTreeFilter option in MissionTreeFilter.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    option == currentFilter
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: option == currentFilter
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
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(option),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
