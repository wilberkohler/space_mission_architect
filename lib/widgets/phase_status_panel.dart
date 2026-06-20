import 'package:flutter/material.dart';

import '../models/mission_phase.dart';

class PhaseStatusPanel extends StatelessWidget {
  const PhaseStatusPanel({
    required this.phases,
    required this.activeIndex,
    super.key,
  });

  final List<MissionPhase> phases;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(phases.length, (int i) {
        final MissionPhase phase = phases[i];
        final bool active = i == activeIndex;
        final bool completed = i < activeIndex;
        final Color color = completed
            ? Colors.greenAccent
            : active
                ? Theme.of(context).colorScheme.primary
                : Colors.white30;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: active ? 1.5 : 1),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                completed ? Icons.check_circle : Icons.adjust,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(phase.name)),
              Text('${phase.targetAltitudeKm.toStringAsFixed(0)} km'),
            ],
          ),
        );
      }),
    );
  }
}
