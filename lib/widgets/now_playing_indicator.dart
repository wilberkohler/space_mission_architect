import 'package:flutter/material.dart';

import '../audio/audio_manager.dart';

/// Overlay global que exibe o nome do som em reprodução no canto inferior esquerdo.
class NowPlayingIndicator extends StatelessWidget {
  const NowPlayingIndicator({required this.child, super.key});

  final Widget child;

  /// Converte o nome camelCase do enum para texto legível.
  /// Ex: "missionControlComputers" → "mission Control Computers"
  static String _formatName(String name) {
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < name.length; i++) {
      final String ch = name[i];
      if (i > 0 && ch == ch.toUpperCase() && ch != ch.toLowerCase()) {
        buf.write(' ');
      }
      buf.write(i == 0 ? ch.toUpperCase() : ch);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        Positioned(
          left: 12,
          bottom: 12,
          child: ValueListenableBuilder<String?>(
            valueListenable: AudioManager.instance.nowPlayingNotifier,
            builder: (BuildContext context, String? value, _) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: value == null
                    ? const SizedBox.shrink()
                    : _SoundChip(key: ValueKey<String>(value), name: _formatName(value)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SoundChip extends StatelessWidget {
  const _SoundChip({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.volume_up, size: 14, color: Colors.cyanAccent),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
