import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MissionEventLog extends StatelessWidget {
  const MissionEventLog({required this.events, super.key});

  final List<String> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum evento registrado',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      );
    }
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: events.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.panelBorder),
      itemBuilder: (BuildContext context, int index) {
        final bool isRecent = index == 0;
        return Padding(
          key: ValueKey<String>('mission-event-${events[index]}-$index'),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 5, right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecent ? AppColors.accent : AppColors.textMuted,
                ),
              ),
              Expanded(
                child: Text(
                  events[index],
                  style: TextStyle(
                    color: isRecent ? AppColors.textPrimary : AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: isRecent ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
