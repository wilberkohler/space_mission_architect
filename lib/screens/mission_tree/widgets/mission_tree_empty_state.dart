import 'package:flutter/material.dart';

import '../../../widgets/shared/empty_state.dart';

class MissionTreeEmptyState extends StatelessWidget {
  const MissionTreeEmptyState({required this.onClear, super.key});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: EmptyState(
            icon: Icons.search_off_outlined,
            title: 'Nenhuma missão encontrada',
            message: 'Nenhuma missão encontrada para os filtros atuais.',
            action: ElevatedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Limpar busca e filtros'),
            ),
          ),
        ),
      ),
    );
  }
}
