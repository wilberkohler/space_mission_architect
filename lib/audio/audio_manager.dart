import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../models/agency.dart';
import 'audio_settings.dart';
import 'sound_effect.dart';

class AudioManager {
  AudioManager._internal();

  static final AudioManager instance = AudioManager._internal();

  static final bool _isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  static final bool _audioSupported = !_isWindows;

  final AudioPlayer? _sfxPlayer = _audioSupported ? AudioPlayer(playerId: 'sfx_player') : null;
  final AudioPlayer? _uiPlayer = _audioSupported ? AudioPlayer(playerId: 'ui_player') : null;
  final AudioPlayer? _criticalPlayer = _audioSupported ? AudioPlayer(playerId: 'critical_player') : null;
  final AudioPlayer? _ambientPlayer = _audioSupported ? AudioPlayer(playerId: 'ambient_player') : null;
  final AudioPlayer? _musicPlayer = _audioSupported ? AudioPlayer(playerId: 'music_player') : null;
  final AudioPlayer? _voicePlayer = _audioSupported ? AudioPlayer(playerId: 'voice_player') : null;

  /// Notifier com o nome do último som disparado. Limpa automaticamente após 4 segundos.
  final ValueNotifier<String?> nowPlayingNotifier = ValueNotifier<String?>(null);

  AudioSettings _settings = AudioSettings();
  bool _initialized = false;
  bool _criticalPlaying = false;
  bool _ambientPlaying = false;
  bool _musicPlaying = false;

  SoundEffect? _currentAmbientEffect;
  SoundEffect? _currentMusicEffect;

  final Map<SoundEffect, DateTime> _lastPlayTime = <SoundEffect, DateTime>{};

  static const Map<AudioCategory, double> _categoryVolumes = <AudioCategory, double>{
    AudioCategory.ui: 0.35,
    AudioCategory.countdown: 0.55,
    AudioCategory.test: 0.50,
    AudioCategory.launch: 0.75,
    AudioCategory.missionPhase: 0.55,
    AudioCategory.critical: 0.85,
    AudioCategory.result: 0.70,
    AudioCategory.ambient: 0.18,
    AudioCategory.voice: 0.70,
    AudioCategory.music: 0.22,
  };

  static const Map<SoundEffect, AudioCategory> _categoryByEffect = <SoundEffect, AudioCategory>{
    SoundEffect.uiClick: AudioCategory.ui,
    SoundEffect.uiBack: AudioCategory.ui,
    SoundEffect.uiConfirm: AudioCategory.ui,
    SoundEffect.tabSwitch: AudioCategory.ui,

    SoundEffect.testStart: AudioCategory.test,
    SoundEffect.testBeep: AudioCategory.test,
    SoundEffect.testSuccess: AudioCategory.test,
    SoundEffect.testWarning: AudioCategory.test,
    SoundEffect.testFailed: AudioCategory.test,

    SoundEffect.countdownBeep: AudioCategory.countdown,
    SoundEffect.countdownFinalBeep: AudioCategory.countdown,
    SoundEffect.launchCountdownVoice: AudioCategory.countdown,

    SoundEffect.launchConfirm: AudioCategory.launch,
    SoundEffect.launchIgnition: AudioCategory.launch,
    SoundEffect.launchLiftoff: AudioCategory.launch,
    SoundEffect.launchLiftoffAlt: AudioCategory.launch,
    SoundEffect.slsLaunchAudio: AudioCategory.launch,
    SoundEffect.goThrottleUp: AudioCategory.launch,
    SoundEffect.goForDeploy: AudioCategory.launch,
    SoundEffect.meco: AudioCategory.launch,
    SoundEffect.rogerRoll: AudioCategory.launch,

    SoundEffect.missionPhaseSuccess: AudioCategory.missionPhase,
    SoundEffect.missionPhaseWarning: AudioCategory.missionPhase,
    SoundEffect.missionPhaseFailed: AudioCategory.missionPhase,

    SoundEffect.criticalAlert: AudioCategory.critical,
    SoundEffect.abortMission: AudioCategory.critical,
    SoundEffect.flightTermination: AudioCategory.critical,
    SoundEffect.spaceDanger: AudioCategory.critical,
    SoundEffect.noGoAlert: AudioCategory.critical,

    SoundEffect.successComplete: AudioCategory.result,
    SoundEffect.successPartial: AudioCategory.result,
    SoundEffect.missionFailed: AudioCategory.result,
    SoundEffect.catastrophicFailure: AudioCategory.result,
    SoundEffect.missionUnlocked: AudioCategory.result,
    SoundEffect.milestoneAchieved: AudioCategory.result,
    SoundEffect.careerPromotion: AudioCategory.result,
    SoundEffect.xpGain: AudioCategory.result,

    SoundEffect.ambientControlRoom: AudioCategory.ambient,
    SoundEffect.ambientDeepSpace: AudioCategory.ambient,
    SoundEffect.ambientSpaceFlight: AudioCategory.ambient,
    SoundEffect.spaceRumble: AudioCategory.ambient,

    SoundEffect.mainTheme: AudioCategory.music,
    SoundEffect.menuAmbient: AudioCategory.music,
    SoundEffect.missionAmbient: AudioCategory.music,
    SoundEffect.deepSpaceAmbient: AudioCategory.music,

    SoundEffect.houstonProblem: AudioCategory.voice,
    SoundEffect.sputnikBeep: AudioCategory.voice,
    SoundEffect.quindarStart: AudioCategory.voice,
    SoundEffect.quindarEnd: AudioCategory.voice,
    SoundEffect.missionControlComputers: AudioCategory.voice,
    SoundEffect.niceToBeInOrbit: AudioCategory.voice,
    SoundEffect.jfkMoonSpeech: AudioCategory.voice,
    SoundEffect.rivalHeadline: AudioCategory.voice,
    SoundEffect.agencySelectNasa: AudioCategory.voice,
    SoundEffect.agencySelectUssr: AudioCategory.voice,
    SoundEffect.agencySelectEsa: AudioCategory.voice,
    SoundEffect.agencySelectIsro: AudioCategory.voice,
  };

  static const Map<SoundEffect, double> _effectAdjustments = <SoundEffect, double>{
    SoundEffect.launchCountdownVoice: 0.55,
    SoundEffect.jfkMoonSpeech: 0.45,
    SoundEffect.ambientControlRoom: 0.12,
    SoundEffect.ambientDeepSpace: 0.14,
    SoundEffect.ambientSpaceFlight: 0.14,
    SoundEffect.launchLiftoff: 0.65,
    SoundEffect.slsLaunchAudio: 0.55,
    SoundEffect.criticalAlert: 0.80,
    SoundEffect.uiClick: 0.25,
    SoundEffect.tabSwitch: 0.22,
  };

  static const double _criticalAlertLoopAdjustment = 0.60;

  static const Map<SoundEffect, List<String>> _assetCandidatesByEffect = <SoundEffect, List<String>>{
    SoundEffect.uiClick: <String>['audio/ui_click.ogg', 'audio/ui_click.mp3'],
    SoundEffect.uiBack: <String>['audio/ui_back.ogg', 'audio/ui_back.mp3'],
    SoundEffect.uiConfirm: <String>['audio/ui_confirm.ogg', 'audio/ui_confirm.mp3'],
    SoundEffect.tabSwitch: <String>['audio/tab_switch.ogg', 'audio/ui_confirm.ogg'],

    SoundEffect.testStart: <String>['audio/test_start.ogg', 'audio/test_start.mp3'],
    SoundEffect.testBeep: <String>['audio/test_beep.ogg', 'audio/test_beep.mp3'],
    SoundEffect.testSuccess: <String>['audio/test_success.ogg', 'audio/test_success.mp3'],
    SoundEffect.testWarning: <String>['audio/test_warning.ogg', 'audio/test_warning.mp3'],
    SoundEffect.testFailed: <String>['audio/test_failed.ogg', 'audio/test_failed.mp3'],

    SoundEffect.countdownBeep: <String>['audio/countdown_beep.ogg', 'audio/countdown_beep.mp3'],
    SoundEffect.countdownFinalBeep: <String>['audio/countdown_final_beep.wav', 'audio/countdown_final_beep.mp3'],
    SoundEffect.launchCountdownVoice: <String>['audio/launch_countdown_voice.mp3'],

    SoundEffect.launchConfirm: <String>['audio/launch_confirm.mp3', 'audio/launch_confirm.ogg'],
    SoundEffect.launchIgnition: <String>['audio/launch_ignition.ogg', 'audio/launch_ignition.mp3'],
    SoundEffect.launchLiftoff: <String>['audio/launch_liftoff.mp3'],
    SoundEffect.launchLiftoffAlt: <String>['audio/launch_liftoff_alt.mp3'],
    SoundEffect.slsLaunchAudio: <String>['audio/sls_launch_audio.mp3'],
    SoundEffect.goThrottleUp: <String>['audio/go_throttle_up.mp3'],
    SoundEffect.goForDeploy: <String>['audio/go_for_deploy.mp3'],
    SoundEffect.meco: <String>['audio/meco.mp3'],
    SoundEffect.rogerRoll: <String>['audio/roger_roll.mp3'],

    SoundEffect.missionPhaseSuccess: <String>['audio/phase_success.ogg', 'audio/phase_success.mp3'],
    SoundEffect.missionPhaseWarning: <String>['audio/phase_warning.ogg', 'audio/phase_warning.mp3'],
    SoundEffect.missionPhaseFailed: <String>['audio/phase_failed.ogg', 'audio/phase_failed.mp3'],

    SoundEffect.criticalAlert: <String>['audio/critical_alert.wav', 'audio/critical_alert.mp3'],
    SoundEffect.abortMission: <String>['audio/abort_mission.mp3', 'audio/abort_mission.ogg'],
    SoundEffect.flightTermination: <String>['audio/flight_termination.ogg', 'audio/flight_termination.mp3'],
    SoundEffect.spaceDanger: <String>['audio/space_danger.mp3'],
    SoundEffect.noGoAlert: <String>['audio/no_go_alert.wav', 'audio/critical_alert.wav'],

    SoundEffect.successComplete: <String>['audio/success_complete.mp3', 'audio/success_complete.ogg'],
    SoundEffect.successPartial: <String>['audio/success_partial.mp3', 'audio/success_partial.ogg'],
    SoundEffect.missionFailed: <String>['audio/mission_failed.ogg', 'audio/mission_failed.mp3'],
    SoundEffect.catastrophicFailure: <String>['audio/catastrophic_failure.ogg', 'audio/catastrophic_failure.mp3'],
    SoundEffect.missionUnlocked: <String>['audio/mission_unlocked.ogg', 'audio/mission_unlocked.mp3'],
    SoundEffect.milestoneAchieved: <String>['audio/milestone_achieved.mp3'],
    SoundEffect.careerPromotion: <String>['audio/career_promotion.ogg', 'audio/mission_unlocked.ogg'],
    SoundEffect.xpGain: <String>['audio/xp_gain.ogg', 'audio/ui_confirm.ogg'],

    SoundEffect.ambientControlRoom: <String>['audio/ambient_control_room.mp3', 'audio/ambient_computer.ogg'],
    SoundEffect.ambientDeepSpace: <String>['audio/ambient_deep_space.mp3'],
    SoundEffect.ambientSpaceFlight: <String>['audio/ambient_space_flight.mp3'],
    SoundEffect.spaceRumble: <String>['audio/space_rumble.mp3'],

    SoundEffect.houstonProblem: <String>['audio/houston_problem.mp3'],
    SoundEffect.sputnikBeep: <String>['audio/sputnik_beep.mp3'],
    SoundEffect.quindarStart: <String>['audio/quindar_start.mp3'],
    SoundEffect.quindarEnd: <String>['audio/quindar_end.mp3'],
    SoundEffect.missionControlComputers: <String>['audio/mission_control_computers.mp3'],
    SoundEffect.niceToBeInOrbit: <String>['audio/nice_to_be_in_orbit.mp3'],
    SoundEffect.jfkMoonSpeech: <String>['audio/jfk_moon_speech.mp3'],
    SoundEffect.rivalHeadline: <String>['audio/rival_headline.mp3'],

    SoundEffect.mainTheme: <String>[
      'audio/ambient_deep_space.mp3',
      'audio/ambient_space_flight.mp3',
      'audio/ambient_control_room.mp3',
      'audio/ambient_computer.ogg',
      'audio/693857main_emfisis_chorus_1.mp3',
    ],
    SoundEffect.menuAmbient: <String>[
      'audio/ambient_control_room.mp3',
      'audio/ambient_deep_space.mp3',
      'audio/ambient_space_flight.mp3',
    ],
    SoundEffect.missionAmbient: <String>[
      'audio/ambient_space_flight.mp3',
      'audio/ambient_deep_space.mp3',
      'audio/ambient_control_room.mp3',
    ],
    SoundEffect.deepSpaceAmbient: <String>[
      'audio/ambient_deep_space.mp3',
      'audio/ambient_space_flight.mp3',
    ],

    SoundEffect.agencySelectNasa: <String>['audio/mission_control_computers.mp3'],
    SoundEffect.agencySelectUssr: <String>['audio/sputnik_beep.mp3'],
    SoundEffect.agencySelectEsa: <String>['audio/milestone_achieved.mp3'],
    SoundEffect.agencySelectIsro: <String>['audio/mission_unlocked.ogg', 'audio/mission_unlocked.mp3'],
  };

  Future<void> _initIfNeeded() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    if (!_audioSupported) {
      return;
    }

    final AudioPlayer? sfxPlayer = _sfxPlayer;
    final AudioPlayer? uiPlayer = _uiPlayer;
    final AudioPlayer? criticalPlayer = _criticalPlayer;
    final AudioPlayer? voicePlayer = _voicePlayer;
    final AudioPlayer? ambientPlayer = _ambientPlayer;
    final AudioPlayer? musicPlayer = _musicPlayer;

    if (sfxPlayer == null ||
        uiPlayer == null ||
        criticalPlayer == null ||
        voicePlayer == null ||
        ambientPlayer == null ||
        musicPlayer == null) {
      return;
    }

    await sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    await uiPlayer.setPlayerMode(PlayerMode.lowLatency);
    await criticalPlayer.setPlayerMode(PlayerMode.lowLatency);
    await voicePlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await ambientPlayer.setReleaseMode(ReleaseMode.loop);
    await musicPlayer.setReleaseMode(ReleaseMode.loop);
    await criticalPlayer.setReleaseMode(ReleaseMode.loop);
  }

  AudioCategory categoryForEffect(SoundEffect effect) {
    return _categoryByEffect[effect] ?? AudioCategory.ui;
  }

  double getVolumeForEffect(SoundEffect effect) {
    final AudioCategory category = categoryForEffect(effect);
    final double categoryVolume = _categoryVolumes[category] ?? 0.5;

    final double baseVolume = switch (category) {
      AudioCategory.music => _settings.masterVolume * _settings.musicVolume * categoryVolume,
      AudioCategory.ambient => _settings.masterVolume * _settings.ambientVolume * categoryVolume,
      _ => _settings.masterVolume * _settings.sfxVolume * categoryVolume,
    };

    final double adjusted = _effectAdjustments[effect] ?? baseVolume;
    return adjusted.clamp(0.0, 1.0);
  }

  Future<void> play(SoundEffect effect) async {
    final AudioCategory category = categoryForEffect(effect);
    if (category == AudioCategory.ui) {
      await playUi(effect);
      return;
    }
    if (category == AudioCategory.voice) {
      await playVoice(effect);
      return;
    }
    await playSfx(effect);
  }

  Future<void> playSfx(SoundEffect effect) async {
    if (!_audioSupported) {
      return;
    }
    await _initIfNeeded();
    if (!_settings.soundEnabled) {
      return;
    }
    final AudioPlayer? sfxPlayer = _sfxPlayer;
    if (sfxPlayer == null) {
      return;
    }
    await _playEffectOnPlayer(
      effect: effect,
      player: sfxPlayer,
      volume: getVolumeForEffect(effect),
      stopBeforePlay: true,
    );
  }

  Future<void> playUi(SoundEffect effect) async {
    if (!_audioSupported) {
      return;
    }
    await _initIfNeeded();
    if (!_settings.soundEnabled) {
      return;
    }
    final AudioPlayer? uiPlayer = _uiPlayer;
    if (uiPlayer == null) {
      return;
    }
    await _playEffectOnPlayer(
      effect: effect,
      player: uiPlayer,
      volume: getVolumeForEffect(effect),
      stopBeforePlay: true,
    );
  }

  Future<void> playVoice(SoundEffect effect) async {
    if (!_audioSupported) {
      return;
    }
    await _initIfNeeded();
    if (!_settings.soundEnabled) {
      return;
    }
    final AudioPlayer? voicePlayer = _voicePlayer;
    if (voicePlayer == null) {
      return;
    }
    await _playEffectOnPlayer(
      effect: effect,
      player: voicePlayer,
      volume: getVolumeForEffect(effect),
      stopBeforePlay: true,
    );
  }

  Future<void> _playEffectOnPlayer({
    required SoundEffect effect,
    required AudioPlayer player,
    required double volume,
    bool stopBeforePlay = false,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime? last = _lastPlayTime[effect];
    if (last != null && now.difference(last) < const Duration(milliseconds: 120)) {
      return;
    }
    _lastPlayTime[effect] = now;

    final List<String> candidates = _assetCandidatesByEffect[effect] ?? <String>[];
    if (candidates.isEmpty) {
      return;
    }

    for (final String assetPath in candidates) {
      try {
        await player.setVolume(volume);
        if (stopBeforePlay) {
          await player.stop();
        }
        _notifyNowPlaying(effect.name);
        await player.play(AssetSource(assetPath)).timeout(const Duration(seconds: 3));
        return;
      } catch (e) {
        debugPrint('AudioManager: failed $assetPath for $effect ($e)');
      }
    }
  }

  void _notifyNowPlaying(String effectName) {
    nowPlayingNotifier.value = effectName;
    Future<void>.delayed(const Duration(seconds: 4), () {
      if (nowPlayingNotifier.value == effectName) {
        nowPlayingNotifier.value = null;
      }
    });
  }

  Future<void> playCountdownBeep({
    required int remainingSeconds,
    required bool isLaunch,
  }) async {
    if (isLaunch) {
      if (remainingSeconds == 0) {
        await playSfx(SoundEffect.launchIgnition);
        return;
      }
      if (remainingSeconds >= 1 && remainingSeconds <= 3) {
        await playSfx(SoundEffect.countdownFinalBeep);
        return;
      }
      if (remainingSeconds >= 4 && remainingSeconds <= 10) {
        await playSfx(SoundEffect.countdownBeep);
      }
      return;
    }

    if (remainingSeconds > 0) {
      await playSfx(SoundEffect.testBeep);
    }
  }

  Future<void> playCriticalAlert() async {
    if (!_audioSupported) {
      return;
    }
    await _initIfNeeded();

    if (!_settings.soundEnabled || !_settings.criticalAlertsEnabled || _criticalPlaying) {
      return;
    }

    final List<String> candidates = _assetCandidatesByEffect[SoundEffect.criticalAlert] ?? <String>[];
    if (candidates.isEmpty) {
      return;
    }

    final double volume = (getVolumeForEffect(SoundEffect.criticalAlert) * (_criticalAlertLoopAdjustment / 0.80))
        .clamp(0.0, 1.0);

    final AudioPlayer? criticalPlayer = _criticalPlayer;
    if (criticalPlayer == null) {
      return;
    }

    for (final String assetPath in candidates) {
      try {
        _criticalPlaying = true;
        await criticalPlayer.setVolume(volume);
        await criticalPlayer.play(AssetSource(assetPath)).timeout(const Duration(seconds: 3));
        return;
      } catch (e) {
        _criticalPlaying = false;
        debugPrint('AudioManager: failed critical alert $assetPath ($e)');
      }
    }
  }

  Future<void> stopCriticalAlert() async {
    if (!_audioSupported) {
      _criticalPlaying = false;
      return;
    }
    await _initIfNeeded();

    if (!_criticalPlaying) {
      return;
    }

    final AudioPlayer? criticalPlayer = _criticalPlayer;
    if (criticalPlayer == null) {
      _criticalPlaying = false;
      return;
    }

    try {
      await criticalPlayer.stop();
    } catch (e) {
      debugPrint('AudioManager: failed to stop critical alert ($e)');
    } finally {
      _criticalPlaying = false;
    }
  }

  Future<void> startBackgroundMusic(SoundEffect effect, {bool loop = true}) async {
    if (!_audioSupported) {
      return;
    }
    await _initIfNeeded();

    // Workaround for a Windows native-thread channel issue in audioplayers
    // that can close the app when the music player publishes events.
    if (_isWindows) {
      return;
    }

    if (!_settings.soundEnabled || !_settings.musicEnabled) {
      return;
    }

    if (_musicPlaying && _currentMusicEffect == effect) {
      return;
    }

    final List<String> candidates = _assetCandidatesByEffect[effect] ?? <String>[];
    if (candidates.isEmpty) {
      return;
    }

    final AudioPlayer? musicPlayer = _musicPlayer;
    if (musicPlayer == null) {
      return;
    }

    try {
      await musicPlayer.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
      await musicPlayer.stop();
      final double volume = getVolumeForEffect(effect);
      await musicPlayer.setVolume(volume);
      for (final String assetPath in candidates) {
        try {
          await musicPlayer.play(AssetSource(assetPath)).timeout(const Duration(seconds: 3));
          _musicPlaying = true;
          _currentMusicEffect = effect;
          return;
        } catch (e) {
          debugPrint('AudioManager: failed music $assetPath ($e)');
        }
      }
    } catch (e) {
      debugPrint('AudioManager: failed to start background music ($e)');
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (!_audioSupported) {
      _musicPlaying = false;
      _currentMusicEffect = null;
      return;
    }
    if (!_musicPlaying) {
      return;
    }
    final AudioPlayer? musicPlayer = _musicPlayer;
    if (musicPlayer == null) {
      _musicPlaying = false;
      _currentMusicEffect = null;
      return;
    }
    try {
      await musicPlayer.stop();
    } catch (e) {
      debugPrint('AudioManager: failed to stop background music ($e)');
    } finally {
      _musicPlaying = false;
      _currentMusicEffect = null;
    }
  }

  Future<void> fadeOutBackgroundMusic({Duration duration = const Duration(milliseconds: 650)}) async {
    if (!_musicPlaying || duration.inMilliseconds <= 0) {
      await stopBackgroundMusic();
      return;
    }

    const int steps = 10;
    final int waitMs = (duration.inMilliseconds / steps).round().clamp(1, 10000);
    final double initial = getVolumeForEffect(_currentMusicEffect ?? SoundEffect.mainTheme);

    for (int i = steps; i >= 0; i--) {
      final double v = initial * (i / steps);
      try {
        await _musicPlayer?.setVolume(v.clamp(0.0, 1.0));
      } catch (_) {}
      await Future<void>.delayed(Duration(milliseconds: waitMs));
    }

    await stopBackgroundMusic();
  }

  Future<void> setMusicVolume(double volume) async {
    if (!_audioSupported) {
      return;
    }
    _settings.setMusicVolume(volume);
    if (_musicPlaying && _currentMusicEffect != null) {
      try {
        await _musicPlayer?.setVolume(getVolumeForEffect(_currentMusicEffect!));
      } catch (e) {
        debugPrint('AudioManager: failed to set music volume ($e)');
      }
    }
  }

  Future<void> startAmbient(SoundEffect effect, {bool loop = true}) async {
    if (!_audioSupported) {
      return;
    }
    await _initIfNeeded();

    if (!_settings.soundEnabled) {
      return;
    }

    if (_ambientPlaying && _currentAmbientEffect == effect) {
      return;
    }

    final List<String> candidates = _assetCandidatesByEffect[effect] ?? <String>[];
    if (candidates.isEmpty) {
      return;
    }

    final AudioPlayer? ambientPlayer = _ambientPlayer;
    if (ambientPlayer == null) {
      return;
    }

    try {
      await ambientPlayer.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
      await ambientPlayer.stop();
      final double volume = getVolumeForEffect(effect);
      await ambientPlayer.setVolume(volume);
      for (final String assetPath in candidates) {
        try {
          await ambientPlayer.play(AssetSource(assetPath)).timeout(const Duration(seconds: 3));
          _ambientPlaying = true;
          _currentAmbientEffect = effect;
          return;
        } catch (e) {
          debugPrint('AudioManager: failed ambient $assetPath ($e)');
        }
      }
    } catch (e) {
      debugPrint('AudioManager: failed to start ambient ($e)');
    }
  }

  Future<void> stopAmbient() async {
    if (!_audioSupported) {
      _ambientPlaying = false;
      _currentAmbientEffect = null;
      return;
    }
    if (!_ambientPlaying) {
      return;
    }
    final AudioPlayer? ambientPlayer = _ambientPlayer;
    if (ambientPlayer == null) {
      _ambientPlaying = false;
      _currentAmbientEffect = null;
      return;
    }
    try {
      await ambientPlayer.stop();
    } catch (e) {
      debugPrint('AudioManager: failed to stop ambient ($e)');
    } finally {
      _ambientPlaying = false;
      _currentAmbientEffect = null;
    }
  }

  Future<void> fadeOutAmbient({Duration duration = const Duration(milliseconds: 650)}) async {
    if (!_ambientPlaying || duration.inMilliseconds <= 0) {
      await stopAmbient();
      return;
    }

    const int steps = 10;
    final int waitMs = (duration.inMilliseconds / steps).round().clamp(1, 10000);
    final double initial = getVolumeForEffect(_currentAmbientEffect ?? SoundEffect.ambientControlRoom);

    for (int i = steps; i >= 0; i--) {
      final double v = initial * (i / steps);
      try {
        await _ambientPlayer?.setVolume(v.clamp(0.0, 1.0));
      } catch (_) {}
      await Future<void>.delayed(Duration(milliseconds: waitMs));
    }

    await stopAmbient();
  }

  Future<void> setAmbientVolume(double volume) async {
    if (!_audioSupported) {
      return;
    }
    _settings.setAmbientVolume(volume);
    if (_ambientPlaying && _currentAmbientEffect != null) {
      try {
        await _ambientPlayer?.setVolume(getVolumeForEffect(_currentAmbientEffect!));
      } catch (e) {
        debugPrint('AudioManager: failed to set ambient volume ($e)');
      }
    }
  }

  Future<void> playAgencySelection(Agency agency) async {
    final String id = agency.id.toLowerCase();
    if (id.contains('nasa') || id.contains('usa') || id.contains('eua')) {
      await playVoice(SoundEffect.missionControlComputers);
      return;
    }
    if (id.contains('ussr') || id.contains('urss') || id.contains('russia')) {
      await playVoice(SoundEffect.sputnikBeep);
      return;
    }
    if (id.contains('esa') || id.contains('europe')) {
      await playSfx(SoundEffect.milestoneAchieved);
      return;
    }
    if (id.contains('isro') || id.contains('india')) {
      await playSfx(SoundEffect.missionUnlocked);
      return;
    }
    await playUi(SoundEffect.uiConfirm);
  }

  Future<void> playAgencyHover(Agency agency) async {
    if (!_settings.soundEnabled) {
      return;
    }

    final String id = agency.id.toLowerCase();
    final String country = agency.country.toLowerCase();
    try {
      if (id.contains('nasa') || id.contains('usa') || id.contains('eua') || country.contains('usa') || country.contains('eua')) {
        final SoundEffect choice = id.hashCode.isEven
            ? SoundEffect.missionControlComputers
            : SoundEffect.launchConfirm;
        if (choice == SoundEffect.missionControlComputers) {
          await playVoice(choice);
        } else {
          await playSfx(choice);
        }
        return;
      }

      if (id.contains('ussr') || id.contains('urss') || id.contains('russia') || country.contains('russia') || country.contains('urss')) {
        final SoundEffect choice = id.hashCode.isEven
            ? SoundEffect.sputnikBeep
            : SoundEffect.quindarStart;
        await playVoice(choice);
        return;
      }

      if (id.contains('esa') || id.contains('europe') || country.contains('europa')) {
        final SoundEffect choice = id.hashCode.isEven
            ? SoundEffect.milestoneAchieved
            : SoundEffect.uiConfirm;
        await playSfx(choice);
        return;
      }

      if (id.contains('isro') || id.contains('india') || country.contains('india')) {
        final SoundEffect choice = id.hashCode.isEven
            ? SoundEffect.missionUnlocked
            : SoundEffect.uiConfirm;
        await playSfx(choice);
        return;
      }

      await playUi(SoundEffect.uiConfirm);
    } catch (e) {
      debugPrint('AudioManager: failed hover agency audio for ${agency.id} ($e)');
    }
  }

  Future<void> stopAgencyHover() async {
    if (!_audioSupported) {
      return;
    }
    try {
      await Future.wait([
        _sfxPlayer!.stop(),
        _voicePlayer!.stop(),
        _uiPlayer!.stop(),
      ]);
    } catch (e) {
      debugPrint('AudioManager: failed to stop agency hover audio ($e)');
    }
  }

  Future<void> playCareerPromotion() async {
    await playSfx(SoundEffect.careerPromotion);
  }

  Future<void> playMilestoneAchieved() async {
    await playSfx(SoundEffect.milestoneAchieved);
  }

  Future<void> playNoGoAlert() async {
    await playSfx(SoundEffect.noGoAlert);
  }

  Future<void> playSuccessByResult(String resultType) async {
    final String key = resultType.toLowerCase();
    if (key.contains('catastrophic') || key.contains('critica')) {
      await playSfx(SoundEffect.catastrophicFailure);
      return;
    }
    if (key.contains('partial') || key.contains('parcial') || key.contains('aborted')) {
      await playSfx(SoundEffect.successPartial);
      return;
    }
    if (key.contains('success') || key.contains('sucesso')) {
      await playSfx(SoundEffect.successComplete);
      return;
    }
    await playSfx(SoundEffect.missionFailed);
  }

  bool get ambientPlaying => _ambientPlaying;
  bool get musicPlaying => _musicPlaying;
  SoundEffect? get currentAmbientEffect => _currentAmbientEffect;
  SoundEffect? get currentMusicEffect => _currentMusicEffect;

  void updateSettings(AudioSettings settings) {
    _settings = settings;
    if (!_audioSupported) {
      return;
    }
    if (_musicPlaying && _currentMusicEffect != null) {
      _musicPlayer?.setVolume(getVolumeForEffect(_currentMusicEffect!));
    }
    if (_ambientPlaying && _currentAmbientEffect != null) {
      _ambientPlayer?.setVolume(getVolumeForEffect(_currentAmbientEffect!));
    }
  }

  AudioSettings get settings => _settings;
}
