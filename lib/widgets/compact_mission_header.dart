import 'package:flutter/material.dart';

import '../models/agency.dart';
import '../theme/app_theme.dart';

class CompactMissionHeader extends StatelessWidget {
  const CompactMissionHeader({
    required this.pageTitle,
    required this.selectedAgency,
    required this.currentYear,
    required this.budget,
    required this.careerTitle,
    required this.scienceScore,
    required this.industryScore,
    required this.reputationScore,
    super.key,
    this.trailing,
  });

  final String pageTitle;
  final Agency? selectedAgency;
  final int currentYear;
  final int budget;
  final String? careerTitle;
  final int scienceScore;
  final int industryScore;
  final int reputationScore;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 860;
        final Widget statusBlock = _statusBlock(compact: compact);

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      pageTitle,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.35,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(alignment: Alignment.centerRight, child: statusBlock),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                pageTitle,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.45,
                ),
              ),
            ),
            if (trailing != null) ...<Widget>[
              trailing!,
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(child: statusBlock),
          ],
        );
      },
    );
  }

  Widget _statusBlock({required bool compact}) {
    final String agencyName = selectedAgency?.name ?? 'Agência Orbital';
    final List<Widget> chips = <Widget>[
      _chip(Icons.public, agencyName, AppColors.accent),
      _chip(Icons.calendar_today_outlined, currentYear.toString(),
          AppColors.textMuted),
      _chip(Icons.attach_money_outlined, '${budget}M', AppColors.green),
      if (careerTitle != null && careerTitle!.isNotEmpty)
        _chip(Icons.workspace_premium_outlined, careerTitle!, AppColors.yellow),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.panelBorderSubtle),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: compact ? 440 : 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Wrap(
              alignment: WrapAlignment.end,
              runAlignment: WrapAlignment.end,
              spacing: 6,
              runSpacing: 6,
              children: chips,
            ),
            const SizedBox(height: 7),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                _scoreDot('Ciência', scienceScore, AppColors.accent),
                _scoreDot('Indústria', industryScore, AppColors.yellow),
                _scoreDot('Reputação', reputationScore, AppColors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, Color color) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(AppRadius.circle),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreDot(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.circle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '$label $value',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
