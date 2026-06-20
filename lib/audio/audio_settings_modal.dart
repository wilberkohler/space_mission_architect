import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'audio_manager.dart';
import 'audio_settings.dart';
import 'sound_effect.dart';

Future<void> showAudioSettingsModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _AudioSettingsDialog(),
  );
}

class _AudioSettingsDialog extends StatefulWidget {
  const _AudioSettingsDialog();

  @override
  State<_AudioSettingsDialog> createState() => _AudioSettingsDialogState();
}

class _AudioSettingsDialogState extends State<_AudioSettingsDialog> {
  late AudioSettings _draft;

  @override
  void initState() {
    super.initState();
    final AudioSettings current = AudioManager.instance.settings;
    _draft = AudioSettings(
      soundEnabled: current.soundEnabled,
      musicEnabled: current.musicEnabled,
      masterVolume: current.masterVolume,
      sfxVolume: current.sfxVolume,
      musicVolume: current.musicVolume,
      ambientVolume: current.ambientVolume,
      criticalAlertsEnabled: current.criticalAlertsEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.panelBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
              ),
              child: const Text(
                'CONFIGURACOES DE AUDIO',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    value: _draft.soundEnabled,
                    activeColor: AppColors.accent,
                    title: const Text('Som ligado'),
                    onChanged: (bool value) {
                      setState(() => _draft.soundEnabled = value);
                    },
                  ),
                  SwitchListTile(
                    value: _draft.criticalAlertsEnabled,
                    activeColor: AppColors.orange,
                    title: const Text('Alertas criticos ligados'),
                    onChanged: (bool value) {
                      setState(() => _draft.criticalAlertsEnabled = value);
                    },
                  ),
                  SwitchListTile(
                    value: _draft.musicEnabled,
                    activeColor: AppColors.green,
                    title: const Text('Musica de fundo ligada'),
                    onChanged: (bool value) {
                      setState(() => _draft.musicEnabled = value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _activeTrackIndicator(),
                  const SizedBox(height: AppSpacing.sm),
                  _volumeSlider(
                    title: 'Volume geral',
                    value: _draft.masterVolume,
                    onChanged: (double v) => setState(() => _draft.setMasterVolume(v)),
                  ),
                  _volumeSlider(
                    title: 'Volume de efeitos',
                    value: _draft.sfxVolume,
                    onChanged: (double v) => setState(() => _draft.setSfxVolume(v)),
                  ),
                  _volumeSlider(
                    title: 'Volume da musica',
                    value: _draft.musicVolume,
                    onChanged: (double v) => setState(() => _draft.setMusicVolume(v)),
                  ),
                  _volumeSlider(
                    title: 'Volume do ambiente',
                    value: _draft.ambientVolume,
                    onChanged: (double v) => setState(() => _draft.setAmbientVolume(v)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            AudioManager.instance.playUi(SoundEffect.uiBack);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            AudioManager.instance.updateSettings(_draft);
                            AudioManager.instance.playUi(SoundEffect.uiConfirm);
                            // TODO: Persistir AudioSettings com shared_preferences.
                            Navigator.of(context).pop();
                          },
                          child: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _volumeSlider({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: const TextStyle(color: AppColors.textSecondary)),
        Slider(value: value, onChanged: onChanged, min: 0, max: 1),
      ],
    );
  }

  Widget _activeTrackIndicator() {
    final AudioManager audio = AudioManager.instance;
    final String music = audio.musicPlaying
        ? _effectName(audio.currentMusicEffect)
        : 'Nenhuma';
    final String ambient = audio.ambientPlaying
        ? _effectName(audio.currentAmbientEffect)
        : 'Nenhum';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.panelLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'TRILHA ATIVA',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text('Musica: $music', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
          const SizedBox(height: 2),
          Text('Ambiente: $ambient', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
        ],
      ),
    );
  }

  String _effectName(SoundEffect? effect) {
    if (effect == null) {
      return 'Nenhuma';
    }

    final String raw = effect.name;
    final String withSpaces = raw.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (Match m) => '${m.group(1)} ${m.group(2)}',
    );
    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
  }
}