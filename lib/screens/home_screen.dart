import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import '../audio/audio_manager.dart';
import '../audio/audio_settings_modal.dart';
import '../audio/sound_effect.dart';
import '../game/game_controller.dart';
import '../widgets/intro_crawl_widget.dart';
import '../widgets/localized_intro_text.dart';
import 'agency_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.controller,
    super.key,
  });

  final GameController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final bool _isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _openingMusicPlayer = AudioPlayer();
  bool _ttsReady = false;
  bool _isNarrating = false;
  bool _narrationBusy = false;
  bool _narrationSequenceActive = false;
  bool _isCrawlPlaying = false;
  List<String> _narrationChunks = const <String>[];
  int _narrationChunkIndex = 0;
  Timer? _crawlStopTimer;
  bool _preferMaleNarrator = true;
  Locale _selectedLocale = const Locale('pt', 'BR');

  bool get _isPt => _selectedLocale.languageCode == 'pt';

  @override
  void initState() {
    super.initState();
    _configureTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isWindows) {
        unawaited(_startOpeningMusicFallback());
      } else {
        AudioManager.instance.startBackgroundMusic(SoundEffect.menuAmbient);
      }
    });
  }

  Future<void> _startOpeningMusicFallback() async {
    try {
      await _openingMusicPlayer.setLoopMode(LoopMode.one);
      await _openingMusicPlayer.setVolume(0.28);
      for (final String asset in <String>[
        'assets/audio/ambient_deep_space.mp3',
        'assets/audio/ambient_space_flight.mp3',
        'assets/audio/ambient_control_room.mp3',
      ]) {
        try {
          await _openingMusicPlayer.setAsset(asset);
          await _openingMusicPlayer.play();
          return;
        } catch (_) {
          // Try the next candidate.
        }
      }
    } catch (_) {
      // Keep silent if background music cannot initialize.
    }
  }

  Future<void> _configureTts() async {
    try {
      // awaitSpeakCompletion(true) dispatches callbacks on a native thread on
      // Windows, which crashes the Flutter engine. Keep it false everywhere;
      // state is driven by the completion/cancel/error handlers below.
      await _tts.awaitSpeakCompletion(false).timeout(const Duration(seconds: 2));
      await _tts.setSpeechRate(0.58).timeout(const Duration(seconds: 2));
      await _tts.setPitch(1.0).timeout(const Duration(seconds: 2));
      await _tts.setVolume(1.0).timeout(const Duration(seconds: 2));
      await _tts.setLanguage(_ttsLanguageFor(_selectedLocale)).timeout(const Duration(seconds: 2));
    } catch (_) {
      // Keep defaults if the platform TTS engine stalls during setup.
    }
    await _applyBestVoice(_selectedLocale.languageCode);

    _tts.setStartHandler(() {
      if (mounted) {
        setState(() => _isNarrating = true);
      }
    });
    _tts.setCompletionHandler(() {
      if (_narrationSequenceActive && _narrationChunkIndex < _narrationChunks.length - 1) {
        _narrationChunkIndex += 1;
        unawaited(_tts.speak(_narrationChunks[_narrationChunkIndex]));
        return;
      }
      _narrationSequenceActive = false;
      _narrationChunks = const <String>[];
      _narrationChunkIndex = 0;
      if (mounted) {
        setState(() => _isNarrating = false);
      }
    });
    _tts.setCancelHandler(() {
      _narrationSequenceActive = false;
      _narrationChunks = const <String>[];
      _narrationChunkIndex = 0;
      if (mounted) {
        setState(() => _isNarrating = false);
      }
    });
    _tts.setErrorHandler((dynamic _) {
      _narrationSequenceActive = false;
      _narrationChunks = const <String>[];
      _narrationChunkIndex = 0;
      if (mounted) {
        setState(() => _isNarrating = false);
      }
    });

    if (mounted) {
      setState(() => _ttsReady = true);
      // Auto-start narration with the default locale.
      final String text = LocalizedIntroText.forLocale(_selectedLocale);
      unawaited(_startIntroNarration(text, _selectedLocale));
    }
  }

  String _ttsLanguageFor(Locale locale) {
    final String code = locale.languageCode.toLowerCase();
    if (code == 'pt') {
      return 'pt-BR';
    }
    if (code == 'es') {
      return 'es-ES';
    }
    return 'en-US';
  }

  Duration _estimateCrawlDuration(String text) {
    final int words = text.trim().split(RegExp(r'\s+')).length;
    // At speech rate ~0.58, practical speed is around 145 words/min.
    return Duration(seconds: (words / 145.0 * 60).round() + 3);
  }

  String _normalizeVoiceLabel(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }

  void _restartIntroCrawl(String text) {
    final Duration duration = _estimateCrawlDuration(text);
    _crawlStopTimer?.cancel();
    if (mounted) {
      setState(() {
        _isCrawlPlaying = true;
      });
    } else {
      _isCrawlPlaying = true;
    }
    _crawlStopTimer = Timer(duration, () {
      if (mounted) {
        setState(() {
          _isCrawlPlaying = false;
        });
      } else {
        _isCrawlPlaying = false;
      }
    });
  }

  Future<void> _applyBestVoice(String languageCode) async {
    try {
      final dynamic raw = await _tts.getVoices;
      if (raw is! List) return;
      final List<Map<dynamic, dynamic>> voices =
          raw.whereType<Map<dynamic, dynamic>>().toList();
      if (voices.isEmpty) return;
      Map<dynamic, dynamic>? best;
      int bestScore = -1;
      for (final Map<dynamic, dynamic> v in voices) {
        final String name = (v['name'] as String? ?? '').toLowerCase();
        final String normalizedName = _normalizeVoiceLabel(name);
        final String locale = (v['locale'] as String? ?? '').toLowerCase();
        final String gender = (v['gender'] as String? ?? '').toLowerCase();
        if (!locale.startsWith(languageCode)) continue;
        int score = 0;

        if (locale == 'pt-br') score += 5;
        if (normalizedName.contains('neural')) score += 7;
        if (normalizedName.contains('(natural)') || normalizedName.contains('natural')) score += 6;
        if (normalizedName.contains('online')) score += 5;
        if (normalizedName.contains('multilingual')) score += 2;

        // Penalize older desktop/classic voices that often sound robotic.
        if (normalizedName.contains('desktop') || normalizedName.contains('classic') || normalizedName.contains('sapi')) {
          score -= 5;
        }

        if (languageCode == 'pt') {
          if (normalizedName.contains('antonio') || normalizedName.contains('duarte') || normalizedName.contains('fabio')) {
            score += 10;
          }
          if (normalizedName.contains('francisca') || normalizedName.contains('maria')) {
            score += 3;
          }
        }

        final bool maleHint = normalizedName.contains('male') ||
            normalizedName.contains('mascul') ||
            normalizedName.contains('antonio') ||
            normalizedName.contains('duarte') ||
            normalizedName.contains('fabio') ||
            gender.contains('male');
        final bool femaleHint = normalizedName.contains('female') ||
            normalizedName.contains('femin') ||
            normalizedName.contains('francisca') ||
            normalizedName.contains('maria') ||
            gender.contains('female');
        if (_preferMaleNarrator) {
          if (maleHint) score += 4;
          if (femaleHint) score -= 2;
        } else {
          if (femaleHint) score += 4;
          if (maleHint) score -= 2;
        }

        if (score > bestScore) {
          bestScore = score;
          best = v;
        }
        best ??= v;
      }
      if (best != null) {
        debugPrint(
          '[TTS] Selected voice: ${best["name"]} | locale: ${best["locale"]} | male=$_preferMaleNarrator',
        );
        await _tts
            .setVoice({'name': best['name'], 'locale': best['locale']})
            .timeout(const Duration(seconds: 2));
      } else {
        debugPrint('[TTS] No voice found for languageCode=$languageCode');
      }
    } catch (e) {
      debugPrint('[TTS] _applyBestVoice error: $e');
    }
  }

  List<String> _splitNarrationText(String text) {
    final List<String> chunks = <String>[];
    final List<String> paragraphs = text
        .split(RegExp(r'\n\s*\n'))
        .map((String p) => p.trim())
        .where((String p) => p.isNotEmpty)
        .toList();

    const int maxChunkLength = 280;
    for (final String paragraph in paragraphs) {
      if (paragraph.length <= maxChunkLength) {
        chunks.add(paragraph);
        continue;
      }

      final List<String> sentences = paragraph
          .split(RegExp(r'(?<=[.!?])\s+'))
          .map((String s) => s.trim())
          .where((String s) => s.isNotEmpty)
          .toList();

      if (sentences.isEmpty) {
        chunks.add(paragraph);
        continue;
      }

      final StringBuffer buffer = StringBuffer();
      for (final String sentence in sentences) {
        if (buffer.isEmpty) {
          buffer.write(sentence);
          continue;
        }
        if (buffer.length + sentence.length + 1 > maxChunkLength) {
          chunks.add(buffer.toString());
          buffer
            ..clear()
            ..write(sentence);
          continue;
        }
        buffer.write(' $sentence');
      }
      if (buffer.isNotEmpty) {
        chunks.add(buffer.toString());
      }
    }

    return chunks.isEmpty ? <String>[text] : chunks;
  }

  Future<void> _toggleIntroNarration(String text, Locale locale) async {
    if (!_ttsReady || _narrationBusy) {
      return;
    }
    if (_isNarrating) {
      await _requestStopNarration();
      return;
    }

    unawaited(_startIntroNarration(text, locale));
  }

  Future<void> _requestStopNarration() async {
    _narrationSequenceActive = false;
    _narrationChunks = const <String>[];
    _narrationChunkIndex = 0;
    _crawlStopTimer?.cancel();
    try {
      await _tts.stop().timeout(const Duration(seconds: 2));
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isNarrating = false;
        _isCrawlPlaying = false;
      });
    }
  }

  Future<void> _toggleNarratorProfile(String text, Locale locale) async {
    if (_isNarrating) {
      await _requestStopNarration();
    }
    setState(() {
      _preferMaleNarrator = !_preferMaleNarrator;
    });
    await _tts.setLanguage(_ttsLanguageFor(locale)).timeout(const Duration(seconds: 2));
    await _applyBestVoice(locale.languageCode);
    if (_ttsReady) {
      unawaited(_startIntroNarration(text, locale));
    }
  }

  Future<void> _startIntroNarration(String text, Locale locale) async {
    _narrationBusy = true;

    try {
      await _tts.stop().timeout(const Duration(seconds: 2));
      // Do NOT call setLanguage here — it resets the voice on Windows SAPI.
      // Language + voice are already applied in _configureTts / _toggleLocale.
      await _applyBestVoice(locale.languageCode);
      _restartIntroCrawl(text);
      _narrationChunks = _splitNarrationText(text);
      _narrationChunkIndex = 0;
      _narrationSequenceActive = _narrationChunks.isNotEmpty;
      if (_narrationSequenceActive) {
        unawaited(_tts.speak(_narrationChunks.first));
      }
    } catch (_) {
      try { await _tts.stop(); } catch (_) {}
      _narrationSequenceActive = false;
      _narrationChunks = const <String>[];
      _narrationChunkIndex = 0;
    } finally {
      _narrationBusy = false;
    }
  }

  Future<void> _toggleLocale() async {
    if (_isNarrating) {
      await _requestStopNarration();
    }
    final Locale newLocale = _isPt ? const Locale('en', 'US') : const Locale('pt', 'BR');
    await _tts.setLanguage(_ttsLanguageFor(newLocale)).timeout(const Duration(seconds: 2));
    await _applyBestVoice(newLocale.languageCode);
    setState(() => _selectedLocale = newLocale);
    _restartIntroCrawl(LocalizedIntroText.forLocale(newLocale));
  }

  @override
  void dispose() {
    _crawlStopTimer?.cancel();
    unawaited(_openingMusicPlayer.stop());
    unawaited(_openingMusicPlayer.dispose());
    unawaited(_tts.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GameController controller = widget.controller;
    final String introText = LocalizedIntroText.forLocale(_selectedLocale);
    final bool compactHeight = MediaQuery.of(context).size.height < 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Space Mission Architect'),
        actions: <Widget>[
          GestureDetector(
            onTap: _toggleLocale,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _isPt ? '🇧🇷' : '🇺🇸',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          IconButton(
            icon: Icon(_isNarrating ? Icons.stop_circle_outlined : Icons.record_voice_over_outlined),
            tooltip: _isNarrating
                ? (_isPt ? 'Parar narracao' : 'Stop narration')
                : (_isPt ? 'Narrar introducao' : 'Narrate intro'),
            onPressed: () {
              _toggleIntroNarration(introText, _selectedLocale);
            },
          ),
          IconButton(
            icon: Icon(_preferMaleNarrator ? Icons.man : Icons.woman),
            tooltip: _isPt
                ? (_preferMaleNarrator ? 'Narrador masculino' : 'Narrador feminino')
                : (_preferMaleNarrator ? 'Male narrator' : 'Female narrator'),
            onPressed: () {
              _toggleNarratorProfile(introText, _selectedLocale);
            },
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_outlined),
            onPressed: () {
              AudioManager.instance.playUi(SoundEffect.uiClick);
              showAudioSettingsModal(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.9),
            radius: 1.35,
            colors: <Color>[Color(0xFF13243E), Color(0xFF070C17), Color(0xFF03060E)],
            stops: <double>[0.0, 0.58, 1.0],
          ),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: _StarfieldLayer()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 4),
                    Text(
                      _isPt ? 'Programa de Missao Espacial' : 'Space Mission Program',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFFFD56E).withOpacity(0.95),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.15,
                        fontSize: compactHeight ? 12 : 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: IntroCrawlWidget(
                        text: introText,
                        playing: _isCrawlPlaying,
                        duration: _estimateCrawlDuration(introText),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _ttsReady
                          ? () {
                              _toggleIntroNarration(introText, _selectedLocale);
                            }
                          : null,
                      icon: Icon(_isNarrating ? Icons.stop_circle_outlined : Icons.record_voice_over_outlined, size: 18),
                      label: Text(_isNarrating
                          ? (_isPt ? 'Parar narracao' : 'Stop narration')
                          : (_isPt ? 'Narrar texto de abertura' : 'Narrate opening text')),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFFD56E),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260, minWidth: 220),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            AudioManager.instance.playUi(SoundEffect.uiConfirm);
                            _tts.stop();
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => AgencySelectionScreen(controller: controller),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          icon: const Icon(Icons.rocket_launch, size: 18),
                          label: Text(_isPt ? 'Iniciar Campanha' : 'Start Campaign'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextButton.icon(
                      onPressed: () {
                        AudioManager.instance.playUi(SoundEffect.uiClick);
                        showAudioSettingsModal(context);
                      },
                      icon: const Icon(Icons.tune, size: 15),
                      label: const Text('Configurar audio'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'v1 mock local - sem backend',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarfieldLayer extends StatelessWidget {
  const _StarfieldLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 70,
            left: 42,
            child: _star(1.0),
          ),
          Positioned(
            top: 160,
            right: 38,
            child: _star(1.7),
          ),
          Positioned(
            top: 240,
            left: 120,
            child: _star(1.4),
          ),
          Positioned(
            top: 300,
            right: 92,
            child: _star(1.2),
          ),
          Positioned(
            bottom: 170,
            left: 68,
            child: _star(1.8),
          ),
          Positioned(
            bottom: 230,
            right: 50,
            child: _star(1.0),
          ),
          Positioned(
            bottom: 120,
            right: 128,
            child: _star(1.45),
          ),
          Positioned(
            bottom: 80,
            left: 148,
            child: _star(1.3),
          ),
        ],
      ),
    );
  }

  Widget _star(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xCCFFFFFF),
        shape: BoxShape.circle,
      ),
    );
  }
}
