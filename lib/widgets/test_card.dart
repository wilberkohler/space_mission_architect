import 'package:flutter/material.dart';

class TestCard extends StatelessWidget {
  const TestCard({
    required this.name,
    required this.cost,
    required this.duration,
    required this.selected,
    super.key,
    this.onTap,
  });

  final String name;
  final int cost;
  final int duration;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(name),
        subtitle: Text('Custo ${cost}M • ${duration} min'),
        trailing: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
      ),
    );
  }
}
