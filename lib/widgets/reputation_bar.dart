import 'package:flutter/material.dart';

class ReputationBar extends StatelessWidget {
  const ReputationBar({
    required this.value,
    super.key,
  });

  final int value;

  @override
  Widget build(BuildContext context) {
    final double normalized = (value / 100).clamp(0, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Reputacao'),
            Text('$value/100'),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: normalized,
            backgroundColor: const Color(0xFF25324A),
          ),
        ),
      ],
    );
  }
}
