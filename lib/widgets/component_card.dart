import 'package:flutter/material.dart';

class ComponentCard extends StatelessWidget {
  const ComponentCard({
    required this.name,
    required this.cost,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final String name;
  final int cost;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: CheckboxListTile(
        value: selected,
        onChanged: (bool? v) => onChanged(v ?? false),
        title: Text(name),
        subtitle: Text('Custo: ${cost}M'),
      ),
    );
  }
}
