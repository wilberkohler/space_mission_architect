import 'package:flutter/material.dart';

class TeamAllocationCard extends StatelessWidget {
  const TeamAllocationCard({
    required this.name,
    required this.assigned,
    required this.recommended,
    required this.onChanged,
    super.key,
  });

  final String name;
  final int assigned;
  final int recommended;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('$name ($assigned/$recommended)'),
            Slider(
              min: 0,
              max: recommended.toDouble(),
              divisions: recommended,
              value: assigned.toDouble(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
