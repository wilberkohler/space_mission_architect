import 'package:flutter/material.dart';

import '../models/mission_log_entry.dart';
import '../utils/formatters.dart';

class EventLogPanel extends StatelessWidget {
  const EventLogPanel({
    required this.entries,
    super.key,
  });

  final List<MissionLogEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, __) => const Divider(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final MissionLogEntry entry = entries[index];
        return Row(
          key: ValueKey<String>('event-log-${entry.tSec}-${entry.message}'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              formatDuration(entry.tSec),
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                entry.message,
                style: TextStyle(
                  color: entry.isCritical ? Theme.of(context).colorScheme.error : Colors.white,
                  fontWeight: entry.isCritical ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
