import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';
import '../audio/sound_effect.dart';
import '../game/game_controller.dart';
import '../models/rival.dart';
import '../widgets/control_card.dart';

class RivalsScreen extends StatefulWidget {
  const RivalsScreen({
    required this.controller,
    super.key,
  });

  final GameController controller;

  @override
  State<RivalsScreen> createState() => _RivalsScreenState();
}

class _RivalsScreenState extends State<RivalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioManager.instance.play(SoundEffect.rivalHeadline);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Rival> rivals = <Rival>[...widget.controller.rivals]
      ..sort((Rival a, Rival b) => b.score.compareTo(a.score));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Rivais'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AudioManager.instance.play(SoundEffect.uiBack);
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rivals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          final Rival rival = rivals[index];
          return ControlCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF1D3354),
                      child: Text('#${index + 1}', style: const TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        rival.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text('Score ${rival.score}'),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Manchete: ${rival.headline}'),
                const SizedBox(height: 4),
                Text('Marco: ${rival.milestone}', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          );
        },
      ),
    );
  }
}
